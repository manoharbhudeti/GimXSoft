using System.ComponentModel.DataAnnotations;
using GimXSoft.Api.Entities;

namespace GimXSoft.Api.DTOs;

public record MembershipPlanDto(
    Guid Id,
    Guid TenantId,
    string Name,
    string Description,
    int DurationDays,
    decimal Price,
    decimal RegistrationFee,
    string BenefitsJson,
    bool IsPersonalTraining,
    int IncludedSessions,
    bool IsActive,
    int ActiveSubscribersCount,
    DateTime CreatedAt
);

public record CreatePlanRequest(
    [Required] string Name,
    string? Description,
    int DurationDays,
    decimal Price,
    decimal RegistrationFee,
    string? BenefitsJson,
    bool IsPersonalTraining,
    int IncludedSessions
);

public record UpdatePlanRequest(
    [Required] string Name,
    string? Description,
    int DurationDays,
    decimal Price,
    decimal RegistrationFee,
    string? BenefitsJson,
    bool IsPersonalTraining,
    int IncludedSessions,
    bool IsActive
);

public record MemberSubscriptionDto(
    Guid Id,
    Guid TenantId,
    Guid MemberId,
    string? MemberName,
    Guid MembershipPlanId,
    string PlanName,
    DateTime StartDate,
    DateTime EndDate,
    decimal PricePaid,
    decimal DiscountAmount,
    string Status,
    DateTime? FreezeStartDate,
    DateTime? FreezeEndDate,
    string? Notes,
    DateTime CreatedAt
);

public record SubscribeMemberRequest(
    Guid MemberId,
    Guid MembershipPlanId,
    DateTime? StartDate,
    decimal? CustomPrice,
    decimal DiscountAmount,
    PaymentMethod PaymentMethod,
    string? Notes
);

public record RenewSubscriptionRequest(
    Guid MembershipPlanId,
    DateTime? StartDate,
    decimal? CustomPrice,
    decimal DiscountAmount,
    PaymentMethod PaymentMethod,
    string? Notes
);

public record FreezeSubscriptionRequest(
    DateTime FreezeStartDate,
    DateTime FreezeEndDate,
    string? Reason
);

