class LeadModel {
  final String id;
  final String tenantId;
  final String branchId;
  final String? branchName;
  final String fullName;
  final String? email;
  final String phone;
  final String source;
  final String stage;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final String? notes;
  final DateTime? nextFollowUpDate;
  final double estimatedValue;
  final DateTime createdAt;

  const LeadModel({
    required this.id,
    required this.tenantId,
    required this.branchId,
    this.branchName,
    required this.fullName,
    this.email,
    required this.phone,
    required this.source,
    required this.stage,
    this.assignedStaffId,
    this.assignedStaffName,
    this.notes,
    this.nextFollowUpDate,
    required this.estimatedValue,
    required this.createdAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      branchName: json['branchName'],
      fullName: json['fullName'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      source: json['source'] ?? 'WalkIn',
      stage: json['stage'] ?? 'New',
      assignedStaffId: json['assignedStaffId']?.toString(),
      assignedStaffName: json['assignedStaffName'],
      notes: json['notes'],
      nextFollowUpDate: DateTime.tryParse(json['nextFollowUpDate'] ?? ''),
      estimatedValue: (json['estimatedValue'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

