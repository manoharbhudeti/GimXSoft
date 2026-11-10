import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/whatsapp/whatsapp_models.dart';
import 'package:frontend/features/whatsapp/whatsapp_provider.dart';
import 'package:frontend/features/whatsapp/whatsapp_messaging_view.dart';
import 'package:frontend/features/whatsapp/widgets/whatsapp_dashboard_tab.dart';
import 'package:frontend/features/whatsapp/widgets/whatsapp_campaigns_tab.dart';
import 'package:frontend/features/whatsapp/widgets/whatsapp_templates_tab.dart';

void main() {
  group('WhatsApp Business Models Tests', () {
    test('WhatsAppDashboardAnalyticsModel parses JSON and computes metrics', () {
      final json = {
        'totalSent': 120,
        'totalDelivered': 118,
        'totalRead': 110,
        'totalFailed': 2,
        'pendingMessages': 0,
        'deliveryRate': 98.3,
        'readRate': 91.7,
        'activeConversations': 42,
        'unreadConversations': 3,
        'totalCampaigns': 5,
        'activeCampaigns': 1,
        'completedCampaigns': 4,
        'approvedTemplates': 8,
        'pendingTemplates': 1,
        'connectedPhoneNumber': '+15550199',
        'displayPhoneNumber': '+1 (555) 0199',
        'verifiedName': 'Titan Fitness Club',
        'qualityRating': 'GREEN',
        'messagingLimitTier': 'TIER_10K',
        'connectionStatus': 'Connected',
        'webhookHealth': 'Active',
        'wabaId': '109283746592837',
        'dailyTrends': [
          {'date': '2026-11-09', 'sent': 24, 'received': 18, 'delivered': 24, 'read': 20, 'failed': 0},
          {'date': '2026-11-10', 'sent': 30, 'received': 22, 'delivered': 30, 'read': 28, 'failed': 0},
        ],
      };

      final model = WhatsAppDashboardAnalyticsModel.fromJson(json);

      expect(model.totalSent, equals(120));
      expect(model.totalDelivered, equals(118));
      expect(model.totalRead, equals(110));
      expect(model.totalFailed, equals(2));
      expect(model.deliveryRate, equals(98.3));
      expect(model.qualityRating, equals('GREEN'));
      expect(model.messagingLimitTier, equals('TIER_10K'));
      expect(model.connectionStatus, equals('Connected'));
      expect(model.dailyTrends.length, equals(2));
      expect(model.dailyTrends.first.sent, equals(24));
    });

    test('WhatsAppCampaignModel computes progress and status', () {
      final json = {
        'id': 'camp-001',
        'name': 'Winter Membership Drive',
        'description': 'Promotional broadcast for new year signups',
        'audienceSegment': 'AllActive',
        'messageContent': 'Renew your membership this week for a 15% discount!',
        'status': 'Completed',
        'totalRecipients': 150,
        'sentCount': 150,
        'deliveredCount': 148,
        'readCount': 130,
        'failedCount': 2,
        'createdAt': '2026-11-08T09:00:00Z',
      };

      final camp = WhatsAppCampaignModel.fromJson(json);

      expect(camp.id, equals('camp-001'));
      expect(camp.isCompleted, isTrue);
      expect(camp.isInProgress, isFalse);
      expect(camp.totalRecipients, equals(150));
      expect(camp.deliveredCount, equals(148));
    });
  });

  group('WhatsApp Business Widgets Tests', () {
    final mockAnalytics = WhatsAppDashboardAnalyticsModel(
      wabaId: '109283746592837',
      displayPhoneNumber: '+1 (555) 0199',
      verifiedName: 'Titan Fitness Club',
      qualityRating: 'GREEN',
      messagingLimitTier: 'TIER_10K',
      connectionStatus: 'Connected',
      healthStatus: 'HEALTHY',
      webhookHealth: 'Active',
      totalSent: 85,
      totalReceived: 45,
      totalDelivered: 84,
      totalRead: 78,
      totalFailed: 1,
      pendingMessages: 0,
      activeConversations: 12,
      unreadConversations: 1,
      deliveryRate: 98.8,
      readRate: 91.8,
      totalCampaigns: 3,
      scheduledCampaigns: 0,
      activeCampaigns: 0,
      completedCampaigns: 3,
      failedCampaigns: 0,
      approvedTemplates: 5,
      pendingTemplates: 0,
      rejectedTemplates: 0,
      dailyTrends: [
        WhatsAppDailyVolumeModel(
          date: '2026-11-09',
          sent: 15,
          received: 10,
          delivered: 15,
          read: 14,
          failed: 0,
        ),
        WhatsAppDailyVolumeModel(
          date: '2026-11-10',
          sent: 20,
          received: 14,
          delivered: 20,
          read: 18,
          failed: 0,
        ),
      ],
      failureReasonsBreakdown: {},
    );

    testWidgets('WhatsAppDashboardTab renders KPIs, health banner and trends', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whatsAppDashboardAnalyticsProvider(7).overrideWith((ref) => Future.value(mockAnalytics)),
            whatsAppDashboardAnalyticsProvider(14).overrideWith((ref) => Future.value(mockAnalytics)),
            whatsAppDashboardAnalyticsProvider(30).overrideWith((ref) => Future.value(mockAnalytics)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WhatsAppDashboardTab(isDark: true),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Messaging & Campaign Telemetry'), findsOneWidget);
      expect(find.text('Titan Fitness Club'), findsOneWidget);
      expect(find.text('Total Dispatched'), findsOneWidget);
      expect(find.text('Delivered Messages'), findsOneWidget);
      expect(find.text('Read & Opened'), findsOneWidget);
      expect(find.text('Rating: GREEN'), findsOneWidget);
      expect(find.text('Tier: TIER_10K'), findsOneWidget);
    });

    testWidgets('WhatsAppCampaignsTab renders campaigns and create button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockCampaigns = [
        WhatsAppCampaignModel(
          id: 'camp-100',
          name: 'Annual Renewal Drive',
          description: 'Renewal discount',
          audienceSegment: 'ExpiringIn7Days',
          messageContent: 'Your membership is expiring soon. Renew today!',
          status: 'Completed',
          totalRecipients: 30,
          sentCount: 30,
          deliveredCount: 29,
          readCount: 25,
          failedCount: 1,
          createdAt: DateTime(2026, 11, 8),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whatsAppCampaignsProvider.overrideWith((ref) => Future.value(mockCampaigns)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WhatsAppCampaignsTab(isDark: true),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Broadcast Campaigns & Segmented Blasts'), findsOneWidget);
      expect(find.text('Annual Renewal Drive'), findsOneWidget);
      expect(find.text('ExpiringIn7Days'), findsOneWidget);
      expect(find.text('Create Campaign'), findsOneWidget);
    });

    testWidgets('WhatsAppTemplatesTab renders approved Meta templates', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockTemplates = [
        WhatsAppTemplateModel(
          id: 'tmpl-101',
          name: 'gym_workout_split',
          category: 'UTILITY',
          language: 'en_US',
          header: 'Today Workout Split',
          body: 'Hi {{1}}, here is your {{2}} workout plan for today.',
          footer: 'Titan Athletic Coaching',
          metaStatus: 'APPROVED',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whatsAppTemplatesProvider.overrideWith((ref) => Future.value(mockTemplates)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WhatsAppTemplatesTab(isDark: true),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Meta Approved WhatsApp Message Templates'), findsOneWidget);
      expect(find.text('gym_workout_split'), findsOneWidget);
      expect(find.text('Create Template'), findsOneWidget);
    });

    testWidgets('WhatsAppMessagingView renders tabs and header', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whatsAppDashboardAnalyticsProvider(7).overrideWith((ref) => Future.value(mockAnalytics)),
            whatsAppDashboardAnalyticsProvider(14).overrideWith((ref) => Future.value(mockAnalytics)),
            whatsAppDashboardAnalyticsProvider(30).overrideWith((ref) => Future.value(mockAnalytics)),
            whatsAppConversationsProvider.overrideWith((ref) => Future.value([])),
            whatsAppCampaignsProvider.overrideWith((ref) => Future.value([])),
            whatsAppTemplatesProvider.overrideWith((ref) => Future.value([])),
            whatsAppTriggersProvider.overrideWith((ref) => Future.value([])),
            whatsAppConfigProvider.overrideWith((ref) => Future.value(
              WhatsAppIntegrationModel(
                id: 'cfg-001',
                wabaId: '109283746592837',
                phoneNumberId: '105938472910482',
                displayPhoneNumber: '+1 555-0199',
                businessPortfolioName: 'Titan Fitness Club',
                connectionStatus: 'Connected',
                healthStatus: 'HEALTHY',
                qualityRating: 'GREEN',
                messagingLimitTier: 'TIER_10K',
                verifiedName: 'Titan Fitness Club',
                codeVerificationStatus: 'VERIFIED',
                costPerUtilityMessage: 0.005,
                costPerMarketingMessage: 0.015,
                timeZoneId: 'Asia/Kolkata',
                webhookUrl: 'https://api.gymxsoft.com/api/whatsapp/webhook',
                webhookVerifyToken: 'gymxsoft_meta_verify_2026',
              ),
            )),
          ],
          child: const MaterialApp(
            home: WhatsAppMessagingView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('WhatsApp Business Dashboard'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Analytics Dashboard'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Conversation Inbox (3-Panel)'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Broadcast Campaigns'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Message Templates'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Automated Triggers'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Meta WABA Connection'), findsOneWidget);
    });
  });
}
