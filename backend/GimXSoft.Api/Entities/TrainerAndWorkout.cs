using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GimXSoft.Api.Entities;

public class TrainerProfile
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid UserId { get; set; }

    [MaxLength(1000)]
    public string Bio { get; set; } = string.Empty;

    [MaxLength(500)]
    public string SpecializationsJson { get; set; } = "[]"; // e.g. ["Strength Training", "HIIT", "Rehab"]

    [MaxLength(500)]
    public string CertificationsJson { get; set; } = "[]"; // e.g. ["ACE Certified", "CSCS"]

    [Column(TypeName = "decimal(18,2)")]
    public decimal HourlyRate { get; set; } = 0.00m;

    public bool IsActive { get; set; } = true;

    // Navigation properties
    public Tenant? Tenant { get; set; }
    public User? User { get; set; }
    public ICollection<TrainerSession> Sessions { get; set; } = new List<TrainerSession>();
}

public enum SessionStatus
{
    Scheduled,
    Completed,
    Cancelled
}

public class TrainerSession
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public Guid TrainerId { get; set; }
    public Guid MemberId { get; set; }

    public DateTime SessionDate { get; set; }
    public int DurationMinutes { get; set; } = 60;

    public SessionStatus Status { get; set; } = SessionStatus.Scheduled;

    [MaxLength(500)]
    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
    public Branch? Branch { get; set; }
    public TrainerProfile? Trainer { get; set; }
    public Member? Member { get; set; }
}

public class WorkoutPlan
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid MemberId { get; set; }
    public Guid? TrainerId { get; set; }

    [Required]
    [MaxLength(100)]
    public string Title { get; set; } = string.Empty; // e.g., "Hypertrophy 4-Day Split"

    [MaxLength(100)]
    public string Goal { get; set; } = string.Empty; // e.g., "Muscle Building", "Fat Loss"

    public DateTime StartDate { get; set; } = DateTime.UtcNow.Date;
    public DateTime? EndDate { get; set; }

    [MaxLength(1000)]
    public string? Notes { get; set; }

    // JSON encoded exercises: [{ "day": "Day 1 - Chest & Triceps", "exercises": [{"name": "Barbell Bench Press", "sets": 4, "reps": "8-10", "rest": "90s"}]}]
    public string ExercisesJson { get; set; } = "[]";

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
    public Member? Member { get; set; }
    public User? Trainer { get; set; }
}

public class AuditLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid? UserId { get; set; }

    [Required]
    [MaxLength(50)]
    public string Action { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string EntityName { get; set; } = string.Empty;

    [MaxLength(100)]
    public string EntityId { get; set; } = string.Empty;

    [MaxLength(2000)]
    public string Details { get; set; } = string.Empty;

    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}

