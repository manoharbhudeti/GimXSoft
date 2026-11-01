import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../auth/auth_provider.dart';
import 'attendance_models.dart';

final attendanceTodaySummaryProvider = FutureProvider.autoDispose<DailyAttendanceSummaryModel>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authProvider);

  final queryParams = <String, dynamic>{};
  if (authState.selectedBranch?.id != null) {
    queryParams['branchId'] = authState.selectedBranch!.id;
  }

  final response = await apiClient.dio.get(
    ApiConstants.attendanceToday,
    queryParameters: queryParams,
  );

  return DailyAttendanceSummaryModel.fromJson(response.data);
});

class AttendanceActionNotifier {
  final ApiClient _apiClient;
  final Ref _ref;

  AttendanceActionNotifier(this._apiClient, this._ref);

  Future<({bool success, String message, AttendanceRecordModel? record})> checkIn(String memberCodeOrId) async {
    try {
      final authState = _ref.read(authProvider);
      final branchId = authState.selectedBranch?.id ??
          (authState.branches.isNotEmpty ? authState.branches.first.id : '');

      final res = await _apiClient.dio.post(
        ApiConstants.attendanceCheckIn,
        data: {
          'branchId': branchId,
          'memberCodeOrId': memberCodeOrId.trim(),
          'method': 0, // Manual
        },
      );

      _ref.invalidate(attendanceTodaySummaryProvider);
      final rec = AttendanceRecordModel.fromJson(res.data);
      return (success: true, message: 'Welcome, ${rec.memberName}! Access Granted.', record: rec);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Check-in failed.';
      return (success: false, message: msg.toString(), record: null);
    } catch (e) {
      return (success: false, message: 'Network error occurred.', record: null);
    }
  }

  Future<bool> checkOut(String attendanceId) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.attendanceCheckOut,
        data: {'attendanceId': attendanceId},
      );
      _ref.invalidate(attendanceTodaySummaryProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final attendanceActionProvider = Provider<AttendanceActionNotifier>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AttendanceActionNotifier(apiClient, ref);
});
