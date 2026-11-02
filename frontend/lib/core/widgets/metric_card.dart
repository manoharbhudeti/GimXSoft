import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import 'interactive_3d_card.dart';

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
    this.enable3d = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
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
            ParallaxLayer(
              depth: 14.0,
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.space8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(isDark ? 0.18 : 0.12),
                  borderRadius: DesignTokens.borderMd,
                  border: Border.all(
                    color: iconColor.withOpacity(0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.20),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space12),
        ParallaxLayer(
          depth: 8.0,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.textPrimary(isDark),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.space8),
        Row(
          children: [
            if (trendPercentage != null) ...[
              ParallaxLayer(
                depth: 6.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isPositiveTrend ? AppColors.success : AppColors.error).withOpacity(0.14),
                    borderRadius: DesignTokens.borderXs,
                    border: Border.all(
                      color: (isPositiveTrend ? AppColors.success : AppColors.error).withOpacity(0.3),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isPositiveTrend ? AppColors.success : AppColors.error).withOpacity(0.12),
                        blurRadius: 4.0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                        size: 13,
                        color: isPositiveTrend ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trendPercentage!.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPositiveTrend ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
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
    );

    if (enable3d) {
      return Interactive3DCard(
        onTap: onTap,
        glowColor: iconColor,
        padding: const EdgeInsets.all(DesignTokens.space20),
        child: content,
      );
    }

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space20),
      child: content,
    );
  }
}
