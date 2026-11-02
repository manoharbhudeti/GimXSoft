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

    // --- Reusable Workout Templates ---
    [HttpGet("templates")]
    public async Task<ActionResult<List<WorkoutTemplateDto>>> GetTemplates()
    {
        var templates = await _context.WorkoutTemplates
            .OrderBy(t => t.Title)
            .Select(t => new WorkoutTemplateDto(
                t.Id,
                t.TenantId,
                t.Title,
                t.Description,
                t.Goal,
                t.Level.ToString(),
                t.DaysPerWeek,
                t.EstimatedMinutesPerSession,
                t.RoutineJson,
                t.CreatedByUserId,
                t.CreatedAt
            ))
            .ToListAsync();

        return Ok(templates);
    }

    [HttpPost("templates")]
    public async Task<ActionResult<WorkoutTemplateDto>> CreateTemplate([FromBody] CreateWorkoutTemplateRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();

        Enum.TryParse<FitnessLevel>(request.Level, true, out var level);

        var template = new WorkoutTemplate
        {
            TenantId = tenantId,
            Title = request.Title.Trim(),
            Description = request.Description ?? "",
            Goal = request.Goal ?? "General Conditioning",
            Level = level,
            DaysPerWeek = request.DaysPerWeek > 0 ? request.DaysPerWeek : 4,
            EstimatedMinutesPerSession = request.EstimatedMinutesPerSession > 0 ? request.EstimatedMinutesPerSession : 45,
            RoutineJson = request.RoutineJson,
            CreatedByUserId = _tenantService.UserId,
            CreatedAt = DateTime.UtcNow
        };

        _context.WorkoutTemplates.Add(template);
        await _context.SaveChangesAsync();

        return Ok(new WorkoutTemplateDto(
            template.Id,
            template.TenantId,
            template.Title,
            template.Description,
            template.Goal,
            template.Level.ToString(),
            template.DaysPerWeek,
            template.EstimatedMinutesPerSession,
            template.RoutineJson,
            template.CreatedByUserId,
            template.CreatedAt
        ));
    }

    // --- Member Delivery Schedules ---
    [HttpGet("schedules")]
    public async Task<ActionResult<List<MemberWorkoutScheduleDto>>> GetSchedules(
        [FromQuery] Guid? memberId,
        [FromQuery] string? dayOfWeek)
    {
        var query = _context.MemberWorkoutSchedules
            .Include(s => s.Member)
            .Include(s => s.WorkoutTemplate)
            .Include(s => s.AssignedTrainer)
            .AsQueryable();

        if (memberId.HasValue)
        {
            query = query.Where(s => s.MemberId == memberId.Value);
        }

        if (!string.IsNullOrEmpty(dayOfWeek))
        {
            query = query.Where(s => s.DayOfWeek.ToLower() == dayOfWeek.ToLower());
        }

        var schedules = await query
            .OrderBy(s => s.DayOfWeek)
            .Select(s => new MemberWorkoutScheduleDto(
                s.Id,
                s.MemberId,
                s.Member != null ? s.Member.FullName : "Member",
                s.WorkoutTemplateId,
                s.WorkoutTemplate != null ? s.WorkoutTemplate.Title : null,
                s.AssignedTrainerId,
                s.AssignedTrainer != null ? s.AssignedTrainer.FullName : null,
                s.DayOfWeek,
                s.ScheduledDeliveryTime,
                s.RoutineTitle,
                s.ExercisesJson,
                s.IsRestDay,
                s.TrainerApproved,
                s.IsActive,
                s.TrainerNotes,
                s.UpdatedAt
            ))
            .ToListAsync();

        return Ok(schedules);
    }

    [HttpPost("schedules/assign")]
    public async Task<ActionResult<MemberWorkoutScheduleDto>> AssignSchedule([FromBody] AssignWorkoutScheduleRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();
        var member = await _context.Members.FindAsync(request.MemberId);
        if (member == null) return NotFound(new { message = "Member not found." });

        // Update or create schedule for the specified day of week
        var schedule = await _context.MemberWorkoutSchedules
            .FirstOrDefaultAsync(s => s.MemberId == request.MemberId && s.DayOfWeek.ToLower() == request.DayOfWeek.ToLower());

        if (schedule == null)
        {
            schedule = new MemberWorkoutSchedule
            {
                TenantId = tenantId,
                MemberId = request.MemberId,
                DayOfWeek = request.DayOfWeek,
                CreatedAt = DateTime.UtcNow
            };
            _context.MemberWorkoutSchedules.Add(schedule);
        }

        schedule.WorkoutTemplateId = request.WorkoutTemplateId;
        schedule.AssignedTrainerId = request.AssignedTrainerId ?? member.AssignedTrainerId;
        schedule.ScheduledDeliveryTime = request.ScheduledDeliveryTime ?? "07:00";
        schedule.RoutineTitle = request.RoutineTitle;
        schedule.ExercisesJson = request.ExercisesJson;
        schedule.IsRestDay = request.IsRestDay;
        schedule.TrainerApproved = request.TrainerApproved;
        schedule.TrainerNotes = request.TrainerNotes;
        schedule.IsActive = true;
        schedule.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new MemberWorkoutScheduleDto(
            schedule.Id,
            schedule.MemberId,
            member.FullName,
            schedule.WorkoutTemplateId,
            null,
            schedule.AssignedTrainerId,
            null,
            schedule.DayOfWeek,
            schedule.ScheduledDeliveryTime,
            schedule.RoutineTitle,
            schedule.ExercisesJson,
            schedule.IsRestDay,
            schedule.TrainerApproved,
            schedule.IsActive,
            schedule.TrainerNotes,
            schedule.UpdatedAt
        ));
    }

    [HttpPost("schedules/{id:guid}/send-now")]
    public async Task<ActionResult> TriggerWorkoutDeliveryNow(Guid id, [FromServices] IWhatsAppCloudApiClient apiClient)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();
        var schedule = await _context.MemberWorkoutSchedules
            .Include(s => s.Member)
            .FirstOrDefaultAsync(s => s.Id == id);

        if (schedule == null || schedule.Member == null) return NotFound();

        var messageContent = schedule.IsRestDay
            ? $"Hi {schedule.Member.FirstName}, today is your Active Recovery & Rest Day. Make sure to hydrate and stretch!"
            : $"Hi {schedule.Member.FirstName}, here is your personal training routine for today: *{schedule.RoutineTitle}*. Reply to this chat if you have any questions for your trainer!";

        var result = await apiClient.SendTemplateMessageAsync(
            "105938472910482",
            "EAAG_TOKEN",
            schedule.Member.Phone,
            "daily_workout_delivery",
            "en_US",
            new List<string> { schedule.Member.FirstName, schedule.RoutineTitle, "https://titanfit.com/workouts/view" }
        );

        _context.WhatsAppMessages.Add(new WhatsAppMessage
        {
            TenantId = tenantId,
            BranchId = schedule.Member.BranchId,
            MemberId = schedule.Member.Id,
            RecipientPhone = schedule.Member.Phone,
            RecipientName = schedule.Member.FullName,
            Direction = WhatsAppDirection.Outbound,
            MessageType = WhatsAppMessageType.Template,
            TemplateName = "daily_workout_delivery",
            MessageContent = messageContent,
            WamId = result.WamId,
            Status = WhatsAppMessageStatus.Delivered,
            SentAt = DateTime.UtcNow,
            DeliveredAt = DateTime.UtcNow.AddSeconds(1)
        });

        await _context.SaveChangesAsync();

        return Ok(new { success = true, wamid = result.WamId, recipient = schedule.Member.FullName });
    }

}

