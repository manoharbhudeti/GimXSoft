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
import '../../core/widgets/status_badge.dart';
import '../auth/auth_models.dart';
import '../auth/auth_provider.dart';

final branchesListProvider = FutureProvider.autoDispose<List<BranchModel>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final res = await client.dio.get(ApiConstants.branches);
  return (res.data as List).map((b) => BranchModel.fromJson(b)).toList();
});

class BranchesView extends ConsumerWidget {
  const BranchesView({super.key});

  void _showAddBranchDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: GlassCard(
              padding: const EdgeInsets.all(DesignTokens.space24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Branch Location',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    AppTextField(
                      label: 'Branch Name *',
                      hint: 'e.g. Uptown Crossfit Annex',
                      controller: nameCtrl,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: DesignTokens.space12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Branch Code *',
                            hint: 'e.g. UT-03',
                            controller: codeCtrl,
                            validator: (v) => v?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space12),
                        Expanded(
                          child: AppTextField(
                            label: 'City',
                            hint: 'Metropolis',
                            controller: cityCtrl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space12),
                    AppTextField(
                      label: 'Street Address',
                      hint: '820 Lexington Way',
                      controller: addrCtrl,
                    ),
                    const SizedBox(height: DesignTokens.space12),
                    AppTextField(
                      label: 'Phone Contact',
                      hint: '+1 (555) 000-0000',
                      controller: phoneCtrl,
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
                          text: 'Save Branch',
                          variant: ButtonVariant.primary,
                          onPressed: () async {
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.of(ctx).pop();
                              final client = ref.read(apiClientProvider);
                              await client.dio.post(
                                ApiConstants.branches,
                                data: {
                                  'name': nameCtrl.text.trim(),
                                  'code': codeCtrl.text.trim(),
                                  'address': addrCtrl.text.trim(),
                                  'city': cityCtrl.text.trim(),
                                  'phone': phoneCtrl.text.trim(),
                                },
                              );
                              ref.invalidate(branchesListProvider);
                              ref.invalidate(authProvider);
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
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final branchesAsync = ref.watch(branchesListProvider);

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
                      'Multi-Branch Management',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Operate and monitor club locations, facility codes, and regional staff',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                AppButton(
                  text: 'Add Location',
                  icon: Icons.add_business_rounded,
                  variant: ButtonVariant.primary,
                  onPressed: () => _showAddBranchDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space24),

            branchesAsync.when(
              loading: () => Row(
                children: List.generate(
                  2,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SkeletonLoader(width: double.infinity, height: 180),
                    ),
                  ),
                ),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (branches) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth > 750
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: branches.map((b) {
                        return SizedBox(
                          width: cardWidth,
                          child: GlassCard(
                            padding: const EdgeInsets.all(DesignTokens.space24),
                            enableHover: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.12),
                                            borderRadius: DesignTokens.borderMd,
                                          ),
                                          child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 22),
                                        ),
                                        const SizedBox(width: DesignTokens.space12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.name,
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                                            ),
                                            Text(
                                              'Facility Code: ${b.code}',
                                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const StatusBadge(status: 'Active'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text('${b.address}, ${b.city}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark))),
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
