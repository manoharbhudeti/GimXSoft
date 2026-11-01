using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GimXSoft.Api.Entities;

public enum AttendanceMethod
{
    Manual,
    QR,
    Kiosk
}

public class AttendanceRecord
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public Guid MemberId { get; set; }

    public DateTime CheckInTime { get; set; } = DateTime.UtcNow;
    public DateTime? CheckOutTime { get; set; }

    public AttendanceMethod Method { get; set; } = AttendanceMethod.Manual;

    [MaxLength(200)]
    public string? Notes { get; set; }

    // Navigation properties
    public Tenant? Tenant { get; set; }
    public Branch? Branch { get; set; }
    public Member? Member { get; set; }
}

public enum PaymentMethod
{
    Cash,
    UPI,
    Card,
    BankTransfer,
    Online
}

public enum PaymentStatus
{
    Completed,
    Refunded,
    Pending,
    Failed
}

public class PaymentTransaction
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public Guid MemberId { get; set; }
    public Guid? SubscriptionId { get; set; }

    [Required]
    [MaxLength(50)]
    public string InvoiceNumber { get; set; } = string.Empty; // e.g. INV-2026-0001

    [Column(TypeName = "decimal(18,2)")]
    public decimal Amount { get; set; }

    public PaymentMethod PaymentMethod { get; set; } = PaymentMethod.Cash;
    public PaymentStatus Status { get; set; } = PaymentStatus.Completed;

    [MaxLength(100)]
    public string? TransactionReference { get; set; }

    [MaxLength(500)]
    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public Tenant? Tenant { get; set; }
    public Branch? Branch { get; set; }
    public Member? Member { get; set; }
    public MemberSubscription? Subscription { get; set; }
}

