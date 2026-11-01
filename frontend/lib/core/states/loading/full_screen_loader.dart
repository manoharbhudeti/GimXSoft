import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import 'inline_loader.dart';

class FullScreenLoader extends StatelessWidget {
  final String? message;
  final double? progress;

  const FullScreenLoader({
    super.key,
    this.message,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Semi-transparent backdrop blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            color: Colors.black.withOpacity(isDark ? 0.65 : 0.35),
          ),
        ),
        // Central glass panel
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingXl,
              vertical: DesignTokens.spacingLg * 1.5,
            ),
            margin: const EdgeInsets.all(DesignTokens.spacingLg),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161922) : Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const InlineLoader(size: 38),
                const SizedBox(height: DesignTokens.spacingLg),
                Text(
                  message ?? 'Processing...',
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (progress != null) ...[
                  const SizedBox(height: DesignTokens.spacingMd),
                  SizedBox(
                    width: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress! * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
