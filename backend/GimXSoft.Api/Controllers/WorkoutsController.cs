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
public class WorkoutsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public WorkoutsController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet]
    public async Task<ActionResult<List<WorkoutPlanDto>>> GetWorkoutPlans([FromQuery] Guid? memberId)
    {
        var query = _context.WorkoutPlans
            .Include(w => w.Member)
            .Include(w => w.Trainer)
            .AsQueryable();

        if (memberId.HasValue)
        {
            query = query.Where(w => w.MemberId == memberId.Value);
        }

        var plans = await query
            .OrderByDescending(w => w.CreatedAt)
            .Select(w => new WorkoutPlanDto(
                w.Id,
                w.TenantId,
                w.MemberId,
                w.Member != null ? w.Member.FullName : "Member",
                w.TrainerId,
                w.Trainer != null ? w.Trainer.FullName : null,
                w.Title,
                w.Goal,
                w.StartDate,
                w.EndDate,
                w.Notes,
                w.ExercisesJson,
                w.CreatedAt
            ))
            .ToListAsync();

        return Ok(plans);
    }

    [HttpPost]
    public async Task<ActionResult<WorkoutPlanDto>> CreateWorkoutPlan([FromBody] CreateWorkoutPlanRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();
        var member = await _context.Members.FindAsync(request.MemberId);
        if (member == null) return NotFound(new { message = "Member not found." });

        var plan = new WorkoutPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            MemberId = request.MemberId,
            TrainerId = request.TrainerId ?? _tenantService.UserId,
            Title = request.Title.Trim(),
            Goal = request.Goal ?? "General Fitness",
            StartDate = request.StartDate ?? DateTime.UtcNow.Date,
            EndDate = request.EndDate ?? DateTime.UtcNow.Date.AddDays(60),
            Notes = request.Notes,
            ExercisesJson = request.ExercisesJson,
            CreatedAt = DateTime.UtcNow
        };

        _context.WorkoutPlans.Add(plan);
        await _context.SaveChangesAsync();

        var trainer = plan.TrainerId.HasValue ? await _context.Users.FindAsync(plan.TrainerId.Value) : null;

        return Ok(new WorkoutPlanDto(
            plan.Id,
            plan.TenantId,
            plan.MemberId,
            member.FullName,
            plan.TrainerId,
            trainer?.FullName,
            plan.Title,
            plan.Goal,
            plan.StartDate,
            plan.EndDate,
            plan.Notes,
            plan.ExercisesJson,
            plan.CreatedAt
        ));
    }
}

