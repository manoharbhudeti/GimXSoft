import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';

class ProgressLoader extends StatelessWidget {
  final double? value;
  final String? label;
  final String? subLabel;
  final bool isLinear;

  const ProgressLoader({
    super.key,
    this.value,
    this.label,
    this.subLabel,
    this.isLinear = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isLinear) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 4,
              backgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: DesignTokens.spacingMd),
            Text(
              label!,
              style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || value != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (value != null)
                Text(
                  '${(value! * 100).toInt()}%',
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet),
          ),
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 6),
          Text(
            subLabel!,
            style: TextStyle(
              color: AppColors.textMuted(isDark),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

