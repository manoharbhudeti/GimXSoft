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

public record CreateWhatsAppTemplateRequest(
    string Name,
    string Category,
    string Language,
    string? HeaderText,
    string BodyText,
    string? FooterText,
    List<string>? Buttons
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

public record WhatsAppDailyVolumeDto(
    string Date,
    int Sent,
    int Received,
    int Delivered,
    int Read,
    int Failed
);

public record WhatsAppDashboardAnalyticsDto(
    // Account Overview
    string WabaId,
    string DisplayPhoneNumber,
    string VerifiedName,
    string QualityRating,
    string MessagingLimitTier,
    string ConnectionStatus,
    string HealthStatus,
    string WebhookHealth,
    DateTime? LastSyncedAt,

    // Messaging Overview
    int TotalSent,
    int TotalReceived,
    int TotalDelivered,
    int TotalRead,
    int TotalFailed,
    int PendingMessages,
    int ActiveConversations,
    int UnreadConversations,
    double DeliveryRate,
    double ReadRate,

    // Campaign Overview
    int TotalCampaigns,
    int ScheduledCampaigns,
    int ActiveCampaigns,
    int CompletedCampaigns,
    int FailedCampaigns,

    // Template Overview
    int ApprovedTemplates,
    int PendingTemplates,
    int RejectedTemplates,

    // Trends & Diagnostics
    List<WhatsAppDailyVolumeDto> DailyTrends,
    Dictionary<string, int> FailureReasonsBreakdown
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
    string QualityRating,
    string MessagingLimitTier,
    string VerifiedName,
    string CodeVerificationStatus,
    string? AppId,
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
    string TimeZoneId,
    string? AppId = null,
    string? AppSecret = null
);

public record RegisterPhoneNumberRequest(
    string Pin
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

// Campaign Management DTOs
public record WhatsAppCampaignDto(
    Guid Id,
    string Name,
    string? Description,
    string AudienceSegment,
    string? SpecificPlanName,
    string? TemplateName,
    string MessageContent,
    string Status,
    DateTime? ScheduledAtUtc,
    DateTime? StartedAtUtc,
    DateTime? CompletedAtUtc,
    int TotalRecipients,
    int SentCount,
    int DeliveredCount,
    int ReadCount,
    int FailedCount,
    DateTime CreatedAt
);

public record CreateCampaignRequest(
    string Name,
    string? Description,
    string AudienceSegment, // "AllActive", "ExpiringIn7Days", "ExpiredIn30Days", "NewMembersLast14Days", "SpecificPlan"
    Guid? SpecificPlanId,
    string? TemplateName,
    string? TemplateLanguage,
    string MessageContent,
    DateTime? ScheduledAtUtc
);

public record WhatsAppCampaignRecipientDto(
    Guid Id,
    Guid? MemberId,
    string RecipientName,
    string RecipientPhone,
    string Status,
    string? WamId,
    DateTime? SentAt,
    DateTime? DeliveredAt,
    DateTime? ReadAt,
    string? FailureReason
);

public record AudiencePreviewDto(
    string AudienceSegment,
    int RecipientCount,
    List<string> SampleRecipientNames
);

// Gym Specific Workflow DTOs
public record ShareWorkoutSplitRequest(
    Guid MemberId,
    string? SplitTitle,
    List<string>? Exercises,
    string? TrainerNotes
);

public record SendBmiReportRequest(
    Guid MemberId,
    decimal WeightKg,
    decimal HeightCm,
    decimal Bmi,
    decimal? BodyFatPercentage,
    string? AssessmentSummary
);

public record SendMembershipExpiryReminderRequest(
    Guid MemberId,
    int DaysRemaining,
    string? CustomMessage
);

public record ShareGymCatalogRequest(
    Guid MemberId,
    string CatalogCategory, // "Supplements", "PersonalTraining", "Memberships"
    string? CustomNote
);
