class PaymentTransactionModel {
  final String id;
  final String tenantId;
  final String branchId;
  final String? branchName;
  final String memberId;
  final String memberName;
  final String memberCode;
  final String? subscriptionId;
  final String? planName;
  final String invoiceNumber;
  final double amount;
  final String paymentMethod;
  final String status;
  final String? transactionReference;
  final String? notes;
  final DateTime createdAt;

  const PaymentTransactionModel({
    required this.id,
    required this.tenantId,
    required this.branchId,
    this.branchName,
    required this.memberId,
    required this.memberName,
    required this.memberCode,
    this.subscriptionId,
    this.planName,
    required this.invoiceNumber,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionReference,
    this.notes,
    required this.createdAt,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      branchName: json['branchName'],
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName'] ?? 'Member',
      memberCode: json['memberCode'] ?? '',
      subscriptionId: json['subscriptionId']?.toString(),
      planName: json['planName'],
      invoiceNumber: json['invoiceNumber'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      status: json['status'] ?? 'Completed',
      transactionReference: json['transactionReference'],
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class FinancialSummaryModel {
  final double totalRevenueThisMonth;
  final double totalRevenueToday;
  final double pendingDues;
  final double totalRefundsThisMonth;
  final double cashTotal;
  final double upiTotal;
  final double cardTotal;
  final double bankTransferTotal;
  final List<PaymentTransactionModel> recentTransactions;

  const FinancialSummaryModel({
    required this.totalRevenueThisMonth,
    required this.totalRevenueToday,
    required this.pendingDues,
    required this.totalRefundsThisMonth,
    required this.cashTotal,
    required this.upiTotal,
    required this.cardTotal,
    required this.bankTransferTotal,
    required this.recentTransactions,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryModel(
      totalRevenueThisMonth: (json['totalRevenueThisMonth'] as num?)?.toDouble() ?? 0.0,
      totalRevenueToday: (json['totalRevenueToday'] as num?)?.toDouble() ?? 0.0,
      pendingDues: (json['pendingDues'] as num?)?.toDouble() ?? 0.0,
      totalRefundsThisMonth: (json['totalRefundsThisMonth'] as num?)?.toDouble() ?? 0.0,
      cashTotal: (json['cashTotal'] as num?)?.toDouble() ?? 0.0,
      upiTotal: (json['upiTotal'] as num?)?.toDouble() ?? 0.0,
      cardTotal: (json['cardTotal'] as num?)?.toDouble() ?? 0.0,
      bankTransferTotal: (json['bankTransferTotal'] as num?)?.toDouble() ?? 0.0,
      recentTransactions: (json['recentTransactions'] as List? ?? [])
          .map((e) => PaymentTransactionModel.fromJson(e))
          .toList(),
    );
  }
}

