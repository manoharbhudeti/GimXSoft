class DashboardMetricsModel {
  final int totalMembers;
  final int activeMembers;
  final int newMembersThisMonth;
  final int expiredMembers;
  final double monthlyRevenue;
  final double revenueGrowthPercentage;
  final double pendingPayments;
  final int todaysAttendance;
  final double membershipRenewalRate;
  final int newLeadsThisMonth;
  final double leadConversionRate;
  final List<MonthlyRevenueItem> monthlyRevenueChart;
  final List<MemberAcquisitionItem> memberAcquisitionChart;
  final List<AttendanceTrendItem> attendanceTrendsChart;
  final List<PlanDistributionItem> membershipDistributionChart;
  final List<PlanRevenueItem> revenueByPlanChart;
  final List<UpcomingExpirationItem> upcomingExpirations;
  final List<PendingFollowUpItem> pendingFollowUps;
  final List<RecentPaymentItem> recentPayments;
  final List<RecentActivityItem> recentActivities;

  const DashboardMetricsModel({
    required this.totalMembers,
    required this.activeMembers,
    required this.newMembersThisMonth,
    required this.expiredMembers,
    required this.monthlyRevenue,
    required this.revenueGrowthPercentage,
    required this.pendingPayments,
    required this.todaysAttendance,
    required this.membershipRenewalRate,
    required this.newLeadsThisMonth,
    required this.leadConversionRate,
    required this.monthlyRevenueChart,
    required this.memberAcquisitionChart,
    required this.attendanceTrendsChart,
    required this.membershipDistributionChart,
    required this.revenueByPlanChart,
    required this.upcomingExpirations,
    required this.pendingFollowUps,
    required this.recentPayments,
    required this.recentActivities,
  });

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    return DashboardMetricsModel(
      totalMembers: json['totalMembers'] ?? 0,
      activeMembers: json['activeMembers'] ?? 0,
      newMembersThisMonth: json['newMembersThisMonth'] ?? 0,
      expiredMembers: json['expiredMembers'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] as num?)?.toDouble() ?? 0.0,
      revenueGrowthPercentage: (json['revenueGrowthPercentage'] as num?)?.toDouble() ?? 0.0,
      pendingPayments: (json['pendingPayments'] as num?)?.toDouble() ?? 0.0,
      todaysAttendance: json['todaysAttendance'] ?? 0,
      membershipRenewalRate: (json['membershipRenewalRate'] as num?)?.toDouble() ?? 0.0,
      newLeadsThisMonth: json['newLeadsThisMonth'] ?? 0,
      leadConversionRate: (json['leadConversionRate'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenueChart: (json['monthlyRevenueChart'] as List? ?? [])
          .map((e) => MonthlyRevenueItem.fromJson(e))
          .toList(),
      memberAcquisitionChart: (json['memberAcquisitionChart'] as List? ?? [])
          .map((e) => MemberAcquisitionItem.fromJson(e))
          .toList(),
      attendanceTrendsChart: (json['attendanceTrendsChart'] as List? ?? [])
          .map((e) => AttendanceTrendItem.fromJson(e))
          .toList(),
      membershipDistributionChart: (json['membershipDistributionChart'] as List? ?? [])
          .map((e) => PlanDistributionItem.fromJson(e))
          .toList(),
      revenueByPlanChart: (json['revenueByPlanChart'] as List? ?? [])
          .map((e) => PlanRevenueItem.fromJson(e))
          .toList(),
      upcomingExpirations: (json['upcomingExpirations'] as List? ?? [])
          .map((e) => UpcomingExpirationItem.fromJson(e))
          .toList(),
      pendingFollowUps: (json['pendingFollowUps'] as List? ?? [])
          .map((e) => PendingFollowUpItem.fromJson(e))
          .toList(),
      recentPayments: (json['recentPayments'] as List? ?? [])
          .map((e) => RecentPaymentItem.fromJson(e))
          .toList(),
      recentActivities: (json['recentActivities'] as List? ?? [])
          .map((e) => RecentActivityItem.fromJson(e))
          .toList(),
    );
  }
}

class MonthlyRevenueItem {
  final String month;
  final double revenue;
  final int count;

  MonthlyRevenueItem({required this.month, required this.revenue, required this.count});

  factory MonthlyRevenueItem.fromJson(Map<String, dynamic> json) => MonthlyRevenueItem(
    month: json['month'] ?? '',
    revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    count: json['transactionsCount'] ?? 0,
  );
}

class MemberAcquisitionItem {
  final String month;
  final int newMembers;
  final int renewals;

  MemberAcquisitionItem({required this.month, required this.newMembers, required this.renewals});

  factory MemberAcquisitionItem.fromJson(Map<String, dynamic> json) => MemberAcquisitionItem(
    month: json['month'] ?? '',
    newMembers: json['newMembers'] ?? 0,
    renewals: json['renewals'] ?? 0,
  );
}

class AttendanceTrendItem {
  final String dayOfWeek;
  final int checkIns;

  AttendanceTrendItem({required this.dayOfWeek, required this.checkIns});

  factory AttendanceTrendItem.fromJson(Map<String, dynamic> json) => AttendanceTrendItem(
    dayOfWeek: json['dayOfWeek'] ?? '',
    checkIns: json['checkInsCount'] ?? 0,
  );
}

class PlanDistributionItem {
  final String planName;
  final int memberCount;
  final double percentage;

  PlanDistributionItem({required this.planName, required this.memberCount, required this.percentage});

  factory PlanDistributionItem.fromJson(Map<String, dynamic> json) => PlanDistributionItem(
    planName: json['planName'] ?? '',
    memberCount: json['memberCount'] ?? 0,
    percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
  );
}

class PlanRevenueItem {
  final String planName;
  final double revenue;

  PlanRevenueItem({required this.planName, required this.revenue});

  factory PlanRevenueItem.fromJson(Map<String, dynamic> json) => PlanRevenueItem(
    planName: json['planName'] ?? '',
    revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
  );
}

class UpcomingExpirationItem {
  final String memberId;
  final String memberName;
  final String planName;
  final DateTime expiryDate;
  final int daysRemaining;
  final String phone;

  UpcomingExpirationItem({
    required this.memberId,
    required this.memberName,
    required this.planName,
    required this.expiryDate,
    required this.daysRemaining,
    required this.phone,
  });

  factory UpcomingExpirationItem.fromJson(Map<String, dynamic> json) => UpcomingExpirationItem(
    memberId: json['memberId']?.toString() ?? '',
    memberName: json['memberName'] ?? '',
    planName: json['planName'] ?? '',
    expiryDate: DateTime.tryParse(json['expiryDate'] ?? '') ?? DateTime.now(),
    daysRemaining: json['daysRemaining'] ?? 0,
    phone: json['phone'] ?? '',
  );
}

class PendingFollowUpItem {
  final String leadId;
  final String leadName;
  final String phone;
  final String stage;
  final DateTime followUpDate;
  final String? notes;

  PendingFollowUpItem({
    required this.leadId,
    required this.leadName,
    required this.phone,
    required this.stage,
    required this.followUpDate,
    this.notes,
  });

  factory PendingFollowUpItem.fromJson(Map<String, dynamic> json) => PendingFollowUpItem(
    leadId: json['leadId']?.toString() ?? '',
    leadName: json['leadName'] ?? '',
    phone: json['phone'] ?? '',
    stage: json['stage'] ?? '',
    followUpDate: DateTime.tryParse(json['followUpDate'] ?? '') ?? DateTime.now(),
    notes: json['notes'],
  );
}

class RecentPaymentItem {
  final String id;
  final String memberName;
  final String invoiceNumber;
  final double amount;
  final String paymentMethod;
  final DateTime date;

  RecentPaymentItem({
    required this.id,
    required this.memberName,
    required this.invoiceNumber,
    required this.amount,
    required this.paymentMethod,
    required this.date,
  });

  factory RecentPaymentItem.fromJson(Map<String, dynamic> json) => RecentPaymentItem(
    id: json['id']?.toString() ?? '',
    memberName: json['memberName'] ?? '',
    invoiceNumber: json['invoiceNumber'] ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    paymentMethod: json['paymentMethod'] ?? '',
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
  );
}

class RecentActivityItem {
  final String title;
  final String description;
  final String category;
  final DateTime timestamp;

  RecentActivityItem({
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
  });

  factory RecentActivityItem.fromJson(Map<String, dynamic> json) => RecentActivityItem(
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
  );
}

