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
public class TrainersController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public TrainersController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet]
    public async Task<ActionResult<List<TrainerDto>>> GetTrainers()
    {
        var trainers = await _context.TrainerProfiles
            .Include(t => t.User)
            .Include(t => t.Sessions)
            .Select(t => new TrainerDto(
                t.Id,
                t.TenantId,
                t.UserId,
                t.User != null ? t.User.FullName : "Trainer",
                t.User != null ? t.User.Email : "",
                t.User != null ? t.User.Phone : "",
                t.User != null ? t.User.AvatarUrl : null,
                t.Bio,
                t.SpecializationsJson,
                t.CertificationsJson,
                t.HourlyRate,
                t.IsActive,
                _context.Members.Count(m => m.AssignedTrainerId == t.UserId),
                t.Sessions.Count(s => s.Status == SessionStatus.Completed)
            ))
            .ToListAsync();

        return Ok(trainers);
    }

    [HttpPost]
    public async Task<ActionResult<TrainerDto>> CreateTrainer([FromBody] CreateTrainerRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();

        var user = new User
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            FullName = request.FullName.Trim(),
            Email = request.Email.ToLower().Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Role = UserRole.Trainer,
            Phone = request.Phone,
            CreatedAt = DateTime.UtcNow
        };
        _context.Users.Add(user);

        var profile = new TrainerProfile
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            UserId = user.Id,
            Bio = request.Bio ?? "",
            SpecializationsJson = request.SpecializationsJson ?? "[]",
            CertificationsJson = request.CertificationsJson ?? "[]",
            HourlyRate = request.HourlyRate,
            IsActive = true
        };
        _context.TrainerProfiles.Add(profile);

        await _context.SaveChangesAsync();

        return Ok(new TrainerDto(
            profile.Id,
            profile.TenantId,
            profile.UserId,
            user.FullName,
            user.Email,
            user.Phone,
            user.AvatarUrl,
            profile.Bio,
            profile.SpecializationsJson,
            profile.CertificationsJson,
            profile.HourlyRate,
            profile.IsActive,
            0,
            0
        ));
    }

    [HttpGet("sessions")]
    public async Task<ActionResult<List<TrainerSessionDto>>> GetSessions([FromQuery] Guid? trainerId, [FromQuery] Guid? memberId)
    {
        var query = _context.TrainerSessions
            .Include(s => s.Trainer)
                .ThenInclude(t => t!.User)
            .Include(s => s.Member)
            .AsQueryable();

        if (trainerId.HasValue) query = query.Where(s => s.TrainerId == trainerId.Value);
        if (memberId.HasValue) query = query.Where(s => s.MemberId == memberId.Value);

        var sessions = await query
            .OrderByDescending(s => s.SessionDate)
            .Take(50)
            .Select(s => new TrainerSessionDto(
                s.Id,
                s.TenantId,
                s.BranchId,
                s.TrainerId,
                s.Trainer != null && s.Trainer.User != null ? s.Trainer.User.FullName : "Trainer",
                s.MemberId,
                s.Member != null ? s.Member.FullName : "Member",
                s.SessionDate,
                s.DurationMinutes,
                s.Status.ToString(),
                s.Notes,
                s.CreatedAt
            ))
            .ToListAsync();

        return Ok(sessions);
    }

    [HttpPost("sessions")]
    public async Task<ActionResult<TrainerSessionDto>> BookSession([FromBody] BookSessionRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();

        var session = new TrainerSession
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            TrainerId = request.TrainerId,
            MemberId = request.MemberId,
            SessionDate = request.SessionDate,
            DurationMinutes = request.DurationMinutes,
            Status = SessionStatus.Scheduled,
            Notes = request.Notes,
            CreatedAt = DateTime.UtcNow
        };

        _context.TrainerSessions.Add(session);
        await _context.SaveChangesAsync();

        var trainer = await _context.TrainerProfiles.Include(t => t.User).FirstOrDefaultAsync(t => t.Id == request.TrainerId);
        var member = await _context.Members.FindAsync(request.MemberId);

        return Ok(new TrainerSessionDto(
            session.Id,
            session.TenantId,
            session.BranchId,
            session.TrainerId,
            trainer?.User?.FullName ?? "Trainer",
            session.MemberId,
            member?.FullName ?? "Member",
            session.SessionDate,
            session.DurationMinutes,
            session.Status.ToString(),
            session.Notes,
            session.CreatedAt
        ));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<TrainerDto>> GetTrainerById(Guid id)
    {
        var t = await _context.TrainerProfiles
            .Include(x => x.User)
            .Include(x => x.Sessions)
            .FirstOrDefaultAsync(x => x.Id == id);

        if (t == null) return NotFound(new { message = "Trainer profile not found." });

        return Ok(new TrainerDto(
            t.Id,
            t.TenantId,
            t.UserId,
            t.User?.FullName ?? "Trainer",
            t.User?.Email ?? "",
            t.User?.Phone ?? "",
            t.User?.AvatarUrl,
            t.Bio,
            t.SpecializationsJson,
            t.CertificationsJson,
            t.HourlyRate,
            t.IsActive,
            _context.Members.Count(m => m.AssignedTrainerId == t.UserId),
            t.Sessions.Count(s => s.Status == SessionStatus.Completed)
        ));
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult> UpdateTrainer(Guid id, [FromBody] UpdateTrainerRequest request)
    {
        var profile = await _context.TrainerProfiles
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (profile == null) return NotFound(new { message = "Trainer profile not found." });

        if (profile.User != null)
        {
            profile.User.FullName = request.FullName.Trim();
            if (!string.IsNullOrWhiteSpace(request.Phone)) profile.User.Phone = request.Phone.Trim();
        }

        profile.Bio = request.Bio ?? "";
        profile.SpecializationsJson = request.SpecializationsJson ?? "[]";
        profile.CertificationsJson = request.CertificationsJson ?? "[]";
        profile.HourlyRate = request.HourlyRate;
        profile.IsActive = request.IsActive;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> DeleteTrainer(Guid id)
    {
        var profile = await _context.TrainerProfiles.FindAsync(id);
        if (profile == null) return NotFound(new { message = "Trainer profile not found." });

        profile.IsActive = false;
        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = "Trainer profile deactivated successfully." });
    }

    [HttpPut("sessions/{id:guid}/status")]
    public async Task<ActionResult> UpdateSessionStatus(Guid id, [FromBody] UpdateSessionStatusRequest request)
    {
        var session = await _context.TrainerSessions.FindAsync(id);
        if (session == null) return NotFound(new { message = "Session not found." });

        session.Status = request.Status;
        if (!string.IsNullOrWhiteSpace(request.Notes))
        {
            session.Notes = $"{session.Notes} | {request.Notes}".Trim(' ', '|');
        }

        await _context.SaveChangesAsync();
        return Ok(new { success = true, sessionId = session.Id, status = session.Status.ToString() });
    }

    [HttpDelete("sessions/{id:guid}")]
    public async Task<ActionResult> CancelSession(Guid id)
    {
        var session = await _context.TrainerSessions.FindAsync(id);
        if (session == null) return NotFound(new { message = "Session not found." });

        session.Status = SessionStatus.Cancelled;
        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = "Session cancelled successfully." });
    }
}

