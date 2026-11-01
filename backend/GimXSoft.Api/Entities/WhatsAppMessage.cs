namespace GimXSoft.Api.Entities;

public enum WhatsAppDirection
{
    Outbound,
    Inbound
}

public enum WhatsAppMessageType
{
    Text,
    Template,
    Interactive,
    Media
}

public enum WhatsAppMessageStatus
{
    Queued,
    Sent,
    Delivered,
    Read,
    Failed
}

public class WhatsAppMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public Guid? MemberId { get; set; }

    public string RecipientPhone { get; set; } = string.Empty;
    public string RecipientName { get; set; } = string.Empty;

    public WhatsAppDirection Direction { get; set; } = WhatsAppDirection.Outbound;
    public WhatsAppMessageType MessageType { get; set; } = WhatsAppMessageType.Text;
    public WhatsAppMessageStatus Status { get; set; } = WhatsAppMessageStatus.Sent;

    public string? TemplateName { get; set; }
    public string MessageContent { get; set; } = string.Empty;
    public string? MediaUrl { get; set; }
    public string? WamId { get; set; } // Meta WhatsApp Message ID
    public string? FailureReason { get; set; }

    public DateTime SentAt { get; set; } = DateTime.UtcNow;
    public DateTime? DeliveredAt { get; set; }
    public DateTime? ReadAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public Tenant? Tenant { get; set; }
    public Branch? Branch { get; set; }
    public Member? Member { get; set; }
}

public class WhatsAppTemplate
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }

    public string Name { get; set; } = string.Empty;
    public string Category { get; set; } = "UTILITY"; // UTILITY, MARKETING, AUTHENTICATION
    public string Language { get; set; } = "en_US";
    public string? Header { get; set; }
    public string Body { get; set; } = string.Empty;
    public string? Footer { get; set; }
    public string MetaStatus { get; set; } = "APPROVED"; // APPROVED, PENDING, REJECTED
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
}

public class WhatsAppTriggerRule
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public string TriggerEvent { get; set; } = string.Empty; // OnPaymentCompleted, OnMembershipExpiring, OnMemberJoined, OnInactivity
    public string TemplateName { get; set; } = string.Empty;
    public bool IsEnabled { get; set; } = true;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
}

