class AttendanceRecordModel {
  final String id;
  final String tenantId;
  final String branchId;
  final String? branchName;
  final String memberId;
  final String memberName;
  final String memberCode;
  final String? planName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String method;
  final String? notes;

  const AttendanceRecordModel({
    required this.id,
    required this.tenantId,
    required this.branchId,
    this.branchName,
    required this.memberId,
    required this.memberName,
    required this.memberCode,
    this.planName,
    required this.checkInTime,
    this.checkOutTime,
    required this.method,
    this.notes,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      branchName: json['branchName'],
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName'] ?? 'Member',
      memberCode: json['memberCode'] ?? '',
      planName: json['planName'],
      checkInTime: DateTime.tryParse(json['checkInTime'] ?? '') ?? DateTime.now(),
      checkOutTime: DateTime.tryParse(json['checkOutTime'] ?? ''),
      method: json['method'] ?? 'Manual',
      notes: json['notes'],
    );
  }
}

class DailyAttendanceSummaryModel {
  final int totalCheckInsToday;
  final int currentlyInGym;
  final int morningPeakCount;
  final int eveningPeakCount;
  final List<AttendanceRecordModel> recentCheckIns;

  const DailyAttendanceSummaryModel({
    required this.totalCheckInsToday,
    required this.currentlyInGym,
    required this.morningPeakCount,
    required this.eveningPeakCount,
    required this.recentCheckIns,
  });

  factory DailyAttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceSummaryModel(
      totalCheckInsToday: json['totalCheckInsToday'] ?? 0,
      currentlyInGym: json['currentlyInGym'] ?? 0,
      morningPeakCount: json['morningPeakCount'] ?? 0,
      eveningPeakCount: json['eveningPeakCount'] ?? 0,
      recentCheckIns: (json['recentCheckIns'] as List? ?? [])
          .map((e) => AttendanceRecordModel.fromJson(e))
          .toList(),
    );
  }
}

