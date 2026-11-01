import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import 'shimmer_loader.dart';

class AppSkeletonLoader extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const AppSkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static Widget card({double height = 160}) {
    return AppSkeletonLoader(
      height: height,
      borderRadius: DesignTokens.radiusMd,
    );
  }

  static Widget metricCard() {
    return const AppSkeletonLoader(
      height: 120,
      borderRadius: DesignTokens.radiusMd,
    );
  }

  static Widget tableRow({int columns = 5}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: List.generate(
          columns,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: const AppSkeletonLoader(
                height: 20,
                borderRadius: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget tableRows({int rows = 5, int columns = 5}) {
    return Column(
      children: List.generate(rows, (_) => tableRow(columns: columns)),
    );
  }
}
