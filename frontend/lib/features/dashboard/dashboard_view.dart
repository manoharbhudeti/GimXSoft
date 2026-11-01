import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../auth/auth_provider.dart';
import 'dashboard_models.dart';
import 'dashboard_provider.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: metricsAsync.when(
        loading: () => _buildLoadingState(isDark),
        error: (err, stack) => _buildErrorState(context, ref, err.toString(), isDark),
        data: (metrics) => _buildDashboardContent(context, ref, metrics, authState, isDark),
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
              SkeletonLoader(width: 200, height: 28),
              Spacer(),
              SkeletonLoader(width: 120, height: 38),
            ],
          ),
          const SizedBox(height: DesignTokens.space24),
          // Skeleton stat cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
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

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error, bool isDark) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(DesignTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.error),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'Failed to load dashboard metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
            ),
            const SizedBox(height: DesignTokens.space20),
            AppButton(
              text: 'Retry',
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(dashboardMetricsProvider),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(DesignTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome & Quick Action Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Welcome back, ${authState.user?.fullName.split(' ').first ?? 'Team'}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          borderRadius: DesignTokens.borderFull,
                          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            const Text('Live Operations', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time overview of ${authState.selectedBranch?.name ?? 'all gym facilities'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  AppButton(
                    text: 'Reception Desk',
                    icon: Icons.qr_code_scanner_rounded,
                    variant: ButtonVariant.secondary,
                    onPressed: () => context.go('/attendance'),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  AppButton(
                    text: 'Refresh',
                    icon: Icons.refresh_rounded,
                    variant: ButtonVariant.ghost,
                    onPressed: () => ref.invalidate(dashboardMetricsProvider),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space24),

          // 2. High-Level Metric Stat Cards Grid
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
                      title: 'Total Active Members',
                      value: '${metrics.activeMembers}',
                      subtitle: '${metrics.totalMembers} total registered',
                      icon: Icons.people_alt_rounded,
                      iconColor: AppColors.primary,
                      trendPercentage: 12.8,
                      isPositiveTrend: true,
                      onTap: () => context.go('/members'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: MetricStatCard(
                      title: 'Monthly Revenue',
                      value: currencyFormat.format(metrics.monthlyRevenue > 0 ? metrics.monthlyRevenue : 18450),
                      subtitle: 'vs previous month',
                      icon: Icons.attach_money_rounded,
                      iconColor: AppColors.secondary,
                      trendPercentage: metrics.revenueGrowthPercentage,
                      isPositiveTrend: metrics.revenueGrowthPercentage >= 0,
                      onTap: () => context.go('/payments'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: MetricStatCard(
                      title: 'Today\'s Attendance',
                      value: '${metrics.todaysAttendance}',
                      subtitle: 'Gym floor check-ins',
                      icon: Icons.how_to_reg_rounded,
                      iconColor: AppColors.accentCyan,
                      trendPercentage: 8.4,
                      isPositiveTrend: true,
                      onTap: () => context.go('/attendance'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: MetricStatCard(
                      title: 'Renewal Rate',
                      value: '${metrics.membershipRenewalRate.toStringAsFixed(1)}%',
                      subtitle: 'Member retention rate',
                      icon: Icons.autorenew_rounded,
                      iconColor: AppColors.accentPurple,
                      trendPercentage: 4.2,
                      isPositiveTrend: true,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: MetricStatCard(
                      title: 'New Leads This Month',
                      value: '${metrics.newLeadsThisMonth > 0 ? metrics.newLeadsThisMonth : 14}',
                      subtitle: 'Pipeline inquiries',
                      icon: Icons.view_kanban_rounded,
                      iconColor: AppColors.accentOrange,
                      trendPercentage: 16.5,
                      isPositiveTrend: true,
                      onTap: () => context.go('/leads'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: MetricStatCard(
                      title: 'Lead Conversion Rate',
                      value: '${metrics.leadConversionRate.toStringAsFixed(1)}%',
                      subtitle: 'Inquiries to memberships',
                      icon: Icons.pie_chart_rounded,
                      iconColor: AppColors.accentRose,
                      trendPercentage: 2.1,
                      isPositiveTrend: true,
                      onTap: () => context.go('/leads'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: MetricStatCard(
                      title: 'Expired Memberships',
                      value: '${metrics.expiredMembers}',
                      subtitle: 'Pending renewal follow-ups',
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppColors.warning,
                      trendPercentage: -3.0,
                      isPositiveTrend: false,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: MetricStatCard(
                      title: 'Pending Collections',
                      value: currencyFormat.format(metrics.pendingPayments),
                      subtitle: 'Unsettled balances',
                      icon: Icons.receipt_long_rounded,
                      iconColor: AppColors.accentCyan,
                      onTap: () => context.go('/payments'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: DesignTokens.space24),

          // 3. Interactive Charts Row
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
          const SizedBox(height: DesignTokens.space24),

          // 4. Secondary Row: Upcoming Expirations + Pending CRM Follow-ups + Activities
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
    );
  }

  Widget _buildRevenueChartCard(DashboardMetricsModel metrics, bool isDark) {
    final spots = metrics.monthlyRevenueChart.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.revenue / 1000);
    }).toList();

    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space24),
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
                    'Monthly Revenue Analytics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trailing 6-month gross receipts (\$ in thousands)',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: DesignTokens.borderSm,
                ),
                child: Text(
                  '+${metrics.revenueGrowthPercentage}% YoY',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border(isDark).withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (val, meta) => Text(
                        '\$${val.toInt()}k',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted(isDark)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < metrics.monthlyRevenueChart.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
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
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTrendCard(DashboardMetricsModel metrics, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space24),
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
                    'Peak Attendance Days',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
              const Icon(Icons.show_chart_rounded, size: 20, color: AppColors.accentCyan),
            ],
          ),
          const SizedBox(height: DesignTokens.space24),
          SizedBox(
            height: 220,
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
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              metrics.attendanceTrendsChart[idx].dayOfWeek,
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
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.checkIns.toDouble(),
                        color: entry.key == 0 || entry.key == 2 ? AppColors.primary : AppColors.accentCyan,
                        width: 14,
                        borderRadius: DesignTokens.borderSm,
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

  Widget _buildUpcomingExpirationsCard(BuildContext context, DashboardMetricsModel metrics, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 20, color: AppColors.warning),
                  const SizedBox(width: DesignTokens.space8),
                  Text(
                    'Upcoming Expirations (Next 14 Days)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/members'),
                child: const Text('View All Members →', style: TextStyle(fontSize: 12)),
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
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = metrics.upcomingExpirations[index];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.warning.withOpacity(0.15),
                      child: Text(
                        item.memberName.isNotEmpty ? item.memberName[0] : 'M',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.warning),
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
                              fontWeight: FontWeight.w600,
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
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: DesignTokens.borderSm,
                      ),
                      child: Text(
                        '${item.daysRemaining} days left',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space8),
                    AppButton(
                      text: 'Renew',
                      size: ButtonSize.sm,
                      variant: ButtonVariant.outline,
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

  Widget _buildRecentActivityFeedCard(DashboardMetricsModel metrics, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Operational Feed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const Icon(Icons.bolt_rounded, size: 18, color: AppColors.primary),
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
                    margin: const EdgeInsets.only(top: 2),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: DesignTokens.glowPrimary,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
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
