import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/states/empty_states/no_data_state.dart';
import '../../core/states/empty_states/search_empty_state.dart';
import '../../core/states/feedback/app_state_handler.dart';
import 'add_member_dialog.dart';
import 'member_detail_dialog.dart';
import 'members_provider.dart';

class MembersView extends ConsumerWidget {
  const MembersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final membersAsync = ref.watch(membersListProvider);
    final statusFilter = ref.watch(memberStatusFilterProvider);
    final searchQuery = ref.watch(memberSearchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Toolbar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Member Directory',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage member profiles, membership lifecycles, and check-in history',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    AppButton(
                      text: 'Add Member',
                      icon: Icons.person_add_rounded,
                      variant: ButtonVariant.primary,
                      onPressed: () => AddMemberDialog.show(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space20),

            // 2. Search & Filters Bar
            GlassCard(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hint: 'Search members by name, phone, or member code...',
                      prefixIcon: Icons.search_rounded,
                      onChanged: (val) {
                        ref.read(memberSearchQueryProvider.notifier).set(val);
                      },
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space16),

                  // Filter Pills
                  Wrap(
                    spacing: 6,
                    children: ['All', 'Active', 'Expired', 'Frozen'].map((status) {
                      final isSelected = (status == 'All' && statusFilter == null) || statusFilter == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref.read(memberStatusFilterProvider.notifier).set(
                              status == 'All' ? null : status);
                        },
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary(isDark),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space20),

            // 3. Member Table Content
            membersAsync.buildTableState(
              context,
              onRetry: () => ref.invalidate(membersListProvider),
              isEmpty: (members) => members.isEmpty,
              emptyWidget: (searchQuery.isNotEmpty || statusFilter != null)
                  ? SearchEmptyState(
                      searchQuery: searchQuery,
                      onClear: () {
                        ref.read(memberSearchQueryProvider.notifier).set('');
                        ref.read(memberStatusFilterProvider.notifier).set(null);
                      },
                    )
                  : NoDataState.members(
                      onAddMember: () => AddMemberDialog.show(context),
                    ),
              onData: (members) {
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
                          DataColumn(label: Text('CODE')),
                          DataColumn(label: Text('CONTACT')),
                          DataColumn(label: Text('MEMBERSHIP PLAN')),
                          DataColumn(label: Text('BRANCH')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: members.map((m) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primary.withOpacity(0.2),
                                      child: Text(
                                        m.firstName.isNotEmpty ? m.firstName[0] : 'M',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: DesignTokens.space12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          m.fullName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary(isDark),
                                          ),
                                        ),
                                        if (m.assignedTrainerName != null)
                                          Text(
                                            'Trainer: ${m.assignedTrainerName}',
                                            style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                                    borderRadius: DesignTokens.borderSm,
                                  ),
                                  child: Text(
                                    m.memberCode,
                                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(m.email, style: TextStyle(fontSize: 12, color: AppColors.textPrimary(isDark))),
                                    Text(m.phone, style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark))),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  m.currentPlanName ?? 'None',
                                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary(isDark)),
                                ),
                              ),
                              DataCell(
                                Text(
                                  m.branchName ?? 'Main Facility',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                                ),
                              ),
                              DataCell(StatusBadge(status: m.status)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, size: 18),
                                      tooltip: 'View Profile',
                                      splashRadius: 18,
                                      onPressed: () => MemberDetailDialog.show(context, m.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.archive_outlined, size: 18, color: AppColors.error),
                                      tooltip: 'Archive Member',
                                      splashRadius: 18,
                                      onPressed: () {
                                        ConfirmDialog.show(
                                          context,
                                          title: 'Archive Member',
                                          message: 'Are you sure you want to deactivate ${m.fullName}? Their membership will be marked as inactive.',
                                          confirmText: 'Archive',
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
