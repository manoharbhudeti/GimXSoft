using System.ComponentModel.DataAnnotations;

namespace GimXSoft.Api.DTOs;

public record RoiCalculationRequest(
    [Range(10, 50000)] int MemberCount,
    [Range(100, 500000)] decimal AverageMonthlyFee,
    decimal? CurrentChurnRatePercent
);

public record RoiCalculationResultDto(
    int TotalMembers,
    decimal AverageMonthlyFee,
    decimal AnnualRevenueCurrent,
    double ChurnRecoveryPercent,
    double RenewalRecoveryPercent,
    int EquivalentRetainedMembersYearly,
    decimal AnnualRevenueRecovered,
    decimal MonthlyRevenueRecovered,
    decimal PlatformCostAnnual,
    decimal NetRoiMultiple,
    string Summary
);

public record HourlyFacilityTrafficDto(
    int Hour,
    string HourLabel,
    int AverageOccupancy,
    double CapacityPercent,
    bool IsPeakHour
);

public record MembershipDistributionDto(
    Guid PlanId,
    string PlanName,
    int ActiveMembersCount,
    decimal MonthlyDuesTotal,
    double SharePercentage
);

