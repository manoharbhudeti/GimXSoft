class MemberModel {
  final String id;
  final String tenantId;
  final String branchId;
  final String? branchName;
  final String memberCode;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String address;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final DateTime joiningDate;
  final String? assignedTrainerId;
  final String? assignedTrainerName;
  final String status;
  final String? medicalNotes;
  final String? avatarUrl;
  final String? currentPlanName;
  final DateTime? planExpiryDate;
  final DateTime createdAt;

  const MemberModel({
    required this.id,
    required this.tenantId,
    required this.branchId,
    this.branchName,
    required this.memberCode,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phone,
    this.gender,
    this.dateOfBirth,
    required this.address,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.joiningDate,
    this.assignedTrainerId,
    this.assignedTrainerName,
    required this.status,
    this.medicalNotes,
    this.avatarUrl,
    this.currentPlanName,
    this.planExpiryDate,
    required this.createdAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      branchName: json['branchName'],
      memberCode: json['memberCode'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'],
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] ?? ''),
      address: json['address'] ?? '',
      emergencyContactName: json['emergencyContactName'] ?? '',
      emergencyContactPhone: json['emergencyContactPhone'] ?? '',
      joiningDate: DateTime.tryParse(json['joiningDate'] ?? '') ?? DateTime.now(),
      assignedTrainerId: json['assignedTrainerId']?.toString(),
      assignedTrainerName: json['assignedTrainerName'],
      status: json['status'] ?? 'Active',
      medicalNotes: json['medicalNotes'],
      avatarUrl: json['avatarUrl'],
      currentPlanName: json['currentPlanName'],
      planExpiryDate: DateTime.tryParse(json['planExpiryDate'] ?? ''),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class MemberDetailModel {
  final MemberModel member;
  final List<dynamic> subscriptions;
  final List<dynamic> recentAttendance;
  final List<dynamic> recentPayments;
  final List<dynamic> workoutPlans;

  const MemberDetailModel({
    required this.member,
    required this.subscriptions,
    required this.recentAttendance,
    required this.recentPayments,
    required this.workoutPlans,
  });

  factory MemberDetailModel.fromJson(Map<String, dynamic> json) {
    return MemberDetailModel(
      member: MemberModel.fromJson(json['member']),
      subscriptions: json['subscriptions'] as List? ?? [],
      recentAttendance: json['recentAttendance'] as List? ?? [],
      recentPayments: json['recentPayments'] as List? ?? [],
      workoutPlans: json['workoutPlans'] as List? ?? [],
    );
  }
}

