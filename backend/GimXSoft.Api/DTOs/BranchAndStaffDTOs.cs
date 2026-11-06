using System.ComponentModel.DataAnnotations;
using GimXSoft.Api.Entities;

namespace GimXSoft.Api.DTOs;

public record BranchDto(
    Guid Id,
    Guid TenantId,
    string Name,
    string Code,
    string Address,
    string City,
    string Phone,
    string Email,
    bool IsActive,
    DateTime CreatedAt
);

public record CreateBranchRequest(
    [Required] string Name,
    [Required] string Code,
    string? Address,
    string? City,
    string? Phone,
    string? Email
);

public record StaffDto(
    Guid Id,
    Guid TenantId,
    Guid? BranchId,
    string? BranchName,
    string FullName,
    string Email,
    string Role,
    string Phone,
    string? AvatarUrl,
    bool IsActive,
    DateTime CreatedAt
);

public record CreateStaffRequest(
    [Required] string FullName,
    [Required, EmailAddress] string Email,
    [Required, MinLength(6)] string Password,
    [Required] UserRole Role,
    Guid? BranchId,
    string? Phone
);

public record UpdateStaffRequest(
    [Required] string FullName,
    [Required, EmailAddress] string Email,
    [Required] UserRole Role,
    Guid? BranchId,
    string? Phone,
    bool IsActive
);

public record UpdateBranchRequest(
    [Required] string Name,
    string? Address,
    string? City,
    string? Phone,
    string? Email,
    bool IsActive
);

public record ResetStaffPasswordRequest(
    [Required, MinLength(6)] string NewPassword
);

