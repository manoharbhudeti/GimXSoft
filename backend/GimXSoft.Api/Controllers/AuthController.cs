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

