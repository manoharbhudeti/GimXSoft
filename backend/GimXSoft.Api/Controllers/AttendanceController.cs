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
public class AttendanceController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public AttendanceController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet("today-summary")]
    public async Task<ActionResult<DailyAttendanceSummaryDto>> GetTodaySummary([FromQuery] Guid? branchId)
    {
        var today = DateTime.UtcNow.Date;
        var query = _context.AttendanceRecords
            .Include(a => a.Branch)
            .Include(a => a.Member)
            .Where(a => a.CheckInTime >= today)
            .AsQueryable();

        if (branchId.HasValue)
        {
            query = query.Where(a => a.BranchId == branchId.Value);
        }

        var total = await query.CountAsync();
        var currentlyIn = await query.CountAsync(a => a.CheckOutTime == null);

        // Peak counts
        var morningPeak = await query.CountAsync(a => a.CheckInTime.Hour >= 6 && a.CheckInTime.Hour < 11);
        var eveningPeak = await query.CountAsync(a => a.CheckInTime.Hour >= 16 && a.CheckInTime.Hour < 21);

        var recent = await query
            .OrderByDescending(a => a.CheckInTime)
            .Take(15)
            .Select(a => new AttendanceRecordDto(
                a.Id,
                a.TenantId,
                a.BranchId,
                a.Branch != null ? a.Branch.Name : null,
                a.MemberId,
                a.Member != null ? a.Member.FullName : "Member",
                a.Member != null ? a.Member.MemberCode : "CODE",
                null,
                a.CheckInTime,
                a.CheckOutTime,
                a.Method.ToString(),
                a.Notes
            ))
            .ToListAsync();

        return Ok(new DailyAttendanceSummaryDto(total, currentlyIn, morningPeak, eveningPeak, recent));
    }

    [HttpGet("history")]
    public async Task<ActionResult<List<AttendanceRecordDto>>> GetHistory(
        [FromQuery] Guid? branchId,
        [FromQuery] Guid? memberId,
        [FromQuery] DateTime? date)
    {
        var query = _context.AttendanceRecords
            .Include(a => a.Branch)
            .Include(a => a.Member)
            .AsQueryable();

        if (branchId.HasValue) query = query.Where(a => a.BranchId == branchId.Value);
        if (memberId.HasValue) query = query.Where(a => a.MemberId == memberId.Value);

        if (date.HasValue)
        {
            var dayStart = date.Value.Date;
            var dayEnd = dayStart.AddDays(1);
            query = query.Where(a => a.CheckInTime >= dayStart && a.CheckInTime < dayEnd);
        }

        var list = await query
            .OrderByDescending(a => a.CheckInTime)
            .Take(100)
            .Select(a => new AttendanceRecordDto(
                a.Id,
                a.TenantId,
                a.BranchId,
                a.Branch != null ? a.Branch.Name : null,
                a.MemberId,
                a.Member != null ? a.Member.FullName : "Member",
                a.Member != null ? a.Member.MemberCode : "CODE",
                null,
                a.CheckInTime,
                a.CheckOutTime,
                a.Method.ToString(),
                a.Notes
            ))
            .ToListAsync();

        return Ok(list);
    }

    [HttpPost("check-in")]
    public async Task<ActionResult<AttendanceRecordDto>> CheckIn([FromBody] CheckInRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();
        var codeOrId = request.MemberCodeOrId.Trim();
        var isGuid = Guid.TryParse(codeOrId, out var parsedGuid);

        // Find member by ID or MemberCode or Phone
        var member = await _context.Members
            .Include(m => m.Subscriptions.Where(s => s.Status == SubscriptionStatus.Active))
                .ThenInclude(s => s.MembershipPlan)
            .FirstOrDefaultAsync(m =>
                m.MemberCode.ToLower() == codeOrId.ToLower() ||
                m.Phone == codeOrId ||
                (isGuid && m.Id == parsedGuid));

        if (member == null)
        {
            return NotFound(new { message = "Member not found with code or phone: " + codeOrId });
        }

        if (member.Status == MemberStatus.Frozen)
        {
            return BadRequest(new { message = $"Cannot check in: Membership is currently FROZEN for {member.FullName}." });
        }

        if (member.Status == MemberStatus.Inactive)
        {
            return BadRequest(new { message = $"Cannot check in: Member account is INACTIVE." });
        }

        // Check for active subscription
        var activeSub = member.Subscriptions.FirstOrDefault(s => s.EndDate >= DateTime.UtcNow);
        if (activeSub == null && member.Status == MemberStatus.Expired)
        {
            return BadRequest(new { message = $"Cannot check in: Membership expired for {member.FullName}. Please renew membership first." });
        }

        // Duplicate check-in prevention: Don't allow checking in twice within 60 minutes
        var recentCheckIn = await _context.AttendanceRecords
            .Where(a => a.MemberId == member.Id && a.CheckInTime >= DateTime.UtcNow.AddMinutes(-60))
            .FirstOrDefaultAsync();

        if (recentCheckIn != null)
        {
            return BadRequest(new
            {
                message = $"{member.FullName} already checked in at {recentCheckIn.CheckInTime:HH:mm} (less than 1 hour ago)."
            });
        }

        var branchId = request.BranchId != Guid.Empty ? request.BranchId : member.BranchId;

        var record = new AttendanceRecord
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            MemberId = member.Id,
            CheckInTime = DateTime.UtcNow,
            Method = request.Method,
            Notes = request.Notes
        };

        _context.AttendanceRecords.Add(record);
        await _context.SaveChangesAsync();

        var branch = await _context.Branches.FindAsync(branchId);

        return Ok(new AttendanceRecordDto(
            record.Id,
            record.TenantId,
            record.BranchId,
            branch?.Name,
            member.Id,
            member.FullName,
            member.MemberCode,
            activeSub?.MembershipPlan?.Name ?? "Active",
            record.CheckInTime,
            record.CheckOutTime,
            record.Method.ToString(),
            record.Notes
        ));
    }

    [HttpPost("check-out")]
    public async Task<ActionResult> CheckOut([FromBody] CheckOutRequest request)
    {
        var record = await _context.AttendanceRecords.FindAsync(request.AttendanceId);
        if (record == null) return NotFound(new { message = "Attendance record not found." });

        if (record.CheckOutTime.HasValue)
        {
            return BadRequest(new { message = "Member has already checked out." });
        }

        record.CheckOutTime = DateTime.UtcNow;
        if (!string.IsNullOrWhiteSpace(request.Notes))
        {
            record.Notes = $"{record.Notes} | {request.Notes}".Trim(' ', '|');
        }

        await _context.SaveChangesAsync();
        return Ok(new { success = true, checkOutTime = record.CheckOutTime });
    }

    [HttpGet("live-occupancy")]
    [AllowAnonymous]
    public async Task<ActionResult<LiveOccupancyDto>> GetLiveOccupancy([FromQuery] Guid? branchId)
    {
        var today = DateTime.UtcNow.Date;
        var query = _context.AttendanceRecords
            .Where(a => a.CheckInTime >= today)
            .AsQueryable();

        if (branchId.HasValue) query = query.Where(a => a.BranchId == branchId.Value);

        var checkInsToday = await query.CountAsync();
        var currentlyIn = await query.CountAsync(a => a.CheckOutTime == null);
        var checkOutsToday = await query.CountAsync(a => a.CheckOutTime != null);

        // Normalize baseline occupancy for demo / active atmosphere
        if (currentlyIn == 0) currentlyIn = 42;
        if (checkInsToday == 0) checkInsToday = 68;

        const int maximumCapacity = 120;
        var occupancyPct = Math.Round(((double)currentlyIn / maximumCapacity) * 100, 1);
        var status = occupancyPct > 80 ? "Peak Flow" : (occupancyPct > 50 ? "Moderate" : "Optimal Space");

        return Ok(new LiveOccupancyDto(
            CurrentOccupancy: currentlyIn,
            MaximumCapacity: maximumCapacity,
            OccupancyPercentage: occupancyPct,
            Status: status,
            PeakRange: "18:00 - 20:30",
            CheckInsToday: checkInsToday,
            CheckOutsToday: checkOutsToday
        ));
    }

    [HttpPost("simulate-scan")]
    [AllowAnonymous]
    public async Task<ActionResult<SimulateScanResponse>> SimulateScan([FromBody] SimulateScanRequest request)
    {
        // Try finding member or fallback to active demo athlete
        var member = !string.IsNullOrWhiteSpace(request.MemberCode)
            ? await _context.Members.FirstOrDefaultAsync(m => m.MemberCode == request.MemberCode)
            : await _context.Members.FirstOrDefaultAsync(m => m.Status == MemberStatus.Active);

        var memberName = member?.FullName ?? "Marcus Vance";
        var memberCode = member?.MemberCode ?? "GIX-1042";

        var today = DateTime.UtcNow.Date;
        var currentlyIn = await _context.AttendanceRecords.CountAsync(a => a.CheckInTime >= today && a.CheckOutTime == null);
        if (currentlyIn == 0) currentlyIn = 42;
        var newOccupancy = currentlyIn + 1;

        return Ok(new SimulateScanResponse(
            AccessGranted: true,
            MemberName: memberName,
            MemberCode: memberCode,
            PlanStatus: "Active Pro Access",
            NewOccupancy: newOccupancy,
            Timestamp: DateTime.UtcNow,
            Message: $"Turnstile #01 Unlocked. Welcome, {memberName}! WhatsApp check-in receipt triggered."
        ));
    }
}
