import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/whatsapp/whatsapp_models.dart';
import 'package:frontend/features/whatsapp/whatsapp_provider.dart';
import 'package:frontend/features/whatsapp/widgets/whatsapp_connection_tab.dart';
import 'package:frontend/features/whatsapp/widgets/whatsapp_onboarding_wizard.dart';

void main() {
  group('WhatsApp Simplified Number + OTP Onboarding Tests', () {
    testWidgets('WhatsAppOnboardingWizard renders Step 1 inputs correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WhatsAppOnboardingWizard(
                isDark: true,
                onConnected: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header and explanation
      expect(find.text('Connect Your WhatsApp Business Number'), findsOneWidget);
      expect(find.text('Gym / Business Brand Name'), findsOneWidget);
      expect(find.text('WhatsApp Business Phone Number'), findsOneWidget);
      expect(find.text('Verification Method'), findsOneWidget);
      expect(find.text('Text SMS Message'), findsOneWidget);
      expect(find.text('Automated Voice Call'), findsOneWidget);
      expect(find.text('Connect WhatsApp Business'), findsOneWidget);
      expect(find.textContaining('Meta Coexistence & Number Eligibility'), findsOneWidget);
    });

    testWidgets('WhatsAppOnboardingWizard shows validation toast on empty phone', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WhatsAppOnboardingWizard(
                isDark: false,
                onConnected: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap connect button without entering phone
      await tester.tap(find.text('Connect WhatsApp Business'));
      await tester.pump(const Duration(seconds: 5));

      // Still on step 1
      expect(find.text('Connect Your WhatsApp Business Number'), findsOneWidget);
    });

    testWidgets('WhatsAppConnectionTab renders Connected management screen when integration is active', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));

      final mockConfig = WhatsAppIntegrationModel(
        id: 'cfg-1',
        wabaId: '109283746592837',
        phoneNumberId: '105938472910482',
        displayPhoneNumber: '+91 98765 43210',
        businessPortfolioName: 'Powerhouse Fitness Club',
        connectionStatus: 'Connected',
        healthStatus: 'HEALTHY',
        qualityRating: 'GREEN',
        messagingLimitTier: 'TIER_10K',
        verifiedName: 'Powerhouse Fitness',
        codeVerificationStatus: 'VERIFIED',
        costPerUtilityMessage: 0.005,
        costPerMarketingMessage: 0.025,
        timeZoneId: 'Asia/Kolkata',
        webhookUrl: 'http://localhost:5128/api/whatsapp/webhook',
        webhookVerifyToken: 'GIMXSOFT_WHATSAPP_WEBHOOK_VERIFY_TOKEN',
        webhookStatus: 'OPERATIONAL',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whatsAppConfigProvider.overrideWith((ref) => Future.value(mockConfig)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WhatsAppConnectionTab(isDark: true),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Powerhouse Fitness Club'), findsOneWidget);
      expect(find.textContaining('Phone: +91 98765 43210'), findsOneWidget);
      expect(find.text('Account Quality Rating'), findsOneWidget);
      expect(find.text('GREEN'), findsOneWidget);
      expect(find.text('Daily Messaging Tier'), findsOneWidget);
      expect(find.text('TIER_10K'), findsOneWidget);
      expect(find.text('Webhook Synchronization'), findsOneWidget);
      expect(find.text('OPERATIONAL'), findsOneWidget);
      expect(find.text('Send Test Message'), findsOneWidget);
      expect(find.text('Reconnect Number'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);
    });
  });
}
