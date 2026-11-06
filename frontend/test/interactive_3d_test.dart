import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/widgets/interactive_3d_card.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/metric_card.dart';

void main() {
  group('Unslopped Interactive UI Elements Tests', () {
    testWidgets('Interactive3DCard renders child with clean surface structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Interactive3DCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(Interactive3DCard), findsOneWidget);
      expect(find.byType(Interactive3DCardScope), findsOneWidget);
    });

    testWidgets('ParallaxLayer renders cleanly and stably', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Interactive3DCardScope(
              isHovered: true,
              child: ParallaxLayer(
                depth: 10.0,
                child: Text('Stable Content Layer'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Stable Content Layer'), findsOneWidget);
    });

    testWidgets('AppButton renders tactile button and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Tactile Action',
              variant: ButtonVariant.primary,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Tactile Action'), findsOneWidget);

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('MetricStatCard renders sentence case title and tabular figure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricStatCard(
              title: 'Active Gym Members',
              value: '1,250',
              icon: Icons.people_outline,
              trendPercentage: 15.4,
            ),
          ),
        ),
      );

      expect(find.text('Active Gym Members'), findsOneWidget);
      expect(find.text('1,250'), findsOneWidget);
      expect(find.text('+15.4%'), findsOneWidget);
    });
  });
}
