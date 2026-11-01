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
public class PaymentsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public PaymentsController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet]
    public async Task<ActionResult<List<PaymentTransactionDto>>> GetPayments(
        [FromQuery] Guid? branchId,
        [FromQuery] PaymentMethod? method,
        [FromQuery] PaymentStatus? status,
        [FromQuery] string? search)
    {
        var query = _context.PaymentTransactions
            .Include(p => p.Branch)
            .Include(p => p.Member)
            .Include(p => p.Subscription)
                .ThenInclude(s => s!.MembershipPlan)
            .AsQueryable();

        if (branchId.HasValue) query = query.Where(p => p.BranchId == branchId.Value);
        if (method.HasValue) query = query.Where(p => p.PaymentMethod == method.Value);
        if (status.HasValue) query = query.Where(p => p.Status == status.Value);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.ToLower().Trim();
            query = query.Where(p =>
                p.InvoiceNumber.ToLower().Contains(s) ||
                (p.Member != null && (p.Member.FirstName.ToLower().Contains(s) || p.Member.LastName.ToLower().Contains(s) || p.Member.MemberCode.ToLower().Contains(s))) ||
                (p.TransactionReference != null && p.TransactionReference.ToLower().Contains(s)));
        }

        var list = await query
            .OrderByDescending(p => p.CreatedAt)
            .Take(100)
            .Select(p => new PaymentTransactionDto(
                p.Id,
                p.TenantId,
                p.BranchId,
                p.Branch != null ? p.Branch.Name : null,
                p.MemberId,
                p.Member != null ? p.Member.FullName : "Direct Payment",
                p.Member != null ? p.Member.MemberCode : "-",
                p.SubscriptionId,
                p.Subscription != null && p.Subscription.MembershipPlan != null ? p.Subscription.MembershipPlan.Name : null,
                p.InvoiceNumber,
                p.Amount,
                p.PaymentMethod.ToString(),
                p.Status.ToString(),
                p.TransactionReference,
                p.Notes,
                p.CreatedAt
            ))
            .ToListAsync();

        return Ok(list);
    }

    [HttpPost("collect")]
    public async Task<ActionResult<PaymentTransactionDto>> CollectPayment([FromBody] CollectPaymentRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();
        var member = await _context.Members.FindAsync(request.MemberId);
        if (member == null) return NotFound(new { message = "Member not found." });

        if (request.Amount <= 0)
        {
            return BadRequest(new { message = "Payment amount must be greater than 0." });
        }

        var count = await _context.PaymentTransactions.CountAsync();
        var invoiceNumber = $"INV-{DateTime.UtcNow.Year}-{1000 + count + 1}";

        var payment = new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId != Guid.Empty ? request.BranchId : member.BranchId,
            MemberId = member.Id,
            SubscriptionId = request.SubscriptionId,
            InvoiceNumber = invoiceNumber,
            Amount = request.Amount,
            PaymentMethod = request.PaymentMethod,
            Status = PaymentStatus.Completed,
            TransactionReference = request.TransactionReference ?? $"MAN_{DateTime.UtcNow.Ticks}",
            Notes = request.Notes,
            CreatedAt = DateTime.UtcNow
        };

        _context.PaymentTransactions.Add(payment);
        await _context.SaveChangesAsync();

        var branch = await _context.Branches.FindAsync(payment.BranchId);

        return Ok(new PaymentTransactionDto(
            payment.Id,
            payment.TenantId,
            payment.BranchId,
            branch?.Name,
            member.Id,
            member.FullName,
            member.MemberCode,
            payment.SubscriptionId,
            null,
            payment.InvoiceNumber,
            payment.Amount,
            payment.PaymentMethod.ToString(),
            payment.Status.ToString(),
            payment.TransactionReference,
            payment.Notes,
            payment.CreatedAt
        ));
    }

    [HttpPost("{id}/refund")]
    public async Task<ActionResult> RefundPayment(Guid id, [FromBody] PaymentRefundRequest request)
    {
        var payment = await _context.PaymentTransactions.FindAsync(id);
        if (payment == null) return NotFound(new { message = "Payment transaction not found." });

        if (payment.Status == PaymentStatus.Refunded)
        {
            return BadRequest(new { message = "This payment has already been refunded." });
        }

        payment.Status = PaymentStatus.Refunded;
        payment.Notes = $"{payment.Notes} | Refunded on {DateTime.UtcNow:yyyy-MM-dd}: {request.Reason}".Trim(' ', '|');

        // Log audit trail
        var audit = new AuditLog
        {
            Id = Guid.NewGuid(),
            TenantId = payment.TenantId,
            UserId = _tenantService.UserId,
            Action = "PaymentRefund",
            EntityName = "PaymentTransaction",
            EntityId = payment.Id.ToString(),
            Details = $"Refund processed for Invoice {payment.InvoiceNumber}, Amount: ${payment.Amount}. Reason: {request.Reason}",
            Timestamp = DateTime.UtcNow
        };
        _context.AuditLogs.Add(audit);

        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = $"Invoice {payment.InvoiceNumber} refunded successfully." });
    }

    [HttpGet("financial-summary")]
    public async Task<ActionResult<FinancialSummaryDto>> GetFinancialSummary([FromQuery] Guid? branchId)
    {
        var now = DateTime.UtcNow;
        var startOfMonth = new DateTime(now.Year, now.Month, 1);
        var today = now.Date;

        var query = _context.PaymentTransactions
            .Include(p => p.Member)
            .AsQueryable();

        if (branchId.HasValue)
        {
            query = query.Where(p => p.BranchId == branchId.Value);
        }

        var completedThisMonth = query.Where(p => p.CreatedAt >= startOfMonth && p.Status == PaymentStatus.Completed);

        var totalMonth = await completedThisMonth.SumAsync(p => p.Amount);
        var totalToday = await query.Where(p => p.CreatedAt >= today && p.Status == PaymentStatus.Completed).SumAsync(p => p.Amount);

        var refundsMonth = await query
            .Where(p => p.CreatedAt >= startOfMonth && p.Status == PaymentStatus.Refunded)
            .SumAsync(p => p.Amount);

        var cash = await completedThisMonth.Where(p => p.PaymentMethod == PaymentMethod.Cash).SumAsync(p => p.Amount);
        var upi = await completedThisMonth.Where(p => p.PaymentMethod == PaymentMethod.UPI).SumAsync(p => p.Amount);
        var card = await completedThisMonth.Where(p => p.PaymentMethod == PaymentMethod.Card).SumAsync(p => p.Amount);
        var bank = await completedThisMonth.Where(p => p.PaymentMethod == PaymentMethod.BankTransfer).SumAsync(p => p.Amount);

        var recent = await query
            .OrderByDescending(p => p.CreatedAt)
            .Take(10)
            .Select(p => new PaymentTransactionDto(
                p.Id,
                p.TenantId,
                p.BranchId,
                null,
                p.MemberId,
                p.Member != null ? p.Member.FullName : "Member",
                p.Member != null ? p.Member.MemberCode : "-",
                p.SubscriptionId,
                null,
                p.InvoiceNumber,
                p.Amount,
                p.PaymentMethod.ToString(),
                p.Status.ToString(),
                p.TransactionReference,
                p.Notes,
                p.CreatedAt
            ))
            .ToListAsync();

        return Ok(new FinancialSummaryDto(
            totalMonth,
            totalToday,
            PendingDues: 380.00m,
            refundsMonth,
            cash,
            upi,
            card,
            bank,
            recent
        ));
    }
}
