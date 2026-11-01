using System.ComponentModel.DataAnnotations;
using GimXSoft.Api.Entities;

namespace GimXSoft.Api.DTOs;

public record MemberDto(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    string? BranchName,
    string MemberCode,
    string FirstName,
    string LastName,
    string FullName,
    string Email,
    string Phone,
    string? Gender,
    DateTime? DateOfBirth,
    string Address,
    string EmergencyContactName,
    string EmergencyContactPhone,
    DateTime JoiningDate,
    Guid? AssignedTrainerId,
    string? AssignedTrainerName,
    string Status,
    string? MedicalNotes,
    string? AvatarUrl,
    string? CurrentPlanName,
    DateTime? PlanExpiryDate,
    DateTime CreatedAt
);

public record CreateMemberRequest(
    Guid BranchId,
    [Required] string FirstName,
    [Required] string LastName,
    [Required, EmailAddress] string Email,
    [Required] string Phone,
    string? Gender,
    DateTime? DateOfBirth,
    string? Address,
    string? EmergencyContactName,
    string? EmergencyContactPhone,
    DateTime? JoiningDate,
    Guid? AssignedTrainerId,
    Guid? InitialPlanId,
    string? MedicalNotes
);

public record UpdateMemberRequest(
    Guid BranchId,
    [Required] string FirstName,
    [Required] string LastName,
    [Required, EmailAddress] string Email,
    [Required] string Phone,
    string? Gender,
    DateTime? DateOfBirth,
    string? Address,
    string? EmergencyContactName,
    string? EmergencyContactPhone,
    Guid? AssignedTrainerId,
    MemberStatus Status,
    string? MedicalNotes
);

public record MemberDetailDto(
    MemberDto Member,
    List<MemberSubscriptionDto> Subscriptions,
    List<AttendanceRecordDto> RecentAttendance,
    List<PaymentTransactionDto> RecentPayments,
    List<WorkoutPlanDto> WorkoutPlans
);

