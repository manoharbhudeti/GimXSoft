using GimXSoft.Api.Data;
using GimXSoft.Api.DTOs;
using GimXSoft.Api.Entities;
using GimXSoft.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GimXSoft.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AuditLogsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public AuditLogsController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet]
    public async Task<ActionResult<List<AuditLogDto>>> GetAuditLogs(
        [FromQuery] string? action,
        [FromQuery] string? entityName,
        [FromQuery] Guid? userId,
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        var query = _context.AuditLogs.AsQueryable();

        if (!string.IsNullOrWhiteSpace(action)) query = query.Where(a => a.Action.ToLower() == action.ToLower().Trim());
        if (!string.IsNullOrWhiteSpace(entityName)) query = query.Where(a => a.EntityName.ToLower() == entityName.ToLower().Trim());
        if (userId.HasValue) query = query.Where(a => a.UserId == userId.Value);
        if (from.HasValue) query = query.Where(a => a.Timestamp >= from.Value);
        if (to.HasValue) query = query.Where(a => a.Timestamp <= to.Value);

        var total = await query.CountAsync();
        Response?.Headers.Append("X-Total-Count", total.ToString());

        var logs = await query
            .OrderByDescending(a => a.Timestamp)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(a => new AuditLogDto(
                a.Id,
                a.TenantId,
                a.UserId,
                null,
                null,
                a.Action,
                a.EntityName,
                a.EntityId,
                a.Details,
                a.Timestamp
            ))
            .ToListAsync();

        return Ok(logs);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<AuditLogDto>> GetAuditLogById(Guid id)
    {
        var log = await _context.AuditLogs.FindAsync(id);
        if (log == null) return NotFound(new { message = "Audit log not found." });

        return Ok(new AuditLogDto(
            log.Id,
            log.TenantId,
            log.UserId,
            null,
            null,
            log.Action,
            log.EntityName,
            log.EntityId,
            log.Details,
            log.Timestamp
        ));
    }

    [HttpPost]
    public async Task<ActionResult<AuditLogDto>> CreateAuditLog([FromBody] CreateAuditLogRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();
        var userId = _tenantService.UserId;

        var log = new AuditLog
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            UserId = userId,
            Action = request.Action.Trim(),
            EntityName = request.EntityName.Trim(),
            EntityId = request.EntityId.Trim(),
            Details = request.Details.Trim(),
            Timestamp = DateTime.UtcNow
        };

        _context.AuditLogs.Add(log);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetAuditLogById), new { id = log.Id }, new AuditLogDto(
            log.Id,
            log.TenantId,
            log.UserId,
            null,
            null,
            log.Action,
            log.EntityName,
            log.EntityId,
            log.Details,
            log.Timestamp
        ));
    }
}
