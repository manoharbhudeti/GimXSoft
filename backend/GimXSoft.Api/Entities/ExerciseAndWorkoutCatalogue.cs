using System.ComponentModel.DataAnnotations;

namespace GimXSoft.Api.Entities;

public enum FitnessLevel
{
    Beginner,
    Intermediate,
    Advanced,
    Custom
}

public class ExerciseCategory
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty; // Strength, Cardio, Flexibility, Mobility, Core, Functional, Bodyweight

    [MaxLength(250)]
    public string Description { get; set; } = string.Empty;

    [MaxLength(50)]
    public string IconName { get; set; } = "dumbbell";

    public Tenant? Tenant { get; set; }
}

public class Exercise
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }

    [Required]
    [MaxLength(120)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string Description { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string Category { get; set; } = "Strength"; // Strength, Cardio, Core, Mobility, Functional

    [Required]
    [MaxLength(50)]
    public string TargetMuscle { get; set; } = "Chest"; // Chest, Back, Legs, Shoulders, Arms, Core, Full Body

    [MaxLength(250)]
    public string SecondaryMusclesJson { get; set; } = "[]"; // e.g. ["Triceps", "Anterior Deltoid"]

    [MaxLength(50)]
    public string Equipment { get; set; } = "Barbell"; // Barbell, Dumbbell, Machine, Cable, Bodyweight, Kettlebell

    public FitnessLevel DifficultyLevel { get; set; } = FitnessLevel.Beginner;

    [MaxLength(2000)]
    public string Instructions { get; set; } = string.Empty;

    public int DefaultSets { get; set; } = 3;

    [MaxLength(30)]
    public string DefaultReps { get; set; } = "10-12";

    public int DefaultRestSeconds { get; set; } = 60;
    public int? DurationSeconds { get; set; }

    [MaxLength(500)]
    public string? DemoImageUrl { get; set; }

    [MaxLength(500)]
    public string? DemoVideoUrl { get; set; }

    [MaxLength(500)]
    public string? SafetyNotes { get; set; }

    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
}

public class WorkoutTemplate
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }

    [Required]
    [MaxLength(150)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(500)]
    public string Description { get; set; } = string.Empty;

    [MaxLength(50)]
    public string Goal { get; set; } = "Muscle Building"; // Muscle Building, Fat Loss, Endurance, Mobility

    public FitnessLevel Level { get; set; } = FitnessLevel.Intermediate;
    public int DaysPerWeek { get; set; } = 4;
    public int EstimatedMinutesPerSession { get; set; } = 45;

    // JSON structure with weekly routine:
    // [
    //   { "day": "Monday", "routineTitle": "Chest & Triceps Hypertrophy", "exercises": [...] },
    //   { "day": "Tuesday", "routineTitle": "Back & Biceps Pull", "exercises": [...] }
    // ]
    public string RoutineJson { get; set; } = "[]";

    public Guid? CreatedByUserId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
    public User? CreatedByUser { get; set; }
}

public class MemberWorkoutSchedule
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid MemberId { get; set; }
    public Guid? WorkoutTemplateId { get; set; }
    public Guid? AssignedTrainerId { get; set; }

    [Required]
    [MaxLength(20)]
    public string DayOfWeek { get; set; } = "Monday"; // Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday

    [MaxLength(10)]
    public string ScheduledDeliveryTime { get; set; } = "07:00"; // Local gym time (e.g. 07:00 AM)

    [MaxLength(100)]
    public string RoutineTitle { get; set; } = "Full Body Circuit";

    // Structured JSON exercises for this specific delivery day
    public string ExercisesJson { get; set; } = "[]";

    public bool IsRestDay { get; set; } = false;
    public bool TrainerApproved { get; set; } = true;
    public bool IsActive { get; set; } = true;

    [MaxLength(500)]
    public string? TrainerNotes { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
    public Member? Member { get; set; }
    public WorkoutTemplate? WorkoutTemplate { get; set; }
    public User? AssignedTrainer { get; set; }
}

public class WorkoutCompletion
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }
    public Guid MemberId { get; set; }
    public Guid? ScheduleId { get; set; }

    public DateTime ScheduledDate { get; set; } = DateTime.UtcNow.Date;
    public DateTime CompletedAt { get; set; } = DateTime.UtcNow;

    public int DurationMinutes { get; set; } = 45;
    public int PerceivedDifficulty { get; set; } = 7; // 1-10 RPE

    [MaxLength(500)]
    public string? MemberFeedback { get; set; }

    public Tenant? Tenant { get; set; }
    public Member? Member { get; set; }
}
