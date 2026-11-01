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
public class MembershipsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public MembershipsController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet("plans")]
    public async Task<ActionResult<List<MembershipPlanDto>>> GetPlans()
    {
        var plans = await _context.MembershipPlans
            .Include(p => p.Subscriptions)
            .OrderBy(p => p.Price)
            .Select(p => new MembershipPlanDto(
                p.Id,
                p.TenantId,
                p.Name,
                p.Description,
                p.DurationDays,
                p.Price,
                p.RegistrationFee,
                p.BenefitsJson,
                p.IsPersonalTraining,
                p.IncludedSessions,
                p.IsActive,
                p.Subscriptions.Count(s => s.Status == SubscriptionStatus.Active),
                p.CreatedAt
            ))
            .ToListAsync();

        return Ok(plans);
    }

    [HttpPost("plans")]
    public async Task<ActionResult<MembershipPlanDto>> CreatePlan([FromBody] CreatePlanRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();

        var plan = new MembershipPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            Name = request.Name.Trim(),
            Description = request.Description ?? "",
            DurationDays = request.DurationDays > 0 ? request.DurationDays : 30,
            Price = request.Price,
            RegistrationFee = request.RegistrationFee,
            BenefitsJson = request.BenefitsJson ?? "[]",
            IsPersonalTraining = request.IsPersonalTraining,
            IncludedSessions = request.IncludedSessions,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.MembershipPlans.Add(plan);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetPlans), new { id = plan.Id }, new MembershipPlanDto(
            plan.Id,
            plan.TenantId,
            plan.Name,
            plan.Description,
            plan.DurationDays,
            plan.Price,
            plan.RegistrationFee,
            plan.BenefitsJson,
            plan.IsPersonalTraining,
            plan.IncludedSessions,
            plan.IsActive,
            0,
            plan.CreatedAt
        ));
    }

    [HttpPut("plans/{id}")]
    public async Task<ActionResult> UpdatePlan(Guid id, [FromBody] UpdatePlanRequest request)
    {
        var plan = await _context.MembershipPlans.FindAsync(id);
        if (plan == null) return NotFound(new { message = "Plan not found." });

        plan.Name = request.Name.Trim();
        plan.Description = request.Description ?? "";
        plan.DurationDays = request.DurationDays;
        plan.Price = request.Price;
        plan.RegistrationFee = request.RegistrationFee;
        plan.BenefitsJson = request.BenefitsJson ?? "[]";
        plan.IsPersonalTraining = request.IsPersonalTraining;
        plan.IncludedSessions = request.IncludedSessions;
        plan.IsActive = request.IsActive;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("subscriptions")]
    public async Task<ActionResult<List<MemberSubscriptionDto>>> GetSubscriptions(
        [FromQuery] Guid? memberId,
        [FromQuery] SubscriptionStatus? status)
    {
        var query = _context.MemberSubscriptions
            .Include(s => s.Member)
            .Include(s => s.MembershipPlan)
            .AsQueryable();

        if (memberId.HasValue)
        {
            query = query.Where(s => s.MemberId == memberId.Value);
        }

        if (status.HasValue)
        {
            query = query.Where(s => s.Status == status.Value);
        }

        var subs = await query
            .OrderByDescending(s => s.CreatedAt)
            .Take(100)
            .Select(s => new MemberSubscriptionDto(
                s.Id,
                s.TenantId,
                s.MemberId,
                s.Member != null ? s.Member.FullName : null,
                s.MembershipPlanId,
                s.MembershipPlan != null ? s.MembershipPlan.Name : "Plan",
                s.StartDate,
                s.EndDate,
                s.PricePaid,
                s.DiscountAmount,
                s.Status.ToString(),
                s.FreezeStartDate,
                s.FreezeEndDate,
                s.Notes,
                s.CreatedAt
            ))
            .ToListAsync();

        return Ok(subs);
    }

    [HttpPost("subscribe")]
    public async Task<ActionResult<MemberSubscriptionDto>> SubscribeMember([FromBody] SubscribeMemberRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();
        var member = await _context.Members.FindAsync(request.MemberId);
        if (member == null) return NotFound(new { message = "Member not found." });

        var plan = await _context.MembershipPlans.FindAsync(request.MembershipPlanId);
        if (plan == null) return NotFound(new { message = "Membership plan not found." });

        var startDate = request.StartDate ?? DateTime.UtcNow.Date;
        var endDate = startDate.AddDays(plan.DurationDays);
        var finalPrice = (request.CustomPrice ?? plan.Price) - request.DiscountAmount;

        var sub = new MemberSubscription
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            MemberId = member.Id,
            MembershipPlanId = plan.Id,
            StartDate = startDate,
            EndDate = endDate,
            PricePaid = finalPrice,
            DiscountAmount = request.DiscountAmount,
            Status = SubscriptionStatus.Active,
            Notes = request.Notes,
            CreatedAt = DateTime.UtcNow
        };
        _context.MemberSubscriptions.Add(sub);

        // Record payment
        var txCount = await _context.PaymentTransactions.CountAsync();
        var payment = new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = member.BranchId,
            MemberId = member.Id,
            SubscriptionId = sub.Id,
            InvoiceNumber = $"INV-{DateTime.UtcNow.Year}-{1000 + txCount + 1}",
            Amount = finalPrice,
            PaymentMethod = request.PaymentMethod,
            Status = PaymentStatus.Completed,
            TransactionReference = $"REF_{DateTime.UtcNow.Ticks}",
            Notes = $"Subscription payment for {plan.Name}",
            CreatedAt = DateTime.UtcNow
        };
        _context.PaymentTransactions.Add(payment);

        member.Status = MemberStatus.Active;

        await _context.SaveChangesAsync();

        return Ok(new MemberSubscriptionDto(
            sub.Id,
            sub.TenantId,
            sub.MemberId,
            member.FullName,
            plan.Id,
            plan.Name,
            sub.StartDate,
            sub.EndDate,
            sub.PricePaid,
            sub.DiscountAmount,
            sub.Status.ToString(),
            sub.FreezeStartDate,
            sub.FreezeEndDate,
            sub.Notes,
            sub.CreatedAt
        ));
    }

    [HttpPost("subscriptions/{id}/freeze")]
    public async Task<ActionResult> FreezeSubscription(Guid id, [FromBody] FreezeSubscriptionRequest request)
    {
        var sub = await _context.MemberSubscriptions
            .Include(s => s.Member)
            .FirstOrDefaultAsync(s => s.Id == id);

        if (sub == null) return NotFound(new { message = "Subscription not found." });

        sub.Status = SubscriptionStatus.Frozen;
        sub.FreezeStartDate = request.FreezeStartDate;
        sub.FreezeEndDate = request.FreezeEndDate;
        sub.Notes = $"{sub.Notes} | Frozen: {request.Reason}".Trim();

        // Also update member status to Frozen
        if (sub.Member != null)
        {
            sub.Member.Status = MemberStatus.Frozen;
        }

        await _context.SaveChangesAsync();
        return Ok(new { success = true, message = "Membership frozen successfully." });
    }

    [HttpPost("subscriptions/{id}/unfreeze")]
    public async Task<ActionResult> UnfreezeSubscription(Guid id)
    {
        var sub = await _context.MemberSubscriptions
            .Include(s => s.Member)
            .FirstOrDefaultAsync(s => s.Id == id);

        if (sub == null) return NotFound(new { message = "Subscription not found." });

        // Extend end date by duration frozen
        if (sub.FreezeStartDate.HasValue)
        {
            var frozenDays = (DateTime.UtcNow.Date - sub.FreezeStartDate.Value.Date).Days;
            if (frozenDays > 0)
            {
                sub.EndDate = sub.EndDate.AddDays(frozenDays);
            }
        }

        sub.Status = SubscriptionStatus.Active;
        sub.FreezeStartDate = null;
        sub.FreezeEndDate = null;

        if (sub.Member != null)
        {
            sub.Member.Status = MemberStatus.Active;
        }

        await _context.SaveChangesAsync();
        return Ok(new { success = true, message = "Membership unfrozen successfully." });
    }

    [HttpPost("subscriptions/{id}/cancel")]
    public async Task<ActionResult> CancelSubscription(Guid id)
    {
        var sub = await _context.MemberSubscriptions.FindAsync(id);
        if (sub == null) return NotFound(new { message = "Subscription not found." });

        sub.Status = SubscriptionStatus.Cancelled;
        await _context.SaveChangesAsync();
        return Ok(new { success = true, message = "Subscription cancelled." });
    }
}

