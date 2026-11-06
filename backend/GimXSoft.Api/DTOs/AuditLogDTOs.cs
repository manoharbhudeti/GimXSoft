using System.ComponentModel.DataAnnotations;

namespace GimXSoft.Api.DTOs;

public record AuditLogDto(
    Guid Id,
    Guid TenantId,
    Guid? UserId,
    string? UserEmail,
    string? UserName,
    string Action,
    string EntityName,
    string EntityId,
    string Details,
    DateTime Timestamp
);

public record CreateAuditLogRequest(
    [Required] string Action,
    [Required] string EntityName,
    [Required] string EntityId,
    [Required] string Details
);

