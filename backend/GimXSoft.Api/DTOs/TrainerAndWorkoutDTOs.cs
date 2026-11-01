using System.ComponentModel.DataAnnotations;
using GimXSoft.Api.Entities;

namespace GimXSoft.Api.DTOs;

public record TrainerDto(
    Guid Id,
    Guid TenantId,
    Guid UserId,
    string FullName,
    string Email,
    string Phone,
    string? AvatarUrl,
    string Bio,
    string SpecializationsJson,
    string CertificationsJson,
    decimal HourlyRate,
    bool IsActive,
    int AssignedMembersCount,
    int TotalSessionsConducted
);

public record CreateTrainerRequest(
    [Required] string FullName,
    [Required, EmailAddress] string Email,
    [Required, MinLength(6)] string Password,
    [Required] string Phone,
    Guid? BranchId,
    string? Bio,
    string? SpecializationsJson,
    string? CertificationsJson,
    decimal HourlyRate
);

public record TrainerSessionDto(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid TrainerId,
    string TrainerName,
    Guid MemberId,
    string MemberName,
    DateTime SessionDate,
    int DurationMinutes,
    string Status,
    string? Notes,
    DateTime CreatedAt
);

public record BookSessionRequest(
    Guid BranchId,
    Guid TrainerId,
    Guid MemberId,
    DateTime SessionDate,
    int DurationMinutes = 60,
    string? Notes = null
);

public record WorkoutPlanDto(
    Guid Id,
    Guid TenantId,
    Guid MemberId,
    string MemberName,
    Guid? TrainerId,
    string? TrainerName,
    string Title,
    string Goal,
    DateTime StartDate,
    DateTime? EndDate,
    string? Notes,
    string ExercisesJson,
    DateTime CreatedAt
);

public record CreateWorkoutPlanRequest(
    Guid MemberId,
    Guid? TrainerId,
    [Required] string Title,
    string? Goal,
    DateTime? StartDate,
    DateTime? EndDate,
    string? Notes,
    string ExercisesJson
);

