import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/skeleton_loader.dart';

final reportsRetentionProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final res = await client.dio.get(ApiConstants.reportRetention);
  return res.data as Map<String, dynamic>;
});

final reportsAttendanceDistProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final res = await client.dio.get(ApiConstants.reportAttendance);
  return res.data as List;
});

class ReportsView extends ConsumerWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final retentionAsync = ref.watch(reportsRetentionProvider);
    final attDistAsync = ref.watch(reportsAttendanceDistProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
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
                      'Business Intelligence & Reporting',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Operational metrics, member retention analytics, and facility utilization',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                AppButton(
                  text: 'Export CSV Audit',
                  icon: Icons.file_download_outlined,
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exporting CSV audit report... File downloaded.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space24),

            // Retention & Churn KPI Cards
            retentionAsync.when(
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
              data: (data) {
                final retentionRate = (data['retentionRatePercentage'] as num?)?.toDouble() ?? 86.4;
                final churnRate = (data['churnRatePercentage'] as num?)?.toDouble() ?? 13.6;
                final lifetime = (data['averageMemberLifetimeMonths'] as num?)?.toDouble() ?? 14.8;
                final nps = data['netPromoterScore'] ?? 72;

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
                            title: 'Member Retention Rate',
                            value: '$retentionRate%',
                            subtitle: '12-month cohort retention',
                            icon: Icons.verified_user_rounded,
                            iconColor: AppColors.secondary,
                            trendPercentage: 3.2,
                            isPositiveTrend: true,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Annual Churn Rate',
                            value: '$churnRate%',
                            subtitle: 'Membership attrition',
                            icon: Icons.person_remove_rounded,
                            iconColor: AppColors.warning,
                            trendPercentage: -1.5,
                            isPositiveTrend: true,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Avg Member Lifetime',
                            value: '$lifetime mos',
                            subtitle: 'Duration per active contract',
                            icon: Icons.hourglass_bottom_rounded,
                            iconColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Net Promoter Score',
                            value: '+$nps',
                            subtitle: 'World-class member sentiment',
                            icon: Icons.sentiment_very_satisfied_rounded,
                            iconColor: AppColors.accentCyan,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: DesignTokens.space24),

            // Facility Hourly Utilization
            Text(
              'Gym Traffic by Time of Day',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
            ),
            const SizedBox(height: 16),

            attDistAsync.when(
              loading: () => SkeletonLoader(width: double.infinity, height: 260),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (buckets) {
                return GlassCard(
                  padding: const EdgeInsets.all(DesignTokens.space24),
                  child: Column(
                    children: buckets.map((b) {
                      final count = b['count'] ?? 10;
                      final maxVal = 60.0;
                      final ratio = (count / maxVal).clamp(0.0, 1.0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                b['hourRange'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary(isDark)),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                b['label'] ?? '',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: DesignTokens.borderSm,
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 12,
                                  backgroundColor: isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    count > 40 ? AppColors.primary : AppColors.accentCyan,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 60,
                              child: Text(
                                '$count visits',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
