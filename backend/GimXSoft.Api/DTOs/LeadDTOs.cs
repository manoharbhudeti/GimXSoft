using System.ComponentModel.DataAnnotations;
using GimXSoft.Api.Entities;

namespace GimXSoft.Api.DTOs;

public record LeadDto(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    string? BranchName,
    string FullName,
    string Email,
    string Phone,
    string Source,
    string Stage,
    Guid? AssignedStaffId,
    string? AssignedStaffName,
    string? Notes,
    DateTime? NextFollowUpDate,
    decimal EstimatedValue,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);

public record CreateLeadRequest(
    Guid BranchId,
    [Required] string FullName,
    string? Email,
    [Required] string Phone,
    LeadSource Source,
    Guid? AssignedStaffId,
    string? Notes,
    DateTime? NextFollowUpDate,
    decimal EstimatedValue
);

public record UpdateLeadRequest(
    Guid BranchId,
    [Required] string FullName,
    string? Email,
    [Required] string Phone,
    LeadSource Source,
    LeadStage Stage,
    Guid? AssignedStaffId,
    string? Notes,
    DateTime? NextFollowUpDate,
    decimal EstimatedValue
);

public record UpdateLeadStageRequest(
    [Required] LeadStage Stage,
    string? Note
);

public record AddLeadActivityRequest(
    [Required] string ActivityType,
    [Required] string Description
);

public record LeadActivityDto(
    Guid Id,
    Guid LeadId,
    Guid? StaffId,
    string? StaffName,
    string ActivityType,
    string Description,
    DateTime CreatedAt
);

