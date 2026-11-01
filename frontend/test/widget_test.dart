import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/core/widgets/glass_card.dart';
import 'package:frontend/core/widgets/metric_card.dart';
import 'package:frontend/core/widgets/status_badge.dart';

void main() {
  test('DesignTokens and Colors integrity test', () {
    expect(AppColors.primary, isNotNull);
    expect(AppColors.secondary, isNotNull);
    expect(DesignTokens.space24, equals(24.0));
  });

  testWidgets('StatusBadge renders correct status and colors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: 'Active'),
        ),
      ),
    );

    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('GlassCard renders child with glass decoration', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            child: Text('Glassmorphic Test'),
          ),
        ),
      ),
    );

    expect(find.text('Glassmorphic Test'), findsOneWidget);
  });

  testWidgets('MetricStatCard renders title, value and trend', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricStatCard(
            title: 'Active Members',
            value: '420',
            icon: Icons.people,
            trendPercentage: 12.5,
          ),
        ),
      ),
    );

    expect(find.text('ACTIVE MEMBERS'), findsOneWidget);
    expect(find.text('420'), findsOneWidget);
    expect(find.text('12.5%'), findsOneWidget);
  });
}
