using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GimXSoft.Api.Entities;

public enum UnitSystem
{
    Metric,   // kg, cm
    Imperial  // lbs, inches
}

public class MemberMeasurement
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid MemberId { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal WeightKg { get; set; } // Stored in normalized metric kg

    [Column(TypeName = "decimal(6,2)")]
    public decimal HeightCm { get; set; } // Stored in normalized metric cm

    [Column(TypeName = "decimal(5,2)")]
    public decimal CalculatedBmi { get; set; } // BMI = WeightKg / ((HeightCm/100)^2)

    [Column(TypeName = "decimal(6,2)")]
    public decimal? WaistCm { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal? ChestCm { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal? HipCm { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal? LeftArmCm { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal? RightArmCm { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal? LeftThighCm { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal? RightThighCm { get; set; }

    [Column(TypeName = "decimal(5,2)")]
    public decimal? BodyFatPercentage { get; set; }

    public UnitSystem InputUnitSystem { get; set; } = UnitSystem.Metric;

    public DateTime MeasurementDate { get; set; } = DateTime.UtcNow.Date;

    public Guid? RecordedByUserId { get; set; }

    [MaxLength(500)]
    public string? Notes { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal? WeightDifferenceKg { get; set; } // Difference from baseline

    [Column(TypeName = "decimal(5,2)")]
    public decimal? WeightChangePercent { get; set; } // Percentage change from baseline

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
    public Member? Member { get; set; }
    public User? RecordedByUser { get; set; }
}

public class MemberFitnessBaseline
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid MemberId { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal InitialWeightKg { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal HeightCm { get; set; }

    [Column(TypeName = "decimal(5,2)")]
    public decimal InitialBmi { get; set; }

    public DateTime InitialMeasurementDate { get; set; } = DateTime.UtcNow.Date;

    [MaxLength(100)]
    public string FitnessGoal { get; set; } = "Weight Loss & Conditioning"; // Muscle Building, Fat Loss, Endurance, General Fitness

    public FitnessLevel FitnessLevel { get; set; } = FitnessLevel.Beginner;

    public int TrainingFrequencyDaysPerWeek { get; set; } = 4;

    [MaxLength(500)]
    public string? MedicalAndDietNotes { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
    public Member? Member { get; set; }
}

public class MemberOnboardingJourney
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid MemberId { get; set; }

    public bool RegistrationCompleted { get; set; } = true;
    public DateTime? RegistrationCompletedAt { get; set; } = DateTime.UtcNow;

    public bool ConsentCollected { get; set; } = true;
    public DateTime? ConsentCollectedAt { get; set; } = DateTime.UtcNow;

    public bool WelcomeSent { get; set; } = true;
    public DateTime? WelcomeSentAt { get; set; } = DateTime.UtcNow;

    public bool AssessmentCompleted { get; set; } = false;
    public DateTime? AssessmentCompletedAt { get; set; }

    public bool InitialMeasurementDone { get; set; } = false;
    public DateTime? InitialMeasurementDoneAt { get; set; }

    public bool TrainerAssigned { get; set; } = false;
    public DateTime? TrainerAssignedAt { get; set; }

    public bool WorkoutPlanAssigned { get; set; } = false;
    public DateTime? WorkoutPlanAssignedAt { get; set; }

    public bool FirstWorkoutDelivered { get; set; } = false;
    public DateTime? FirstWorkoutDeliveredAt { get; set; }

    public bool FirstWeekReviewDone { get; set; } = false;
    public DateTime? FirstWeekReviewDoneAt { get; set; }

    [MaxLength(500)]
    public string? Notes { get; set; }

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
    public Member? Member { get; set; }
}

public class MemberProgressReview
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid MemberId { get; set; }
    public Guid? TrainerId { get; set; }

    public DateTime ReviewDate { get; set; } = DateTime.UtcNow.Date;

    [Column(TypeName = "decimal(6,2)")]
    public decimal BaselineWeightKg { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal CurrentWeightKg { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal WeightChangeKg { get; set; }

    [Column(TypeName = "decimal(5,2)")]
    public decimal WeightChangePercent { get; set; }

    [MaxLength(1000)]
    public string StrengthsNotes { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string AreasForImprovement { get; set; } = string.Empty;

    [MaxLength(500)]
    public string NextMilestoneGoal { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
    public Member? Member { get; set; }
    public User? Trainer { get; set; }
}
