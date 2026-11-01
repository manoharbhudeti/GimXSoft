import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/status_badge.dart';
import 'add_lead_dialog.dart';
import 'lead_models.dart';
import 'leads_provider.dart';

class LeadsKanbanView extends ConsumerWidget {
  const LeadsKanbanView({super.key});

  static const List<String> kPipelineStages = [
    'New',
    'Contacted',
    'Interested',
    'TrialScheduled',
    'TrialCompleted',
    'Converted',
    'Lost',
  ];

  static const Map<String, String> kStageTitles = {
    'New': 'New Inquiries',
    'Contacted': 'Contacted',
    'Interested': 'Qualified / Interested',
    'TrialScheduled': 'Trial Scheduled',
    'TrialCompleted': 'Trial Completed',
    'Converted': 'Won / Converted',
    'Lost': 'Closed / Lost',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leadsAsync = ref.watch(leadsListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Toolbar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leads CRM & Pipeline',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Visual prospect pipeline, stage progression, and conversion management',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    AppButton(
                      text: 'Add Lead',
                      icon: Icons.person_add_alt_rounded,
                      variant: ButtonVariant.primary,
                      onPressed: () => AddLeadDialog.show(context),
                    ),
                    const SizedBox(width: DesignTokens.space12),
                    AppButton(
                      text: 'Refresh',
                      icon: Icons.refresh_rounded,
                      variant: ButtonVariant.ghost,
                      onPressed: () => ref.refresh(leadsListProvider),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space20),

            // Kanban Columns
            Expanded(
              child: leadsAsync.when(
                loading: () => Row(
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SkeletonLoader(width: double.infinity, height: double.infinity),
                      ),
                    ),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text('Error loading leads: $err', style: const TextStyle(color: AppColors.error)),
                ),
                data: (leads) {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: kPipelineStages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, idx) {
                      final stage = kPipelineStages[idx];
                      final stageLeads = leads.where((l) => l.stage.toLowerCase() == stage.toLowerCase()).toList();

                      return _KanbanColumn(
                        stage: stage,
                        title: kStageTitles[stage] ?? stage,
                        leads: stageLeads,
                        isDark: isDark,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanColumn extends ConsumerWidget {
  final String stage;
  final String title;
  final List<LeadModel> leads;
  final bool isDark;

  const _KanbanColumn({
    required this.stage,
    required this.title,
    required this.leads,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double totalEstimated = leads.fold(0.0, (acc, l) => acc + l.estimatedValue);

    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827).withOpacity(0.6) : const Color(0xFFF1F5F9).withOpacity(0.7),
        borderRadius: DesignTokens.borderLg,
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border(isDark))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: DesignTokens.borderFull,
                      ),
                      child: Text(
                        '${leads.length}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${totalEstimated.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted(isDark)),
                ),
              ],
            ),
          ),

          // Cards list
          Expanded(
            child: leads.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No leads in this stage',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: leads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final lead = leads[idx];
                      return _LeadCard(lead: lead, isDark: isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LeadCard extends ConsumerWidget {
  final LeadModel lead;
  final bool isDark;

  const _LeadCard({required this.lead, required this.isDark});

  void _showMoveStageMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Move ${lead.fullName} to Stage',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ...LeadsKanbanView.kPipelineStages.map((stg) {
                return ListTile(
                  title: Text(LeadsKanbanView.kStageTitles[stg] ?? stg),
                  trailing: lead.stage == stg ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    ref.read(leadsActionProvider).updateStage(lead.id, stg);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space12),
      enableHover: true,
      onTap: () => _showMoveStageMenu(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  lead.fullName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: DesignTokens.borderSm,
                ),
                child: Text(
                  '\$${lead.estimatedValue.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 12, color: AppColors.textMuted(isDark)),
              const SizedBox(width: 4),
              Text(lead.phone, style: TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark))),
            ],
          ),
          if (lead.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              lead.notes!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: lead.source, isPill: false),
              if (lead.nextFollowUpDate != null)
                Row(
                  children: [
                    const Icon(Icons.event_outlined, size: 12, color: AppColors.accentOrange),
                    const SizedBox(width: 3),
                    Text(
                      DateFormat('MMM d').format(lead.nextFollowUpDate!),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.accentOrange),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

