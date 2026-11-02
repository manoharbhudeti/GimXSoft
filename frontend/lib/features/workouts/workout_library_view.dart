import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/states/feedback/app_state_handler.dart';
import '../../core/states/success/app_toast.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import 'workout_provider.dart';

class WorkoutLibraryView extends ConsumerStatefulWidget {
  const WorkoutLibraryView({super.key});

  @override
  ConsumerState<WorkoutLibraryView> createState() => _WorkoutLibraryViewState();
}

class _WorkoutLibraryViewState extends ConsumerState<WorkoutLibraryView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedCategory = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddExerciseDialog() {
    final nameCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Strength');
    final muscleCtrl = TextEditingController(text: 'Chest');
    final equipCtrl = TextEditingController(text: 'Barbell');
    final setsCtrl = TextEditingController(text: '4');
    final repsCtrl = TextEditingController(text: '8-10');
    final restCtrl = TextEditingController(text: '90');
    final instrCtrl = TextEditingController();
    final safetyCtrl = TextEditingController();
    String difficulty = 'Intermediate';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Custom Exercise to Catalogue',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    AppTextField(label: 'Exercise Name', controller: nameCtrl, hint: 'e.g. Incline Dumbbell Press'),
                    const SizedBox(height: DesignTokens.space12),
                    Row(
                      children: [
                        Expanded(child: AppTextField(label: 'Category', controller: catCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(label: 'Target Muscle', controller: muscleCtrl)),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space12),
                    Row(
                      children: [
                        Expanded(child: AppTextField(label: 'Equipment Required', controller: equipCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: difficulty,
                            decoration: InputDecoration(
                              labelText: 'Difficulty Level',
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                              DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                              DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
                            ],
                            onChanged: (val) => setDialogState(() => difficulty = val ?? 'Beginner'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space12),
                    Row(
                      children: [
                        Expanded(child: AppTextField(label: 'Default Sets', controller: setsCtrl, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(label: 'Default Reps', controller: repsCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(label: 'Rest (seconds)', controller: restCtrl, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space12),
                    AppTextField(label: 'Coaching Cues & Instructions', controller: instrCtrl, maxLines: 3),
                    const SizedBox(height: DesignTokens.space12),
                    AppTextField(label: 'Safety Instructions', controller: safetyCtrl, maxLines: 2),
                    const SizedBox(height: DesignTokens.space20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(text: 'Cancel', variant: ButtonVariant.ghost, onPressed: () => Navigator.of(context).pop()),
                        const SizedBox(width: 12),
                        AppButton(
                          text: 'Save Exercise',
                          icon: Icons.check_rounded,
                          onPressed: () async {
                            if (nameCtrl.text.trim().isEmpty) return;
                            final ok = await ref.read(workoutActionProvider).createExercise({
                              'name': nameCtrl.text.trim(),
                              'category': catCtrl.text.trim(),
                              'targetMuscle': muscleCtrl.text.trim(),
                              'equipment': equipCtrl.text.trim(),
                              'difficultyLevel': difficulty,
                              'defaultSets': int.tryParse(setsCtrl.text) ?? 3,
                              'defaultReps': repsCtrl.text.trim(),
                              'defaultRestSeconds': int.tryParse(restCtrl.text) ?? 60,
                              'instructions': instrCtrl.text.trim(),
                              'safetyNotes': safetyCtrl.text.trim(),
                            });
                            if (mounted) {
                              Navigator.of(context).pop();
                              if (ok) {
                                ref.read(toastProvider.notifier).success('Exercise Created', message: '${nameCtrl.text} added to library.');
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exercisesAsync = ref.watch(exercisesProvider(_selectedCategory == 'All' ? null : _selectedCategory));
    final templatesAsync = ref.watch(workoutTemplatesProvider);

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
                      'Workout & Exercise Library',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Catalogue of exercises, structured workout splits, and automated training routines.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    AppButton(
                      text: 'Add Exercise',
                      icon: Icons.add_rounded,
                      variant: ButtonVariant.primary,
                      onPressed: _showAddExerciseDialog,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary(isDark),
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(icon: Icon(Icons.fitness_center_rounded, size: 18), text: 'Exercise Catalogue'),
                  Tab(icon: Icon(Icons.layers_rounded, size: 18), text: 'Workout Templates & Splits'),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space16),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Exercise Catalogue
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter Bar
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _searchCtrl,
                              hint: 'Search exercises by name, muscle group, or equipment...',
                              prefixIcon: Icons.search_rounded,
                              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Category Chips
                          Wrap(
                            spacing: 8,
                            children: ['All', 'Strength', 'Cardio', 'Core', 'Mobility'].map((cat) {
                              final isSelected = _selectedCategory == cat;
                              return ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary(isDark),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (_) => setState(() => _selectedCategory = cat),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space16),

                      // Exercises Grid
                      Expanded(
                        child: exercisesAsync.buildStateWidget(
                          context,
                          onRetry: () => ref.invalidate(exercisesProvider),
                          onData: (exercises) {
                            final filtered = exercises.where((e) {
                              if (_searchQuery.isEmpty) return true;
                              return e.name.toLowerCase().contains(_searchQuery) ||
                                  e.targetMuscle.toLowerCase().contains(_searchQuery) ||
                                  e.equipment.toLowerCase().contains(_searchQuery);
                            }).toList();

                            if (filtered.isEmpty) {
                              return Center(
                                child: Text('No exercises found.', style: TextStyle(color: AppColors.textSecondary(isDark))),
                              );
                            }

                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.55,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final ex = filtered[index];
                                return GlassCard(
                                  padding: const EdgeInsets.all(DesignTokens.space16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              ex.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary(isDark),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          StatusBadge(status: ex.difficultyLevel, isPill: true),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${ex.category} • Muscle: ${ex.targetMuscle} • Equip: ${ex.equipment}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                          ex.instructions,
                                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark), height: 1.3),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${ex.defaultSets} Sets × ${ex.defaultReps} • Rest ${ex.defaultRestSeconds}s',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark)),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                                            onPressed: () => ref.read(workoutActionProvider).deleteExercise(ex.id),
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

                  // Tab 2: Workout Templates
                  templatesAsync.buildStateWidget(
                    context,
                    onRetry: () => ref.invalidate(workoutTemplatesProvider),
                    onData: (templates) {
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: templates.length,
                        itemBuilder: (context, index) {
                          final tmpl = templates[index];
                          return GlassCard(
                            padding: const EdgeInsets.all(DesignTokens.space20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tmpl.title,
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    StatusBadge(status: tmpl.level, isPill: true),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${tmpl.goal} • ${tmpl.daysPerWeek} Days/Week • ~${tmpl.estimatedMinutesPerSession} mins/session',
                                  style: const TextStyle(fontSize: 13, color: AppColors.accentCyan, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  tmpl.description,
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Ready for Member Scheduling', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                                    AppButton(
                                      text: 'Use Template',
                                      icon: Icons.arrow_forward_rounded,
                                      variant: ButtonVariant.outline,
                                      onPressed: () {
                                        ref.read(toastProvider.notifier).info('Template Selected', message: 'You can assign this template in Workout Scheduler.');
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
