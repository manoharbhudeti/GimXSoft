using System.ComponentModel.DataAnnotations;

namespace GimXSoft.Api.Entities;

public enum MemberStatus
{
    Active,
    Inactive,
    Expired,
    Frozen
}

public class Member
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }

    [Required]
    [MaxLength(30)]
    public string MemberCode { get; set; } = string.Empty; // e.g., GIX-1001

    [Required]
    [MaxLength(50)]
    public string FirstName { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string LastName { get; set; } = string.Empty;

    public string FullName => $"{FirstName} {LastName}".Trim();

    [Required]
    [EmailAddress]
    [MaxLength(150)]
    public string Email { get; set; } = string.Empty;

    [Required]
    [MaxLength(20)]
    public string Phone { get; set; } = string.Empty;

    [MaxLength(10)]
    public string? Gender { get; set; } // Male, Female, Other

    public DateTime? DateOfBirth { get; set; }

    [MaxLength(250)]
    public string Address { get; set; } = string.Empty;

    [MaxLength(100)]
    public string EmergencyContactName { get; set; } = string.Empty;

    [MaxLength(20)]
    public string EmergencyContactPhone { get; set; } = string.Empty;

    public DateTime JoiningDate { get; set; } = DateTime.UtcNow.Date;

    public Guid? AssignedTrainerId { get; set; }

    public MemberStatus Status { get; set; } = MemberStatus.Active;

    [MaxLength(1000)]
    public string? MedicalNotes { get; set; }

    [MaxLength(255)]
    public string? AvatarUrl { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    // Navigation properties
    public Tenant? Tenant { get; set; }
    public Branch? Branch { get; set; }
    public User? AssignedTrainer { get; set; }
    public ICollection<MemberSubscription> Subscriptions { get; set; } = new List<MemberSubscription>();
    public ICollection<AttendanceRecord> AttendanceRecords { get; set; } = new List<AttendanceRecord>();
    public ICollection<PaymentTransaction> PaymentTransactions { get; set; } = new List<PaymentTransaction>();
    public ICollection<WorkoutPlan> WorkoutPlans { get; set; } = new List<WorkoutPlan>();
}

