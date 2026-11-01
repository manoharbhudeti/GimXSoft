import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/status_badge.dart';
import 'add_plan_dialog.dart';
import 'membership_models.dart';
import 'memberships_provider.dart';

class MembershipsView extends ConsumerWidget {
  const MembershipsView({super.key});

  void _showFreezeDialog(BuildContext context, WidgetRef ref, MemberSubscriptionModel sub) {
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    final reasonCtrl = TextEditingController(text: 'Travel / Vacation Freeze');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: GlassCard(
                  padding: const EdgeInsets.all(DesignTokens.space24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.ac_unit_rounded, color: AppColors.accentCyan),
                          const SizedBox(width: DesignTokens.space8),
                          Text(
                            'Freeze Membership',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      Text(
                        'Pause ${sub.memberName ?? 'Member'}\'s subscription. The end date will be automatically extended upon reactivation.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                      ),
                      const SizedBox(height: DesignTokens.space16),
                      Text(
                        'Freeze Start Date',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE, MMM d, yyyy').format(startDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      Text(
                        'Expected Unfreeze Date',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE, MMM d, yyyy').format(endDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: DesignTokens.space24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            text: 'Cancel',
                            variant: ButtonVariant.ghost,
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          const SizedBox(width: DesignTokens.space12),
                          AppButton(
                            text: 'Confirm Freeze',
                            variant: ButtonVariant.primary,
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              final ok = await ref.read(membershipActionProvider).freezeSubscription(
                                    sub.id,
                                    startDate,
                                    endDate,
                                    reasonCtrl.text.trim(),
                                  );
                              if (ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Membership successfully frozen.'),
                                    backgroundColor: AppColors.accentCyan,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plansAsync = ref.watch(membershipPlansProvider);
    final subsAsync = ref.watch(memberSubscriptionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
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
                      'Membership Plans & Passes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure membership tiers, pricing models, benefits, and active subscription lifecycles',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                AppButton(
                  text: 'Create Plan',
                  icon: Icons.add_rounded,
                  variant: ButtonVariant.primary,
                  onPressed: () => AddPlanDialog.show(context),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space20),

            // 1. Membership Plans Cards Grid
            plansAsync.when(
              loading: () => Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SkeletonLoader(width: double.infinity, height: 220),
                    ),
                  ),
                ),
              ),
              error: (err, _) => Center(child: Text('Error loading plans: $err')),
              data: (plans) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth > 1100
                        ? (constraints.maxWidth - (3 * 16)) / 4
                        : (constraints.maxWidth > 700
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth);

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: plans.map((plan) {
                        List<dynamic> benefits = [];
                        try {
                          benefits = jsonDecode(plan.benefitsJson) as List;
                        } catch (_) {}

                        return SizedBox(
                          width: cardWidth,
                          child: GlassCard(
                            padding: const EdgeInsets.all(DesignTokens.space20),
                            enableHover: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        plan.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(isDark),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.12),
                                        borderRadius: DesignTokens.borderSm,
                                      ),
                                      child: Text(
                                        '${plan.durationDays} Days',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '\$${plan.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary(isDark),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '/ term',
                                      style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  plan.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 12),
                                ...benefits.take(3).map((b) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.secondary),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              b.toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${plan.activeSubscribersCount} Active Subscribers',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted(isDark)),
                                    ),
                                    if (plan.isPersonalTraining)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary.withOpacity(0.12),
                                          borderRadius: DesignTokens.borderXs,
                                        ),
                                        child: Text(
                                          '${plan.includedSessions} PT Sessions',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: DesignTokens.space32),

            // 2. Active Member Subscriptions Ledger
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Member Subscriptions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                AppButton(
                  text: 'Refresh Subscriptions',
                  icon: Icons.refresh_rounded,
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.sm,
                  onPressed: () => ref.refresh(memberSubscriptionsProvider),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),

            subsAsync.when(
              loading: () => SkeletonLoader(width: double.infinity, height: 260),
              error: (err, _) => Center(child: Text('Error loading subscriptions: $err')),
              data: (subs) {
                if (subs.isEmpty) {
                  return GlassCard(
                    padding: const EdgeInsets.all(DesignTokens.space32),
                    child: Center(
                      child: Text('No subscriptions on record.', style: TextStyle(color: AppColors.textMuted(isDark))),
                    ),
                  );
                }

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
                          DataColumn(label: Text('MEMBER')),
                          DataColumn(label: Text('PLAN')),
                          DataColumn(label: Text('DURATION / DATES')),
                          DataColumn(label: Text('PRICE PAID')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: subs.map((sub) {
                          final isFrozen = sub.status.toLowerCase() == 'frozen';

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  sub.memberName ?? 'Member',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
                                ),
                              ),
                              DataCell(Text(sub.planName)),
                              DataCell(
                                Text(
                                  '${DateFormat('MMM d, yyyy').format(sub.startDate)} → ${DateFormat('MMM d, yyyy').format(sub.endDate)}',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$${sub.pricePaid.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                                ),
                              ),
                              DataCell(StatusBadge(status: sub.status)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isFrozen)
                                      AppButton(
                                        text: 'Unfreeze',
                                        size: ButtonSize.sm,
                                        variant: ButtonVariant.outline,
                                        onPressed: () async {
                                          await ref.read(membershipActionProvider).unfreezeSubscription(sub.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Membership unfrozen.')),
                                            );
                                          }
                                        },
                                      )
                                    else
                                      AppButton(
                                        text: 'Freeze',
                                        size: ButtonSize.sm,
                                        variant: ButtonVariant.ghost,
                                        icon: Icons.ac_unit_rounded,
                                        onPressed: () => _showFreezeDialog(context, ref, sub),
                                      ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                                      tooltip: 'Cancel Subscription',
                                      splashRadius: 18,
                                      onPressed: () {
                                        ConfirmDialog.show(
                                          context,
                                          title: 'Cancel Subscription',
                                          message: 'Cancel membership for ${sub.memberName}?',
                                          confirmText: 'Cancel Plan',
                                          isDestructive: true,
                                          onConfirm: () {},
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
