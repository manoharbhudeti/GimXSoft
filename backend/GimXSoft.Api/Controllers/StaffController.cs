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
[Authorize]
public class StaffController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public StaffController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet]
    public async Task<ActionResult<List<StaffDto>>> GetStaff([FromQuery] Guid? branchId, [FromQuery] UserRole? role)
    {
        var query = _context.Users
            .Include(u => u.Branch)
            .AsQueryable();

        if (branchId.HasValue)
        {
            query = query.Where(u => u.BranchId == branchId.Value || u.BranchId == null);
        }

        if (role.HasValue)
        {
            query = query.Where(u => u.Role == role.Value);
        }

        var staff = await query
            .OrderBy(u => u.FullName)
            .Select(u => new StaffDto(
                u.Id,
                u.TenantId,
                u.BranchId,
                u.Branch != null ? u.Branch.Name : "All Branches",
                u.FullName,
                u.Email,
                u.Role.ToString(),
                u.Phone,
                u.AvatarUrl,
                u.IsActive,
                u.CreatedAt
            ))
            .ToListAsync();

        return Ok(staff);
    }

    [HttpPost]
    public async Task<ActionResult<StaffDto>> CreateStaff([FromBody] CreateStaffRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();

        var existing = await _context.Users.AnyAsync(u => u.Email.ToLower() == request.Email.ToLower());
        if (existing)
        {
            return BadRequest(new { message = "A staff member with this email already exists." });
        }

        var staff = new User
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            FullName = request.FullName.Trim(),
            Email = request.Email.ToLower().Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Role = request.Role,
            Phone = request.Phone ?? "",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(staff);
        await _context.SaveChangesAsync();

        var branch = request.BranchId.HasValue ? await _context.Branches.FindAsync(request.BranchId.Value) : null;

        return Ok(new StaffDto(
            staff.Id,
            staff.TenantId,
            staff.BranchId,
            branch?.Name ?? "All Branches",
            staff.FullName,
            staff.Email,
            staff.Role.ToString(),
            staff.Phone,
            staff.AvatarUrl,
            staff.IsActive,
            staff.CreatedAt
        ));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> UpdateStaff(Guid id, [FromBody] UpdateStaffRequest request)
    {
        var staff = await _context.Users.FindAsync(id);
        if (staff == null) return NotFound(new { message = "Staff member not found." });

        staff.FullName = request.FullName.Trim();
        staff.Email = request.Email.ToLower().Trim();
        staff.Role = request.Role;
        staff.BranchId = request.BranchId;
        staff.Phone = request.Phone ?? "";
        staff.IsActive = request.IsActive;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<StaffDto>> GetStaffById(Guid id)
    {
        var staff = await _context.Users
            .Include(u => u.Branch)
            .FirstOrDefaultAsync(u => u.Id == id);

        if (staff == null) return NotFound(new { message = "Staff member not found." });

        return Ok(new StaffDto(
            staff.Id,
            staff.TenantId,
            staff.BranchId,
            staff.Branch?.Name ?? "All Branches",
            staff.FullName,
            staff.Email,
            staff.Role.ToString(),
            staff.Phone,
            staff.AvatarUrl,
            staff.IsActive,
            staff.CreatedAt
        ));
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteStaff(Guid id)
    {
        var staff = await _context.Users.FindAsync(id);
        if (staff == null) return NotFound(new { message = "Staff member not found." });

        staff.IsActive = false;
        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = "Staff account deactivated successfully." });
    }

    [HttpPost("{id}/reset-password")]
    public async Task<ActionResult> ResetPassword(Guid id, [FromBody] ResetStaffPasswordRequest request)
    {
        var staff = await _context.Users.FindAsync(id);
        if (staff == null) return NotFound(new { message = "Staff member not found." });

        staff.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = "Password updated successfully." });
    }
}

