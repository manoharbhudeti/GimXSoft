import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/measurements/measurement_models.dart';
import 'package:frontend/features/whatsapp/whatsapp_models.dart';
import 'package:frontend/features/workouts/workout_models.dart';

void main() {
  group('Phase 2: Member Fitness Progress & Body Measurement Tests', () {
    test('FitnessProgressCardModel correctly deserializes and calculates BMI category', () {
      final json = {
        'memberId': '0e95213d-7258-4c1a-9681-558e211bb8bd',
        'memberName': 'James Wilson',
        'memberCode': 'GIX-1001',
        'avatarUrl': null,
        'fitnessGoal': 'Lean Muscle Hypertrophy & Fat Reduction',
        'fitnessLevel': 'Intermediate',
        'baselineWeightKg': 84.5,
        'currentWeightKg': 79.8,
        'totalWeightChangeKg': -4.7,
        'weightChangePercentage': -5.56,
        'currentBmi': 25.19,
        'bmiCategory': 'Overweight',
        'lastMeasurementDate': '2026-10-28T00:00:00Z',
        'weightHistory': [
          {'date': '2026-05-02T00:00:00Z', 'weightKg': 84.5, 'bmi': 26.67},
          {'date': '2026-08-02T00:00:00Z', 'weightKg': 82.2, 'bmi': 25.94},
          {'date': '2026-10-28T00:00:00Z', 'weightKg': 79.8, 'bmi': 25.19},
        ],
        'measurementTrends': [
          {'date': '2026-05-02T00:00:00Z', 'waistCm': 93.0, 'chestCm': 104.0, 'hipCm': 102.0, 'bodyFatPercentage': 22.4},
          {'date': '2026-10-28T00:00:00Z', 'waistCm': 85.0, 'chestCm': 106.5, 'hipCm': 98.0, 'bodyFatPercentage': 16.5},
        ],
        'hasOverdueReview': false,
      };

      final card = FitnessProgressCardModel.fromJson(json);

      expect(card.memberName, 'James Wilson');
      expect(card.baselineWeightKg, 84.5);
      expect(card.currentWeightKg, 79.8);
      expect(card.totalWeightChangeKg, -4.7);
      expect(card.weightChangePercentage, -5.56);
      expect(card.currentBmi, 25.19);
      expect(card.bmiCategory, 'Overweight');
      expect(card.weightHistory.length, 3);
      expect(card.measurementTrends.length, 2);
      expect(card.hasOverdueReview, false);
    });

    test('MemberMeasurementModel correctly parses metric body circumference records', () {
      final json = {
        'id': 'm-101',
        'memberId': 'mem-001',
        'memberName': 'Sophia Chen',
        'weightKg': 62.4,
        'heightCm': 165.0,
        'calculatedBmi': 22.92,
        'waistCm': 68.5,
        'chestCm': 88.0,
        'hipCm': 94.0,
        'bodyFatPercentage': 21.0,
        'inputUnitSystem': 'Metric',
        'measurementDate': '2026-11-01T00:00:00Z',
        'notes': 'Excellent consistency and squat strength.',
        'weightDifferenceKg': -2.1,
        'weightChangePercent': -3.25,
        'createdAt': '2026-11-01T10:00:00Z',
      };

      final m = MemberMeasurementModel.fromJson(json);

      expect(m.memberName, 'Sophia Chen');
      expect(m.weightKg, 62.4);
      expect(m.calculatedBmi, 22.92);
      expect(m.waistCm, 68.5);
      expect(m.weightDifferenceKg, -2.1);
    });
  });

  group('Phase 2: Workout and Exercise Catalogue Tests', () {
    test('ExerciseModel correctly parses compound attributes and safety notes', () {
      final json = {
        'id': 'ex-01',
        'tenantId': 'tenant-01',
        'name': 'Barbell Bench Press',
        'description': 'Compound horizontal push for pectoralis major.',
        'category': 'Strength',
        'targetMuscle': 'Chest',
        'secondaryMusclesJson': '["Triceps", "Anterior Deltoids"]',
        'equipment': 'Barbell & Bench',
        'difficultyLevel': 'Intermediate',
        'instructions': 'Lower bar with control to sternum.',
        'defaultSets': 4,
        'defaultReps': '8-10',
        'defaultRestSeconds': 90,
        'safetyNotes': 'Use spotters on heavy sets.',
        'isActive': true,
        'createdAt': '2026-11-01T00:00:00Z',
      };

      final ex = ExerciseModel.fromJson(json);

      expect(ex.name, 'Barbell Bench Press');
      expect(ex.category, 'Strength');
      expect(ex.targetMuscle, 'Chest');
      expect(ex.secondaryMuscles.contains('Triceps'), true);
      expect(ex.defaultSets, 4);
      expect(ex.defaultRestSeconds, 90);
    });

    test('MemberWorkoutScheduleModel parses weekly delivery routine and rest days', () {
      final json = {
        'id': 'sched-01',
        'memberId': 'mem-01',
        'memberName': 'James Wilson',
        'dayOfWeek': 'Wednesday',
        'scheduledDeliveryTime': '08:00',
        'routineTitle': 'Active Recovery & Stretching',
        'exercisesJson': '[]',
        'isRestDay': true,
        'trainerApproved': true,
        'isActive': true,
        'trainerNotes': 'Hydrate well.',
        'updatedAt': '2026-11-01T00:00:00Z',
      };

      final sched = MemberWorkoutScheduleModel.fromJson(json);

      expect(sched.dayOfWeek, 'Wednesday');
      expect(sched.isRestDay, true);
      expect(sched.scheduledDeliveryTime, '08:00');
      expect(sched.trainerApproved, true);
    });
  });

  group('Phase 2: WhatsApp Cloud Platform Integration & Scheduler Tests', () {
    test('WhatsAppIntegrationModel parses WABA credentials and health status', () {
      final json = {
        'id': 'waba-01',
        'wabaId': '109283746592837',
        'phoneNumberId': '105938472910482',
        'displayPhoneNumber': '+1 (555) 234-9428',
        'businessPortfolioName': 'Titan Performance Club',
        'connectionStatus': 'Connected',
        'healthStatus': 'HEALTHY',
        'costPerUtilityMessage': 0.005,
        'costPerMarketingMessage': 0.025,
        'timeZoneId': 'Asia/Kolkata',
        'lastSyncedAt': '2026-11-02T10:00:00Z',
        'webhookUrl': 'http://localhost:5128/api/whatsapp/webhook',
        'webhookVerifyToken': 'GIMXSOFT_WHATSAPP_WEBHOOK_VERIFY_TOKEN',
      };

      final waba = WhatsAppIntegrationModel.fromJson(json);

      expect(waba.isConnected, true);
      expect(waba.healthStatus, 'HEALTHY');
      expect(waba.wabaId, '109283746592837');
      expect(waba.timeZoneId, 'Asia/Kolkata');
    });

    test('ScheduledMessageModel parses pending status and trigger type', () {
      final json = {
        'id': 'sched-msg-01',
        'memberId': 'mem-01',
        'recipientPhone': '+15553018841',
        'recipientName': 'James Wilson',
        'templateName': 'daily_workout_delivery',
        'messageContent': 'Hi James, your workout for today is Chest & Delts Hypertrophy.',
        'scheduledForUtc': '2026-11-03T01:30:00Z',
        'status': 'Pending',
        'triggerType': 'DailyWorkout',
        'createdAt': '2026-11-02T12:00:00Z',
      };

      final msg = ScheduledMessageModel.fromJson(json);

      expect(msg.isPending, true);
      expect(msg.triggerType, 'DailyWorkout');
      expect(msg.templateName, 'daily_workout_delivery');
    });
  });
}

