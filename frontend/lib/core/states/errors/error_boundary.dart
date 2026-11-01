import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glass_card.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails details)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
  }

  void _resetError() {
    setState(() {
      _errorDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_errorDetails!);
      }
      return _DefaultErrorFallback(
        details: _errorDetails!,
        onReset: _resetError,
      );
    }

    return widget.child;
  }
}

class _DefaultErrorFallback extends StatelessWidget {
  final FlutterErrorDetails details;
  final VoidCallback onReset;

  const _DefaultErrorFallback({
    required this.details,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingLg),
        child: GlassCard(
          borderRadius: DesignTokens.borderLg,
          padding: const EdgeInsets.all(DesignTokens.spacingXl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bug_report_rounded,
                  color: AppColors.rose,
                  size: 44,
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                Text(
                  kDebugMode
                      ? details.exceptionAsString()
                      : 'An unexpected rendering error occurred. The application remains stable.',
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DesignTokens.spacingLg),
                AppButton(
                  label: 'Reload View',
                  icon: Icons.refresh_rounded,
                  onPressed: onReset,
                  variant: AppButtonVariant.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
