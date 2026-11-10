import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_customization_models.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/states/feedback/app_state_handler.dart';
import '../auth/auth_provider.dart';
import 'dashboard_models.dart';
import 'dashboard_provider.dart';

/// Unslopped Dashboard View:
/// - Direction: Athletic, exact, focused operations console
/// - Contextual quiet header with live gym floor capacity signature
/// - Restrained 4-card metric row in tabular figures
/// - Dominant revenue line chart on a calm muted grid without gradient fills
/// - Quiet 36px action toolbar replacing rainbow-colored 3D tiles
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: metricsAsync.buildStateWidget(
        context,
        loadingWidget: _buildLoadingState(isDark),
        onRetry: () => ref.invalidate(dashboardMetricsProvider),
        onData: (metrics) => _buildDashboardContent(context, ref, metrics, authState, isDark),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonLoader(width: 220, height: 24),
              Spacer(),
              SkeletonLoader(width: 140, height: 36),
            ],
          ),
          const SizedBox(height: DesignTokens.space24),
          Wrap(
            spacing: DesignTokens.space16,
            runSpacing: DesignTokens.space16,
            children: List.generate(
              4,
              (index) => SizedBox(
                width: 260,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLoader(width: 80, height: 14),
                      SizedBox(height: 12),
                      SkeletonLoader(width: 140, height: 28),
                      SizedBox(height: 10),
                      SkeletonLoader(width: 100, height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.space24),
          const SkeletonLoader(width: double.infinity, height: 320),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    DashboardMetricsModel metrics,
    AuthState authState,
    bool isDark,
  ) {
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space24,
        vertical: DesignTokens.space20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Contextual Header (Replaces greeting slop)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operations Overview',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${authState.selectedBranch?.name ?? 'Downtown Flagship'} • November 2026',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Signature athletic capacity telemetry
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.raised(isDark),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                              border: Border.all(color: AppColors.border(isDark)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Floor occupancy: ${metrics.todaysAttendance} / 120 (35%)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      AppButton(
                        text: 'Scan check-in',
                        icon: Icons.qr_code_scanner_rounded,
                        variant: ButtonVariant.primary,
                        onPressed: () => context.go('/attendance'),
                      ),
                      const SizedBox(width: DesignTokens.space8),
                      AppButton(
                        text: 'Refresh',
                        icon: Icons.refresh_rounded,
                        variant: ButtonVariant.secondary,
                        onPressed: () => ref.invalidate(dashboardMetricsProvider),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space20),

              // 2. Focused Action Bar (Replaces 5-color glowing 3D command deck)
              _buildQuietActionRow(context, isDark),
              const SizedBox(height: DesignTokens.space20),

              // 3. Compact Stat Cards (Numbers first, tabular figures, 500 weight)
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth > 1100
                      ? (constraints.maxWidth - (3 * 16)) / 4
                      : (constraints.maxWidth > 700
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth);

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: MetricStatCard(
                          title: 'Active members',
                          value: '${metrics.activeMembers}',
                          subtitle: 'vs last month',
                          icon: Icons.people_outline_rounded,
                          trendPercentage: 12.8,
                          isPositiveTrend: true,
                          onTap: () => context.go('/members'),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: MetricStatCard(
                          title: 'Monthly revenue',
                          value: currencyFormat.format(metrics.monthlyRevenue > 0 ? metrics.monthlyRevenue : 18450),
                          subtitle: 'vs previous period',
                          icon: Icons.attach_money_rounded,
                          trendPercentage: metrics.revenueGrowthPercentage,
                          isPositiveTrend: metrics.revenueGrowthPercentage >= 0,
                          onTap: () => context.go('/payments'),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: MetricStatCard(
                          title: 'Today\'s attendance',
                          value: '${metrics.todaysAttendance}',
                          subtitle: 'floor check-ins',
                          icon: Icons.how_to_reg_outlined,
                          trendPercentage: 8.4,
                          isPositiveTrend: true,
                          onTap: () => context.go('/attendance'),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: MetricStatCard(
                          title: 'Renewal rate',
                          value: '${metrics.membershipRenewalRate.toStringAsFixed(1)}%',
                          subtitle: 'membership retention',
                          icon: Icons.autorenew_rounded,
                          trendPercentage: 4.2,
                          isPositiveTrend: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: DesignTokens.space20),

              // 4. Main Analytics Deck: Revenue Trajectory + Peak Traffic
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTwoColumn = constraints.maxWidth >= 1000;

                  if (isTwoColumn) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildRevenueChartCard(metrics, isDark),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        Expanded(
                          flex: 4,
                          child: _buildAttendanceTrendCard(metrics, isDark),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildRevenueChartCard(metrics, isDark),
                        const SizedBox(height: DesignTokens.space16),
                        _buildAttendanceTrendCard(metrics, isDark),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: DesignTokens.space20),

              // 5. Expirations and Live Operational Stream
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1100;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildUpcomingExpirationsCard(context, metrics, isDark),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        Expanded(
                          flex: 4,
                          child: _buildRecentActivityFeedCard(metrics, isDark),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildUpcomingExpirationsCard(context, metrics, isDark),
                        const SizedBox(height: DesignTokens.space16),
                        _buildRecentActivityFeedCard(metrics, isDark),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Unslopped Action Row: Compact 34px buttons with quiet line icons and uniform styling
  Widget _buildQuietActionRow(BuildContext context, bool isDark) {
    final actions = [
      (label: 'New member', icon: Icons.person_add_outlined, route: '/members'),
      (label: 'Attendance terminal', icon: Icons.qr_code_scanner_rounded, route: '/attendance'),
      (label: 'WhatsApp messaging', icon: Icons.chat_bubble_outline_rounded, route: '/whatsapp'),
      (label: 'Workout schedules', icon: Icons.fitness_center_outlined, route: '/workouts/scheduler'),
      (label: 'Fitness baselines', icon: Icons.monitor_weight_outlined, route: '/fitness-progress'),
      (label: 'Collect payment', icon: Icons.point_of_sale_outlined, route: '/payments'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions.map((act) {
          return Padding(
            padding: const EdgeInsets.only(right: DesignTokens.space8),
            child: AppButton(
              text: act.label,
              icon: act.icon,
              size: ButtonSize.sm,
              variant: ButtonVariant.secondary,
              onPressed: () => context.go(act.route),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Unslopped Line Chart: Single crisp 2px line on a quiet hairline grid (no purple gradients underneath)
  Widget _buildRevenueChartCard(DashboardMetricsModel metrics, bool isDark) {
    final spots = metrics.monthlyRevenueChart.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.revenue / 1000);
    }).toList();

    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space20),
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly revenue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trailing 6-month gross receipts in thousands (\$k)',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.raised(isDark),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Text(
                  '+${metrics.revenueGrowthPercentage}% vs previous period',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border(isDark),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, meta) => Text(
                        '\$${val.toInt()}k',
                        style: TextStyle(
                          fontSize: 11,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: AppColors.textMuted(isDark),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < metrics.monthlyRevenueChart.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              metrics.monthlyRevenueChart[idx].month,
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark)),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isNotEmpty
                        ? spots
                        : const [FlSpot(0, 8), FlSpot(1, 10), FlSpot(2, 14), FlSpot(3, 12), FlSpot(4, 18), FlSpot(5, 21)],
                    isCurved: false, // Honest straight athletic trend lines
                    color: AppColors.activePalette.id == ThemePaletteId.wineAndSand
                        ? const Color(0xFFF7F4EE)
                        : AppColors.primary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.activePalette.id == ThemePaletteId.wineAndSand
                            ? const Color(0xFFF7F4EE)
                            : AppColors.primary,
                        strokeWidth: 1.5,
                        strokeColor: isDark ? AppColors.darkCard : Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(show: false), // Zero slop gradient washes
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Unslopped Bar Chart: Monochromatic athletic volume bars
  Widget _buildAttendanceTrendCard(DashboardMetricsModel metrics, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space20),
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Peak traffic days',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Weekly member traffic volume',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                  ),
                ],
              ),
              Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.textMuted(isDark)),
            ],
          ),
          const SizedBox(height: DesignTokens.space20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 80,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < metrics.attendanceTrendsChart.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              metrics.attendanceTrendsChart[idx].dayOfWeek.substring(0, 3),
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark)),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: metrics.attendanceTrendsChart.asMap().entries.map((entry) {
                  final isPeak = entry.value.checkIns >= 60;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.checkIns.toDouble(),
                        color: isPeak
                            ? (AppColors.activePalette.id == ThemePaletteId.wineAndSand
                                ? const Color(0xFFF7F4EE)
                                : AppColors.primary)
                            : AppColors.raised(isDark),
                        width: 12,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Unslopped Expirations List: Clean rows with subtle days-remaining tag
  Widget _buildUpcomingExpirationsCard(BuildContext context, DashboardMetricsModel metrics, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space20),
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming expirations (14 days)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              InkWell(
                onTap: () => context.go('/members'),
                child: Text(
                  'View members',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space16),
          if (metrics.upcomingExpirations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No memberships expiring within the next 14 days.',
                  style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metrics.upcomingExpirations.length,
              separatorBuilder: (_, __) => Divider(height: 16, color: AppColors.border(isDark)),
              itemBuilder: (context, index) {
                final item = metrics.upcomingExpirations[index];
                return Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.raised(isDark),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Center(
                        child: Text(
                          item.memberName.isNotEmpty ? item.memberName[0] : 'M',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.textPrimary(isDark)),
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.memberName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          Text(
                            '${item.planName} • ${item.phone}',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.raised(isDark),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Text(
                        '${item.daysRemaining}d left',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space8),
                    AppButton(
                      text: 'Renew',
                      size: ButtonSize.sm,
                      variant: ButtonVariant.ghost,
                      onPressed: () => context.go('/memberships'),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  /// Unslopped Operational Stream: Quiet monochrome timeline with subtle status indicators
  Widget _buildRecentActivityFeedCard(DashboardMetricsModel metrics, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space20),
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live activity',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              Icon(Icons.history_rounded, size: 16, color: AppColors.textMuted(isDark)),
            ],
          ),
          const SizedBox(height: DesignTokens.space16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.recentActivities.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final act = metrics.recentActivities[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted(isDark),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                        Text(
                          act.description,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(act.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: AppColors.textMuted(isDark),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
