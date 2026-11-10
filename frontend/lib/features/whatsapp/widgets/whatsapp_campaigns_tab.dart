import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/states/feedback/app_state_handler.dart';
import '../../../core/states/success/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../whatsapp_provider.dart';

class WhatsAppCampaignsTab extends ConsumerStatefulWidget {
  final bool isDark;
  const WhatsAppCampaignsTab({super.key, required this.isDark});

  @override
  ConsumerState<WhatsAppCampaignsTab> createState() => _WhatsAppCampaignsTabState();
}

class _WhatsAppCampaignsTabState extends ConsumerState<WhatsAppCampaignsTab> {
  void _openCreateCampaignDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final msgCtrl = TextEditingController(
      text: 'Hi {{name}}! Titan Fitness is hosting a special Saturday HIIT conditioning blast at 8 AM. Confirm your spot by replying YES!',
    );
    String selectedAudience = 'AllActive';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: widget.isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            side: BorderSide(color: AppColors.border(widget.isDark)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Create Broadcast Campaign',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(widget.isDark),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Campaign Title',
                    controller: nameCtrl,
                    hint: 'e.g. Summer Fitness Blast',
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Internal Notes / Purpose (Optional)',
                    controller: descCtrl,
                    hint: 'Retention, event notice, seasonal offer...',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Target Gym Audience Segment',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary(widget.isDark)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.raised(widget.isDark),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      border: Border.all(color: AppColors.border(widget.isDark)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedAudience,
                        isExpanded: true,
                        dropdownColor: widget.isDark ? AppColors.darkCard : Colors.white,
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary(widget.isDark)),
                        items: const [
                          DropdownMenuItem(value: 'AllActive', child: Text('All Active Gym Members')),
                          DropdownMenuItem(value: 'ExpiringIn7Days', child: Text('Expiring in 7 Days (Renewal Alert)')),
                          DropdownMenuItem(value: 'ExpiredIn30Days', child: Text('Expired in Last 30 Days (Win-Back)')),
                          DropdownMenuItem(value: 'NewMembersLast14Days', child: Text('New Members (Last 14 Days Onboarding)')),
                        ],
                        onChanged: (val) => setDialogState(() => selectedAudience = val ?? 'AllActive'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Message Content (Meta Template / Freeform)',
                    controller: msgCtrl,
                    maxLines: 4,
                    hint: 'Use {{name}} for dynamic member greeting...',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ℹ️ Messages are dispatched via official Meta Cloud API with rate limiting and suppression checks.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.textMuted(widget.isDark))),
            ),
            AppButton(
              label: 'Launch Campaign',
              icon: Icons.rocket_launch_rounded,
              isLoading: isSubmitting,
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || msgCtrl.text.trim().isEmpty) {
                  ref.read(toastProvider.notifier).error('Validation Error', message: 'Name and message are required.');
                  return;
                }

                setDialogState(() => isSubmitting = true);

                final ok = await ref.read(whatsAppActionProvider).createCampaign(
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                      audienceSegment: selectedAudience,
                      messageContent: msgCtrl.text.trim(),
                    );

                setDialogState(() => isSubmitting = false);

                if (context.mounted) {
                  Navigator.pop(ctx);
                  if (ok) {
                    ref.read(toastProvider.notifier).success(
                          'Campaign Dispatched',
                          message: 'Broadcast campaign queued and dispatched to target athletes.',
                        );
                  } else {
                    ref.read(toastProvider.notifier).error(
                          'Campaign Failed',
                          message: 'Could not create campaign.',
                        );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(whatsAppCampaignsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Broadcast Campaigns & Segmented Blasts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(widget.isDark),
                  ),
                ),
                Text(
                  'Send segmented notifications to active, expiring, or prospective members via Meta Cloud API',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                ),
              ],
            ),
            AppButton(
              label: 'Create Campaign',
              icon: Icons.add_rounded,
              onPressed: _openCreateCampaignDialog,
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space16),

        // Campaign List
        Expanded(
          child: campaignsAsync.buildStateWidget(
            context,
            onRetry: () => ref.refresh(whatsAppCampaignsProvider),
            onData: (campaigns) {
              if (campaigns.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, size: 48, color: AppColors.textMuted(widget.isDark)),
                      const SizedBox(height: 12),
                      Text(
                        'No WhatsApp Campaigns Created',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create targeted blasts for renewals, holiday schedules, or fitness workshops.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Launch First Campaign',
                        icon: Icons.rocket_launch_rounded,
                        onPressed: _openCreateCampaignDialog,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: campaigns.length,
                separatorBuilder: (_, __) => const SizedBox(height: DesignTokens.space12),
                itemBuilder: (context, index) {
                  final camp = campaigns[index];

                  return GlassCard(
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  camp.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(widget.isDark),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                  ),
                                  child: Text(
                                    camp.audienceSegment,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                StatusBadge(status: camp.status),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM dd, HH:mm').format(camp.createdAt),
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          camp.messageContent,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary(widget.isDark)),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Telemetry stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildStatPill('Recipients', '${camp.totalRecipients}', Icons.people_alt_rounded),
                                const SizedBox(width: 16),
                                _buildStatPill('Sent', '${camp.sentCount}', Icons.send_rounded),
                                const SizedBox(width: 16),
                                _buildStatPill('Delivered', '${camp.deliveredCount}', Icons.done_all_rounded, color: AppColors.success),
                                const SizedBox(width: 16),
                                _buildStatPill('Read', '${camp.readCount}', Icons.mark_email_read_rounded, color: AppColors.info),
                                if (camp.failedCount > 0) ...[
                                  const SizedBox(width: 16),
                                  _buildStatPill('Failed', '${camp.failedCount}', Icons.error_outline_rounded, color: AppColors.error),
                                ],
                              ],
                            ),
                            Text(
                              'Dispatched via Meta Cloud API',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon, {Color? color}) {
    final effectiveColor = color ?? AppColors.textPrimary(widget.isDark);
    return Row(
      children: [
        Icon(icon, size: 14, color: effectiveColor),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark)),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: effectiveColor),
        ),
      ],
    );
  }
}
