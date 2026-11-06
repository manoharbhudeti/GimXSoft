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
    [Authorize]
    public async Task<ActionResult<List<LeadDto>>> GetLeads(
        [FromQuery] Guid? branchId,
        [FromQuery] LeadStage? stage,
        [FromQuery] LeadSource? source,
        [FromQuery] string? search,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
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
                l.Phone.Contains(s) ||
                (l.Notes != null && l.Notes.ToLower().Contains(s)));
        }

        var total = await query.CountAsync();
        Response?.Headers.Append("X-Total-Count", total.ToString());

        var list = await query
            .OrderByDescending(l => l.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
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

        return Ok(list);
    }

    [HttpGet("{id:guid}")]
    [Authorize]
    public async Task<ActionResult<object>> GetLeadById(Guid id)
    {
        var lead = await _context.Leads
            .Include(l => l.Branch)
            .Include(l => l.AssignedStaff)
            .Include(l => l.Activities.OrderByDescending(a => a.CreatedAt))
                .ThenInclude(a => a.Staff)
            .FirstOrDefaultAsync(l => l.Id == id);

        if (lead == null) return NotFound(new { message = "Lead not found." });

        var leadDto = new LeadDto(
            lead.Id,
            lead.TenantId,
            lead.BranchId,
            lead.Branch?.Name,
            lead.FullName,
            lead.Email,
            lead.Phone,
            lead.Source.ToString(),
            lead.Stage.ToString(),
            lead.AssignedStaffId,
            lead.AssignedStaff?.FullName,
            lead.Notes,
            lead.NextFollowUpDate,
            lead.EstimatedValue,
            lead.CreatedAt,
            lead.UpdatedAt
        );

        var activities = lead.Activities.Select(a => new LeadActivityDto(
            a.Id,
            a.LeadId,
            a.StaffId,
            a.Staff?.FullName,
            a.ActivityType,
            a.Description,
            a.CreatedAt
        )).ToList();

        return Ok(new { lead = leadDto, activities });
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<LeadDto>> CreateLead([FromBody] CreateLeadRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();

        var lead = new Lead
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            FullName = request.FullName.Trim(),
            Email = request.Email?.ToLower().Trim() ?? "",
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
            StaffId = request.AssignedStaffId,
            ActivityType = "Created",
            Description = $"Lead created via {request.Source}.",
            CreatedAt = DateTime.UtcNow
        };
        _context.LeadActivities.Add(activity);

        await _context.SaveChangesAsync();

        var branch = await _context.Branches.FindAsync(lead.BranchId);
        var staff = lead.AssignedStaffId.HasValue ? await _context.Users.FindAsync(lead.AssignedStaffId.Value) : null;

        return CreatedAtAction(nameof(GetLeadById), new { id = lead.Id }, new LeadDto(
            lead.Id,
            lead.TenantId,
            lead.BranchId,
            branch?.Name,
            lead.FullName,
            lead.Email,
            lead.Phone,
            lead.Source.ToString(),
            lead.Stage.ToString(),
            lead.AssignedStaffId,
            staff?.FullName,
            lead.Notes,
            lead.NextFollowUpDate,
            lead.EstimatedValue,
            lead.CreatedAt,
            null
        ));
    }

    [HttpPost("public-inquiry")]
    [AllowAnonymous]
    public async Task<ActionResult> SubmitPublicInquiry([FromBody] PublicInquiryRequest request)
    {
        // Public website landing inquiry: resolves tenant or defaults to Titan Fitness flagship
        var tenant = await _context.Tenants.FirstOrDefaultAsync() 
                     ?? throw new InvalidOperationException("No tenant registered.");

        var branch = await _context.Branches
            .Where(b => b.TenantId == tenant.Id)
            .OrderBy(b => b.CreatedAt)
            .FirstOrDefaultAsync();

        var branchId = branch?.Id ?? Guid.NewGuid();

        var notesBuilder = new List<string>();
        if (!string.IsNullOrWhiteSpace(request.GymName)) notesBuilder.Add($"Gym Name: {request.GymName}");
        if (!string.IsNullOrWhiteSpace(request.MemberRange)) notesBuilder.Add($"Scale: {request.MemberRange} members");
        if (!string.IsNullOrWhiteSpace(request.Message)) notesBuilder.Add($"Notes: {request.Message}");

        var lead = new Lead
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchId,
            FullName = request.FullName.Trim(),
            Email = request.Email?.ToLower().Trim() ?? "",
            Phone = request.Phone.Trim(),
            Source = LeadSource.Website,
            Stage = LeadStage.New,
            Notes = string.Join(" | ", notesBuilder),
            EstimatedValue = 2000.00m,
            CreatedAt = DateTime.UtcNow
        };

        _context.Leads.Add(lead);

        var activity = new LeadActivity
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            LeadId = lead.Id,
            ActivityType = "DemoRequest",
            Description = $"Live demo requested via landing page form. Contact: {request.Phone}",
            CreatedAt = DateTime.UtcNow
        };
        _context.LeadActivities.Add(activity);

        await _context.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            leadId = lead.Id,
            message = "Thank you! Our engineering team will reach out within 2 business hours for your live walkthrough."
        });
    }

    [HttpPut("{id:guid}")]
    [Authorize]
    public async Task<ActionResult> UpdateLead(Guid id, [FromBody] UpdateLeadRequest request)
    {
        var lead = await _context.Leads.FindAsync(id);
        if (lead == null) return NotFound(new { message = "Lead not found." });

        lead.BranchId = request.BranchId;
        lead.FullName = request.FullName.Trim();
        lead.Email = request.Email?.ToLower().Trim() ?? "";
        lead.Phone = request.Phone.Trim();
        lead.Source = request.Source;
        lead.Stage = request.Stage;
        lead.AssignedStaffId = request.AssignedStaffId;
        lead.Notes = request.Notes;
        lead.NextFollowUpDate = request.NextFollowUpDate;
        lead.EstimatedValue = request.EstimatedValue;
        lead.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpPut("{id:guid}/stage")]
    [Authorize]
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
            ActivityType = "StageChange",
            Description = $"Stage changed from {prevStage} to {request.Stage}. {(string.IsNullOrWhiteSpace(request.Note) ? "" : "Note: " + request.Note)}".Trim(),
            CreatedAt = DateTime.UtcNow
        };
        _context.LeadActivities.Add(activity);

        await _context.SaveChangesAsync();
        return Ok(new { success = true, leadId = lead.Id, stage = lead.Stage.ToString() });
    }

    [HttpPost("{id:guid}/activity")]
    [Authorize]
    public async Task<ActionResult<LeadActivityDto>> AddActivity(Guid id, [FromBody] AddLeadActivityRequest request)
    {
        var lead = await _context.Leads.FindAsync(id);
        if (lead == null) return NotFound(new { message = "Lead not found." });

        var activity = new LeadActivity
        {
            Id = Guid.NewGuid(),
            TenantId = lead.TenantId,
            LeadId = lead.Id,
            ActivityType = request.ActivityType.Trim(),
            Description = request.Description.Trim(),
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

    [HttpPost("{id:guid}/convert")]
    [Authorize]
    public async Task<ActionResult<MemberDto>> ConvertToMember(Guid id, [FromBody] ConvertLeadRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();
        var lead = await _context.Leads.FindAsync(id);
        if (lead == null) return NotFound(new { message = "Lead not found." });

        if (lead.Stage == LeadStage.Converted)
        {
            return BadRequest(new { message = "Lead has already been converted to an active member." });
        }

        // Split FullName into First and Last
        var names = lead.FullName.Trim().Split(' ', 2, StringSplitOptions.RemoveEmptyEntries);
        var firstName = names.Length > 0 ? names[0] : lead.FullName;
        var lastName = names.Length > 1 ? names[1] : "";

        var memberCount = await _context.Members.CountAsync();
        var memberCode = $"GIX-{1000 + memberCount + 1}";
        var branchId = request.BranchId ?? lead.BranchId;

        var member = new Member
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            MemberCode = memberCode,
            FirstName = firstName,
            LastName = lastName,
            Email = lead.Email,
            Phone = lead.Phone,
            Gender = "Unspecified",
            Address = request.Address ?? "",
            EmergencyContactName = request.EmergencyContactName ?? "",
            EmergencyContactPhone = request.EmergencyContactPhone ?? "",
            JoiningDate = DateTime.UtcNow.Date,
            AssignedTrainerId = null,
            Status = MemberStatus.Active,
            MedicalNotes = lead.Notes,
            CreatedAt = DateTime.UtcNow
        };

        _context.Members.Add(member);

        // If plan is requested, create subscription
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
                    Notes = $"Conversion enrollment: {plan.Name}",
                    CreatedAt = DateTime.UtcNow
                };
                _context.MemberSubscriptions.Add(sub);

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
                    TransactionReference = $"CONV_{DateTime.UtcNow.Ticks}",
                    Notes = $"Initial dues for {plan.Name}",
                    CreatedAt = DateTime.UtcNow
                };
                _context.PaymentTransactions.Add(payment);
            }
        }

        // Update lead status
        lead.Stage = LeadStage.Converted;
        lead.UpdatedAt = DateTime.UtcNow;

        _context.LeadActivities.Add(new LeadActivity
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            LeadId = lead.Id,
            ActivityType = "Converted",
            Description = $"Successfully converted lead to Member {member.FullName} ({member.MemberCode}).",
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync();

        return Ok(new MemberDto(
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

    [HttpDelete("{id:guid}")]
    [Authorize]
    public async Task<ActionResult> DeleteLead(Guid id)
    {
        var lead = await _context.Leads.FindAsync(id);
        if (lead == null) return NotFound(new { message = "Lead not found." });

        _context.Leads.Remove(lead);
        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = "Lead removed successfully." });
    }
}
