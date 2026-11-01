class MembershipPlanModel {
  final String id;
  final String tenantId;
  final String name;
  final String description;
  final int durationDays;
  final double price;
  final double registrationFee;
  final String benefitsJson;
  final bool isPersonalTraining;
  final int includedSessions;
  final bool isActive;
  final int activeSubscribersCount;

  const MembershipPlanModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.price,
    required this.registrationFee,
    required this.benefitsJson,
    required this.isPersonalTraining,
    required this.includedSessions,
    required this.isActive,
    required this.activeSubscribersCount,
  });

  factory MembershipPlanModel.fromJson(Map<String, dynamic> json) {
    return MembershipPlanModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      durationDays: json['durationDays'] ?? 30,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      registrationFee: (json['registrationFee'] as num?)?.toDouble() ?? 0.0,
      benefitsJson: json['benefitsJson'] ?? '[]',
      isPersonalTraining: json['isPersonalTraining'] ?? false,
      includedSessions: json['includedSessions'] ?? 0,
      isActive: json['isActive'] ?? true,
      activeSubscribersCount: json['activeSubscribersCount'] ?? 0,
    );
  }
}

class MemberSubscriptionModel {
  final String id;
  final String tenantId;
  final String memberId;
  final String? memberName;
  final String membershipPlanId;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final double pricePaid;
  final double discountAmount;
  final String status;
  final DateTime? freezeStartDate;
  final DateTime? freezeEndDate;
  final String? notes;

  const MemberSubscriptionModel({
    required this.id,
    required this.tenantId,
    required this.memberId,
    this.memberName,
    required this.membershipPlanId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.pricePaid,
    required this.discountAmount,
    required this.status,
    this.freezeStartDate,
    this.freezeEndDate,
    this.notes,
  });

  factory MemberSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MemberSubscriptionModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName'],
      membershipPlanId: json['membershipPlanId']?.toString() ?? '',
      planName: json['planName'] ?? 'Plan',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      pricePaid: (json['pricePaid'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Active',
      freezeStartDate: DateTime.tryParse(json['freezeStartDate'] ?? ''),
      freezeEndDate: DateTime.tryParse(json['freezeEndDate'] ?? ''),
      notes: json['notes'],
    );
  }
}

