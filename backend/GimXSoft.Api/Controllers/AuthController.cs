using System.Security.Claims;
using GimXSoft.Api.Data;
using GimXSoft.Api.DTOs;
using GimXSoft.Api.Entities;
using GimXSoft.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GimXSoft.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ITokenService _tokenService;
    private readonly ICurrentTenantService _tenantService;

    public AuthController(ApplicationDbContext context, ITokenService tokenService, ICurrentTenantService tenantService)
    {
        _context = context;
        _tokenService = tokenService;
        _tenantService = tenantService;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        var user = await _context.Users
            .IgnoreQueryFilters()
            .Include(u => u.Tenant)
            .Include(u => u.Branch)
            .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower());

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new { message = "Invalid email or password." });
        }

        if (!user.IsActive)
        {
            return Unauthorized(new { message = "This account has been deactivated. Please contact support." });
        }

        var tenant = user.Tenant;
        if (tenant == null || !tenant.IsActive)
        {
            return Unauthorized(new { message = "The gym organization is inactive or suspended." });
        }

        var accessToken = _tokenService.GenerateAccessToken(user);
        var refreshToken = _tokenService.GenerateRefreshToken();

        user.RefreshToken = refreshToken;
        user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
        await _context.SaveChangesAsync();

        var branches = await _context.Branches
            .IgnoreQueryFilters()
            .Where(b => b.TenantId == user.TenantId && b.IsActive)
            .Select(b => new BranchDto(
                b.Id,
                b.TenantId,
                b.Name,
                b.Code,
                b.Address,
                b.City,
                b.Phone,
                b.Email,
                b.IsActive,
                b.CreatedAt
            ))
            .ToListAsync();

        var userDto = new UserDto(
            user.Id,
            user.TenantId,
            user.BranchId,
            user.FullName,
            user.Email,
            user.Role.ToString(),
            user.Phone,
            user.AvatarUrl,
            user.IsActive
        );

        var tenantDto = new TenantSummaryDto(
            tenant.Id,
            tenant.Name,
            tenant.Slug,
            tenant.LogoUrl,
            tenant.SubscriptionPlan,
            tenant.SubscriptionStatus,
            tenant.MaxBranches,
            tenant.MaxMembers
        );

        return Ok(new LoginResponse(accessToken, refreshToken, DateTime.UtcNow.AddMinutes(120), userDto, tenantDto, branches));
    }

    [HttpPost("register-tenant")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponse>> RegisterTenant([FromBody] RegisterTenantRequest request)
    {
        var existingSlug = await _context.Tenants
            .IgnoreQueryFilters()
            .AnyAsync(t => t.Slug.ToLower() == request.Slug.ToLower());

        if (existingSlug)
        {
            return BadRequest(new { message = "Gym slug / URL identifier is already in use. Please select another." });
        }

        var tenant = new Tenant
        {
            Id = Guid.NewGuid(),
            Name = request.GymName,
            Slug = request.Slug.ToLower(),
            SubscriptionPlan = "Growth",
            SubscriptionStatus = "Active",
            MaxBranches = 3,
            MaxMembers = 1000,
            CreatedAt = DateTime.UtcNow
        };
        _context.Tenants.Add(tenant);

        var branch = new Branch
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = request.BranchName,
            Code = "HQ-01",
            Address = request.BranchAddress ?? "",
            City = request.BranchCity ?? "",
            Phone = request.Phone ?? "",
            Email = request.AdminEmail,
            CreatedAt = DateTime.UtcNow
        };
        _context.Branches.Add(branch);

        var adminUser = new User
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branch.Id,
            FullName = request.AdminFullName,
            Email = request.AdminEmail.ToLower(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.AdminPassword),
            Role = UserRole.GymOwner,
            Phone = request.Phone ?? "",
            CreatedAt = DateTime.UtcNow
        };
        _context.Users.Add(adminUser);

        // Add standard default membership plans for this new tenant
        var defaultMonthly = new MembershipPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "Monthly Standard Plan",
            Description = "Full access to gym facilities and locker room",
            DurationDays = 30,
            Price = 69.00m,
            RegistrationFee = 20.00m,
            BenefitsJson = "[\"Unlimited Gym Floor Access\", \"Locker Access\"]"
        };
        var defaultAnnual = new MembershipPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "Annual VIP All-Access",
            Description = "Year-round fitness commitment with VIP perks",
            DurationDays = 365,
            Price = 649.00m,
            RegistrationFee = 0.00m,
            BenefitsJson = "[\"All-Access\", \"Free InBody Scans\", \"2 Free Guest Passes/mo\"]"
        };
        _context.MembershipPlans.AddRange(defaultMonthly, defaultAnnual);

        var accessToken = _tokenService.GenerateAccessToken(adminUser);
        var refreshToken = _tokenService.GenerateRefreshToken();

        adminUser.RefreshToken = refreshToken;
        adminUser.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);

        await _context.SaveChangesAsync();

        var userDto = new UserDto(
            adminUser.Id,
            adminUser.TenantId,
            adminUser.BranchId,
            adminUser.FullName,
            adminUser.Email,
            adminUser.Role.ToString(),
            adminUser.Phone,
            adminUser.AvatarUrl,
            adminUser.IsActive
        );

        var tenantDto = new TenantSummaryDto(
            tenant.Id,
            tenant.Name,
            tenant.Slug,
            tenant.LogoUrl,
            tenant.SubscriptionPlan,
            tenant.SubscriptionStatus,
            tenant.MaxBranches,
            tenant.MaxMembers
        );

        var branches = new List<BranchDto>
        {
            new(branch.Id, branch.TenantId, branch.Name, branch.Code, branch.Address, branch.City, branch.Phone, branch.Email, branch.IsActive, branch.CreatedAt)
        };

        return Ok(new LoginResponse(accessToken, refreshToken, DateTime.UtcNow.AddMinutes(120), userDto, tenantDto, branches));
    }

    [HttpPost("register-trial")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponse>> RegisterTrial([FromBody] RegisterTrialRequest request)
    {
        // 1. Determine clean slug
        var baseSlug = !string.IsNullOrWhiteSpace(request.Slug) 
            ? request.Slug.Trim().ToLower() 
            : System.Text.RegularExpressions.Regex.Replace(request.GymName.ToLower(), @"[^a-z0-9]+", "-").Trim('-');

        if (string.IsNullOrWhiteSpace(baseSlug))
        {
            baseSlug = "gym-" + Guid.NewGuid().ToString()[..6];
        }

        var slug = baseSlug;
        var suffix = 1;
        while (await _context.Tenants.IgnoreQueryFilters().AnyAsync(t => t.Slug.ToLower() == slug.ToLower()))
        {
            slug = $"{baseSlug}-{suffix++}";
        }

        // Check if email already registered
        var existingUser = await _context.Users.IgnoreQueryFilters().AnyAsync(u => u.Email.ToLower() == request.AdminEmail.ToLower());
        if (existingUser)
        {
            return BadRequest(new { message = "An account with this email address already exists. Please sign in instead." });
        }

        var trialEnd = DateTime.UtcNow.AddMonths(1);

        // 2. Create Tenant with 1-Month Free Trial and Zero Payment Needed
        var tenant = new Tenant
        {
            Id = Guid.NewGuid(),
            Name = request.GymName.Trim(),
            Slug = slug,
            SubscriptionPlan = "1-Month Free Trial",
            SubscriptionStatus = "TrialActive",
            MaxBranches = 5,
            MaxMembers = 2500,
            CreatedAt = DateTime.UtcNow
        };
        _context.Tenants.Add(tenant);

        // 3. Create default primary branch
        var branch = new Branch
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = !string.IsNullOrWhiteSpace(request.BranchName) ? request.BranchName.Trim() : $"{request.GymName.Trim()} Main",
            Code = "HQ-01",
            Address = "Main Facility",
            City = request.City ?? "City Hub",
            Phone = request.Phone ?? "",
            Email = request.AdminEmail.Trim().ToLower(),
            CreatedAt = DateTime.UtcNow
        };
        _context.Branches.Add(branch);

        // 4. Create GymOwner Admin User
        var adminUser = new User
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branch.Id,
            FullName = request.AdminFullName.Trim(),
            Email = request.AdminEmail.Trim().ToLower(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.AdminPassword),
            Role = UserRole.GymOwner,
            Phone = request.Phone ?? "",
            CreatedAt = DateTime.UtcNow
        };
        _context.Users.Add(adminUser);

        // 5. Default ₹200 Monthly Plan and ₹2,000 Annual Plan
        var defaultMonthly = new MembershipPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "Monthly All-Access (₹200)",
            Description = "Standard monthly membership with turnstile access & WhatsApp alerts",
            DurationDays = 30,
            Price = 200.00m,
            RegistrationFee = 0.00m,
            BenefitsJson = "[\"Full Gym Floor Access\", \"Turnstile RFID / QR Access\", \"Automated WhatsApp Receipts\"]"
        };
        var defaultAnnual = new MembershipPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "Annual VIP All-Access (₹2,000)",
            Description = "Yearly access with VIP routine splits and biometrics tracking",
            DurationDays = 365,
            Price = 2000.00m,
            RegistrationFee = 0.00m,
            BenefitsJson = "[\"All-Access\", \"Trainer Routine Splits\", \"InBody Scans\", \"Priority WhatsApp Alerts\"]"
        };
        _context.MembershipPlans.AddRange(defaultMonthly, defaultAnnual);

        var accessToken = _tokenService.GenerateAccessToken(adminUser);
        var refreshToken = _tokenService.GenerateRefreshToken();

        adminUser.RefreshToken = refreshToken;
        adminUser.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);

        await _context.SaveChangesAsync();

        var userDto = new UserDto(
            adminUser.Id,
            adminUser.TenantId,
            adminUser.BranchId,
            adminUser.FullName,
            adminUser.Email,
            adminUser.Role.ToString(),
            adminUser.Phone,
            adminUser.AvatarUrl,
            adminUser.IsActive
        );

        var tenantDto = new TenantSummaryDto(
            tenant.Id,
            tenant.Name,
            tenant.Slug,
            tenant.LogoUrl,
            tenant.SubscriptionPlan,
            tenant.SubscriptionStatus,
            tenant.MaxBranches,
            tenant.MaxMembers,
            IsTrial: true,
            TrialEndsAt: trialEnd,
            MonthlyPrice: 200.00m
        );

        var branches = new List<BranchDto>
        {
            new(branch.Id, branch.TenantId, branch.Name, branch.Code, branch.Address, branch.City, branch.Phone, branch.Email, branch.IsActive, branch.CreatedAt)
        };

        return Ok(new LoginResponse(accessToken, refreshToken, DateTime.UtcNow.AddMinutes(120), userDto, tenantDto, branches));
    }

    [HttpGet("trial-status")]
    [Authorize]
    public async Task<ActionResult<TrialStatusResponse>> GetTrialStatus()
    {
        var tenantId = _tenantService.TenantId;
        if (!tenantId.HasValue) return Unauthorized(new { message = "Tenant context required." });

        var tenant = await _context.Tenants.IgnoreQueryFilters().FirstOrDefaultAsync(t => t.Id == tenantId.Value);
        if (tenant == null) return NotFound(new { message = "Tenant not found." });

        var isTrial = tenant.SubscriptionPlan.Contains("Trial", StringComparison.OrdinalIgnoreCase) || 
                      tenant.SubscriptionStatus.Contains("Trial", StringComparison.OrdinalIgnoreCase);

        var trialEnds = tenant.CreatedAt.AddMonths(1);
        var remainingDays = Math.Max(0, (trialEnds - DateTime.UtcNow).Days);

        return Ok(new TrialStatusResponse(
            IsTrial: isTrial,
            SubscriptionPlan: tenant.SubscriptionPlan,
            SubscriptionStatus: tenant.SubscriptionStatus,
            TrialEndsAt: trialEnds,
            DaysRemaining: remainingDays,
            MonthlyPrice: 200.00m,
            NoPaymentNeeded: true,
            CanCancelAnytime: true,
            Message: isTrial 
                ? $"Your 1-month free trial is active with {remainingDays} days remaining. No payment needed for registration. You can cancel anytime."
                : "Active subscription."
        ));
    }

    [HttpPost("cancel-subscription")]
    [Authorize]
    public async Task<ActionResult<CancelSubscriptionResponse>> CancelSubscription()
    {
        var tenantId = _tenantService.TenantId;
        if (!tenantId.HasValue) return Unauthorized(new { message = "Tenant context required." });

        var tenant = await _context.Tenants.IgnoreQueryFilters().FirstOrDefaultAsync(t => t.Id == tenantId.Value);
        if (tenant == null) return NotFound(new { message = "Tenant not found." });

        tenant.SubscriptionStatus = "Cancelled";
        await _context.SaveChangesAsync();

        return Ok(new CancelSubscriptionResponse(
            Success: true,
            Status: "Cancelled",
            Message: "Your subscription/trial has been cancelled. No payments will be charged. You can continue using the platform until the end of your current 1-month period."
        ));
    }

    [HttpPost("refresh-token")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponse>> RefreshToken([FromBody] RefreshTokenRequest request)
    {
        var principal = _tokenService.GetPrincipalFromExpiredToken(request.AccessToken);
        if (principal == null)
        {
            return BadRequest(new { message = "Invalid access token." });
        }

        var userIdString = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out var userId))
        {
            return BadRequest(new { message = "Invalid token payload." });
        }

        var user = await _context.Users
            .IgnoreQueryFilters()
            .Include(u => u.Tenant)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null || user.RefreshToken != request.RefreshToken || user.RefreshTokenExpiryTime <= DateTime.UtcNow)
        {
            return BadRequest(new { message = "Invalid or expired refresh token." });
        }

        var newAccessToken = _tokenService.GenerateAccessToken(user);
        var newRefreshToken = _tokenService.GenerateRefreshToken();

        user.RefreshToken = newRefreshToken;
        user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
        await _context.SaveChangesAsync();

        var branches = await _context.Branches
            .IgnoreQueryFilters()
            .Where(b => b.TenantId == user.TenantId && b.IsActive)
            .Select(b => new BranchDto(
                b.Id,
                b.TenantId,
                b.Name,
                b.Code,
                b.Address,
                b.City,
                b.Phone,
                b.Email,
                b.IsActive,
                b.CreatedAt
            ))
            .ToListAsync();

        var userDto = new UserDto(user.Id, user.TenantId, user.BranchId, user.FullName, user.Email, user.Role.ToString(), user.Phone, user.AvatarUrl, user.IsActive);
        var tenantDto = new TenantSummaryDto(user.Tenant!.Id, user.Tenant.Name, user.Tenant.Slug, user.Tenant.LogoUrl, user.Tenant.SubscriptionPlan, user.Tenant.SubscriptionStatus, user.Tenant.MaxBranches, user.Tenant.MaxMembers);

        return Ok(new LoginResponse(newAccessToken, newRefreshToken, DateTime.UtcNow.AddMinutes(120), userDto, tenantDto, branches));
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<UserDto>> GetCurrentUser()
    {
        var userId = _tenantService.UserId;
        if (!userId.HasValue) return Unauthorized();

        var user = await _context.Users.FindAsync(userId.Value);
        if (user == null) return NotFound();

        return Ok(new UserDto(
            user.Id,
            user.TenantId,
            user.BranchId,
            user.FullName,
            user.Email,
            user.Role.ToString(),
            user.Phone,
            user.AvatarUrl,
            user.IsActive
        ));
    }

    [HttpPost("change-password")]
    [Authorize]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var userId = _tenantService.UserId;
        if (!userId.HasValue) return Unauthorized();

        var user = await _context.Users.FindAsync(userId.Value);
        if (user == null) return NotFound();

        if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, user.PasswordHash))
        {
            return BadRequest(new { message = "Incorrect current password." });
        }

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = "Password updated successfully." });
    }
}

