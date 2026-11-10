using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GimXSoft.Api.Entities;

public enum WhatsAppCampaignStatus
{
    Draft,
    Scheduled,
    InProgress,
    Completed,
    Paused,
    Cancelled,
    Failed
}

public enum WhatsAppAudienceSegment
{
    AllActive,
    ExpiringIn7Days,
    ExpiringIn30Days,
    ExpiredIn30Days,
    NewMembersLast14Days,
    Inactive30Days,
    SpecificPlan,
    Custom
}

public class WhatsAppCampaign
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }

    [Required]
    [MaxLength(150)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Description { get; set; }

    public WhatsAppAudienceSegment AudienceSegment { get; set; } = WhatsAppAudienceSegment.AllActive;
    public Guid? SpecificPlanId { get; set; }

    [MaxLength(100)]
    public string? TemplateName { get; set; }

    [MaxLength(20)]
    public string TemplateLanguage { get; set; } = "en_US";

    [Required]
    public string MessageContent { get; set; } = string.Empty;

    public WhatsAppCampaignStatus Status { get; set; } = WhatsAppCampaignStatus.Draft;

    public DateTime? ScheduledAtUtc { get; set; }
    public DateTime? StartedAtUtc { get; set; }
    public DateTime? CompletedAtUtc { get; set; }

    public int TotalRecipients { get; set; }
    public int SentCount { get; set; }
    public int DeliveredCount { get; set; }
    public int ReadCount { get; set; }
    public int FailedCount { get; set; }

    public Guid? CreatedByUserId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    // Navigation properties
    public Tenant? Tenant { get; set; }
    public Branch? Branch { get; set; }
    public MembershipPlan? SpecificPlan { get; set; }
    public ICollection<WhatsAppCampaignRecipient> Recipients { get; set; } = new List<WhatsAppCampaignRecipient>();
}

public class WhatsAppCampaignRecipient
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid CampaignId { get; set; }
    public Guid? MemberId { get; set; }

    [Required]
    [MaxLength(25)]
    public string RecipientPhone { get; set; } = string.Empty;

    [MaxLength(100)]
    public string RecipientName { get; set; } = string.Empty;

    public WhatsAppMessageStatus Status { get; set; } = WhatsAppMessageStatus.Queued;

    [MaxLength(100)]
    public string? WamId { get; set; } // Meta WhatsApp Message ID

    public DateTime? SentAt { get; set; }
    public DateTime? DeliveredAt { get; set; }
    public DateTime? ReadAt { get; set; }
    public string? FailureReason { get; set; }

    // Navigation properties
    public Tenant? Tenant { get; set; }
    public WhatsAppCampaign? Campaign { get; set; }
    public Member? Member { get; set; }
}

public class WhatsAppWebhookLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid? TenantId { get; set; }

    [Required]
    [MaxLength(150)]
    public string EventId { get; set; } = string.Empty; // Unique Meta Event ID / Message ID / Status ID for idempotency

    [Required]
    [MaxLength(50)]
    public string EventType { get; set; } = "messages"; // messages, statuses, template_status

    public string PayloadJson { get; set; } = string.Empty;
    public bool ProcessedSuccessfully { get; set; } = true;

    [MaxLength(500)]
    public string? ErrorMessage { get; set; }

    public DateTime ReceivedAt { get; set; } = DateTime.UtcNow;
}

