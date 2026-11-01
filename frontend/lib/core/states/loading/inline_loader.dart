import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class InlineLoader extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const InlineLoader({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 2.5,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.violet;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        ),
      ),
    );
  }
}
