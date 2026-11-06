import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/landing/landing_view.dart';
import 'package:frontend/features/landing/interactive_3d_stage.dart';

void main() {
  testWidgets('LandingView renders hero, 3D stage, and interactive simulator', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LandingView(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify Top Bar, Email Pill and Hero Headlines
    expect(find.text('GimXSoft'), findsWidgets);
    expect(find.text('Smarter gym operations.\nExact member telemetry.'), findsOneWidget);
    expect(find.textContaining('ekametechnologie@gmail.com'), findsWidgets);
    expect(find.text('Try 1 Month Free (₹2,000 after trial)'), findsOneWidget);

    // 2. Verify 2D Zeus Stage widget is present
    expect(find.byType(Interactive3DStage), findsOneWidget);

    // 3. Verify Live Simulator Section
    expect(find.text('Live interactive console'), findsOneWidget);
    expect(find.text('Tap Member RFID / Scan QR'), findsOneWidget);
  });

  testWidgets('Interactive Simulator check-in workflow increments capacity and simulates WhatsApp dispatch', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LandingView(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify initial capacity count in simulator
    expect(find.textContaining('42 / 120 capacity'), findsWidgets);

    // Scroll to the simulator section
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -450));
    await tester.pump(const Duration(milliseconds: 100));

    final scanButton = find.text('Tap Member RFID / Scan QR');
    expect(scanButton, findsOneWidget);

    await tester.tap(scanButton);
    await tester.pump(); // Trigger scan processing

    // Allow simulated scan processing delay (600ms in widget)
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify member name appeared in scanner telemetry
    expect(find.textContaining('Marcus Vance'), findsWidgets);
    // Occupancy should have incremented to 43
    expect(find.textContaining('43 / 120 capacity'), findsWidgets);

    // Drain the status reset timer (3000ms)
    await tester.pump(const Duration(milliseconds: 3200));
  });

  testWidgets('Pricing section explains 1 month free trial then ₹2,000 only with all included features', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LandingView(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Scroll down to the pricing section
    final pricingHeading = find.text('1-Month Free Trial, Then ₹2,000 Only');
    await tester.scrollUntilVisible(
      pricingHeading,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify pricing heading and badge
    expect(pricingHeading, findsOneWidget);
    expect(find.text('TRY 1 MONTH FREE (₹2,000 AFTER)'), findsOneWidget);
    expect(find.text('₹2,000'), findsWidgets);

    // Verify key features included
    expect(find.text('1-on-1 Individual WhatsApp messaging for any member (Meta Cloud API)'), findsOneWidget);
    expect(find.text('Turnstile RFID & QR attendance integration (99.98% uptime)'), findsOneWidget);
    expect(find.text('7-Day workout routine splits builder & exercise movement library'), findsOneWidget);
    expect(find.text('Member biometrics, BMI progress & body composition tracking'), findsOneWidget);
    expect(find.text('Automated UPI QR payments & GST tax invoice PDF generation'), findsOneWidget);
  });

  testWidgets('LandingView guarantees free billing for 1 month, cancel anytime, and zero payment registration', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LandingView(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 1. Verify 4-box metrics counter is completely removed
    expect(find.text('650+'), findsNothing);
    expect(find.text('420K+'), findsNothing);
    expect(find.text('Turnstile gateway uptime'), findsNothing);

    // 2. Verify Zero-Risk Pillars are prominently displayed in the KPI bar
    expect(find.text('Free billing'), findsWidgets);
    expect(find.text('Cancel'), findsWidgets);
    expect(find.text('Anytime'), findsWidgets);
    expect(find.text('No payment needed'), findsWidgets);

    // 3. Verify Trial Dialog opens with zero-payment registration form
    final trialBtn = find.text('Try 1 Month Free (₹2,000 after trial)').first;
    await tester.tap(trialBtn);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Start 1-Month Free Trial'), findsWidgets);
    expect(find.text('Claim 1-Month Free (₹0)'), findsOneWidget);
    expect(find.text('Gym / Fitness Club Name'), findsOneWidget);
    expect(find.text('Already an existing admin or customer? Sign in →'), findsOneWidget);
  });
}
