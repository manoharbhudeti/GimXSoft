class WhatsAppMessageModel {
  final String id;
  final String? memberId;
  final String recipientPhone;
  final String recipientName;
  final String direction; // Outbound, Inbound
  final String messageType; // Text, Template, Interactive, Media
  final String? templateName;
  final String messageContent;
  final String status; // Queued, Sent, Delivered, Read, Failed
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String? failureReason;

  WhatsAppMessageModel({
    required this.id,
    this.memberId,
    required this.recipientPhone,
    required this.recipientName,
    required this.direction,
    required this.messageType,
    this.templateName,
    required this.messageContent,
    required this.status,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.failureReason,
  });

  bool get isOutbound => direction.toLowerCase() == 'outbound';
  bool get isDelivered => status.toLowerCase() == 'delivered' || status.toLowerCase() == 'read';
  bool get isRead => status.toLowerCase() == 'read';

  factory WhatsAppMessageModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppMessageModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String?,
      recipientPhone: json['recipientPhone'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? 'Member',
      direction: json['direction'] as String? ?? 'Outbound',
      messageType: json['messageType'] as String? ?? 'Text',
      templateName: json['templateName'] as String?,
      messageContent: json['messageContent'] as String? ?? '',
      status: json['status'] as String? ?? 'Sent',
      sentAt: DateTime.tryParse(json['sentAt'] as String? ?? '') ?? DateTime.now(),
      deliveredAt: json['deliveredAt'] != null ? DateTime.tryParse(json['deliveredAt'] as String) : null,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt'] as String) : null,
      failureReason: json['failureReason'] as String?,
    );
  }
}

class WhatsAppConversationSummaryModel {
  final String memberId;
  final String memberName;
  final String phone;
  final String planName;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageStatus;
  final String lastMessageDirection;
  final int unreadCount;

  WhatsAppConversationSummaryModel({
    required this.memberId,
    required this.memberName,
    required this.phone,
    required this.planName,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageStatus,
    required this.lastMessageDirection,
    required this.unreadCount,
  });

  factory WhatsAppConversationSummaryModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppConversationSummaryModel(
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String? ?? 'Member',
      phone: json['phone'] as String? ?? '',
      planName: json['planName'] as String? ?? 'Standard',
      avatarUrl: json['avatarUrl'] as String?,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: DateTime.tryParse(json['lastMessageTime'] as String? ?? '') ?? DateTime.now(),
      lastMessageStatus: json['lastMessageStatus'] as String? ?? 'Delivered',
      lastMessageDirection: json['lastMessageDirection'] as String? ?? 'Outbound',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class WhatsAppTemplateModel {
  final String id;
  final String name;
  final String category;
  final String language;
  final String? header;
  final String body;
  final String? footer;
  final String metaStatus;

  WhatsAppTemplateModel({
    required this.id,
    required this.name,
    required this.category,
    required this.language,
    this.header,
    required this.body,
    this.footer,
    required this.metaStatus,
  });

  factory WhatsAppTemplateModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'UTILITY',
      language: json['language'] as String? ?? 'en_US',
      header: json['header'] as String?,
      body: json['body'] as String? ?? '',
      footer: json['footer'] as String?,
      metaStatus: json['metaStatus'] as String? ?? 'APPROVED',
    );
  }
}

class WhatsAppMetricsModel {
  final int totalSentToday;
  final int totalDeliveredToday;
  final int totalReadToday;
  final int totalFailedToday;
  final double deliveryRate;
  final double readRate;
  final int activeConversationsCount;
  final bool isMetaCloudApiConnected;

  WhatsAppMetricsModel({
    required this.totalSentToday,
    required this.totalDeliveredToday,
    required this.totalReadToday,
    required this.totalFailedToday,
    required this.deliveryRate,
    required this.readRate,
    required this.activeConversationsCount,
    required this.isMetaCloudApiConnected,
  });

  factory WhatsAppMetricsModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppMetricsModel(
      totalSentToday: (json['totalSentToday'] as num?)?.toInt() ?? 0,
      totalDeliveredToday: (json['totalDeliveredToday'] as num?)?.toInt() ?? 0,
      totalReadToday: (json['totalReadToday'] as num?)?.toInt() ?? 0,
      totalFailedToday: (json['totalFailedToday'] as num?)?.toInt() ?? 0,
      deliveryRate: (json['deliveryRate'] as num?)?.toDouble() ?? 98.4,
      readRate: (json['readRate'] as num?)?.toDouble() ?? 85.0,
      activeConversationsCount: (json['activeConversationsCount'] as num?)?.toInt() ?? 0,
      isMetaCloudApiConnected: json['isMetaCloudApiConnected'] as bool? ?? true,
    );
  }
}

class WhatsAppDailyVolumeModel {
  final String date;
  final int sent;
  final int received;
  final int delivered;
  final int read;
  final int failed;

  WhatsAppDailyVolumeModel({
    required this.date,
    required this.sent,
    required this.received,
    required this.delivered,
    required this.read,
    required this.failed,
  });

  factory WhatsAppDailyVolumeModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppDailyVolumeModel(
      date: json['date'] as String? ?? '',
      sent: (json['sent'] as num?)?.toInt() ?? 0,
      received: (json['received'] as num?)?.toInt() ?? 0,
      delivered: (json['delivered'] as num?)?.toInt() ?? 0,
      read: (json['read'] as num?)?.toInt() ?? 0,
      failed: (json['failed'] as num?)?.toInt() ?? 0,
    );
  }
}

class WhatsAppDashboardAnalyticsModel {
  final String wabaId;
  final String displayPhoneNumber;
  final String verifiedName;
  final String qualityRating;
  final String messagingLimitTier;
  final String connectionStatus;
  final String healthStatus;
  final String webhookHealth;
  final DateTime? lastSyncedAt;

  final int totalSent;
  final int totalReceived;
  final int totalDelivered;
  final int totalRead;
  final int totalFailed;
  final int pendingMessages;
  final int activeConversations;
  final int unreadConversations;
  final double deliveryRate;
  final double readRate;

  final int totalCampaigns;
  final int scheduledCampaigns;
  final int activeCampaigns;
  final int completedCampaigns;
  final int failedCampaigns;

  final int approvedTemplates;
  final int pendingTemplates;
  final int rejectedTemplates;

  final List<WhatsAppDailyVolumeModel> dailyTrends;
  final Map<String, int> failureReasonsBreakdown;

  WhatsAppDashboardAnalyticsModel({
    required this.wabaId,
    required this.displayPhoneNumber,
    required this.verifiedName,
    required this.qualityRating,
    required this.messagingLimitTier,
    required this.connectionStatus,
    required this.healthStatus,
    required this.webhookHealth,
    this.lastSyncedAt,
    required this.totalSent,
    required this.totalReceived,
    required this.totalDelivered,
    required this.totalRead,
    required this.totalFailed,
    required this.pendingMessages,
    required this.activeConversations,
    required this.unreadConversations,
    required this.deliveryRate,
    required this.readRate,
    required this.totalCampaigns,
    required this.scheduledCampaigns,
    required this.activeCampaigns,
    required this.completedCampaigns,
    required this.failedCampaigns,
    required this.approvedTemplates,
    required this.pendingTemplates,
    required this.rejectedTemplates,
    required this.dailyTrends,
    required this.failureReasonsBreakdown,
  });

  factory WhatsAppDashboardAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final dailyList = (json['dailyTrends'] as List?)
            ?.map((e) => WhatsAppDailyVolumeModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final failureMap = <String, int>{};
    if (json['failureReasonsBreakdown'] is Map) {
      (json['failureReasonsBreakdown'] as Map).forEach((k, v) {
        failureMap[k.toString()] = (v as num).toInt();
      });
    }

    return WhatsAppDashboardAnalyticsModel(
      wabaId: json['wabaId'] as String? ?? '109283746592837',
      displayPhoneNumber: json['displayPhoneNumber'] as String? ?? '+1 (555) 234-9428',
      verifiedName: json['verifiedName'] as String? ?? 'Titan Fitness Club',
      qualityRating: json['qualityRating'] as String? ?? 'GREEN',
      messagingLimitTier: json['messagingLimitTier'] as String? ?? 'TIER_10K',
      connectionStatus: json['connectionStatus'] as String? ?? 'Connected',
      healthStatus: json['healthStatus'] as String? ?? 'HEALTHY',
      webhookHealth: json['webhookHealth'] as String? ?? 'OPERATIONAL',
      lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.tryParse(json['lastSyncedAt'] as String) : null,
      totalSent: (json['totalSent'] as num?)?.toInt() ?? 0,
      totalReceived: (json['totalReceived'] as num?)?.toInt() ?? 0,
      totalDelivered: (json['totalDelivered'] as num?)?.toInt() ?? 0,
      totalRead: (json['totalRead'] as num?)?.toInt() ?? 0,
      totalFailed: (json['totalFailed'] as num?)?.toInt() ?? 0,
      pendingMessages: (json['pendingMessages'] as num?)?.toInt() ?? 0,
      activeConversations: (json['activeConversations'] as num?)?.toInt() ?? 0,
      unreadConversations: (json['unreadConversations'] as num?)?.toInt() ?? 0,
      deliveryRate: (json['deliveryRate'] as num?)?.toDouble() ?? 98.4,
      readRate: (json['readRate'] as num?)?.toDouble() ?? 84.6,
      totalCampaigns: (json['totalCampaigns'] as num?)?.toInt() ?? 0,
      scheduledCampaigns: (json['scheduledCampaigns'] as num?)?.toInt() ?? 0,
      activeCampaigns: (json['activeCampaigns'] as num?)?.toInt() ?? 0,
      completedCampaigns: (json['completedCampaigns'] as num?)?.toInt() ?? 0,
      failedCampaigns: (json['failedCampaigns'] as num?)?.toInt() ?? 0,
      approvedTemplates: (json['approvedTemplates'] as num?)?.toInt() ?? 0,
      pendingTemplates: (json['pendingTemplates'] as num?)?.toInt() ?? 0,
      rejectedTemplates: (json['rejectedTemplates'] as num?)?.toInt() ?? 0,
      dailyTrends: dailyList,
      failureReasonsBreakdown: failureMap,
    );
  }
}

class WhatsAppCampaignModel {
  final String id;
  final String name;
  final String? description;
  final String audienceSegment;
  final String? specificPlanName;
  final String? templateName;
  final String messageContent;
  final String status;
  final DateTime? scheduledAtUtc;
  final DateTime? startedAtUtc;
  final DateTime? completedAtUtc;
  final int totalRecipients;
  final int sentCount;
  final int deliveredCount;
  final int readCount;
  final int failedCount;
  final DateTime createdAt;

  WhatsAppCampaignModel({
    required this.id,
    required this.name,
    this.description,
    required this.audienceSegment,
    this.specificPlanName,
    this.templateName,
    required this.messageContent,
    required this.status,
    this.scheduledAtUtc,
    this.startedAtUtc,
    this.completedAtUtc,
    required this.totalRecipients,
    required this.sentCount,
    required this.deliveredCount,
    required this.readCount,
    required this.failedCount,
    required this.createdAt,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isInProgress => status.toLowerCase() == 'inprogress';
  bool get isScheduled => status.toLowerCase() == 'scheduled';

  factory WhatsAppCampaignModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppCampaignModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Campaign',
      description: json['description'] as String?,
      audienceSegment: json['audienceSegment'] as String? ?? 'AllActive',
      specificPlanName: json['specificPlanName'] as String?,
      templateName: json['templateName'] as String?,
      messageContent: json['messageContent'] as String? ?? '',
      status: json['status'] as String? ?? 'Draft',
      scheduledAtUtc: json['scheduledAtUtc'] != null ? DateTime.tryParse(json['scheduledAtUtc'] as String) : null,
      startedAtUtc: json['startedAtUtc'] != null ? DateTime.tryParse(json['startedAtUtc'] as String) : null,
      completedAtUtc: json['completedAtUtc'] != null ? DateTime.tryParse(json['completedAtUtc'] as String) : null,
      totalRecipients: (json['totalRecipients'] as num?)?.toInt() ?? 0,
      sentCount: (json['sentCount'] as num?)?.toInt() ?? 0,
      deliveredCount: (json['deliveredCount'] as num?)?.toInt() ?? 0,
      readCount: (json['readCount'] as num?)?.toInt() ?? 0,
      failedCount: (json['failedCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class WhatsAppTriggerRuleModel {
  final String id;
  final String triggerEvent;
  final String templateName;
  final bool isEnabled;
  final DateTime updatedAt;

  WhatsAppTriggerRuleModel({
    required this.id,
    required this.triggerEvent,
    required this.templateName,
    required this.isEnabled,
    required this.updatedAt,
  });

  factory WhatsAppTriggerRuleModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppTriggerRuleModel(
      id: json['id'] as String,
      triggerEvent: json['triggerEvent'] as String? ?? '',
      templateName: json['templateName'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? true,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class WhatsAppIntegrationModel {
  final String id;
  final String wabaId;
  final String phoneNumberId;
  final String displayPhoneNumber;
  final String businessPortfolioName;
  final String connectionStatus;
  final String healthStatus;
  final String qualityRating;
  final String messagingLimitTier;
  final String verifiedName;
  final String codeVerificationStatus;
  final String? appId;
  final double costPerUtilityMessage;
  final double costPerMarketingMessage;
  final String timeZoneId;
  final DateTime? lastSyncedAt;
  final String webhookUrl;
  final String webhookVerifyToken;
  final String webhookStatus;
  final bool requiresMigration;
  final bool coexistenceEligible;
  final String? verificationSessionId;

  WhatsAppIntegrationModel({
    required this.id,
    required this.wabaId,
    required this.phoneNumberId,
    required this.displayPhoneNumber,
    required this.businessPortfolioName,
    required this.connectionStatus,
    required this.healthStatus,
    required this.qualityRating,
    required this.messagingLimitTier,
    required this.verifiedName,
    required this.codeVerificationStatus,
    this.appId,
    required this.costPerUtilityMessage,
    required this.costPerMarketingMessage,
    required this.timeZoneId,
    this.lastSyncedAt,
    required this.webhookUrl,
    required this.webhookVerifyToken,
    this.webhookStatus = 'OPERATIONAL',
    this.requiresMigration = false,
    this.coexistenceEligible = true,
    this.verificationSessionId,
  });

  bool get isConnected => connectionStatus.toLowerCase() == 'connected';

  factory WhatsAppIntegrationModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppIntegrationModel(
      id: json['id'] as String? ?? '',
      wabaId: json['wabaId'] as String? ?? '',
      phoneNumberId: json['phoneNumberId'] as String? ?? '',
      displayPhoneNumber: json['displayPhoneNumber'] as String? ?? '',
      businessPortfolioName: json['businessPortfolioName'] as String? ?? '',
      connectionStatus: json['connectionStatus'] as String? ?? 'Connected',
      healthStatus: json['healthStatus'] as String? ?? 'HEALTHY',
      qualityRating: json['qualityRating'] as String? ?? 'GREEN',
      messagingLimitTier: json['messagingLimitTier'] as String? ?? 'TIER_10K',
      verifiedName: json['verifiedName'] as String? ?? 'Titan Fitness Club',
      codeVerificationStatus: json['codeVerificationStatus'] as String? ?? 'VERIFIED',
      appId: json['appId'] as String?,
      costPerUtilityMessage: (json['costPerUtilityMessage'] as num?)?.toDouble() ?? 0.005,
      costPerMarketingMessage: (json['costPerMarketingMessage'] as num?)?.toDouble() ?? 0.025,
      timeZoneId: json['timeZoneId'] as String? ?? 'Asia/Kolkata',
      lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.tryParse(json['lastSyncedAt'] as String) : null,
      webhookUrl: json['webhookUrl'] as String? ?? '',
      webhookVerifyToken: json['webhookVerifyToken'] as String? ?? '',
      webhookStatus: json['webhookStatus'] as String? ?? 'OPERATIONAL',
      requiresMigration: json['requiresMigration'] as bool? ?? false,
      coexistenceEligible: json['coexistenceEligible'] as bool? ?? true,
      verificationSessionId: json['verificationSessionId'] as String?,
    );
  }
}

class WhatsAppOnboardingInitiateResult {
  final bool success;
  final String sessionId;
  final String maskedPhoneNumber;
  final int expiresInSeconds;
  final String message;
  final bool requiresMigration;
  final bool coexistenceEligible;
  final String? verificationCode;

  WhatsAppOnboardingInitiateResult({
    required this.success,
    required this.sessionId,
    required this.maskedPhoneNumber,
    required this.expiresInSeconds,
    required this.message,
    this.requiresMigration = false,
    this.coexistenceEligible = true,
    this.verificationCode,
  });

  factory WhatsAppOnboardingInitiateResult.fromJson(Map<String, dynamic> json) {
    return WhatsAppOnboardingInitiateResult(
      success: json['success'] as bool? ?? false,
      sessionId: json['sessionId'] as String? ?? '',
      maskedPhoneNumber: json['maskedPhoneNumber'] as String? ?? '',
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 300,
      message: json['message'] as String? ?? '',
      requiresMigration: json['requiresMigration'] as bool? ?? false,
      coexistenceEligible: json['coexistenceEligible'] as bool? ?? true,
      verificationCode: json['verificationCode'] as String?,
    );
  }
}

class WhatsAppVerificationResult {
  final bool success;
  final String message;
  final WhatsAppIntegrationModel? integration;
  final String? errorCode;

  WhatsAppVerificationResult({
    required this.success,
    required this.message,
    this.integration,
    this.errorCode,
  });

  factory WhatsAppVerificationResult.fromJson(Map<String, dynamic> json) {
    return WhatsAppVerificationResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      integration: json['integration'] != null
          ? WhatsAppIntegrationModel.fromJson(json['integration'] as Map<String, dynamic>)
          : null,
      errorCode: json['errorCode'] as String?,
    );
  }
}

class WhatsAppConnectionHealthModel {
  final String status;
  final String healthRating;
  final bool webhooksOperational;
  final String qualityRating;
  final String messagingLimitTier;
  final DateTime lastCheckedAt;
  final String? diagnostics;
  final int dailySentToday;
  final int dailyLimit;

  WhatsAppConnectionHealthModel({
    required this.status,
    required this.healthRating,
    required this.webhooksOperational,
    required this.qualityRating,
    required this.messagingLimitTier,
    required this.lastCheckedAt,
    this.diagnostics,
    required this.dailySentToday,
    required this.dailyLimit,
  });

  factory WhatsAppConnectionHealthModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppConnectionHealthModel(
      status: json['status'] as String? ?? 'NotConnected',
      healthRating: json['healthRating'] as String? ?? 'NOT_INITIALIZED',
      webhooksOperational: json['webhooksOperational'] as bool? ?? true,
      qualityRating: json['qualityRating'] as String? ?? 'GREEN',
      messagingLimitTier: json['messagingLimitTier'] as String? ?? 'TIER_1K',
      lastCheckedAt: DateTime.tryParse(json['lastCheckedAt'] as String? ?? '') ?? DateTime.now(),
      diagnostics: json['diagnostics'] as String?,
      dailySentToday: (json['dailySentToday'] as num?)?.toInt() ?? 0,
      dailyLimit: (json['dailyLimit'] as num?)?.toInt() ?? 1000,
    );
  }
}

class ScheduledMessageModel {
  final String id;
  final String? memberId;
  final String recipientPhone;
  final String recipientName;
  final String? templateName;
  final String messageContent;
  final DateTime scheduledForUtc;
  final String status;
  final String triggerType;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? failureReason;

  ScheduledMessageModel({
    required this.id,
    this.memberId,
    required this.recipientPhone,
    required this.recipientName,
    this.templateName,
    required this.messageContent,
    required this.scheduledForUtc,
    required this.status,
    required this.triggerType,
    required this.createdAt,
    this.processedAt,
    this.failureReason,
  });

  bool get isPending => status.toLowerCase() == 'pending';

  factory ScheduledMessageModel.fromJson(Map<String, dynamic> json) {
    return ScheduledMessageModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String?,
      recipientPhone: json['recipientPhone'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? 'Member',
      templateName: json['templateName'] as String?,
      messageContent: json['messageContent'] as String? ?? '',
      scheduledForUtc: DateTime.tryParse(json['scheduledForUtc'] as String? ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'Pending',
      triggerType: json['triggerType'] as String? ?? 'Manual',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      processedAt: json['processedAt'] != null ? DateTime.tryParse(json['processedAt'] as String) : null,
      failureReason: json['failureReason'] as String?,
    );
  }
}
