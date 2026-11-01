import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/whatsapp/whatsapp_models.dart';

void main() {
  group('WhatsApp Customer Messaging API Tests', () {
    test('WhatsAppMessageModel parses JSON and computes delivery flags', () {
      final json = {
        'id': 'msg-001',
        'memberId': 'mem-123',
        'recipientPhone': '+15552345678',
        'recipientName': 'James Wilson',
        'direction': 'Outbound',
        'messageType': 'Template',
        'templateName': 'payment_invoice_receipt',
        'messageContent': 'Payment of \$749.00 confirmed for invoice INV-001.',
        'status': 'Read',
        'sentAt': '2026-11-01T10:00:00Z',
        'deliveredAt': '2026-11-01T10:00:02Z',
        'readAt': '2026-11-01T10:05:00Z',
      };

      final msg = WhatsAppMessageModel.fromJson(json);

      expect(msg.id, equals('msg-001'));
      expect(msg.recipientName, equals('James Wilson'));
      expect(msg.isOutbound, isTrue);
      expect(msg.isDelivered, isTrue);
      expect(msg.isRead, isTrue);
      expect(msg.templateName, equals('payment_invoice_receipt'));
    });

    test('WhatsAppTemplateModel accurately substitutes customer variables', () {
      final json = {
        'id': 'tmpl-001',
        'name': 'welcome_onboarding',
        'category': 'UTILITY',
        'language': 'en_US',
        'header': 'Welcome!',
        'body': 'Welcome to Titan Fitness, {{1}}! Your trainer is {{2}}.',
        'footer': 'Front Desk Team',
        'metaStatus': 'APPROVED',
      };

      final tmpl = WhatsAppTemplateModel.fromJson(json);

      expect(tmpl.name, equals('welcome_onboarding'));
      expect(tmpl.metaStatus, equals('APPROVED'));

      final customized = tmpl.body
          .replaceAll('{{1}}', 'Sophia')
          .replaceAll('{{2}}', 'Coach David');

      expect(customized, equals('Welcome to Titan Fitness, Sophia! Your trainer is Coach David.'));
    });

    test('WhatsAppMetricsModel parses SLA percentages and active counts', () {
      final json = {
        'totalSentToday': 50,
        'totalDeliveredToday': 49,
        'totalReadToday': 44,
        'totalFailedToday': 1,
        'deliveryRate': 98.0,
        'readRate': 88.0,
        'activeConversationsCount': 6,
        'isMetaCloudApiConnected': true,
      };

      final metrics = WhatsAppMetricsModel.fromJson(json);

      expect(metrics.totalSentToday, equals(50));
      expect(metrics.deliveryRate, equals(98.0));
      expect(metrics.readRate, equals(88.0));
      expect(metrics.isMetaCloudApiConnected, isTrue);
      expect(metrics.activeConversationsCount, equals(6));
    });
  });
}
