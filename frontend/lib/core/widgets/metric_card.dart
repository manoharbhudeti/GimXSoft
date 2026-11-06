import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import 'glass_card.dart';

/// Unslopped Stat Card conforming to heydamir/unslop:
/// - Numbers first: A quiet label, a prominent figure in tabular numbers, and a reference comparison
/// - Sentence case titles (e.g. "Active members", not "TOTAL ACTIVE MEMBERS")
/// - Two weights: 400 and 500 (max 600)
/// - Zero colored glowing orbs or 3D tilts; clean hairline depth
class MetricStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final double? trendPercentage;
  final bool isPositiveTrend;
  final VoidCallback? onTap;
  final bool enable3d;

  const MetricStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.iconColor = AppColors.primary,
    this.trendPercentage,
    this.isPositiveTrend = true,
    this.onTap,
    this.enable3d = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
      enableHover: onTap != null,
      padding: const EdgeInsets.all(DesignTokens.space20),
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Label and Quiet Line Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                icon,
                size: 16,
                color: AppColors.textMuted(isDark),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space12),

          // 2. Main Tabular Figure (28-32px, weight 500)
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.5,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: DesignTokens.space8),

          // 3. Comparison with Reference Context
          Row(
            children: [
              if (trendPercentage != null) ...[
                Text(
                  '${isPositiveTrend ? '+' : ''}${trendPercentage!.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: isPositiveTrend ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  subtitle ?? 'vs last month',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted(isDark),
                  ),
                ),
              ] else if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted(isDark),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
