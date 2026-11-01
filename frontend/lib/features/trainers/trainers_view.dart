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

final trainersListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final res = await client.dio.get(ApiConstants.trainers);
  return res.data as List;
});

class TrainersView extends ConsumerWidget {
  const TrainersView({super.key});

  void _showAddTrainerDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'Trainer123!');
    final phoneCtrl = TextEditingController();
    final rateCtrl = TextEditingController(text: '65.00');
    final bioCtrl = TextEditingController();
    final specCtrl = TextEditingController(text: 'Hypertrophy, Strength & Conditioning');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: GlassCard(
              padding: const EdgeInsets.all(DesignTokens.space24),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Onboard Personal Trainer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                      ),
                      const SizedBox(height: DesignTokens.space16),
                      AppTextField(
                        label: 'Full Name *',
                        hint: 'e.g. David Kovacs',
                        controller: nameCtrl,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Email *',
                              hint: 'david@titanfit.com',
                              controller: emailCtrl,
                              validator: (v) => v?.contains('@') != true ? 'Valid email required' : null,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.space12),
                          Expanded(
                            child: AppTextField(
                              label: 'Phone *',
                              hint: '+1 (555) 000-0000',
                              controller: phoneCtrl,
                              validator: (v) => v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Hourly Rate (\$) *',
                              hint: '60.00',
                              controller: rateCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.space12),
                          Expanded(
                            child: AppTextField(
                              label: 'Portal Password *',
                              hint: 'Min 6 chars',
                              controller: passCtrl,
                              isPassword: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      AppTextField(
                        label: 'Specializations (Comma Separated)',
                        hint: 'Powerlifting, Functional Fitness, Mobility',
                        controller: specCtrl,
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      AppTextField(
                        label: 'Biography / Qualifications',
                        hint: 'Certifications, experience, coaching philosophy...',
                        controller: bioCtrl,
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
                            text: 'Save Trainer',
                            variant: ButtonVariant.primary,
                            onPressed: () async {
                              if (formKey.currentState?.validate() ?? false) {
                                Navigator.of(ctx).pop();
                                final specs = specCtrl.text.split(',').map((s) => s.trim()).toList();
                                final client = ref.read(apiClientProvider);
                                await client.dio.post(
                                  ApiConstants.trainers,
                                  data: {
                                    'fullName': nameCtrl.text.trim(),
                                    'email': emailCtrl.text.trim(),
                                    'password': passCtrl.text,
                                    'phone': phoneCtrl.text.trim(),
                                    'hourlyRate': double.tryParse(rateCtrl.text) ?? 60.0,
                                    'bio': bioCtrl.text.trim(),
                                    'specializationsJson': jsonEncode(specs),
                                  },
                                );
                                ref.invalidate(trainersListProvider);
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
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trainersAsync = ref.watch(trainersListProvider);

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
                      'Personal Trainers & Coaching Staff',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Roster of certified trainers, member assignments, and training schedules',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                AppButton(
                  text: 'Onboard Trainer',
                  icon: Icons.person_add_rounded,
                  variant: ButtonVariant.primary,
                  onPressed: () => _showAddTrainerDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space24),

            trainersAsync.when(
              loading: () => Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SkeletonLoader(width: double.infinity, height: 260),
                    ),
                  ),
                ),
              ),
              error: (err, _) => Center(child: Text('Error loading trainers: $err')),
              data: (trainers) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth > 1000
                        ? (constraints.maxWidth - (2 * 16)) / 3
                        : (constraints.maxWidth > 650
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth);

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: trainers.map((t) {
                        List<dynamic> specs = [];
                        try {
                          specs = jsonDecode(t['specializationsJson'] ?? '[]') as List;
                        } catch (_) {}

                        return SizedBox(
                          width: cardWidth,
                          child: GlassCard(
                            padding: const EdgeInsets.all(DesignTokens.space20),
                            enableHover: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundImage: t['avatarUrl'] != null ? NetworkImage(t['avatarUrl']) : null,
                                      backgroundColor: AppColors.primaryHover,
                                      child: t['avatarUrl'] == null
                                          ? Text(
                                              t['fullName'] != null && t['fullName'].isNotEmpty ? t['fullName'][0] : 'T',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: DesignTokens.space12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t['fullName'] ?? 'Trainer',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary(isDark),
                                            ),
                                          ),
                                          Text(
                                            '\$${t['hourlyRate']} / hour session',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  t['bio'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: specs.map((s) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.12),
                                        borderRadius: DesignTokens.borderSm,
                                      ),
                                      child: Text(
                                        s.toString(),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${t['assignedMembersCount']} Assigned Members',
                                      style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
                                    ),
                                    Text(
                                      '${t['totalSessionsConducted']} Sessions Conducted',
                                      style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
