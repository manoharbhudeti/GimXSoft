import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/widgets/interactive_3d_card.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/metric_card.dart';

void main() {
  group('3D & Interactive UI Elements Tests', () {
    testWidgets('Interactive3DCard renders child with 3D perspective structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Interactive3DCard(
              enableTilt: true,
              enableGlare: true,
              child: Text('3D Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('3D Card Content'), findsOneWidget);
      expect(find.byType(Interactive3DCard), findsOneWidget);
      expect(find.byType(Interactive3DCardScope), findsOneWidget);
    });

    testWidgets('ParallaxLayer respects Interactive3DCardScope tilt offset', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Interactive3DCardScope(
              tiltOffset: Offset(0.5, -0.5),
              isHovered: true,
              child: ParallaxLayer(
                depth: 10.0,
                child: Text('Parallax Floating Badge'),
              ),
            ),
          ),
        ),
      );

      final textWidget = find.text('Parallax Floating Badge');
      expect(textWidget, findsOneWidget);

      final transformFinder = find.ancestor(
        of: textWidget,
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsWidgets);

      final Transform transform = tester.widget(transformFinder.first);
      // Translation offset should be (0.5 * 10, -0.5 * 10) = (5.0, -5.0)
      expect(transform.transform.getTranslation().x, closeTo(5.0, 0.001));
      expect(transform.transform.getTranslation().y, closeTo(-5.0, 0.001));
    });

    testWidgets('AppButton renders tactile 3D elements and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Tactile 3D Action',
              enable3d: true,
              variant: ButtonVariant.primary,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Tactile 3D Action'), findsOneWidget);

      // Perform tap
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('MetricStatCard integrates 3D tilt and ParallaxLayer widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricStatCard(
              title: 'Active Gym Members',
              value: '1,250',
              icon: Icons.people,
              trendPercentage: 15.4,
              enable3d: true,
            ),
          ),
        ),
      );

      expect(find.text('ACTIVE GYM MEMBERS'), findsOneWidget);
      expect(find.text('1,250'), findsOneWidget);
      expect(find.text('15.4%'), findsOneWidget);
      expect(find.byType(Interactive3DCard), findsOneWidget);
      expect(find.byType(ParallaxLayer), findsNWidgets(3));
    });
  });
}

