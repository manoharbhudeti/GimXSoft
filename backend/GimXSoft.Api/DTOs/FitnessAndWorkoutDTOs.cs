using GimXSoft.Api.Entities;

namespace GimXSoft.Api.DTOs;

// --- Exercises & Categories ---
public record ExerciseDto(
    Guid Id,
    Guid TenantId,
    string Name,
    string Description,
    string Category,
    string TargetMuscle,
    string SecondaryMusclesJson,
    string Equipment,
    string DifficultyLevel,
    string Instructions,
    int DefaultSets,
    string DefaultReps,
    int DefaultRestSeconds,
    int? DurationSeconds,
    string? DemoImageUrl,
    string? DemoVideoUrl,
    string? SafetyNotes,
    bool IsActive,
    DateTime CreatedAt
);

public record CreateExerciseRequest(
    string Name,
    string Description,
    string Category,
    string TargetMuscle,
    string? SecondaryMusclesJson,
    string Equipment,
    string DifficultyLevel,
    string Instructions,
    int DefaultSets,
    string DefaultReps,
    int DefaultRestSeconds,
    int? DurationSeconds,
    string? DemoImageUrl,
    string? DemoVideoUrl,
    string? SafetyNotes
);

public record ExerciseCategoryDto(
    Guid Id,
    string Name,
    string Description,
    string IconName
);

// --- Workout Templates & Routines ---
public record WorkoutTemplateDto(
    Guid Id,
    Guid TenantId,
    string Title,
    string Description,
    string Goal,
    string Level,
    int DaysPerWeek,
    int EstimatedMinutesPerSession,
    string RoutineJson,
    Guid? CreatedByUserId,
    DateTime CreatedAt
);

public record CreateWorkoutTemplateRequest(
    string Title,
    string Description,
    string Goal,
    string Level,
    int DaysPerWeek,
    int EstimatedMinutesPerSession,
    string RoutineJson
);

// --- Member Workout Schedules & Delivery ---
public record MemberWorkoutScheduleDto(
    Guid Id,
    Guid MemberId,
    string MemberName,
    Guid? WorkoutTemplateId,
    string? TemplateTitle,
    Guid? AssignedTrainerId,
    string? TrainerName,
    string DayOfWeek,
    string ScheduledDeliveryTime,
    string RoutineTitle,
    string ExercisesJson,
    bool IsRestDay,
    bool TrainerApproved,
    bool IsActive,
    string? TrainerNotes,
    DateTime UpdatedAt
);

public record AssignWorkoutScheduleRequest(
    Guid MemberId,
    Guid? WorkoutTemplateId,
    Guid? AssignedTrainerId,
    string DayOfWeek,
    string ScheduledDeliveryTime,
    string RoutineTitle,
    string ExercisesJson,
    bool IsRestDay,
    bool TrainerApproved,
    string? TrainerNotes
);

public record LogWorkoutCompletionRequest(
    Guid MemberId,
    Guid? ScheduleId,
    DateTime ScheduledDate,
    int DurationMinutes,
    int PerceivedDifficulty,
    string? MemberFeedback
);

// --- Body Measurements & Fitness Profiles ---
public record MemberMeasurementDto(
    Guid Id,
    Guid MemberId,
    string MemberName,
    decimal WeightKg,
    decimal HeightCm,
    decimal CalculatedBmi,
    decimal? WaistCm,
    decimal? ChestCm,
    decimal? HipCm,
    decimal? LeftArmCm,
    decimal? RightArmCm,
    decimal? LeftThighCm,
    decimal? RightThighCm,
    decimal? BodyFatPercentage,
    string InputUnitSystem,
    DateTime MeasurementDate,
    Guid? RecordedByUserId,
    string? RecordedByUserName,
    string? Notes,
    decimal? WeightDifferenceKg,
    decimal? WeightChangePercent,
    DateTime CreatedAt
);

public record RecordMeasurementRequest(
    Guid MemberId,
    decimal WeightKg,
    decimal HeightCm,
    decimal? WaistCm,
    decimal? ChestCm,
    decimal? HipCm,
    decimal? LeftArmCm,
    decimal? RightArmCm,
    decimal? LeftThighCm,
    decimal? RightThighCm,
    decimal? BodyFatPercentage,
    string UnitSystem,
    DateTime? MeasurementDate,
    string? Notes
);

public record MemberFitnessBaselineDto(
    Guid Id,
    Guid MemberId,
    string MemberName,
    decimal InitialWeightKg,
    decimal HeightCm,
    decimal InitialBmi,
    DateTime InitialMeasurementDate,
    string FitnessGoal,
    string FitnessLevel,
    int TrainingFrequencyDaysPerWeek,
    string? MedicalAndDietNotes
);

public record CreateOrUpdateBaselineRequest(
    Guid MemberId,
    decimal InitialWeightKg,
    decimal HeightCm,
    string FitnessGoal,
    string FitnessLevel,
    int TrainingFrequencyDaysPerWeek,
    string? MedicalAndDietNotes
);

public record FitnessProgressCardDto(
    Guid MemberId,
    string MemberName,
    string MemberCode,
    string? AvatarUrl,
    string FitnessGoal,
    string FitnessLevel,
    decimal BaselineWeightKg,
    decimal CurrentWeightKg,
    decimal TotalWeightChangeKg,
    decimal WeightChangePercentage,
    decimal CurrentBmi,
    string BmiCategory,
    DateTime? LastMeasurementDate,
    List<WeightDataPoint> WeightHistory,
    List<MeasurementHistoryPoint> MeasurementTrends,
    bool HasOverdueReview
);

public record WeightDataPoint(
    DateTime Date,
    decimal WeightKg,
    decimal Bmi
);

public record MeasurementHistoryPoint(
    DateTime Date,
    decimal? WaistCm,
    decimal? ChestCm,
    decimal? HipCm,
    decimal? BodyFatPercentage
);

// --- Onboarding & Journey Timelines ---
public record MemberOnboardingJourneyDto(
    Guid Id,
    Guid MemberId,
    string MemberName,
    bool RegistrationCompleted,
    DateTime? RegistrationCompletedAt,
    bool ConsentCollected,
    DateTime? ConsentCollectedAt,
    bool WelcomeSent,
    DateTime? WelcomeSentAt,
    bool AssessmentCompleted,
    DateTime? AssessmentCompletedAt,
    bool InitialMeasurementDone,
    DateTime? InitialMeasurementDoneAt,
    bool TrainerAssigned,
    DateTime? TrainerAssignedAt,
    bool WorkoutPlanAssigned,
    DateTime? WorkoutPlanAssignedAt,
    bool FirstWorkoutDelivered,
    DateTime? FirstWorkoutDeliveredAt,
    bool FirstWeekReviewDone,
    DateTime? FirstWeekReviewDoneAt,
    string? Notes,
    DateTime UpdatedAt
);

public record UpdateOnboardingStageRequest(
    Guid MemberId,
    string StageName, // e.g. "AssessmentCompleted", "InitialMeasurementDone", etc.
    bool IsCompleted,
    string? Notes
);

public record MemberProgressReviewDto(
    Guid Id,
    Guid MemberId,
    string MemberName,
    Guid? TrainerId,
    string? TrainerName,
    DateTime ReviewDate,
    decimal BaselineWeightKg,
    decimal CurrentWeightKg,
    decimal WeightChangeKg,
    decimal WeightChangePercent,
    string StrengthsNotes,
    string AreasForImprovement,
    string NextMilestoneGoal
);

public record CreateProgressReviewRequest(
    Guid MemberId,
    Guid? TrainerId,
    DateTime? ReviewDate,
    decimal CurrentWeightKg,
    string StrengthsNotes,
    string AreasForImprovement,
    string NextMilestoneGoal
);
