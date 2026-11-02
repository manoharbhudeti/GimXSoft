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
  final double costPerUtilityMessage;
  final double costPerMarketingMessage;
  final String timeZoneId;
  final DateTime? lastSyncedAt;
  final String webhookUrl;
  final String webhookVerifyToken;

  WhatsAppIntegrationModel({
    required this.id,
    required this.wabaId,
    required this.phoneNumberId,
    required this.displayPhoneNumber,
    required this.businessPortfolioName,
    required this.connectionStatus,
    required this.healthStatus,
    required this.costPerUtilityMessage,
    required this.costPerMarketingMessage,
    required this.timeZoneId,
    this.lastSyncedAt,
    required this.webhookUrl,
    required this.webhookVerifyToken,
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
      costPerUtilityMessage: (json['costPerUtilityMessage'] as num?)?.toDouble() ?? 0.005,
      costPerMarketingMessage: (json['costPerMarketingMessage'] as num?)?.toDouble() ?? 0.025,
      timeZoneId: json['timeZoneId'] as String? ?? 'Asia/Kolkata',
      lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.tryParse(json['lastSyncedAt'] as String) : null,
      webhookUrl: json['webhookUrl'] as String? ?? '',
      webhookVerifyToken: json['webhookVerifyToken'] as String? ?? 'GIMXSOFT_WHATSAPP_WEBHOOK_VERIFY_TOKEN',
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


