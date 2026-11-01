using System.ComponentModel.DataAnnotations;
using GimXSoft.Api.Entities;

namespace GimXSoft.Api.DTOs;

public record PaymentTransactionDto(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    string? BranchName,
    Guid MemberId,
    string MemberName,
    string MemberCode,
    Guid? SubscriptionId,
    string? PlanName,
    string InvoiceNumber,
    decimal Amount,
    string PaymentMethod,
    string Status,
    string? TransactionReference,
    string? Notes,
    DateTime CreatedAt
);

public record CollectPaymentRequest(
    Guid BranchId,
    Guid MemberId,
    Guid? SubscriptionId,
    [Required] decimal Amount,
    PaymentMethod PaymentMethod,
    string? TransactionReference,
    string? Notes
);

public record PaymentRefundRequest(
    [Required] string Reason,
    decimal? RefundAmount
);

public record FinancialSummaryDto(
    decimal TotalRevenueThisMonth,
    decimal TotalRevenueToday,
    decimal PendingDues,
    decimal TotalRefundsThisMonth,
    decimal CashTotal,
    decimal UpiTotal,
    decimal CardTotal,
    decimal BankTransferTotal,
    List<PaymentTransactionDto> RecentTransactions
);

