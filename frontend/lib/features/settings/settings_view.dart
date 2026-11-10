import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../auth/auth_provider.dart';
import 'widgets/theme_customization_section.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _isChangingPass = false;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_currentPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty) return;

    setState(() => _isChangingPass = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.changePassword,
        data: {
          'currentPassword': _currentPassCtrl.text,
          'newPassword': _newPassCtrl.text,
        },
      );
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!'), backgroundColor: AppColors.success),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect current password.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isChangingPass = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System & Organization Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your gym SaaS subscription, branding, interface themes, and credentials',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
            ),
            const SizedBox(height: DesignTokens.space24),

            // 1. Organization SaaS Entitlements
            GlassCard(
              padding: const EdgeInsets.all(DesignTokens.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: DesignTokens.borderMd,
                            ),
                            child: const Icon(Icons.corporate_fare_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: DesignTokens.space12),
                          Text(
                            'SaaS Enterprise Tenant Profile',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                          ),
                        ],
                      ),
                      const StatusBadge(status: 'Active'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _tenantMeta('Organization Name', authState.tenant?.name ?? 'Titan Fitness Club', isDark),
                      _tenantMeta('Tenant Slug Identifier', authState.tenant?.slug ?? 'titan-fitness', isDark),
                      _tenantMeta('SaaS Plan Tier', authState.tenant?.subscriptionPlan ?? 'Enterprise Pro', isDark),
                      _tenantMeta('Facility Entitlement', '${authState.tenant?.maxBranches ?? 10} Branches / ${authState.tenant?.maxMembers ?? 5000} Members', isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space24),

            // 2. Interface Theme & Typography Customization Studio
            ThemeCustomizationSection(isDark: isDark),
            const SizedBox(height: DesignTokens.space24),

            // 3. Security & Password Change
            GlassCard(
              padding: const EdgeInsets.all(DesignTokens.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Security',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Update account credentials with cryptographic verification',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'Current Password',
                          hint: '••••••••',
                          controller: _currentPassCtrl,
                          isPassword: true,
                        ),
                        const SizedBox(height: DesignTokens.space12),
                        AppTextField(
                          label: 'New Password',
                          hint: 'Minimum 6 characters',
                          controller: _newPassCtrl,
                          isPassword: true,
                        ),
                        const SizedBox(height: DesignTokens.space16),
                        AppButton(
                          text: 'Update Password',
                          variant: ButtonVariant.primary,
                          isLoading: _isChangingPass,
                          onPressed: _changePassword,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tenantMeta(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted(isDark))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark))),
        ],
      ),
    );
  }
}

