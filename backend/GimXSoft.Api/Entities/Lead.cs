using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GimXSoft.Api.Entities;

public enum LeadSource
{
    Website,
    WalkIn,
    Phone,
    Referral,
    SocialMedia,
    Advertisement,
    Other
}

public enum LeadStage
{
    New,
    Contacted,
    Interested,
    TrialScheduled,
    TrialCompleted,
    Converted,
    Lost
}

public class Lead
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }

    [Required]
    [MaxLength(100)]
    public string FullName { get; set; } = string.Empty;

    [MaxLength(150)]
    public string Email { get; set; } = string.Empty;

    [Required]
    [MaxLength(20)]
    public string Phone { get; set; } = string.Empty;

    public LeadSource Source { get; set; } = LeadSource.WalkIn;
    public LeadStage Stage { get; set; } = LeadStage.New;

    public Guid? AssignedStaffId { get; set; }

    [MaxLength(1000)]
    public string? Notes { get; set; }

    public DateTime? NextFollowUpDate { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal EstimatedValue { get; set; } = 0.00m;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    // Navigation properties
    public Tenant? Tenant { get; set; }
    public Branch? Branch { get; set; }
    public User? AssignedStaff { get; set; }
    public ICollection<LeadActivity> Activities { get; set; } = new List<LeadActivity>();
}

public class LeadActivity
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid LeadId { get; set; }
    public Guid? StaffId { get; set; }

    [Required]
    [MaxLength(50)]
    public string ActivityType { get; set; } = "Note"; // Note, Call, Email, Meeting, StageChange

    [Required]
    [MaxLength(500)]
    public string Description { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Lead? Lead { get; set; }
    public User? Staff { get; set; }
}

