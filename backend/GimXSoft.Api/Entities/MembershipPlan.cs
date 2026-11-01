using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GimXSoft.Api.Entities;

public enum SubscriptionStatus
{
    Active,
    Expired,
    Frozen,
    Cancelled
}

public class MembershipPlan
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(500)]
    public string Description { get; set; } = string.Empty;

    public int DurationDays { get; set; } = 30; // 30, 90, 180, 365, etc.

    [Column(TypeName = "decimal(18,2)")]
    public decimal Price { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal RegistrationFee { get; set; } = 0.00m;

    [MaxLength(1000)]
    public string BenefitsJson { get; set; } = "[]"; // e.g. ["Full gym access", "Locker room", "Free assessment"]

    public bool IsPersonalTraining { get; set; } = false;
    public int IncludedSessions { get; set; } = 0;

    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
    public ICollection<MemberSubscription> Subscriptions { get; set; } = new List<MemberSubscription>();
}

public class MemberSubscription
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid MemberId { get; set; }
    public Guid MembershipPlanId { get; set; }

    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal PricePaid { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal DiscountAmount { get; set; } = 0.00m;

    public SubscriptionStatus Status { get; set; } = SubscriptionStatus.Active;

    public DateTime? FreezeStartDate { get; set; }
    public DateTime? FreezeEndDate { get; set; }

    [MaxLength(200)]
    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public Tenant? Tenant { get; set; }
    public Member? Member { get; set; }
    public MembershipPlan? MembershipPlan { get; set; }
}

