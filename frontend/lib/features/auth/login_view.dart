import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import 'auth_provider.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController(text: 'admin@titanfit.com');
  final _passwordController = TextEditingController(text: 'Admin123!');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
      if (success && mounted) {
        context.go('/dashboard');
      }
    }
  }

  void _quickFill(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    _handleLogin();
  }

  void _showRegisterDialog() {
    final nameCtrl = TextEditingController();
    final slugCtrl = TextEditingController();
    final adminNameCtrl = TextEditingController();
    final adminEmailCtrl = TextEditingController();
    final adminPassCtrl = TextEditingController();
    final branchNameCtrl = TextEditingController();
    final regFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: GlassCard(
              padding: const EdgeInsets.all(DesignTokens.space24),
              child: Form(
                key: regFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Register Gym Organization',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space16),
                      AppTextField(
                        label: 'Gym / Enterprise Name',
                        hint: 'e.g. Apex Performance Club',
                        controller: nameCtrl,
                        prefixIcon: Icons.fitness_center,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      AppTextField(
                        label: 'Tenant URL Slug',
                        hint: 'e.g. apex-club',
                        controller: slugCtrl,
                        prefixIcon: Icons.link,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      AppTextField(
                        label: 'Initial Branch Name',
                        hint: 'e.g. Downtown Central',
                        controller: branchNameCtrl,
                        prefixIcon: Icons.storefront,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      AppTextField(
                        label: 'Admin Full Name',
                        hint: 'e.g. John Doe',
                        controller: adminNameCtrl,
                        prefixIcon: Icons.person,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      AppTextField(
                        label: 'Admin Email',
                        hint: 'john@apexclub.com',
                        controller: adminEmailCtrl,
                        prefixIcon: Icons.email,
                        validator: (v) => v?.contains('@') != true ? 'Valid email required' : null,
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      AppTextField(
                        label: 'Admin Password',
                        hint: 'Minimum 6 characters',
                        controller: adminPassCtrl,
                        isPassword: true,
                        prefixIcon: Icons.lock,
                        validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
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
                            text: 'Create Organization',
                            variant: ButtonVariant.primary,
                            onPressed: () async {
                              if (regFormKey.currentState?.validate() ?? false) {
                                Navigator.of(ctx).pop();
                                final ok = await ref.read(authProvider.notifier).registerTenant(
                                      gymName: nameCtrl.text,
                                      slug: slugCtrl.text,
                                      adminFullName: adminNameCtrl.text,
                                      adminEmail: adminEmailCtrl.text,
                                      adminPassword: adminPassCtrl.text,
                                      branchName: branchNameCtrl.text,
                                    );
                                if (ok && mounted) {
                                  context.go('/dashboard');
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= DesignTokens.breakpointTablet;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: Stack(
        children: [
          // Background subtle ambient lights
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(isDark ? 0.10 : 0.05),
              ),
            ),
          ),

          // Main Center Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.space24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 960 : 440),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Brand Panel
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: DesignTokens.space48),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.12),
                                      borderRadius: DesignTokens.borderFull,
                                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
                                        SizedBox(width: 6),
                                        Text(
                                          'SaaS Gym OS & Intelligence',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.space24),
                                  Text(
                                    'Smarter Fitness.\nSimpler Management.',
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1.0,
                                      height: 1.15,
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.space16),
                                  Text(
                                    'An all-in-one SaaS platform unifying member tracking, billing, staff, multi-branch operations, and leads CRM with strict tenant isolation.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondary(isDark),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.space32),
                                  _FeatureBullet(
                                    icon: Icons.shield_outlined,
                                    title: 'Multi-Tenant Security',
                                    subtitle: 'Query filter isolation and granular role permissions',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: DesignTokens.space16),
                                  _FeatureBullet(
                                    icon: Icons.qr_code_scanner_rounded,
                                    title: 'High-Speed Reception Terminal',
                                    subtitle: 'Sub-second check-ins with anti-duplicate guards',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: DesignTokens.space16),
                                  _FeatureBullet(
                                    icon: Icons.view_kanban_outlined,
                                    title: 'Visual Lead CRM',
                                    subtitle: 'Drag-and-drop pipeline with conversion analytics',
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Right Glass Login Card
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: _buildLoginCard(context, isDark, authState),
                          ),
                        ],
                      )
                    : _buildLoginCard(context, isDark, authState),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool isDark, AuthState authState) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accentCyan],
                    ),
                    borderRadius: DesignTokens.borderMd,
                    boxShadow: DesignTokens.glowPrimary,
                  ),
                  child: const Center(
                    child: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: DesignTokens.space12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign In to GIMXSOFT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Access your club management dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space24),

            if (authState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: DesignTokens.borderMd,
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authState.errorMessage!,
                        style: const TextStyle(fontSize: 13, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
            ],

            AppTextField(
              label: 'Email Address',
              hint: 'admin@titanfit.com',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v?.contains('@') != true ? 'Please enter a valid email' : null,
            ),
            const SizedBox(height: DesignTokens.space16),

            AppTextField(
              label: 'Password',
              hint: '••••••••',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              onSubmitted: (_) => _handleLogin(),
              validator: (v) => (v?.length ?? 0) < 4 ? 'Password required' : null,
            ),
            const SizedBox(height: DesignTokens.space24),

            AppButton(
              text: 'Sign In to Workspace',
              isFullWidth: true,
              size: ButtonSize.lg,
              isLoading: authState.isLoading,
              onPressed: _handleLogin,
            ),
            const SizedBox(height: DesignTokens.space20),

            // One-Click Demo Quick Switchers
            Text(
              'ONE-CLICK DEMO ACCOUNTS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppColors.textMuted(isDark),
              ),
            ),
            const SizedBox(height: DesignTokens.space8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _DemoChip(
                  label: 'Gym Owner',
                  onTap: () => _quickFill('admin@titanfit.com', 'Admin123!'),
                  isDark: isDark,
                ),
                _DemoChip(
                  label: 'Branch Manager',
                  onTap: () => _quickFill('sarah.manager@titanfit.com', 'Manager123!'),
                  isDark: isDark,
                ),
                _DemoChip(
                  label: 'Reception Desk',
                  onTap: () => _quickFill('marcus.desk@titanfit.com', 'Staff123!'),
                  isDark: isDark,
                ),
                _DemoChip(
                  label: 'Personal Trainer',
                  onTap: () => _quickFill('david.trainer@titanfit.com', 'Trainer123!'),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space20),

            const Divider(),
            const SizedBox(height: DesignTokens.space12),

            Center(
              child: TextButton(
                onPressed: _showRegisterDialog,
                child: Text(
                  'Register New Gym Organization →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _FeatureBullet({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
            borderRadius: DesignTokens.borderMd,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: DesignTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DemoChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _DemoChip({
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: DesignTokens.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9),
          borderRadius: DesignTokens.borderSm,
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary(isDark),
          ),
        ),
      ),
    );
  }
}

