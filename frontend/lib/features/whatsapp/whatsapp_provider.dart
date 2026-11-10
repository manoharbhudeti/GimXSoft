import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'whatsapp_models.dart';

final whatsAppMetricsProvider = FutureProvider<WhatsAppMetricsModel>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(ApiConstants.whatsAppMetrics);
  return WhatsAppMetricsModel.fromJson(response.data as Map<String, dynamic>);
});

final whatsAppDashboardAnalyticsProvider =
    FutureProvider.family<WhatsAppDashboardAnalyticsModel, int>((ref, days) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(
    ApiConstants.whatsAppAnalytics,
    queryParameters: {'days': days},
  );
  return WhatsAppDashboardAnalyticsModel.fromJson(response.data as Map<String, dynamic>);
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

final whatsAppCampaignsProvider =
    FutureProvider<List<WhatsAppCampaignModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(ApiConstants.whatsAppCampaigns);
  final list = response.data as List;
  return list
      .map((item) => WhatsAppCampaignModel.fromJson(item as Map<String, dynamic>))
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

final whatsAppConfigProvider =
    FutureProvider<WhatsAppIntegrationModel>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(ApiConstants.whatsAppConfig);
  return WhatsAppIntegrationModel.fromJson(response.data as Map<String, dynamic>);
});

final whatsAppScheduledMessagesProvider =
    FutureProvider<List<ScheduledMessageModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(ApiConstants.whatsAppScheduled);
  final list = response.data as List;
  return list
      .map((item) => ScheduledMessageModel.fromJson(item as Map<String, dynamic>))
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
      ref.invalidate(whatsAppDashboardAnalyticsProvider(7));

      return WhatsAppMessageModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> createCampaign({
    required String name,
    String? description,
    required String audienceSegment,
    String? specificPlanId,
    String? templateName,
    required String messageContent,
    DateTime? scheduledAtUtc,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.whatsAppCampaigns,
        data: {
          'name': name,
          'description': description,
          'audienceSegment': audienceSegment,
          'specificPlanId': specificPlanId,
          'templateName': templateName,
          'messageContent': messageContent,
          'scheduledAtUtc': scheduledAtUtc?.toIso8601String(),
        },
      );

      ref.invalidate(whatsAppCampaignsProvider);
      ref.invalidate(whatsAppConversationsProvider);
      ref.invalidate(whatsAppMetricsProvider);
      ref.invalidate(whatsAppDashboardAnalyticsProvider(7));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> broadcastCampaign({
    required String audienceFilter,
    required String message,
    String? templateName,
  }) async {
    return createCampaign(
      name: 'Broadcast_${DateTime.now().millisecondsSinceEpoch}',
      audienceSegment: audienceFilter,
      messageContent: message,
      templateName: templateName,
    );
  }

  Future<bool> createTemplate({
    required String name,
    required String category,
    required String language,
    String? headerText,
    required String bodyText,
    String? footerText,
    List<String>? buttons,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.whatsAppTemplates,
        data: {
          'name': name,
          'category': category,
          'language': language,
          'headerText': headerText,
          'bodyText': bodyText,
          'footerText': footerText,
          'buttons': buttons,
        },
      );
      ref.invalidate(whatsAppTemplatesProvider);
      ref.invalidate(whatsAppDashboardAnalyticsProvider(7));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTemplate(String id) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.delete('${ApiConstants.whatsAppTemplates}/$id');
      ref.invalidate(whatsAppTemplatesProvider);
      ref.invalidate(whatsAppDashboardAnalyticsProvider(7));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> registerPhoneNumber(String pin) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.whatsAppRegisterNumber,
        data: {'pin': pin},
      );
      ref.invalidate(whatsAppConfigProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> shareWorkoutSplit({
    required String memberId,
    String? splitTitle,
    List<String>? exercises,
    String? trainerNotes,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.whatsAppShareWorkout,
        data: {
          'memberId': memberId,
          'splitTitle': splitTitle,
          'exercises': exercises,
          'trainerNotes': trainerNotes,
        },
      );
      ref.invalidate(whatsAppMessagesProvider(memberId));
      ref.invalidate(whatsAppConversationsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendBmiReport({
    required String memberId,
    required double weightKg,
    required double heightCm,
    required double bmi,
    double? bodyFatPercentage,
    String? assessmentSummary,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.whatsAppSendBmi,
        data: {
          'memberId': memberId,
          'weightKg': weightKg,
          'heightCm': heightCm,
          'bmi': bmi,
          'bodyFatPercentage': bodyFatPercentage,
          'assessmentSummary': assessmentSummary,
        },
      );
      ref.invalidate(whatsAppMessagesProvider(memberId));
      ref.invalidate(whatsAppConversationsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendExpiryReminder({
    required String memberId,
    required int daysRemaining,
    String? customMessage,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.whatsAppSendExpiry,
        data: {
          'memberId': memberId,
          'daysRemaining': daysRemaining,
          'customMessage': customMessage,
        },
      );
      ref.invalidate(whatsAppMessagesProvider(memberId));
      ref.invalidate(whatsAppConversationsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> shareGymCatalog({
    required String memberId,
    required String catalogCategory,
    String? customNote,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.whatsAppShareCatalog,
        data: {
          'memberId': memberId,
          'catalogCategory': catalogCategory,
          'customNote': customNote,
        },
      );
      ref.invalidate(whatsAppMessagesProvider(memberId));
      ref.invalidate(whatsAppConversationsProvider);
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

  Future<bool> updateConfig({
    required String wabaId,
    required String phoneNumberId,
    required String displayPhoneNumber,
    required String businessPortfolioName,
    required String accessToken,
    required String timeZoneId,
    String? appId,
    String? appSecret,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.whatsAppConfig,
        data: {
          'wabaId': wabaId,
          'phoneNumberId': phoneNumberId,
          'displayPhoneNumber': displayPhoneNumber,
          'businessPortfolioName': businessPortfolioName,
          'accessToken': accessToken,
          'timeZoneId': timeZoneId,
          'appId': appId,
          'appSecret': appSecret,
        },
      );
      ref.invalidate(whatsAppConfigProvider);
      ref.invalidate(whatsAppMetricsProvider);
      ref.invalidate(whatsAppDashboardAnalyticsProvider(7));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> disconnectConfig() async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(ApiConstants.whatsAppDisconnect);
      ref.invalidate(whatsAppConfigProvider);
      ref.invalidate(whatsAppMetricsProvider);
      ref.invalidate(whatsAppDashboardAnalyticsProvider(7));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> syncTemplates() async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(ApiConstants.whatsAppSyncTemplates);
      ref.invalidate(whatsAppTemplatesProvider);
      ref.invalidate(whatsAppConfigProvider);
      ref.invalidate(whatsAppDashboardAnalyticsProvider(7));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelScheduledMessage(String id) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.delete('${ApiConstants.whatsAppScheduled}/$id');
      ref.invalidate(whatsAppScheduledMessagesProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final whatsAppActionProvider = Provider<WhatsAppActionService>((ref) {
  return WhatsAppActionService(ref);
});
