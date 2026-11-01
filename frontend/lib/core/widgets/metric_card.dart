import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import 'glass_card.dart';

class MetricStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final double? trendPercentage;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      enableHover: true,
      onTap: onTap,
      padding: const EdgeInsets.all(DesignTokens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted(isDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(DesignTokens.space8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(isDark ? 0.15 : 0.10),
                  borderRadius: DesignTokens.borderMd,
                  border: Border.all(color: iconColor.withOpacity(0.25), width: 1),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          Row(
            children: [
              if (trendPercentage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositiveTrend ? AppColors.success : AppColors.error).withOpacity(0.12),
                    borderRadius: DesignTokens.borderXs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                        size: 13,
                        color: isPositiveTrend ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${trendPercentage!.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isPositiveTrend ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DesignTokens.space8),
              ],
              if (subtitle != null)
                Expanded(
                  child: Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted(isDark),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

