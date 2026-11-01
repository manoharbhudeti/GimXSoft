import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/states/empty_states/no_data_state.dart';
import '../../core/states/feedback/app_state_handler.dart';
import 'collect_payment_dialog.dart';
import 'invoice_preview_dialog.dart';
import 'payments_provider.dart';

class PaymentsView extends ConsumerWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(financialSummaryProvider);
    final paymentsAsync = ref.watch(paymentsListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payments & Billing Ledger',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Revenue tracking, cash, UPI, card, bank wire collections, and receipt records',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    AppButton(
                      text: 'Collect Payment',
                      icon: Icons.add_card_rounded,
                      variant: ButtonVariant.primary,
                      onPressed: () => CollectPaymentDialog.show(context),
                    ),
                    const SizedBox(width: DesignTokens.space12),
                    AppButton(
                      text: 'Refresh',
                      icon: Icons.refresh_rounded,
                      variant: ButtonVariant.ghost,
                      onPressed: () {
                        ref.invalidate(financialSummaryProvider);
                        ref.invalidate(paymentsListProvider);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space20),

            // 1. KPI Financial Cards
            summaryAsync.when(
              loading: () => Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SkeletonLoader(width: double.infinity, height: 110),
                    ),
                  ),
                ),
              ),
              error: (err, _) => const SizedBox.shrink(),
              data: (summary) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth > 1000
                        ? (constraints.maxWidth - (3 * 16)) / 4
                        : (constraints.maxWidth - 16) / 2;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Month-To-Date Revenue',
                            value: '\$${summary.totalRevenueThisMonth.toStringAsFixed(2)}',
                            subtitle: 'Gross revenue aggregate',
                            icon: Icons.payments_rounded,
                            iconColor: AppColors.secondary,
                            trendPercentage: 14.2,
                            isPositiveTrend: true,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Collected Today',
                            value: '\$${summary.totalRevenueToday.toStringAsFixed(2)}',
                            subtitle: 'Daily cashflow',
                            icon: Icons.today_rounded,
                            iconColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Outstanding Dues',
                            value: '\$${summary.pendingDues.toStringAsFixed(2)}',
                            subtitle: 'Pending member balances',
                            icon: Icons.receipt_long_rounded,
                            iconColor: AppColors.warning,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Refunds / Adjustments',
                            value: '\$${summary.totalRefundsThisMonth.toStringAsFixed(2)}',
                            subtitle: 'Processed this month',
                            icon: Icons.undo_rounded,
                            iconColor: AppColors.error,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: DesignTokens.space24),

            // 2. Transactions Table
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History & Invoices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),

            paymentsAsync.buildTableState(
              context,
              onRetry: () => ref.invalidate(paymentsListProvider),
              isEmpty: (payments) => payments.isEmpty,
              emptyWidget: NoDataState.payments(
                onCollectPayment: () => CollectPaymentDialog.show(context),
              ),
              onData: (payments) {
                return GlassCard(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width - 300,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? const Color(0xFF162032) : const Color(0xFFF8FAFC),
                        ),
                        horizontalMargin: DesignTokens.space20,
                        columnSpacing: DesignTokens.space24,
                        columns: const [
                          DataColumn(label: Text('INVOICE')),
                          DataColumn(label: Text('MEMBER')),
                          DataColumn(label: Text('AMOUNT')),
                          DataColumn(label: Text('PAYMENT METHOD')),
                          DataColumn(label: Text('REFERENCE')),
                          DataColumn(label: Text('DATE')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: payments.map((tx) {
                          final isRefunded = tx.status.toLowerCase() == 'refunded';

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  tx.invoiceNumber,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tx.memberName,
                                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
                                    ),
                                    Text(tx.memberCode, style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark))),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$${tx.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isRefunded ? AppColors.error : AppColors.secondary,
                                    decoration: isRefunded ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      tx.paymentMethod.toLowerCase() == 'card'
                                          ? Icons.credit_card
                                          : (tx.paymentMethod.toLowerCase() == 'cash'
                                              ? Icons.money
                                              : (tx.paymentMethod.toLowerCase() == 'upi'
                                                  ? Icons.qr_code
                                                  : Icons.account_balance)),
                                      size: 16,
                                      color: AppColors.textSecondary(isDark),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(tx.paymentMethod),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  tx.transactionReference ?? '-',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
                                ),
                              ),
                              DataCell(
                                Text(
                                  DateFormat('MMM d, yyyy').format(tx.createdAt),
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                                ),
                              ),
                              DataCell(StatusBadge(status: tx.status)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.receipt_long_outlined, size: 18),
                                      tooltip: 'View Receipt',
                                      splashRadius: 18,
                                      onPressed: () => InvoicePreviewDialog.show(context, tx),
                                    ),
                                    if (!isRefunded)
                                      IconButton(
                                        icon: const Icon(Icons.undo_rounded, size: 18, color: AppColors.error),
                                        tooltip: 'Process Refund',
                                        splashRadius: 18,
                                        onPressed: () {
                                          ConfirmDialog.show(
                                            context,
                                            title: 'Refund Payment',
                                            message: 'Are you sure you want to refund \$${tx.amount.toStringAsFixed(2)} for ${tx.invoiceNumber}?',
                                            confirmText: 'Confirm Refund',
                                            isDestructive: true,
                                            onConfirm: () async {
                                              await ref.read(paymentsActionProvider).refundPayment(
                                                    tx.id,
                                                    'Customer request',
                                                  );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Refund processed.')),
                                                );
                                              }
                                            },
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
