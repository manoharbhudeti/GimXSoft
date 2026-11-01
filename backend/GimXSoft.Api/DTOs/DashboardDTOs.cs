namespace GimXSoft.Api.DTOs;

public record DashboardMetricsDto(
    int TotalMembers,
    int ActiveMembers,
    int NewMembersThisMonth,
    int ExpiredMembers,
    decimal MonthlyRevenue,
    decimal RevenueGrowthPercentage,
    decimal PendingPayments,
    int TodaysAttendance,
    double MembershipRenewalRate,
    int NewLeadsThisMonth,
    double LeadConversionRate,
    int WhatsAppSentToday,
    double WhatsAppDeliveryRate,
    List<MonthlyRevenueItemDto> MonthlyRevenueChart,
    List<MemberAcquisitionItemDto> MemberAcquisitionChart,
    List<AttendanceTrendItemDto> AttendanceTrendsChart,
    List<PlanDistributionItemDto> MembershipDistributionChart,
    List<PlanRevenueItemDto> RevenueByPlanChart,
    List<UpcomingExpirationDto> UpcomingExpirations,
    List<PendingFollowUpDto> PendingFollowUps,
    List<RecentPaymentDto> RecentPayments,
    List<RecentActivityDto> RecentActivities
);

public record MonthlyRevenueItemDto(
    string Month,
    decimal Revenue,
    int TransactionsCount
);

public record MemberAcquisitionItemDto(
    string Month,
    int NewMembers,
    int Renewals
);

public record AttendanceTrendItemDto(
    string DayOfWeek,
    int CheckInsCount
);

public record PlanDistributionItemDto(
    string PlanName,
    int MemberCount,
    double Percentage
);

public record PlanRevenueItemDto(
    string PlanName,
    decimal Revenue
);

public record UpcomingExpirationDto(
    Guid MemberId,
    string MemberName,
    string PlanName,
    DateTime ExpiryDate,
    int DaysRemaining,
    string Phone
);

public record PendingFollowUpDto(
    Guid LeadId,
    string LeadName,
    string Phone,
    string Stage,
    DateTime FollowUpDate,
    string? Notes
);

public record RecentPaymentDto(
    Guid Id,
    string MemberName,
    string InvoiceNumber,
    decimal Amount,
    string PaymentMethod,
    DateTime Date
);

public record RecentActivityDto(
    string Title,
    string Description,
    string Category, // Member, Payment, Attendance, Lead
    DateTime Timestamp
);

