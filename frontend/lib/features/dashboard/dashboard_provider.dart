import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../auth/auth_provider.dart';
import 'dashboard_models.dart';

final dashboardMetricsProvider = FutureProvider.autoDispose<DashboardMetricsModel>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authProvider);

  final branchId = authState.selectedBranch?.id;
  final queryParams = <String, dynamic>{};
  if (branchId != null) {
    queryParams['branchId'] = branchId;
  }

  final response = await apiClient.dio.get(
    ApiConstants.dashboardMetrics,
    queryParameters: queryParams,
  );

  return DashboardMetricsModel.fromJson(response.data);
});

