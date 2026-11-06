namespace GimXSoft.Api.DTOs;

public record SendWhatsAppMessageRequest(
    Guid? MemberId,
    string RecipientPhone,
    string? RecipientName,
    string Message,
    string? TemplateName,
    List<string>? TemplateParams
);

public record SendBroadcastRequest(
    string AudienceFilter, // "all_active", "expiring_7_days", "pending_dues"
    string? TemplateName,
    string Message,
    List<string>? TemplateParams
);

public record WhatsAppMessageDto(
    Guid Id,
    Guid? MemberId,
    string RecipientPhone,
    string RecipientName,
    string Direction,
    string MessageType,
    string? TemplateName,
    string MessageContent,
    string Status,
    DateTime SentAt,
    DateTime? DeliveredAt,
    DateTime? ReadAt,
    string? FailureReason
);

public record WhatsAppConversationSummaryDto(
    Guid MemberId,
    string MemberName,
    string Phone,
    string PlanName,
    string? AvatarUrl,
    string LastMessage,
    DateTime LastMessageTime,
    string LastMessageStatus,
    string LastMessageDirection,
    int UnreadCount
);

public record WhatsAppTemplateDto(
    Guid Id,
    string Name,
    string Category,
    string Language,
    string? Header,
    string Body,
    string? Footer,
    string MetaStatus
);

public record WhatsAppMetricsDto(
    int TotalSentToday,
    int TotalDeliveredToday,
    int TotalReadToday,
    int TotalFailedToday,
    double DeliveryRate,
    double ReadRate,
    int ActiveConversationsCount,
    bool IsMetaCloudApiConnected
);

public record WhatsAppTriggerRuleDto(
    Guid Id,
    string TriggerEvent,
    string TemplateName,
    bool IsEnabled,
    DateTime UpdatedAt
);

public record ToggleTriggerRequest(
    string TriggerEvent,
    bool IsEnabled
);

public record CreateTriggerRuleRequest(
    string TriggerEvent,
    string TemplateName,
    bool IsEnabled = true
);

public record QuickSendWhatsAppRequest(
    string RecipientPhone,
    string? RecipientName,
    string Message,
    Guid? MemberId
);

public record TestWhatsAppMessageRequest(
    string DestinationPhone,
    string? TestMessage
);

public record WhatsAppIntegrationDto(
    Guid Id,
    string WabaId,
    string PhoneNumberId,
    string DisplayPhoneNumber,
    string BusinessPortfolioName,
    string ConnectionStatus,
    string HealthStatus,
    decimal CostPerUtilityMessage,
    decimal CostPerMarketingMessage,
    string TimeZoneId,
    DateTime? LastSyncedAt,
    string WebhookUrl,
    string WebhookVerifyToken
);

public record UpdateWhatsAppConfigRequest(
    string WabaId,
    string PhoneNumberId,
    string DisplayPhoneNumber,
    string BusinessPortfolioName,
    string AccessToken,
    string TimeZoneId
);

public record WhatsAppConsentDto(
    Guid Id,
    Guid MemberId,
    string Phone,
    bool HasConsented,
    string ConsentSource,
    DateTime ConsentedAt,
    DateTime? RevokedAt,
    string AllowedCategoriesJson
);

public record RecordConsentRequest(
    Guid MemberId,
    string Phone,
    bool HasConsented,
    string? ConsentSource,
    List<string>? AllowedCategories
);

public record ScheduledMessageDto(
    Guid Id,
    Guid? MemberId,
    string RecipientPhone,
    string RecipientName,
    string? TemplateName,
    string MessageContent,
    DateTime ScheduledForUtc,
    string Status,
    string TriggerType,
    DateTime CreatedAt,
    DateTime? ProcessedAt,
    string? FailureReason
);

public record CreateScheduledMessageRequest(
    Guid? MemberId,
    string RecipientPhone,
    string? RecipientName,
    string? TemplateName,
    string MessageContent,
    DateTime ScheduledForUtc,
    string TriggerType
);

public record OptOutRequest(
    string Phone,
    string? Reason
);


