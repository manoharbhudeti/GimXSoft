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

final staffListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final res = await client.dio.get(ApiConstants.staff);
  return res.data as List;
});

class StaffView extends ConsumerWidget {
  const StaffView({super.key});

  static const List<String> kRoles = [
    'GymOwner',
    'BranchManager',
    'Receptionist',
    'Trainer',
    'Accountant',
  ];

  void _showAddStaffDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'Staff123!');
    final phoneCtrl = TextEditingController();
    String selectedRole = 'Receptionist';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
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
                            'Add Staff Member',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                          ),
                          const SizedBox(height: DesignTokens.space16),
                          AppTextField(
                            label: 'Full Name *',
                            hint: 'e.g. Jessica Taylor',
                            controller: nameCtrl,
                            validator: (v) => v?.isEmpty == true ? 'Required' : null,
                          ),
                          const SizedBox(height: DesignTokens.space12),
                          AppTextField(
                            label: 'Staff Email *',
                            hint: 'jessica@titanfit.com',
                            controller: emailCtrl,
                            validator: (v) => v?.contains('@') != true ? 'Valid email required' : null,
                          ),
                          const SizedBox(height: DesignTokens.space12),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Phone *',
                                  hint: '+1 (555) 000-0000',
                                  controller: phoneCtrl,
                                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
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
                          Text('System Access Role *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary(isDark))),
                          const SizedBox(height: DesignTokens.space6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                              borderRadius: DesignTokens.borderMd,
                              border: Border.all(color: AppColors.border(isDark)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedRole,
                                isExpanded: true,
                                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                                items: kRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                                onChanged: (val) => setState(() => selectedRole = val ?? 'Receptionist'),
                              ),
                            ),
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
                                text: 'Save Staff',
                                variant: ButtonVariant.primary,
                                onPressed: () async {
                                  if (formKey.currentState?.validate() ?? false) {
                                    Navigator.of(ctx).pop();
                                    final roleIndex = kRoles.indexOf(selectedRole);
                                    final client = ref.read(apiClientProvider);
                                    await client.dio.post(
                                      ApiConstants.staff,
                                      data: {
                                        'fullName': nameCtrl.text.trim(),
                                        'email': emailCtrl.text.trim(),
                                        'password': passCtrl.text,
                                        'phone': phoneCtrl.text.trim(),
                                        'role': roleIndex >= 0 ? roleIndex : 3,
                                      },
                                    );
                                    ref.invalidate(staffListProvider);
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
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final staffAsync = ref.watch(staffListProvider);

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
                      'Staff Management & RBAC Permissions',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Employee directories, role assignments (Owner, Branch Manager, Receptionist, Trainer, Accountant)',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                AppButton(
                  text: 'Add Staff Member',
                  icon: Icons.badge_rounded,
                  variant: ButtonVariant.primary,
                  onPressed: () => _showAddStaffDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space24),

            staffAsync.when(
              loading: () => SkeletonLoader(width: double.infinity, height: 260),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (staff) {
                return GlassCard(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 300),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? const Color(0xFF162032) : const Color(0xFFF8FAFC),
                        ),
                        horizontalMargin: DesignTokens.space20,
                        columnSpacing: DesignTokens.space24,
                        columns: const [
                          DataColumn(label: Text('EMPLOYEE')),
                          DataColumn(label: Text('ROLE')),
                          DataColumn(label: Text('BRANCH SCOPE')),
                          DataColumn(label: Text('CONTACT')),
                          DataColumn(label: Text('STATUS')),
                        ],
                        rows: staff.map((s) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primaryHover,
                                      child: Text(
                                        s['fullName'] != null && s['fullName'].isNotEmpty ? s['fullName'][0] : 'S',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: DesignTokens.space12),
                                    Text(
                                      s['fullName'] ?? 'Staff',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(StatusBadge(status: s['role'] ?? 'Staff')),
                              DataCell(Text(s['branchName'] ?? 'All Branches')),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(s['email'] ?? '', style: TextStyle(fontSize: 12, color: AppColors.textPrimary(isDark))),
                                    Text(s['phone'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark))),
                                  ],
                                ),
                              ),
                              DataCell(
                                StatusBadge(status: s['isActive'] == true ? 'Active' : 'Inactive'),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
