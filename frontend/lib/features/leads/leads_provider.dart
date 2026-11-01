import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../auth/auth_provider.dart';
import 'lead_models.dart';

final leadsListProvider = FutureProvider.autoDispose<List<LeadModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authProvider);

  final queryParams = <String, dynamic>{};
  if (authState.selectedBranch?.id != null) {
    queryParams['branchId'] = authState.selectedBranch!.id;
  }

  final response = await apiClient.dio.get(
    ApiConstants.leads,
    queryParameters: queryParams,
  );

  return (response.data as List)
      .map((item) => LeadModel.fromJson(item))
      .toList();
});

class LeadsActionNotifier {
  final ApiClient _apiClient;
  final Ref _ref;

  LeadsActionNotifier(this._apiClient, this._ref);

  Future<bool> updateStage(String leadId, String newStage, {String? note}) async {
    try {
      await _apiClient.dio.patch(
        '${ApiConstants.leads}/$leadId/stage',
        data: {'stage': newStage, 'note': note},
      );
      _ref.invalidate(leadsListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createLead({
    required String fullName,
    String? email,
    required String phone,
    required String source,
    String? notes,
    DateTime? followUpDate,
    double estimatedValue = 0,
  }) async {
    try {
      final authState = _ref.read(authProvider);
      final branchId = authState.selectedBranch?.id ??
          (authState.branches.isNotEmpty ? authState.branches.first.id : '');

      await _apiClient.dio.post(
        ApiConstants.leads,
        data: {
          'branchId': branchId,
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'source': source,
          'notes': notes,
          'nextFollowUpDate': followUpDate?.toIso8601String(),
          'estimatedValue': estimatedValue,
        },
      );
      _ref.invalidate(leadsListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final leadsActionProvider = Provider<LeadsActionNotifier>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LeadsActionNotifier(apiClient, ref);
});
