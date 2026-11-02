using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GimXSoft.Api.Entities;

public enum WhatsAppConnectionStatus
{
    Disconnected,
    Connected,
    PendingVerification,
    Suspended
}

public enum ScheduledMessageStatus
{
    Pending,
    Processing,
    Sent,
    Cancelled,
    Failed
}

public class WhatsAppIntegration
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }

    [MaxLength(100)]
    public string WabaId { get; set; } = string.Empty; // WhatsApp Business Account ID

    [MaxLength(100)]
    public string PhoneNumberId { get; set; } = string.Empty;

    [MaxLength(50)]
    public string DisplayPhoneNumber { get; set; } = string.Empty; // e.g., +1 555-0199

    [MaxLength(150)]
    public string BusinessPortfolioName { get; set; } = string.Empty;

    [MaxLength(500)]
    public string AccessToken { get; set; } = string.Empty; // Meta System User Access Token

    [MaxLength(100)]
    public string WebhookVerifyToken { get; set; } = "GIMXSOFT_WHATSAPP_WEBHOOK_VERIFY_TOKEN";

    public WhatsAppConnectionStatus ConnectionStatus { get; set; } = WhatsAppConnectionStatus.Connected;

    public string HealthStatus { get; set; } = "HEALTHY"; // HEALTHY, WARNING, DEGRADED

    [Column(TypeName = "decimal(18,4)")]
    public decimal CostPerUtilityMessage { get; set; } = 0.0050m;

    [Column(TypeName = "decimal(18,4)")]
    public decimal CostPerMarketingMessage { get; set; } = 0.0250m;

    [MaxLength(50)]
    public string TimeZoneId { get; set; } = "Asia/Kolkata"; // Default timezone for scheduled deliveries

    public DateTime? LastSyncedAt { get; set; } = DateTime.UtcNow;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    public Tenant? Tenant { get; set; }
}

public class WhatsAppConsent
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid MemberId { get; set; }

    [Required]
    [MaxLength(25)]
    public string Phone { get; set; } = string.Empty;

    public bool HasConsented { get; set; } = true;

    [MaxLength(100)]
    public string ConsentSource { get; set; } = "Onboarding Registration Form";

    public DateTime ConsentedAt { get; set; } = DateTime.UtcNow;
    public DateTime? RevokedAt { get; set; }

    [MaxLength(250)]
    public string AllowedCategoriesJson { get; set; } = "[\"UTILITY\",\"MARKETING\",\"AUTHENTICATION\"]";

    public Tenant? Tenant { get; set; }
    public Member? Member { get; set; }
}

public class WhatsAppSuppression
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }

    [Required]
    [MaxLength(25)]
    public string Phone { get; set; } = string.Empty;

    [MaxLength(150)]
    public string Reason { get; set; } = "User opted out with STOP keyword";

    public DateTime SuppressedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
}

public class ScheduledMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid? MemberId { get; set; }

    [Required]
    [MaxLength(25)]
    public string RecipientPhone { get; set; } = string.Empty;

    [MaxLength(100)]
    public string RecipientName { get; set; } = string.Empty;

    [MaxLength(100)]
    public string? TemplateName { get; set; }

    [Required]
    public string MessageContent { get; set; } = string.Empty;

    public DateTime ScheduledForUtc { get; set; }
    public ScheduledMessageStatus Status { get; set; } = ScheduledMessageStatus.Pending;

    [MaxLength(50)]
    public string TriggerType { get; set; } = "DailyWorkout"; // DailyWorkout, ExpiryReminder, Onboarding, Birthday, PaymentDue

    public Guid? AutomationRuleId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ProcessedAt { get; set; }
    public string? FailureReason { get; set; }

    public Tenant? Tenant { get; set; }
    public Member? Member { get; set; }
}

