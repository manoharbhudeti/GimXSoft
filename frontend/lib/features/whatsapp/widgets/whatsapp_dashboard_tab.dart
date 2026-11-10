import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/states/feedback/app_state_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../whatsapp_models.dart';
import '../whatsapp_provider.dart';

class WhatsAppDashboardTab extends ConsumerStatefulWidget {
  final bool isDark;
  const WhatsAppDashboardTab({super.key, required this.isDark});

  @override
  ConsumerState<WhatsAppDashboardTab> createState() => _WhatsAppDashboardTabState();
}

class _WhatsAppDashboardTabState extends ConsumerState<WhatsAppDashboardTab> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(whatsAppDashboardAnalyticsProvider(_selectedDays));

    return analyticsAsync.buildStateWidget(
      context,
      onRetry: () => ref.refresh(whatsAppDashboardAnalyticsProvider(_selectedDays)),
      onData: (data) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Account Overview & Live Health Banner
            _buildAccountHealthBanner(data),
            const SizedBox(height: DesignTokens.space20),

            // 2. Filter Bar & Quick Stats Headline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Messaging & Campaign Telemetry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(widget.isDark),
                      ),
                    ),
                    Text(
                      'Aggregated official Meta Cloud API telemetry across member conversations',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                    ),
                  ],
                ),
                // Days Filter Segment
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    border: Border.all(color: AppColors.border(widget.isDark)),
                  ),
                  child: Row(
                    children: [7, 14, 30].map((d) {
                      final isSelected = _selectedDays == d;
                      return InkWell(
                        onTap: () => setState(() => _selectedDays = d),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$d Days',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textSecondary(widget.isDark),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),

            // 3. Primary KPI Metric Cards
            Row(
              children: [
                Expanded(
                  child: MetricStatCard(
                    title: 'Total Dispatched',
                    value: '${data.totalSent}',
                    icon: Icons.send_rounded,
                    iconColor: AppColors.primary,
                    subtitle: '${data.activeConversations} active athlete chats',
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                Expanded(
                  child: MetricStatCard(
                    title: 'Delivered Messages',
                    value: '${data.totalDelivered}',
                    icon: Icons.done_all_rounded,
                    iconColor: AppColors.success,
                    subtitle: '${data.deliveryRate}% delivery SLA rate',
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                Expanded(
                  child: MetricStatCard(
                    title: 'Read & Opened',
                    value: '${data.totalRead}',
                    icon: Icons.mark_email_read_rounded,
                    iconColor: AppColors.info,
                    subtitle: '${data.readRate}% member engagement',
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                Expanded(
                  child: MetricStatCard(
                    title: 'Delivery Failures',
                    value: '${data.totalFailed}',
                    icon: Icons.error_outline_rounded,
                    iconColor: data.totalFailed > 0 ? AppColors.error : AppColors.textMuted(widget.isDark),
                    subtitle: data.totalFailed > 0 ? 'Diagnostic details below' : 'Zero delivery anomalies',
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space24),

            // 4. Trend Charts & Breakdown Split
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily Trend Bar Chart Visualization
                Expanded(
                  flex: 7,
                  child: GlassCard(
                    padding: const EdgeInsets.all(DesignTokens.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Outbound vs Inbound Volume (Daily)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(widget.isDark),
                              ),
                            ),
                            Row(
                              children: [
                                _buildLegendIndicator('Outbound', AppColors.primary),
                                const SizedBox(width: 12),
                                _buildLegendIndicator('Inbound', AppColors.success),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 180,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: data.dailyTrends.map((trend) {
                              final maxVal = 50.0;
                              final sentHeight = (trend.sent / maxVal * 140).clamp(6.0, 140.0);
                              final recvHeight = (trend.received / maxVal * 140).clamp(6.0, 140.0);

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: sentHeight,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Container(
                                            width: 10,
                                            height: recvHeight,
                                            decoration: BoxDecoration(
                                              color: AppColors.success,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        trend.date.length >= 5 ? trend.date.substring(5) : trend.date,
                                        style: TextStyle(fontSize: 10, color: AppColors.textMuted(widget.isDark)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),

                // Campaigns & Templates Summary Card
                Expanded(
                  flex: 5,
                  child: GlassCard(
                    padding: const EdgeInsets.all(DesignTokens.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campaign & Template Ecosystem',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(widget.isDark),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow(
                          icon: Icons.campaign_rounded,
                          title: 'Broadcast Campaigns',
                          value: '${data.totalCampaigns} Total (${data.activeCampaigns} Active, ${data.completedCampaigns} Done)',
                          color: AppColors.primary,
                        ),
                        const Divider(height: 20),
                        _buildSummaryRow(
                          icon: Icons.fact_check_rounded,
                          title: 'Meta Approved Templates',
                          value: '${data.approvedTemplates} Approved, ${data.pendingTemplates} Reviewing',
                          color: AppColors.success,
                        ),
                        const Divider(height: 20),
                        _buildSummaryRow(
                          icon: Icons.schedule_send_rounded,
                          title: 'Queue & Triggers',
                          value: '${data.pendingMessages} Messages Scheduled',
                          color: AppColors.warning,
                        ),
                        const Divider(height: 20),
                        _buildSummaryRow(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Unread Athlete Inquiries',
                          value: '${data.unreadConversations} Requiring Front Desk Reply',
                          color: data.unreadConversations > 0 ? AppColors.warning : AppColors.textMuted(widget.isDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountHealthBanner(WhatsAppDashboardAnalyticsModel data) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: AppColors.raised(widget.isDark),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: AppColors.border(widget.isDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: const Center(
                  child: Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 26),
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        data.verifiedName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(widget.isDark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: data.connectionStatus),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Connected: ${data.displayPhoneNumber}  •  WABA: ${data.wabaId}',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildBadgePill(
                label: 'Rating: ${data.qualityRating}',
                color: data.qualityRating == 'GREEN' ? AppColors.success : AppColors.warning,
                icon: Icons.verified_user_rounded,
              ),
              const SizedBox(width: 10),
              _buildBadgePill(
                label: 'Tier: ${data.messagingLimitTier}',
                color: AppColors.primary,
                icon: Icons.speed_rounded,
              ),
              const SizedBox(width: 10),
              _buildBadgePill(
                label: 'Webhook: ${data.webhookHealth}',
                color: AppColors.success,
                icon: Icons.sync_alt_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgePill({required String label, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary(widget.isDark))),
      ],
    );
  }

  Widget _buildSummaryRow({required IconData icon, required String title, required String value, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark))),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
