using System.Text;
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
public class MembersController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public MembersController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet]
    public async Task<ActionResult<List<MemberDto>>> GetMembers(
        [FromQuery] string? search,
        [FromQuery] Guid? branchId,
        [FromQuery] MemberStatus? status,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        var query = _context.Members
            .Include(m => m.Branch)
            .Include(m => m.AssignedTrainer)
            .Include(m => m.Subscriptions.OrderByDescending(s => s.EndDate))
                .ThenInclude(s => s.MembershipPlan)
            .AsQueryable();

        if (branchId.HasValue)
        {
            query = query.Where(m => m.BranchId == branchId.Value);
        }

        if (status.HasValue)
        {
            query = query.Where(m => m.Status == status.Value);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.ToLower().Trim();
            query = query.Where(m =>
                m.FirstName.ToLower().Contains(s) ||
                m.LastName.ToLower().Contains(s) ||
                m.Email.ToLower().Contains(s) ||
                m.Phone.Contains(s) ||
                m.MemberCode.ToLower().Contains(s));
        }

        var total = await query.CountAsync();
        Response.Headers.Append("X-Total-Count", total.ToString());

        var members = await query
            .OrderByDescending(m => m.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(m => new MemberDto(
                m.Id,
                m.TenantId,
                m.BranchId,
                m.Branch != null ? m.Branch.Name : null,
                m.MemberCode,
                m.FirstName,
                m.LastName,
                m.FullName,
                m.Email,
                m.Phone,
                m.Gender,
                m.DateOfBirth,
                m.Address,
                m.EmergencyContactName,
                m.EmergencyContactPhone,
                m.JoiningDate,
                m.AssignedTrainerId,
                m.AssignedTrainer != null ? m.AssignedTrainer.FullName : null,
                m.Status.ToString(),
                m.MedicalNotes,
                m.AvatarUrl,
                m.Subscriptions.FirstOrDefault() != null ? m.Subscriptions.First().MembershipPlan!.Name : "No Active Plan",
                m.Subscriptions.FirstOrDefault() != null ? (DateTime?)m.Subscriptions.First().EndDate : null,
                m.CreatedAt
            ))
            .ToListAsync();

        return Ok(members);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<MemberDetailDto>> GetMemberById(Guid id)
    {
        var m = await _context.Members
            .Include(x => x.Branch)
            .Include(x => x.AssignedTrainer)
            .Include(x => x.Subscriptions)
                .ThenInclude(s => s.MembershipPlan)
            .Include(x => x.AttendanceRecords.OrderByDescending(a => a.CheckInTime).Take(10))
            .Include(x => x.PaymentTransactions.OrderByDescending(p => p.CreatedAt).Take(10))
            .Include(x => x.WorkoutPlans.OrderByDescending(w => w.CreatedAt).Take(5))
            .FirstOrDefaultAsync(x => x.Id == id);

        if (m == null) return NotFound(new { message = "Member not found." });

        var memberDto = new MemberDto(
            m.Id,
            m.TenantId,
            m.BranchId,
            m.Branch?.Name,
            m.MemberCode,
            m.FirstName,
            m.LastName,
            m.FullName,
            m.Email,
            m.Phone,
            m.Gender,
            m.DateOfBirth,
            m.Address,
            m.EmergencyContactName,
            m.EmergencyContactPhone,
            m.JoiningDate,
            m.AssignedTrainerId,
            m.AssignedTrainer?.FullName,
            m.Status.ToString(),
            m.MedicalNotes,
            m.AvatarUrl,
            m.Subscriptions.OrderByDescending(s => s.EndDate).FirstOrDefault()?.MembershipPlan?.Name ?? "No Plan",
            m.Subscriptions.OrderByDescending(s => s.EndDate).FirstOrDefault()?.EndDate,
            m.CreatedAt
        );

        var subs = m.Subscriptions.Select(s => new MemberSubscriptionDto(
            s.Id,
            s.TenantId,
            s.MemberId,
            m.FullName,
            s.MembershipPlanId,
            s.MembershipPlan?.Name ?? "Standard",
            s.StartDate,
            s.EndDate,
            s.PricePaid,
            s.DiscountAmount,
            s.Status.ToString(),
            s.FreezeStartDate,
            s.FreezeEndDate,
            s.Notes,
            s.CreatedAt
        )).ToList();

        var att = m.AttendanceRecords.Select(a => new AttendanceRecordDto(
            a.Id,
            a.TenantId,
            a.BranchId,
            m.Branch?.Name,
            a.MemberId,
            m.FullName,
            m.MemberCode,
            null,
            a.CheckInTime,
            a.CheckOutTime,
            a.Method.ToString(),
            a.Notes
        )).ToList();

        var payments = m.PaymentTransactions.Select(p => new PaymentTransactionDto(
            p.Id,
            p.TenantId,
            p.BranchId,
            m.Branch?.Name,
            p.MemberId,
            m.FullName,
            m.MemberCode,
            p.SubscriptionId,
            null,
            p.InvoiceNumber,
            p.Amount,
            p.PaymentMethod.ToString(),
            p.Status.ToString(),
            p.TransactionReference,
            p.Notes,
            p.CreatedAt
        )).ToList();

        var workouts = m.WorkoutPlans.Select(w => new WorkoutPlanDto(
            w.Id,
            w.TenantId,
            w.MemberId,
            m.FullName,
            w.TrainerId,
            m.AssignedTrainer?.FullName,
            w.Title,
            w.Goal,
            w.StartDate,
            w.EndDate,
            w.Notes,
            w.ExercisesJson,
            w.CreatedAt
        )).ToList();

        return Ok(new MemberDetailDto(memberDto, subs, att, payments, workouts));
    }

    [HttpPost]
    public async Task<ActionResult<MemberDto>> CreateMember([FromBody] CreateMemberRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();

        // Duplicate check on phone or email within this tenant
        var duplicate = await _context.Members.AnyAsync(m =>
            m.Email.ToLower() == request.Email.ToLower() || m.Phone == request.Phone);

        if (duplicate)
        {
            return BadRequest(new { message = "A member with this email or phone number already exists." });
        }

        // Generate unique sequential member code
        var memberCount = await _context.Members.CountAsync();
        var memberCode = $"GIX-{1000 + memberCount + 1}";

        var member = new Member
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            MemberCode = memberCode,
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            Email = request.Email.ToLower().Trim(),
            Phone = request.Phone.Trim(),
            Gender = request.Gender,
            DateOfBirth = request.DateOfBirth,
            Address = request.Address ?? "",
            EmergencyContactName = request.EmergencyContactName ?? "",
            EmergencyContactPhone = request.EmergencyContactPhone ?? "",
            JoiningDate = request.JoiningDate ?? DateTime.UtcNow.Date,
            AssignedTrainerId = request.AssignedTrainerId,
            Status = MemberStatus.Active,
            MedicalNotes = request.MedicalNotes,
            CreatedAt = DateTime.UtcNow
        };

        _context.Members.Add(member);

        // If initial membership plan is provided, subscribe member
        if (request.InitialPlanId.HasValue)
        {
            var plan = await _context.MembershipPlans.FindAsync(request.InitialPlanId.Value);
            if (plan != null)
            {
                var sub = new MemberSubscription
                {
                    Id = Guid.NewGuid(),
                    TenantId = tenantId,
                    MemberId = member.Id,
                    MembershipPlanId = plan.Id,
                    StartDate = member.JoiningDate,
                    EndDate = member.JoiningDate.AddDays(plan.DurationDays),
                    PricePaid = plan.Price + plan.RegistrationFee,
                    DiscountAmount = 0.00m,
                    Status = SubscriptionStatus.Active,
                    Notes = "Initial plan on enrollment",
                    CreatedAt = DateTime.UtcNow
                };
                _context.MemberSubscriptions.Add(sub);

                // Add payment record
                var txCount = await _context.PaymentTransactions.CountAsync();
                var payment = new PaymentTransaction
                {
                    Id = Guid.NewGuid(),
                    TenantId = tenantId,
                    BranchId = member.BranchId,
                    MemberId = member.Id,
                    SubscriptionId = sub.Id,
                    InvoiceNumber = $"INV-{DateTime.UtcNow.Year}-{1000 + txCount + 1}",
                    Amount = sub.PricePaid,
                    PaymentMethod = PaymentMethod.Card,
                    Status = PaymentStatus.Completed,
                    TransactionReference = $"SYS_{DateTime.UtcNow.Ticks}",
                    Notes = $"Enrollment fee & {plan.Name}",
                    CreatedAt = DateTime.UtcNow
                };
                _context.PaymentTransactions.Add(payment);
            }
        }

        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetMemberById), new { id = member.Id }, new MemberDto(
            member.Id,
            member.TenantId,
            member.BranchId,
            null,
            member.MemberCode,
            member.FirstName,
            member.LastName,
            member.FullName,
            member.Email,
            member.Phone,
            member.Gender,
            member.DateOfBirth,
            member.Address,
            member.EmergencyContactName,
            member.EmergencyContactPhone,
            member.JoiningDate,
            member.AssignedTrainerId,
            null,
            member.Status.ToString(),
            member.MedicalNotes,
            member.AvatarUrl,
            null,
            null,
            member.CreatedAt
        ));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> UpdateMember(Guid id, [FromBody] UpdateMemberRequest request)
    {
        var member = await _context.Members.FindAsync(id);
        if (member == null) return NotFound(new { message = "Member not found." });

        member.BranchId = request.BranchId;
        member.FirstName = request.FirstName.Trim();
        member.LastName = request.LastName.Trim();
        member.Email = request.Email.ToLower().Trim();
        member.Phone = request.Phone.Trim();
        member.Gender = request.Gender;
        member.DateOfBirth = request.DateOfBirth;
        member.Address = request.Address ?? "";
        member.EmergencyContactName = request.EmergencyContactName ?? "";
        member.EmergencyContactPhone = request.EmergencyContactPhone ?? "";
        member.AssignedTrainerId = request.AssignedTrainerId;
        member.Status = request.Status;
        member.MedicalNotes = request.MedicalNotes;
        member.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> ArchiveMember(Guid id)
    {
        var member = await _context.Members.FindAsync(id);
        if (member == null) return NotFound(new { message = "Member not found." });

        member.Status = MemberStatus.Inactive;
        member.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = "Member archived successfully." });
    }

    [HttpGet("export")]
    public async Task<IActionResult> ExportCsv()
    {
        var members = await _context.Members
            .Include(m => m.Branch)
            .OrderBy(m => m.MemberCode)
            .ToListAsync();

        var builder = new StringBuilder();
        builder.AppendLine("MemberCode,FullName,Email,Phone,Gender,Status,Branch,JoiningDate");

        foreach (var m in members)
        {
            builder.AppendLine($"\"{m.MemberCode}\",\"{m.FullName}\",\"{m.Email}\",\"{m.Phone}\",\"{m.Gender}\",\"{m.Status}\",\"{m.Branch?.Name}\",\"{m.JoiningDate:yyyy-MM-dd}\"");
        }

        var bytes = Encoding.UTF8.GetBytes(builder.ToString());
        return File(bytes, "text/csv", $"Members_Export_{DateTime.UtcNow:yyyyMMdd_HHmm}.csv");
    }
}

