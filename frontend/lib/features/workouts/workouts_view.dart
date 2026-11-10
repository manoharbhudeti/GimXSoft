import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../members/member_models.dart';

final workoutsListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final res = await client.dio.get(ApiConstants.workouts);
  return res.data as List;
});

class WorkoutsView extends ConsumerWidget {
  const WorkoutsView({super.key});

  void _showCreateWorkoutDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController(text: 'Upper/Lower Hypertrophy Split 4-Day');
    final goalCtrl = TextEditingController(text: 'Lean Muscle Hypertrophy & Strength');
    final notesCtrl = TextEditingController(text: 'Focus on 2-second eccentric contraction and progressive overload.');
    String? selectedMemberId;

    List<MemberModel> members = [];
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.dio.get(ApiConstants.members);
      members = (res.data as List).map((m) => MemberModel.fromJson(m)).toList();
      if (members.isNotEmpty) selectedMemberId = members.first.id;
    } catch (_) {}

    final defaultExercises = [
      {'day': 'Day 1: Upper Power', 'exercises': [{'name': 'Barbell Bench Press', 'sets': 4, 'reps': '6-8', 'rest': '120s'}]},
      {'day': 'Day 2: Lower Power', 'exercises': [{'name': 'Barbell Back Squat', 'sets': 4, 'reps': '6-8', 'rest': '120s'}]},
    ];

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: GlassCard(
                  padding: const EdgeInsets.all(DesignTokens.space24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Workout Routine Plan',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                        ),
                        const SizedBox(height: DesignTokens.space16),

                        if (members.isNotEmpty) ...[
                          Text('Target Member', style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark))),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                              borderRadius: DesignTokens.borderMd,
                              border: Border.all(color: AppColors.border(isDark)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedMemberId,
                                isExpanded: true,
                                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                                items: members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.fullName))).toList(),
                                onChanged: (val) => setState(() => selectedMemberId = val),
                              ),
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space12),
                        ],

                        AppTextField(
                          label: 'Workout Routine Title *',
                          hint: 'e.g. 5-Day Push Pull Legs',
                          controller: titleCtrl,
                        ),
                        const SizedBox(height: DesignTokens.space12),
                        AppTextField(
                          label: 'Fitness Objective / Goal',
                          hint: 'e.g. Fat Loss, Athletic Conditioning',
                          controller: goalCtrl,
                        ),
                        const SizedBox(height: DesignTokens.space12),
                        AppTextField(
                          label: 'Coaching Instructions / Notes',
                          hint: 'Rest periods, warm-up protocol...',
                          controller: notesCtrl,
                          maxLines: 2,
                        ),
                        const SizedBox(height: DesignTokens.space24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButton(
                              text: 'Cancel',
                              variant: ButtonVariant.ghost,
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            const SizedBox(width: DesignTokens.space12),
                            AppButton(
                              text: 'Assign Workout Plan',
                              variant: ButtonVariant.primary,
                              onPressed: () async {
                                if (selectedMemberId == null) return;
                                Navigator.of(ctx).pop();
                                final client = ref.read(apiClientProvider);
                                await client.dio.post(
                                  ApiConstants.workouts,
                                  data: {
                                    'memberId': selectedMemberId,
                                    'title': titleCtrl.text.trim(),
                                    'goal': goalCtrl.text.trim(),
                                    'notes': notesCtrl.text.trim(),
                                    'exercisesJson': jsonEncode(defaultExercises),
                                  },
                                );
                                ref.invalidate(workoutsListProvider);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workoutsAsync = ref.watch(workoutsListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Plan Builder & Prescriptions',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Design custom training splits, routines, and track member exercise prescriptions',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                AppButton(
                  text: 'Create Routine',
                  icon: Icons.fitness_center_rounded,
                  variant: ButtonVariant.primary,
                  onPressed: () => _showCreateWorkoutDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space24),

            workoutsAsync.when(
              loading: () => SkeletonLoader(width: double.infinity, height: 300),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (plans) {
                if (plans.isEmpty) {
                  return GlassCard(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text('No workout plans assigned yet.', style: TextStyle(color: AppColors.textMuted(isDark)))),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plans.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, idx) {
                    final p = plans[idx];
                    List<dynamic> days = [];
                    try {
                      days = jsonDecode(p['exercisesJson'] ?? '[]') as List;
                    } catch (_) {}

                    return GlassCard(
                      padding: const EdgeInsets.all(DesignTokens.space20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['title'] ?? 'Workout Plan',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Goal: ${p['goal'] ?? "General"} • Assigned to: ${p['memberName'] ?? "Member"}',
                                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              if (p['trainerName'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.12),
                                    borderRadius: DesignTokens.borderSm,
                                  ),
                                  child: Text(
                                    'Coach: ${p['trainerName']}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                  ),
                                ),
                            ],
                          ),
                          if (p['notes'] != null && p['notes'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(p['notes'], style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark))),
                          ],
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 10),

                          // Days breakdown
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: days.map((d) {
                              final dayName = d['day'] ?? 'Training Day';
                              final exList = d['exercises'] as List? ?? [];

                              return Container(
                                width: 280,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                                  borderRadius: DesignTokens.borderMd,
                                  border: Border.all(color: AppColors.border(isDark)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dayName,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary(isDark)),
                                    ),
                                    const SizedBox(height: 6),
                                    ...exList.map((e) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  e['name'] ?? '',
                                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                                                ),
                                              ),
                                              Text(
                                                '${e['sets']}x${e['reps']}',
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
