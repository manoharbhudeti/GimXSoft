import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../auth/auth_provider.dart';
import 'payment_models.dart';

final paymentsListProvider = FutureProvider.autoDispose<List<PaymentTransactionModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authProvider);

  final queryParams = <String, dynamic>{};
  if (authState.selectedBranch?.id != null) {
    queryParams['branchId'] = authState.selectedBranch!.id;
  }

  final response = await apiClient.dio.get(
    ApiConstants.payments,
    queryParameters: queryParams,
  );

  return (response.data as List)
      .map((item) => PaymentTransactionModel.fromJson(item))
      .toList();
});

final financialSummaryProvider = FutureProvider.autoDispose<FinancialSummaryModel>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authProvider);

  final queryParams = <String, dynamic>{};
  if (authState.selectedBranch?.id != null) {
    queryParams['branchId'] = authState.selectedBranch!.id;
  }

  final response = await apiClient.dio.get(
    ApiConstants.financialSummary,
    queryParameters: queryParams,
  );

  return FinancialSummaryModel.fromJson(response.data);
});

class PaymentsActionNotifier {
  final ApiClient _apiClient;
  final Ref _ref;

  PaymentsActionNotifier(this._apiClient, this._ref);

  Future<bool> collectPayment({
    required String memberId,
    required double amount,
    required int paymentMethod, // 0: Cash, 1: UPI, 2: Card, 3: BankTransfer
    String? reference,
    String? notes,
  }) async {
    try {
      final authState = _ref.read(authProvider);
      final branchId = authState.selectedBranch?.id ??
          (authState.branches.isNotEmpty ? authState.branches.first.id : '');

      await _apiClient.dio.post(
        ApiConstants.collectPayment,
        data: {
          'branchId': branchId,
          'memberId': memberId,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'transactionReference': reference,
          'notes': notes,
        },
      );
      _ref.invalidate(paymentsListProvider);
      _ref.invalidate(financialSummaryProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> refundPayment(String paymentId, String reason) async {
    try {
      await _apiClient.dio.post(
        '${ApiConstants.payments}/$paymentId/refund',
        data: {'reason': reason},
      );
      _ref.invalidate(paymentsListProvider);
      _ref.invalidate(financialSummaryProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final paymentsActionProvider = Provider<PaymentsActionNotifier>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentsActionNotifier(apiClient, ref);
});
