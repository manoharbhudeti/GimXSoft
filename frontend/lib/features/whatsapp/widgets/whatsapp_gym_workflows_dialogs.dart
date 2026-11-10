import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/states/success/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../whatsapp_provider.dart';

class WhatsAppGymWorkflowsDialogs {
  static Future<void> showShareWorkoutDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String memberId,
    required String memberName,
    bool isDark = true,
  }) async {
    final titleCtrl = TextEditingController(text: 'Chest & Triceps Hypertrophy');
    final exercisesCtrl = TextEditingController(
      text: '1. Incline Dumbbell Press (4x10)\n2. Flat Barbell Bench Press (3x8)\n3. Cable Chest Flyes (3x12)\n4. Rope Triceps Pushdowns (4x15)\n5. Overhead Dumbbell Extension (3x12)',
    );
    final notesCtrl = TextEditingController(text: 'Rest 90s between sets. Hydrate with electrolyte drink.');
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            side: BorderSide(color: AppColors.border(isDark)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Workout via WhatsApp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Recipient: $memberName',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Routine Split Title',
                    controller: titleCtrl,
                    hint: 'e.g. Quad Dominant Leg Day',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Exercise Prescription',
                    controller: exercisesCtrl,
                    maxLines: 5,
                    hint: 'List sets, reps, and exercise movements...',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Coach Instructions & Notes',
                    controller: notesCtrl,
                    hint: 'Target intensity, rest times, nutrition...',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.textMuted(isDark))),
            ),
            AppButton(
              label: 'Dispatch to WhatsApp',
              icon: Icons.send_rounded,
              isLoading: isSubmitting,
              onPressed: () async {
                setState(() => isSubmitting = true);
                final exercises = exercisesCtrl.text
                    .split('\n')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                final ok = await ref.read(whatsAppActionProvider).shareWorkoutSplit(
                      memberId: memberId,
                      splitTitle: titleCtrl.text.trim(),
                      exercises: exercises,
                      trainerNotes: notesCtrl.text.trim(),
                    );
                setState(() => isSubmitting = false);

                if (context.mounted) {
                  Navigator.pop(ctx);
                  if (ok) {
                    ref.read(toastProvider.notifier).success(
                          'Workout Dispatched',
                          message: 'Workout routine split delivered to $memberName on WhatsApp.',
                        );
                  } else {
                    ref.read(toastProvider.notifier).error(
                          'Dispatch Failed',
                          message: 'Could not deliver workout to member.',
                        );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showSendBmiReportDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String memberId,
    required String memberName,
    bool isDark = true,
  }) async {
    final weightCtrl = TextEditingController(text: '76.4');
    final heightCtrl = TextEditingController(text: '178');
    final fatCtrl = TextEditingController(text: '14.8');
    final summaryCtrl = TextEditingController(text: 'Metabolic rate high. Lean tissue synthesis trending up +0.8kg.');
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final w = double.tryParse(weightCtrl.text) ?? 76.4;
          final h = (double.tryParse(heightCtrl.text) ?? 178) / 100.0;
          final bmi = h > 0 ? (w / (h * h)) : 24.1;

          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              side: BorderSide(color: AppColors.border(isDark)),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.monitor_weight_rounded, color: AppColors.success, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send BMI & Biometrics Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Recipient: $memberName',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Weight (kg)',
                            controller: weightCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            label: 'Height (cm)',
                            controller: heightCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Body Fat % (Optional)',
                            controller: fatCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.raised(isDark),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                              border: Border.all(color: AppColors.border(isDark)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Calculated BMI', style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark))),
                                const SizedBox(height: 2),
                                Text(
                                  '${bmi.toStringAsFixed(1)} (Healthy)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Trainer Feedback / Assessment',
                      controller: summaryCtrl,
                      maxLines: 3,
                      hint: 'Summary of body composition changes...',
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(color: AppColors.textMuted(isDark))),
              ),
              AppButton(
                label: 'Send Biometrics Update',
                icon: Icons.send_rounded,
                isLoading: isSubmitting,
                onPressed: () async {
                  setState(() => isSubmitting = true);
                  final weight = double.tryParse(weightCtrl.text) ?? 76.4;
                  final height = double.tryParse(heightCtrl.text) ?? 178;
                  final bodyFat = double.tryParse(fatCtrl.text);

                  final ok = await ref.read(whatsAppActionProvider).sendBmiReport(
                        memberId: memberId,
                        weightKg: weight,
                        heightCm: height,
                        bmi: double.parse(bmi.toStringAsFixed(1)),
                        bodyFatPercentage: bodyFat,
                        assessmentSummary: summaryCtrl.text.trim(),
                      );
                  setState(() => isSubmitting = false);

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    if (ok) {
                      ref.read(toastProvider.notifier).success(
                            'BMI Report Dispatched',
                            message: 'Biometric update sent to $memberName on WhatsApp.',
                          );
                    } else {
                      ref.read(toastProvider.notifier).error(
                            'Dispatch Failed',
                            message: 'Could not deliver BMI report.',
                          );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> showSendExpiryReminderDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String memberId,
    required String memberName,
    int defaultDays = 7,
    bool isDark = true,
  }) async {
    final daysCtrl = TextEditingController(text: defaultDays.toString());
    final customMsgCtrl = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            side: BorderSide(color: AppColors.border(isDark)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.alarm_on_rounded, color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Membership Expiry Reminder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Recipient: $memberName',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Days Remaining',
                  controller: daysCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Custom Renewal Note (Optional)',
                  controller: customMsgCtrl,
                  maxLines: 3,
                  hint: 'Leave blank to use default template with 1-click UPI link...',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.textMuted(isDark))),
            ),
            AppButton(
              label: 'Dispatch Renewal Notice',
              icon: Icons.send_rounded,
              isLoading: isSubmitting,
              onPressed: () async {
                setState(() => isSubmitting = true);
                final days = int.tryParse(daysCtrl.text) ?? defaultDays;

                final ok = await ref.read(whatsAppActionProvider).sendExpiryReminder(
                      memberId: memberId,
                      daysRemaining: days,
                      customMessage: customMsgCtrl.text.trim().isEmpty ? null : customMsgCtrl.text.trim(),
                    );
                setState(() => isSubmitting = false);

                if (context.mounted) {
                  Navigator.pop(ctx);
                  if (ok) {
                    ref.read(toastProvider.notifier).success(
                          'Renewal Notice Dispatched',
                          message: 'Expiry reminder sent to $memberName on WhatsApp.',
                        );
                  } else {
                    ref.read(toastProvider.notifier).error(
                          'Dispatch Failed',
                          message: 'Could not send expiry reminder.',
                        );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
