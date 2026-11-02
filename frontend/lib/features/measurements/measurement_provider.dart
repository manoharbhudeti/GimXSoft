import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'measurement_models.dart';

class SelectedMeasurementMemberIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String memberId) => state = memberId;
}

final selectedMeasurementMemberIdProvider =
    NotifierProvider<SelectedMeasurementMemberIdNotifier, String?>(() {
  return SelectedMeasurementMemberIdNotifier();
});

final memberMeasurementsProvider =
    FutureProvider.family<List<MemberMeasurementModel>, String>((ref, memberId) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get('${ApiConstants.memberMeasurements}/$memberId');
  final list = response.data as List;
  return list.map((item) => MemberMeasurementModel.fromJson(item as Map<String, dynamic>)).toList();
});

final progressCardProvider =
    FutureProvider.family<FitnessProgressCardModel, String>((ref, memberId) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get('${ApiConstants.progressCard}/$memberId');
  return FitnessProgressCardModel.fromJson(response.data as Map<String, dynamic>);
});

final memberBaselineProvider =
    FutureProvider.family<MemberFitnessBaselineModel, String>((ref, memberId) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get('${ApiConstants.measurementBaseline}/$memberId');
  return MemberFitnessBaselineModel.fromJson(response.data as Map<String, dynamic>);
});

final memberOnboardingProvider =
    FutureProvider.family<MemberOnboardingJourneyModel, String>((ref, memberId) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get('${ApiConstants.onboardingJourney}/$memberId');
  return MemberOnboardingJourneyModel.fromJson(response.data as Map<String, dynamic>);
});

class MeasurementActionService {
  final Ref ref;

  MeasurementActionService(this.ref);

  Future<bool> recordMeasurement(Map<String, dynamic> data) async {
    try {
      final client = ref.read(apiClientProvider);
      final memberId = data['memberId'] as String;
      await client.dio.post(ApiConstants.measurements, data: data);

      ref.invalidate(memberMeasurementsProvider(memberId));
      ref.invalidate(progressCardProvider(memberId));
      ref.invalidate(memberOnboardingProvider(memberId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> saveBaseline(Map<String, dynamic> data) async {
    try {
      final client = ref.read(apiClientProvider);
      final memberId = data['memberId'] as String;
      await client.dio.post(ApiConstants.measurementBaseline, data: data);

      ref.invalidate(memberBaselineProvider(memberId));
      ref.invalidate(progressCardProvider(memberId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateOnboardingStage(String memberId, String stageName, bool isCompleted, [String? notes]) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.onboardingStage,
        data: {
          'memberId': memberId,
          'stageName': stageName,
          'isCompleted': isCompleted,
          'notes': notes,
        },
      );
      ref.invalidate(memberOnboardingProvider(memberId));
      return true;
    } catch (_) {
      return false;
    }
  }
}

final measurementActionProvider = Provider<MeasurementActionService>((ref) {
  return MeasurementActionService(ref);
});
