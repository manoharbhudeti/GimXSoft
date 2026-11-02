import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/states/feedback/app_state_handler.dart';
import '../../core/states/loading/inline_loader.dart';
import '../../core/states/success/app_toast.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../members/members_provider.dart';
import 'workout_models.dart';
import 'workout_provider.dart';

class WorkoutSchedulerView extends ConsumerStatefulWidget {
  const WorkoutSchedulerView({super.key});

  @override
  ConsumerState<WorkoutSchedulerView> createState() => _WorkoutSchedulerViewState();
}

class _WorkoutSchedulerViewState extends ConsumerState<WorkoutSchedulerView> {
  String? _selectedMemberId;

  void _showEditDayDialog(MemberWorkoutScheduleModel schedule) {
    final titleCtrl = TextEditingController(text: schedule.routineTitle);
    final timeCtrl = TextEditingController(text: schedule.scheduledDeliveryTime);
    final notesCtrl = TextEditingController(text: schedule.trainerNotes ?? '');
    bool isRest = schedule.isRestDay;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: GlassCard(
              padding: const EdgeInsets.all(DesignTokens.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit ${schedule.dayOfWeek} Schedule',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  SwitchListTile(
                    title: const Text('Mark as Rest & Active Recovery Day'),
                    value: isRest,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setDialogState(() => isRest = val),
                  ),
                  const SizedBox(height: DesignTokens.space12),
                  if (!isRest) ...[
                    AppTextField(label: 'Routine Title', controller: titleCtrl),
                    const SizedBox(height: DesignTokens.space12),
                  ],
                  AppTextField(label: 'Scheduled Delivery Time', controller: timeCtrl, hint: '07:00 AM'),
                  const SizedBox(height: DesignTokens.space12),
                  AppTextField(label: 'Trainer Coaching Notes', controller: notesCtrl, maxLines: 2),
                  const SizedBox(height: DesignTokens.space20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(text: 'Cancel', variant: ButtonVariant.ghost, onPressed: () => Navigator.of(context).pop()),
                      const SizedBox(width: 12),
                      AppButton(
                        text: 'Save Schedule',
                        icon: Icons.check_rounded,
                        onPressed: () async {
                          final ok = await ref.read(workoutActionProvider).assignSchedule({
                            'memberId': schedule.memberId,
                            'dayOfWeek': schedule.dayOfWeek,
                            'scheduledDeliveryTime': timeCtrl.text.trim(),
                            'routineTitle': isRest ? 'Rest & Recovery' : titleCtrl.text.trim(),
                            'exercisesJson': schedule.exercisesJson,
                            'isRestDay': isRest,
                            'trainerApproved': true,
                            'trainerNotes': notesCtrl.text.trim(),
                          });
                          if (mounted) {
                            Navigator.of(context).pop();
                            if (ok) {
                              ref.read(toastProvider.notifier).success('Schedule Updated', message: '${schedule.dayOfWeek} schedule updated.');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final membersAsync = ref.watch(membersListProvider);

    // Default select first member if not selected yet
    membersAsync.whenData((members) {
      if (_selectedMemberId == null && members.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _selectedMemberId = members.first.id);
          }
        });
      }
    });

    final schedulesAsync = ref.watch(workoutSchedulesProvider(_selectedMemberId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalised Workout Scheduler',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure weekly training splits, rest days, and automated WhatsApp delivery for individual members.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                // Member Dropdown Selector
                membersAsync.when(
                  loading: () => const SizedBox(width: 200, height: 40, child: InlineLoader()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (members) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border(isDark)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMemberId,
                          hint: const Text('Select Gym Member'),
                          items: members.map((m) {
                            return DropdownMenuItem(
                              value: m.id,
                              child: Text('${m.fullName} (${m.memberCode})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedMemberId = val);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space20),

            // Weekly Days Grid
            Expanded(
              child: schedulesAsync.buildStateWidget(
                context,
                onRetry: () => ref.invalidate(workoutSchedulesProvider(_selectedMemberId)),
                onData: (schedules) {
                  if (schedules.isEmpty) {
                    return Center(
                      child: Text('No schedules found for this member.', style: TextStyle(color: AppColors.textSecondary(isDark))),
                    );
                  }

                  final daysOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                  // Sort schedules by standard days of week
                  final sorted = [...schedules]..sort((a, b) {
                      final iA = daysOrder.indexOf(a.dayOfWeek);
                      final iB = daysOrder.indexOf(b.dayOfWeek);
                      return (iA == -1 ? 99 : iA).compareTo(iB == -1 ? 99 : iB);
                    });

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.35,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final item = sorted[index];
                      return GlassCard(
                        padding: const EdgeInsets.all(DesignTokens.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      item.isRestDay ? Icons.hotel_rounded : Icons.fitness_center_rounded,
                                      color: item.isRestDay ? Colors.teal : AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.dayOfWeek,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                                StatusBadge(status: item.isRestDay ? 'Rest Day' : 'Active Workout', isPill: true),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.routineTitle,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: item.isRestDay ? Colors.teal : AppColors.textPrimary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'WhatsApp Delivery Time: ${item.scheduledDeliveryTime}',
                              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            if (item.trainerNotes != null && item.trainerNotes!.isNotEmpty)
                              Expanded(
                                child: Text(
                                  'Coach notes: "${item.trainerNotes}"',
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary(isDark)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            else
                              const Spacer(),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppButton(
                                  text: 'Edit',
                                  icon: Icons.edit_outlined,
                                  variant: ButtonVariant.ghost,
                                  onPressed: () => _showEditDayDialog(item),
                                ),
                                AppButton(
                                  text: 'Send Now',
                                  icon: Icons.send_rounded,
                                  variant: ButtonVariant.primary,
                                  onPressed: () async {
                                    final ok = await ref.read(workoutActionProvider).triggerWorkoutDeliveryNow(item.id);
                                    if (ok) {
                                      ref.read(toastProvider.notifier).success(
                                            'Workout Sent via WhatsApp',
                                            message: 'Dispatched "${item.routineTitle}" to member.',
                                          );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
