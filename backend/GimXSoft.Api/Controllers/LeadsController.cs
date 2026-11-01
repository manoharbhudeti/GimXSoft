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
public class LeadsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public LeadsController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet]
    public async Task<ActionResult<List<LeadDto>>> GetLeads(
        [FromQuery] Guid? branchId,
        [FromQuery] LeadStage? stage,
        [FromQuery] LeadSource? source,
        [FromQuery] string? search)
    {
        var query = _context.Leads
            .Include(l => l.Branch)
            .Include(l => l.AssignedStaff)
            .AsQueryable();

        if (branchId.HasValue) query = query.Where(l => l.BranchId == branchId.Value);
        if (stage.HasValue) query = query.Where(l => l.Stage == stage.Value);
        if (source.HasValue) query = query.Where(l => l.Source == source.Value);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.ToLower().Trim();
            query = query.Where(l =>
                l.FullName.ToLower().Contains(s) ||
                l.Email.ToLower().Contains(s) ||
                l.Phone.Contains(s));
        }

        var leads = await query
            .OrderByDescending(l => l.CreatedAt)
            .Select(l => new LeadDto(
                l.Id,
                l.TenantId,
                l.BranchId,
                l.Branch != null ? l.Branch.Name : null,
                l.FullName,
                l.Email,
                l.Phone,
                l.Source.ToString(),
                l.Stage.ToString(),
                l.AssignedStaffId,
                l.AssignedStaff != null ? l.AssignedStaff.FullName : null,
                l.Notes,
                l.NextFollowUpDate,
                l.EstimatedValue,
                l.CreatedAt,
                l.UpdatedAt
            ))
            .ToListAsync();

        return Ok(leads);
    }

    [HttpPost]
    public async Task<ActionResult<LeadDto>> CreateLead([FromBody] CreateLeadRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();

        var lead = new Lead
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            FullName = request.FullName.Trim(),
            Email = request.Email?.Trim() ?? "",
            Phone = request.Phone.Trim(),
            Source = request.Source,
            Stage = LeadStage.New,
            AssignedStaffId = request.AssignedStaffId,
            Notes = request.Notes,
            NextFollowUpDate = request.NextFollowUpDate,
            EstimatedValue = request.EstimatedValue,
            CreatedAt = DateTime.UtcNow
        };

        _context.Leads.Add(lead);

        var activity = new LeadActivity
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            LeadId = lead.Id,
            StaffId = _tenantService.UserId,
            ActivityType = "Creation",
            Description = $"Lead created via {request.Source}",
            CreatedAt = DateTime.UtcNow
        };
        _context.LeadActivities.Add(activity);

        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetLeads), new { id = lead.Id }, new LeadDto(
            lead.Id,
            lead.TenantId,
            lead.BranchId,
            null,
            lead.FullName,
            lead.Email,
            lead.Phone,
            lead.Source.ToString(),
            lead.Stage.ToString(),
            lead.AssignedStaffId,
            null,
            lead.Notes,
            lead.NextFollowUpDate,
            lead.EstimatedValue,
            lead.CreatedAt,
            lead.UpdatedAt
        ));
    }

    [HttpPatch("{id}/stage")]
    public async Task<ActionResult> UpdateLeadStage(Guid id, [FromBody] UpdateLeadStageRequest request)
    {
        var lead = await _context.Leads.FindAsync(id);
        if (lead == null) return NotFound(new { message = "Lead not found." });

        var prevStage = lead.Stage;
        lead.Stage = request.Stage;
        lead.UpdatedAt = DateTime.UtcNow;

        var activity = new LeadActivity
        {
            Id = Guid.NewGuid(),
            TenantId = lead.TenantId,
            LeadId = lead.Id,
            StaffId = _tenantService.UserId,
            ActivityType = "StageChange",
            Description = $"Stage moved from {prevStage} to {request.Stage}. {(string.IsNullOrWhiteSpace(request.Note) ? "" : $"Note: {request.Note}")}".Trim(),
            CreatedAt = DateTime.UtcNow
        };
        _context.LeadActivities.Add(activity);

        await _context.SaveChangesAsync();
        return Ok(new { success = true, newStage = request.Stage.ToString() });
    }

    [HttpGet("{id}/activities")]
    public async Task<ActionResult<List<LeadActivityDto>>> GetActivities(Guid id)
    {
        var activities = await _context.LeadActivities
            .Include(a => a.Staff)
            .Where(a => a.LeadId == id)
            .OrderByDescending(a => a.CreatedAt)
            .Select(a => new LeadActivityDto(
                a.Id,
                a.LeadId,
                a.StaffId,
                a.Staff != null ? a.Staff.FullName : null,
                a.ActivityType,
                a.Description,
                a.CreatedAt
            ))
            .ToListAsync();

        return Ok(activities);
    }

    [HttpPost("{id}/activities")]
    public async Task<ActionResult<LeadActivityDto>> AddActivity(Guid id, [FromBody] AddLeadActivityRequest request)
    {
        var lead = await _context.Leads.FindAsync(id);
        if (lead == null) return NotFound(new { message = "Lead not found." });

        var activity = new LeadActivity
        {
            Id = Guid.NewGuid(),
            TenantId = lead.TenantId,
            LeadId = lead.Id,
            StaffId = _tenantService.UserId,
            ActivityType = request.ActivityType,
            Description = request.Description,
            CreatedAt = DateTime.UtcNow
        };

        _context.LeadActivities.Add(activity);
        lead.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new LeadActivityDto(
            activity.Id,
            activity.LeadId,
            activity.StaffId,
            null,
            activity.ActivityType,
            activity.Description,
            activity.CreatedAt
        ));
    }
}

