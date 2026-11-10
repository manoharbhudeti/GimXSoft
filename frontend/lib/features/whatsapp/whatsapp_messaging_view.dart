import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/states/feedback/app_state_handler.dart';
import '../../core/states/success/app_toast.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import 'whatsapp_provider.dart';
import 'widgets/whatsapp_campaigns_tab.dart';
import 'widgets/whatsapp_connection_tab.dart';
import 'widgets/whatsapp_dashboard_tab.dart';
import 'widgets/whatsapp_inbox_tab.dart';
import 'widgets/whatsapp_templates_tab.dart';

class WhatsAppMessagingView extends ConsumerStatefulWidget {
  const WhatsAppMessagingView({super.key});

  @override
  ConsumerState<WhatsAppMessagingView> createState() => _WhatsAppMessagingViewState();
}

class _WhatsAppMessagingViewState extends ConsumerState<WhatsAppMessagingView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTriggerTitle(String eventKey) {
    switch (eventKey) {
      case 'OnPaymentCompleted':
        return 'Instant Tax Invoice & Payment Receipt Alert';
      case 'OnMembershipExpiring':
        return '7-Day Membership Expiry Warning & UPI Renewal Link';
      case 'OnMemberJoined':
        return 'New Member Onboarding Journey & Trainer Introduction';
      case 'OnInactivity':
        return '14-Day Inactivity Check-in & Workout Motivation';
      default:
        return eventKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 28),
                    ),
                    const SizedBox(width: DesignTokens.space12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WhatsApp Business Dashboard',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Meta Cloud API • 1-on-1 Athlete Chat • Automated Triggers • Campaigns • Workouts',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: const [
                    StatusBadge(status: 'Active'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: isDark ? Colors.white : AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary(isDark),
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.analytics_rounded, size: 18), text: 'Analytics Dashboard'),
                  Tab(icon: Icon(Icons.chat_bubble_outline_rounded, size: 18), text: 'Conversation Inbox (3-Panel)'),
                  Tab(icon: Icon(Icons.campaign_outlined, size: 18), text: 'Broadcast Campaigns'),
                  Tab(icon: Icon(Icons.fact_check_rounded, size: 18), text: 'Message Templates'),
                  Tab(icon: Icon(Icons.auto_mode_rounded, size: 18), text: 'Automated Triggers'),
                  Tab(icon: Icon(Icons.hub_outlined, size: 18), text: 'Meta WABA Connection'),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space16),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  WhatsAppDashboardTab(isDark: isDark),
                  WhatsAppInboxTab(isDark: isDark),
                  WhatsAppCampaignsTab(isDark: isDark),
                  WhatsAppTemplatesTab(isDark: isDark),
                  _buildAutomatedTriggersTab(isDark),
                  WhatsAppConnectionTab(isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutomatedTriggersTab(bool isDark) {
    final triggersAsync = ref.watch(whatsAppTriggersProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Trigger Automation Rules',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Configure automatic WhatsApp notifications dispatched on core operational events in real time',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
          ),
          const SizedBox(height: DesignTokens.space16),

          triggersAsync.buildStateWidget(
            context,
            onRetry: () => ref.refresh(whatsAppTriggersProvider),
            onData: (triggers) {
              return Column(
                children: triggers.map((rule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(DesignTokens.space16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bolt_rounded, color: Color(0xFF25D366), size: 24),
                          ),
                          const SizedBox(width: DesignTokens.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatTriggerTitle(rule.triggerEvent),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Linked Meta Template: ${rule.templateName}',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: rule.isEnabled,
                            activeThumbColor: const Color(0xFF25D366),
                            onChanged: (val) async {
                              await ref.read(whatsAppActionProvider).toggleTrigger(rule.triggerEvent, val);
                              ref.read(toastProvider.notifier).info(
                                    'Trigger Updated',
                                    message: '${_formatTriggerTitle(rule.triggerEvent)} is now ${val ? "enabled" : "disabled"}.',
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
