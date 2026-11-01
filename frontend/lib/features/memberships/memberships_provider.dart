import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'membership_models.dart';

final membershipPlansProvider = FutureProvider.autoDispose<List<MembershipPlanModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get(ApiConstants.membershipPlans);
  return (response.data as List)
      .map((item) => MembershipPlanModel.fromJson(item))
      .toList();
});

final memberSubscriptionsProvider = FutureProvider.autoDispose<List<MemberSubscriptionModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get(ApiConstants.subscriptions);
  return (response.data as List)
      .map((item) => MemberSubscriptionModel.fromJson(item))
      .toList();
});

class MembershipActionNotifier {
  final ApiClient _apiClient;
  final Ref _ref;

  MembershipActionNotifier(this._apiClient, this._ref);

  Future<bool> createPlan({
    required String name,
    String? description,
    required int durationDays,
    required double price,
    required double registrationFee,
    bool isPersonalTraining = false,
    int includedSessions = 0,
    String? benefitsJson,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.membershipPlans,
        data: {
          'name': name,
          'description': description ?? '',
          'durationDays': durationDays,
          'price': price,
          'registrationFee': registrationFee,
          'isPersonalTraining': isPersonalTraining,
          'includedSessions': includedSessions,
          'benefitsJson': benefitsJson ?? '[]',
        },
      );
      _ref.invalidate(membershipPlansProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> subscribeMember({
    required String memberId,
    required String planId,
    required String paymentMethod,
    double discountAmount = 0,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.subscribe,
        data: {
          'memberId': memberId,
          'membershipPlanId': planId,
          'paymentMethod': paymentMethod,
          'discountAmount': discountAmount,
        },
      );
      _ref.invalidate(memberSubscriptionsProvider);
      _ref.invalidate(membershipPlansProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> freezeSubscription(String id, DateTime start, DateTime end, String reason) async {
    try {
      await _apiClient.dio.post(
        '${ApiConstants.subscriptions}/$id/freeze',
        data: {
          'freezeStartDate': start.toIso8601String(),
          'freezeEndDate': end.toIso8601String(),
          'reason': reason,
        },
      );
      _ref.invalidate(memberSubscriptionsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unfreezeSubscription(String id) async {
    try {
      await _apiClient.dio.post('${ApiConstants.subscriptions}/$id/unfreeze');
      _ref.invalidate(memberSubscriptionsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final membershipActionProvider = Provider<MembershipActionNotifier>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MembershipActionNotifier(apiClient, ref);
});
