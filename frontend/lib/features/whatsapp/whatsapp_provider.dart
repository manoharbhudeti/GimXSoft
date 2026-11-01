import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'whatsapp_models.dart';

final whatsAppMetricsProvider = FutureProvider<WhatsAppMetricsModel>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(ApiConstants.whatsAppMetrics);
  return WhatsAppMetricsModel.fromJson(response.data as Map<String, dynamic>);
});

final whatsAppConversationsProvider =
    FutureProvider<List<WhatsAppConversationSummaryModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(ApiConstants.whatsAppConversations);
  final list = response.data as List;
  return list
      .map((item) => WhatsAppConversationSummaryModel.fromJson(item as Map<String, dynamic>))
      .toList();
});

class SelectedMemberIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String memberId) => state = memberId;
}

final selectedMemberIdProvider =
    NotifierProvider<SelectedMemberIdNotifier, String?>(() {
  return SelectedMemberIdNotifier();
});

final whatsAppMessagesProvider =
    FutureProvider.family<List<WhatsAppMessageModel>, String>((ref, memberId) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get('${ApiConstants.whatsAppHistory}/$memberId');
  final list = response.data as List;
  return list
      .map((item) => WhatsAppMessageModel.fromJson(item as Map<String, dynamic>))
      .toList();
});

final whatsAppTemplatesProvider =
    FutureProvider<List<WhatsAppTemplateModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(ApiConstants.whatsAppTemplates);
  final list = response.data as List;
  return list
      .map((item) => WhatsAppTemplateModel.fromJson(item as Map<String, dynamic>))
      .toList();
});

final whatsAppTriggersProvider =
    FutureProvider<List<WhatsAppTriggerRuleModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(ApiConstants.whatsAppTriggers);
  final list = response.data as List;
  return list
      .map((item) => WhatsAppTriggerRuleModel.fromJson(item as Map<String, dynamic>))
      .toList();
});

class WhatsAppActionService {
  final Ref ref;

  WhatsAppActionService(this.ref);

  Future<WhatsAppMessageModel?> sendMessage({
    required String memberId,
    required String message,
    String? templateName,
    List<String>? templateParams,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.dio.post(
        ApiConstants.whatsAppSend,
        data: {
          'memberId': memberId,
          'message': message,
          'templateName': templateName,
          'templateParams': templateParams,
        },
      );

      // Invalidate relevant providers to update conversation list and chat thread
      ref.invalidate(whatsAppMessagesProvider(memberId));
      ref.invalidate(whatsAppConversationsProvider);
      ref.invalidate(whatsAppMetricsProvider);

      return WhatsAppMessageModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> broadcastCampaign({
    required String audienceFilter,
    required String message,
    String? templateName,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.whatsAppBroadcast,
        data: {
          'audienceFilter': audienceFilter,
          'message': message,
          'templateName': templateName,
        },
      );

      ref.invalidate(whatsAppConversationsProvider);
      ref.invalidate(whatsAppMetricsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleTrigger(String triggerEvent, bool isEnabled) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.whatsAppToggleTrigger,
        data: {
          'triggerEvent': triggerEvent,
          'isEnabled': isEnabled,
        },
      );
      ref.invalidate(whatsAppTriggersProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final whatsAppActionProvider = Provider<WhatsAppActionService>((ref) {
  return WhatsAppActionService(ref);
});

