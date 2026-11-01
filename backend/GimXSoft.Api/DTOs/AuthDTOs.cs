using System.ComponentModel.DataAnnotations;
using GimXSoft.Api.Entities;

namespace GimXSoft.Api.DTOs;

public record LoginRequest(
    [Required, EmailAddress] string Email,
    [Required] string Password
);

public record LoginResponse(
    string AccessToken,
    string RefreshToken,
    DateTime ExpiresAt,
    UserDto User,
    TenantSummaryDto Tenant,
    List<BranchDto> Branches
);

public record RefreshTokenRequest(
    [Required] string AccessToken,
    [Required] string RefreshToken
);

public record RegisterTenantRequest(
    [Required] string GymName,
    [Required] string Slug,
    [Required] string AdminFullName,
    [Required, EmailAddress] string AdminEmail,
    [Required, MinLength(6)] string AdminPassword,
    [Required] string BranchName,
    string? BranchAddress,
    string? BranchCity,
    string? Phone
);

public record ChangePasswordRequest(
    [Required] string CurrentPassword,
    [Required, MinLength(6)] string NewPassword
);

public record UserDto(
    Guid Id,
    Guid TenantId,
    Guid? BranchId,
    string FullName,
    string Email,
    string Role,
    string? Phone,
    string? AvatarUrl,
    bool IsActive
);

public record TenantSummaryDto(
    Guid Id,
    string Name,
    string Slug,
    string? LogoUrl,
    string SubscriptionPlan,
    string SubscriptionStatus,
    int MaxBranches,
    int MaxMembers
);

