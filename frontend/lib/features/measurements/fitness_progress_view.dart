import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/states/feedback/app_state_handler.dart';
import '../../core/states/loading/inline_loader.dart';
import '../../core/states/success/app_toast.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/interactive_3d_card.dart';
import '../members/members_provider.dart';
import 'measurement_models.dart';
import 'measurement_provider.dart';

class FitnessProgressView extends ConsumerStatefulWidget {
  const FitnessProgressView({super.key});

  @override
  ConsumerState<FitnessProgressView> createState() => _FitnessProgressViewState();
}

class _FitnessProgressViewState extends ConsumerState<FitnessProgressView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedMemberId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRecordMeasurementDialog(String memberId, double currentHeight) {
    final weightCtrl = TextEditingController(text: '78.5');
    final heightCtrl = TextEditingController(text: currentHeight > 0 ? '$currentHeight' : '178');
    final waistCtrl = TextEditingController(text: '84.0');
    final chestCtrl = TextEditingController(text: '106.0');
    final hipCtrl = TextEditingController(text: '98.0');
    final bfCtrl = TextEditingController(text: '16.0');
    final notesCtrl = TextEditingController();
    double liveBmi = 24.78;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void updateBmi() {
            final w = double.tryParse(weightCtrl.text) ?? 0.0;
            final h = (double.tryParse(heightCtrl.text) ?? 178.0) / 100.0;
            if (h > 0) {
              setDialogState(() {
                liveBmi = (w / (h * h) * 100).round() / 100;
              });
            }
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
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
                            'Record Physical Measurements',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Weight (kg)',
                              controller: weightCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => updateBmi(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Height (cm)',
                              controller: heightCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => updateBmi(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space12),

                      // Live Calculated BMI Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Calculated BMI: $liveBmi',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            Text(
                              liveBmi < 18.5
                                  ? 'Underweight'
                                  : liveBmi < 25.0
                                      ? 'Normal Weight'
                                      : liveBmi < 30.0
                                          ? 'Overweight'
                                          : 'Obese',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space12),

                      Row(
                        children: [
                          Expanded(child: AppTextField(label: 'Waist (cm)', controller: waistCtrl, keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: AppTextField(label: 'Chest (cm)', controller: chestCtrl, keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: AppTextField(label: 'Hip (cm)', controller: hipCtrl, keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      AppTextField(label: 'Body Fat Percentage (%)', controller: bfCtrl, keyboardType: TextInputType.number),
                      const SizedBox(height: DesignTokens.space12),
                      AppTextField(label: 'Trainer Clinical Observations / Notes', controller: notesCtrl, maxLines: 3),
                      const SizedBox(height: DesignTokens.space20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(text: 'Cancel', variant: ButtonVariant.ghost, onPressed: () => Navigator.of(context).pop()),
                          const SizedBox(width: 12),
                          AppButton(
                            text: 'Save Measurement',
                            icon: Icons.check_rounded,
                            onPressed: () async {
                              final w = double.tryParse(weightCtrl.text);
                              final h = double.tryParse(heightCtrl.text);
                              if (w == null || h == null) return;

                              final ok = await ref.read(measurementActionProvider).recordMeasurement({
                                'memberId': memberId,
                                'weightKg': w,
                                'heightCm': h,
                                'waistCm': double.tryParse(waistCtrl.text),
                                'chestCm': double.tryParse(chestCtrl.text),
                                'hipCm': double.tryParse(hipCtrl.text),
                                'bodyFatPercentage': double.tryParse(bfCtrl.text),
                                'unitSystem': 'Metric',
                                'notes': notesCtrl.text.trim(),
                              });

                              if (mounted) {
                                Navigator.of(context).pop();
                                if (ok) {
                                  ref.read(toastProvider.notifier).success('Measurement Recorded', message: 'New physical measurement saved.');
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final membersAsync = ref.watch(membersListProvider);

    // Select first member as default
    membersAsync.whenData((members) {
      if (_selectedMemberId == null && members.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _selectedMemberId = members.first.id);
          }
        });
      }
    });

    final progressAsync = _selectedMemberId != null
        ? ref.watch(progressCardProvider(_selectedMemberId!))
        : null;

    final historyAsync = _selectedMemberId != null
        ? ref.watch(memberMeasurementsProvider(_selectedMemberId!))
        : null;

    final onboardingAsync = _selectedMemberId != null
        ? ref.watch(memberOnboardingProvider(_selectedMemberId!))
        : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header & Member Switcher
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Member Fitness Progress & Body Metrics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chronological physical measurements, BMI calculations, and member journey tracking.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
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
                          hint: const Text('Select Member'),
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
                  Tab(icon: Icon(Icons.badge_outlined, size: 18), text: 'Fitness Progress Card & Charts'),
                  Tab(icon: Icon(Icons.table_chart_outlined, size: 18), text: 'Measurement History Table'),
                  Tab(icon: Icon(Icons.timeline_rounded, size: 18), text: 'Member Onboarding Journey'),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space16),

            // Tab Views
            Expanded(
              child: _selectedMemberId == null
                  ? const Center(child: Text('Select a member to view fitness progress.'))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Progress Card & Charts
                        progressAsync?.buildStateWidget(
                              context,
                              onRetry: () => ref.invalidate(progressCardProvider(_selectedMemberId!)),
                              onData: (card) => _buildProgressCardTab(card, isDark),
                            ) ??
                            const SizedBox.shrink(),

                        // Tab 2: Measurement History Table
                        historyAsync?.buildStateWidget(
                              context,
                              onRetry: () => ref.invalidate(memberMeasurementsProvider(_selectedMemberId!)),
                              onData: (history) => _buildHistoryTable(history, isDark),
                            ) ??
                            const SizedBox.shrink(),

                        // Tab 3: Onboarding Journey Timeline
                        onboardingAsync?.buildStateWidget(
                              context,
                              onRetry: () => ref.invalidate(memberOnboardingProvider(_selectedMemberId!)),
                              onData: (journey) => _buildOnboardingJourney(journey, isDark),
                            ) ??
                            const SizedBox.shrink(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCardTab(FitnessProgressCardModel card, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reusable Master Progress Card (3D Holographic Perspective)
          Interactive3DCard(
            glowColor: AppColors.primary,
            maxTiltAngle: 0.08,
            padding: const EdgeInsets.all(DesignTokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParallaxLayer(
                      depth: 16.0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const SweepGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                              AppColors.accentCyan,
                              AppColors.primary,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          child: Text(
                            card.memberName.isNotEmpty ? card.memberName[0] : 'M',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ParallaxLayer(
                            depth: 8.0,
                            child: Row(
                              children: [
                                Text(
                                  card.memberName,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark)),
                                ),
                                const SizedBox(width: 10),
                                StatusBadge(status: card.memberCode, isPill: true),
                                const SizedBox(width: 8),
                                StatusBadge(status: card.fitnessLevel, isPill: true),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Goal: ${card.fitnessGoal} • Last Logged: ${card.lastMeasurementDate != null ? DateFormat('MMM dd, yyyy').format(card.lastMeasurementDate!) : 'Baseline Intake'}',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                          ),
                        ],
                      ),
                    ),
                    ParallaxLayer(
                      depth: 12.0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppButton(
                            text: 'Record Measurement',
                            icon: Icons.add_rounded,
                            variant: ButtonVariant.primary,
                            onPressed: () => _showRecordMeasurementDialog(card.memberId, 178.0),
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            text: 'Share / Print',
                            icon: Icons.print_rounded,
                            variant: ButtonVariant.outline,
                            onPressed: () {
                              ref.read(toastProvider.notifier).success('Report Ready', message: 'Fitness progress summary prepared for export.');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space20),

                // Metrics Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - (DesignTokens.space16 * 3)) / 4;
                    return Row(
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Starting Weight',
                            value: '${card.baselineWeightKg} kg',
                            subtitle: 'Baseline at enrollment',
                            icon: Icons.flag_circle_outlined,
                            iconColor: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Current Weight',
                            value: '${card.currentWeightKg} kg',
                            subtitle: 'Latest verified check-in',
                            icon: Icons.monitor_weight_rounded,
                            iconColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Total Weight Change',
                            value: '${card.totalWeightChangeKg > 0 ? "+" : ""}${card.totalWeightChangeKg} kg',
                            subtitle: '${card.weightChangePercentage}% progress from baseline',
                            icon: Icons.trending_down_rounded,
                            iconColor: card.totalWeightChangeKg <= 0 ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Current BMI',
                            value: '${card.currentBmi}',
                            subtitle: 'Screening: ${card.bmiCategory}',
                            icon: Icons.speed_rounded,
                            iconColor: AppColors.accentCyan,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space20),

          // Interactive FL Chart Progression Line Chart
          GlassCard(
            padding: const EdgeInsets.all(DesignTokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weight Progression Trend (kg)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark)),
                    ),
                    Text(
                      'Consistent reduction towards target composition',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space24),
                SizedBox(
                  height: 240,
                  child: card.weightHistory.isEmpty
                      ? const Center(child: Text('Not enough measurement points for chart.'))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true, drawVerticalLine: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (val, meta) => Text('${val.toInt()} kg', style: const TextStyle(fontSize: 11)),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    final idx = val.toInt();
                                    if (idx >= 0 && idx < card.weightHistory.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          DateFormat('MMM dd').format(card.weightHistory[idx].date),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  card.weightHistory.length,
                                  (i) => FlSpot(i.toDouble(), card.weightHistory[i].weightKg),
                                ),
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 3.5,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withOpacity(0.12),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(List<MemberMeasurementModel> history, bool isDark) {
    if (history.isEmpty) {
      return Center(
        child: Text('No measurement records available.', style: TextStyle(color: AppColors.textSecondary(isDark))),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: ListView.separated(
        itemCount: history.length,
        separatorBuilder: (_, __) => Divider(color: isDark ? Colors.white10 : Colors.black12),
        itemBuilder: (context, index) {
          final m = history[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: const Icon(Icons.analytics_outlined, color: AppColors.primary),
            ),
            title: Row(
              children: [
                Text(
                  '${DateFormat('MMM dd, yyyy').format(m.measurementDate)}: ${m.weightKg} kg (BMI: ${m.calculatedBmi})',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark)),
                ),
                if (m.weightDifferenceKg != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (m.weightDifferenceKg! <= 0 ? Colors.green : Colors.orange).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${m.weightDifferenceKg! > 0 ? "+" : ""}${m.weightDifferenceKg} kg (${m.weightChangePercent}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: m.weightDifferenceKg! <= 0 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              'Waist: ${m.waistCm ?? "--"} cm • Chest: ${m.chestCm ?? "--"} cm • Hip: ${m.hipCm ?? "--"} cm • Body Fat: ${m.bodyFatPercentage ?? "--"}%\nNotes: ${m.notes ?? "Regular check-in."}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnboardingJourney(MemberOnboardingJourneyModel journey, bool isDark) {
    final stages = [
      {'title': '1. Registration Completed', 'status': journey.registrationCompleted, 'key': 'RegistrationCompleted'},
      {'title': '2. WhatsApp Communication Consent Collected', 'status': journey.consentCollected, 'key': 'ConsentCollected'},
      {'title': '3. Automated Welcome Message Sent', 'status': journey.welcomeSent, 'key': 'WelcomeSent'},
      {'title': '4. Physical Health & Fitness Assessment', 'status': journey.assessmentCompleted, 'key': 'AssessmentCompleted'},
      {'title': '5. Initial Body Measurements Recorded', 'status': journey.initialMeasurementDone, 'key': 'InitialMeasurementDone'},
      {'title': '6. Personal Trainer Assigned', 'status': journey.trainerAssigned, 'key': 'TrainerAssigned'},
      {'title': '7. Personalised Workout Plan Assigned', 'status': journey.workoutPlanAssigned, 'key': 'WorkoutPlanAssigned'},
      {'title': '8. First Daily Workout Routine Delivered via WhatsApp', 'status': journey.firstWorkoutDelivered, 'key': 'FirstWorkoutDelivered'},
      {'title': '9. First-Week Progress Review Check-in', 'status': journey.firstWeekReviewDone, 'key': 'FirstWeekReviewDone'},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Member Onboarding Journey Timeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark)),
          ),
          const SizedBox(height: 6),
          Text(
            'Step-by-step progress tracking from initial sign-up to recurring training delivery.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
          ),
          const SizedBox(height: DesignTokens.space20),
          Expanded(
            child: ListView.separated(
              itemCount: stages.length,
              separatorBuilder: (_, __) => Divider(color: isDark ? Colors.white10 : Colors.black12),
              itemBuilder: (context, index) {
                final stage = stages[index];
                final isDone = stage['status'] as bool;
                final key = stage['key'] as String;

                return CheckboxListTile(
                  title: Text(
                    stage['title'] as String,
                    style: TextStyle(
                      fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                      color: isDone ? AppColors.textPrimary(isDark) : AppColors.textSecondary(isDark),
                    ),
                  ),
                  value: isDone,
                  activeColor: AppColors.primary,
                  onChanged: (val) async {
                    if (val != null) {
                      await ref.read(measurementActionProvider).updateOnboardingStage(
                            journey.memberId,
                            key,
                            val,
                          );
                      ref.read(toastProvider.notifier).success('Journey Stage Updated');
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
