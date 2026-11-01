import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import 'payment_models.dart';

class InvoicePreviewDialog extends StatelessWidget {
  final PaymentTransactionModel transaction;

  const InvoicePreviewDialog({super.key, required this.transaction});

  static void show(BuildContext context, PaymentTransactionModel tx) {
    showDialog(
      context: context,
      builder: (context) => InvoicePreviewDialog(transaction: tx),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TITAN FITNESS HUB',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Official Payment Receipt',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                      ),
                    ],
                  ),
                  StatusBadge(status: transaction.status),
                ],
              ),
              const SizedBox(height: DesignTokens.space20),
              const Divider(),
              const SizedBox(height: DesignTokens.space16),

              // Invoice Details Meta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INVOICE NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted(isDark))),
                      const SizedBox(height: 2),
                      Text(transaction.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                      const SizedBox(height: 8),
                      Text('DATE & TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted(isDark))),
                      const SizedBox(height: 2),
                      Text(DateFormat('MMM d, yyyy HH:mm').format(transaction.createdAt)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('BILLED TO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted(isDark))),
                      const SizedBox(height: 2),
                      Text(transaction.memberName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('MEMBER CODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted(isDark))),
                      const SizedBox(height: 2),
                      Text(transaction.memberCode, style: const TextStyle(fontFamily: 'monospace')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space24),

              // Item line table
              Container(
                padding: const EdgeInsets.all(DesignTokens.space16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                  borderRadius: DesignTokens.borderMd,
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted(isDark))),
                        Text('Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted(isDark))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            transaction.notes ?? 'Gym Membership / Access Fee',
                            style: TextStyle(fontSize: 13, color: AppColors.textPrimary(isDark)),
                          ),
                        ),
                        Text(
                          '\$${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount Paid', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '\$${transaction.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space16),

              Text(
                'Payment Channel: ${transaction.paymentMethod}  |  Ref: ${transaction.transactionReference ?? "Direct"}',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
              ),
              const SizedBox(height: DesignTokens.space24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Close',
                    variant: ButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  AppButton(
                    text: 'Print / Save PDF',
                    icon: Icons.print_rounded,
                    variant: ButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receipt sent to printer spooler.')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

