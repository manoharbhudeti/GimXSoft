import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/auth_provider.dart';
import 'interactive_3d_stage.dart';

/// 3D Interactive, Reactive High-Quality Landing Page for GimXSoft
/// Built according to heydamir/unslop specifications:
/// - Asymmetric split hero with 3D Olympic Plate stage
/// - Interactive live gym floor check-in & WhatsApp automation simulator
/// - Clean graphite neutral ramp with athletic amber accent
/// - Real product moments and authentic athletic domain character
class LandingView extends ConsumerStatefulWidget {
  const LandingView({super.key});

  @override
  ConsumerState<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends ConsumerState<LandingView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _simulatorKey = GlobalKey();
  final GlobalKey _modulesKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();

  // Interactive Live Simulator State
  int _simulatedOccupancy = 42;
  bool _isScanProcessing = false;
  String _scanStatus = 'READY'; // READY, SCANNING, GRANTED
  String? _lastScannedMember;
  DateTime? _lastScanTime;

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: DesignTokens.easeOutStandard,
      );
    }
  }

  void _triggerSimulatedScan() {
    if (_isScanProcessing) return;

    setState(() {
      _isScanProcessing = true;
      _scanStatus = 'SCANNING';
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isScanProcessing = false;
        _scanStatus = 'GRANTED';
        _simulatedOccupancy = (_simulatedOccupancy + 1).clamp(0, 120);
        _lastScannedMember = 'Marcus Vance (TF-1082)';
        _lastScanTime = DateTime.now();
      });

      Future.delayed(const Duration(milliseconds: 3000), () {
        if (!mounted) return;
        setState(() {
          _scanStatus = 'READY';
        });
      });
    });
  }

  void _showDemoDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141720) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          side: BorderSide(color: AppColors.border(isDark)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.15),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF25D366)),
            ),
            const SizedBox(width: 10),
            Text(
              'Connect with GimXSoft',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reach out to our engineering team directly via WhatsApp for quick onboarding, live walkthroughs, and custom demos.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
            ),
            const SizedBox(height: 16),
            // WhatsApp Direct Connect Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(color: const Color(0xFF25D366).withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_android_rounded, size: 20, color: Color(0xFF25D366)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WhatsApp Direct Line',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          '+91 83743 86604',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    tooltip: 'Copy Number',
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: '+91 83743 86604'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('WhatsApp number copied: +91 83743 86604'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Email backup box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.raised(isDark),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mark_email_read_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      'ekametechnologie@gmail.com',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Available on WhatsApp 7 days a week. We typically respond within minutes.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close', style: TextStyle(color: AppColors.textSecondary(isDark))),
          ),
          AppButton(
            text: 'Open WhatsApp Chat',
            icon: Icons.chat_bubble_rounded,
            size: ButtonSize.sm,
            variant: ButtonVariant.primary,
            onPressed: () {
              Navigator.of(ctx).pop();
              final uri = Uri.parse('https://wa.me/918374386604?text=Hi%2C+I%27m+interested+in+GimXSoft+for+my+gym');
              launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }

  void _showTrialDialog(BuildContext context, bool isDark) {
    final gymNameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'Admin123!');
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    String? submitError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF141720) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            side: BorderSide(color: AppColors.border(isDark)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: const Icon(Icons.card_giftcard_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start 1-Month Free Trial',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Free billing for 30 days • Cancel anytime • ₹0 due today',
                      style: TextStyle(fontSize: 11, color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.raised(isDark),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        border: Border.all(color: AppColors.border(isDark)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Zero payment needed to register. Try free for 1 month. After 1 month, full platform access continues at ₹2,000 only. Cancel anytime with zero penalty.',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (submitError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                        child: Text(
                          submitError!,
                          style: const TextStyle(fontSize: 11, color: AppColors.error),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    AppTextField(
                      label: 'Gym / Fitness Club Name',
                      hint: 'e.g. Iron Core Fitness',
                      controller: gymNameCtrl,
                      prefixIcon: Icons.fitness_center_rounded,
                      validator: (v) => v?.trim().isEmpty == true ? 'Gym name required' : null,
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      label: 'Your Full Name',
                      hint: 'e.g. Vikram Malhotra',
                      controller: nameCtrl,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => v?.trim().isEmpty == true ? 'Name required' : null,
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      label: 'Admin Work Email',
                      hint: 'vikram@ironcore.com',
                      controller: emailCtrl,
                      prefixIcon: Icons.mail_outline_rounded,
                      validator: (v) => v?.contains('@') != true ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      label: 'Create Admin Password',
                      hint: 'Minimum 6 characters',
                      controller: passCtrl,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.go('/login');
                        },
                        child: Text(
                          'Already an existing admin or customer? Sign in →',
                          style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary(isDark))),
            ),
            AppButton(
              text: isSubmitting ? 'Activating...' : 'Claim 1-Month Free (₹0)',
              icon: Icons.check_circle_outline_rounded,
              size: ButtonSize.sm,
              variant: ButtonVariant.primary,
              isLoading: isSubmitting,
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() ?? false) {
                        setDialogState(() {
                          isSubmitting = true;
                          submitError = null;
                        });
                        final ok = await ref.read(authProvider.notifier).registerTrial(
                              gymName: gymNameCtrl.text,
                              adminFullName: nameCtrl.text,
                              adminEmail: emailCtrl.text,
                              adminPassword: passCtrl.text,
                            );
                        if (ok && mounted) {
                          Navigator.of(ctx).pop();
                          context.go('/dashboard');
                        } else {
                          setDialogState(() {
                            isSubmitting = false;
                            submitError = ref.read(authProvider).errorMessage ?? 'Registration failed. Please try again.';
                          });
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = ref.watch(themeModeProvider.notifier);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: Stack(
        children: [
          // 1. Scrollable Landing Content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 72), // Top nav clearance

                // Section 1: 3D Interactive Hero
                _buildHeroSection(context, isDark, authState),

                const SizedBox(height: 64),

                // Section 2: Interactive Live Operations Simulator
                Container(
                  key: _simulatorKey,
                  child: _buildSimulatorSection(isDark),
                ),

                const SizedBox(height: 64),

                // Section 3: 4-Pillar Core Modules
                Container(
                  key: _modulesKey,
                  child: _buildCoreModulesSection(isDark),
                ),

                const SizedBox(height: 64),

                // Section 4: Multi-Branch Telemetry Comparison
                _buildMultiBranchTelemetry(isDark),

                const SizedBox(height: 64),

                // Section 5: Transparent Pricing & ROI
                Container(
                  key: _pricingKey,
                  child: _buildPricingSection(isDark),
                ),

                const SizedBox(height: 64),

                // Section 6: CTA Action Banner
                _buildCtaBanner(context, isDark, authState),

                // Section 7: Enterprise Footer
                _buildFooter(isDark),
              ],
            ),
          ),

          // 2. Fixed Floating Header Navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopNav(context, isDark, themeNotifier, authState),
          ),
        ],
      ),
    );
  }

  // --- 1. Top Navbar ---
  Widget _buildTopNav(
    BuildContext context,
    bool isDark,
    ThemeModeNotifier themeNotifier,
    AuthState authState,
  ) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space24),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkDeepest : Colors.white).withOpacity(0.92),
        border: Border(
          bottom: BorderSide(color: AppColors.border(isDark), width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Row(
            children: [
              // Brand mark
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: const Center(
                      child: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space10),
                  Text(
                    'GimXSoft',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),

              if (isDesktop) ...[
                const SizedBox(width: 32),
                _buildNavAnchor('Simulator', () => _scrollToKey(_simulatorKey), isDark),
                const SizedBox(width: 20),
                _buildNavAnchor('Modules', () => _scrollToKey(_modulesKey), isDark),
                const SizedBox(width: 20),
                _buildNavAnchor('Pricing', () => _scrollToKey(_pricingKey), isDark),
              ],

              const Spacer(),

              // Email Demo Contact Pill
              InkWell(
                onTap: () => _showDemoDialog(context, isDark),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.raised(isDark),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    border: Border.all(color: AppColors.border(isDark)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mail_outline_rounded, size: 13, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'ekametechnologie@gmail.com',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.space4),

              // Quick WhatsApp Direct Connect Icon Button
              IconButton(
                tooltip: 'WhatsApp: +91 83743 86604',
                icon: const Icon(
                  Icons.chat_bubble_rounded,
                  size: 16,
                  color: Color(0xFF25D366),
                ),
                splashRadius: 16,
                onPressed: () {
                  final uri = Uri.parse('https://wa.me/918374386604?text=Hi%2C+I%27m+interested+in+GimXSoft+for+my+gym');
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(width: DesignTokens.space8),

              // Live Network Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.raised(isDark),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      'Titan Network: Online',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.space12),

              // Theme Switcher
              IconButton(
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 18,
                  color: AppColors.textSecondary(isDark),
                ),
                splashRadius: 16,
                onPressed: () => themeNotifier.toggle(),
              ),

              const SizedBox(width: DesignTokens.space8),

              // Primary Action: Launch Console
              AppButton(
                text: authState.isAuthenticated ? 'Open Desk' : 'Sign in',
                icon: authState.isAuthenticated ? Icons.dashboard_outlined : Icons.login_rounded,
                size: ButtonSize.sm,
                variant: ButtonVariant.primary,
                onPressed: () {
                  if (authState.isAuthenticated) {
                    context.go('/dashboard');
                  } else {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavAnchor(String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary(isDark),
          ),
        ),
      ),
    );
  }

  // --- 2. 3D Interactive Hero Section ---
  Widget _buildHeroSection(BuildContext context, bool isDark, AuthState authState) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space24,
            vertical: DesignTokens.space32,
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: _buildHeroLeftColumn(context, isDark, authState)),
                    const SizedBox(width: DesignTokens.space32),
                    Expanded(flex: 5, child: _buildHeroRight3DStage(isDark)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeroLeftColumn(context, isDark, authState),
                    const SizedBox(height: DesignTokens.space40),
                    _buildHeroRight3DStage(isDark),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroLeftColumn(BuildContext context, bool isDark, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.raised(isDark),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            border: Border.all(color: AppColors.border(isDark)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(
                'ATHLETIC CLUB & FRANCHISE OPERATING SYSTEM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space20),

        // Hero Headline (Sentence case, size for hierarchy, 500 weight)
        Text(
          'Smarter gym operations.\nExact member telemetry.',
          style: TextStyle(
            fontSize: 42,
            height: 1.12,
            fontWeight: FontWeight.w500,
            letterSpacing: -1.0,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        const SizedBox(height: DesignTokens.space16),

        // Subhead
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Text(
            'Manage turnstile check-ins, 1-on-1 individual WhatsApp messaging, 7-day routine splits, and recurring billing. 1-Month free trial, then ₹2,000 only.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.space32),

        // Action CTA Row
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            AppButton(
              text: 'Try 1 Month Free (₹2,000 after trial)',
              icon: Icons.card_giftcard_rounded,
              size: ButtonSize.lg,
              variant: ButtonVariant.primary,
              onPressed: () => _showTrialDialog(context, isDark),
            ),
            AppButton(
              text: 'Book Demo',
              icon: Icons.mail_outline_rounded,
              size: ButtonSize.lg,
              variant: ButtonVariant.secondary,
              onPressed: () => _showDemoDialog(context, isDark),
            ),
            AppButton(
              text: 'Live Simulator',
              icon: Icons.tune_rounded,
              size: ButtonSize.lg,
              variant: ButtonVariant.outline,
              onPressed: () => _scrollToKey(_simulatorKey),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space32),

        // Quiet Guarantee & Trust Bar (Unslopped zero-risk pillars)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildHeroKpi('1 Month', 'Free billing', isDark),
              const SizedBox(width: 18),
              Container(width: 1, height: 28, color: AppColors.border(isDark)),
              const SizedBox(width: 18),
              _buildHeroKpi('Cancel', 'Anytime', isDark),
              const SizedBox(width: 18),
              Container(width: 1, height: 28, color: AppColors.border(isDark)),
              const SizedBox(width: 18),
              _buildHeroKpi('₹0 Due', 'No payment needed', isDark),
              const SizedBox(width: 18),
              Container(width: 1, height: 28, color: AppColors.border(isDark)),
              const SizedBox(width: 18),
              _buildHeroKpi('₹2,000', 'After 30 days', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroKpi(String figure, String label, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          figure,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: AppColors.textPrimary(isDark),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroRight3DStage(bool isDark) {
    return Center(
      child: Interactive3DStage(
        liveOccupancy: _simulatedOccupancy,
      ),
    );
  }

  // --- 3. Interactive Live Operations Simulator ---
  Widget _buildSimulatorSection(bool isDark) {
    final capacityPercentage = ((_simulatedOccupancy / 120) * 100).toInt();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Text(
                'Live interactive console',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Experience turnstile reception & WhatsApp dispatch',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Drag the occupancy slider or trigger a simulated RFID badge scan to see real-time state telemetry and WhatsApp automation in action.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary(isDark)),
              ),
              const SizedBox(height: DesignTokens.space24),

              // Interactive Simulator Console
              GlassCard(
                padding: const EdgeInsets.all(DesignTokens.space24),
                borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                child: Column(
                  children: [
                    // Top Controls Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                              ),
                              child: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: AppColors.primary),
                            ),
                            const SizedBox(width: DesignTokens.space12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Turnstile Terminal #01',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                ),
                                Text(
                                  'Downtown Flagship • Reception Gate',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Terminal Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _scanStatus == 'GRANTED'
                                ? AppColors.success.withOpacity(0.15)
                                : (_scanStatus == 'SCANNING'
                                    ? AppColors.primary.withOpacity(0.15)
                                    : AppColors.raised(isDark)),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                            border: Border.all(
                              color: _scanStatus == 'GRANTED'
                                  ? AppColors.success
                                  : (_scanStatus == 'SCANNING' ? AppColors.primary : AppColors.border(isDark)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _scanStatus == 'GRANTED'
                                    ? Icons.check_circle_outline
                                    : (_scanStatus == 'SCANNING' ? Icons.sync_rounded : Icons.radio_button_checked),
                                size: 14,
                                color: _scanStatus == 'GRANTED'
                                    ? AppColors.success
                                    : (_scanStatus == 'SCANNING' ? AppColors.primary : AppColors.textMuted(isDark)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _scanStatus == 'GRANTED'
                                    ? 'ACCESS GRANTED'
                                    : (_scanStatus == 'SCANNING' ? 'SCANNING BADGE…' : 'TERMINAL READY'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _scanStatus == 'GRANTED'
                                      ? AppColors.success
                                      : (_scanStatus == 'SCANNING' ? AppColors.primary : AppColors.textSecondary(isDark)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space24),

                    // Middle: Occupancy Gauge Slider
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.space16),
                      decoration: BoxDecoration(
                        color: AppColors.raised(isDark),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        border: Border.all(color: AppColors.border(isDark)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Simulate Floor Occupancy',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                              Text(
                                '$_simulatedOccupancy / 120 capacity ($capacityPercentage%)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  color: capacityPercentage > 85 ? AppColors.error : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: capacityPercentage > 85 ? AppColors.error : AppColors.primary,
                              inactiveTrackColor: AppColors.border(isDark),
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primary.withOpacity(0.12),
                            ),
                            child: Slider(
                              value: _simulatedOccupancy.toDouble(),
                              min: 0,
                              max: 120,
                              onChanged: (val) {
                                setState(() {
                                  _simulatedOccupancy = val.toInt();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space24),

                    // Lower Split: Interactive Scanner Simulator & WhatsApp Instant Dispatch Stream
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isTwoCol = constraints.maxWidth >= 720;
                        final scanBox = Container(
                          padding: const EdgeInsets.all(DesignTokens.space20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF141416) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            border: Border.all(color: AppColors.border(isDark)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Member Scan Simulation',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Click below to test hardware turnstile integration and automatic member log creation.',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                              ),
                              const SizedBox(height: DesignTokens.space16),
                              AppButton(
                                text: _isScanProcessing ? 'Processing…' : 'Tap Member RFID / Scan QR',
                                icon: Icons.nfc_rounded,
                                isLoading: _isScanProcessing,
                                variant: ButtonVariant.primary,
                                onPressed: _triggerSimulatedScan,
                              ),
                              if (_lastScannedMember != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Last Check-in: $_lastScannedMember at ${DateFormat('HH:mm:ss').format(_lastScanTime!)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );

                        final whatsAppBox = Container(
                          padding: const EdgeInsets.all(DesignTokens.space20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF141416) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            border: Border.all(color: AppColors.border(isDark)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF25D366)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Meta Cloud Automated Dispatch',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (isDark ? const Color(0xFF1E2428) : const Color(0xFFDCF8C6)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _scanStatus == 'GRANTED'
                                          ? 'Hi Marcus! Welcome to Titan Downtown Flagship. Your workout check-in is logged at ${DateFormat('HH:mm').format(_lastScanTime!)}. Today\'s routine: Chest & Triceps Hypertrophy.'
                                          : 'Waiting for attendance check-in trigger to dispatch welcome notification…',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          DateFormat('HH:mm').format(DateTime.now()),
                                          style: TextStyle(fontSize: 10, color: AppColors.textMuted(isDark)),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF53BDEB)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );

                        if (isTwoCol) {
                          return Row(
                            children: [
                              Expanded(child: scanBox),
                              const SizedBox(width: DesignTokens.space16),
                              Expanded(child: whatsAppBox),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              scanBox,
                              const SizedBox(height: DesignTokens.space16),
                              whatsAppBox,
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 4. Four Core Functional Modules ---
  Widget _buildCoreModulesSection(bool isDark) {
    final modules = [
      (
        title: 'Turnstile & Member RFID / QR',
        desc: 'Sub-second QR scan and RFID badge processing with automated duplicate check prevention, floor capacity alarms, and offline cache fallback.',
        icon: Icons.qr_code_scanner_rounded,
        tag: 'OPERATIONS',
      ),
      (
        title: '1-on-1 Individual WhatsApp Messaging',
        desc: 'Direct member chat from their profile without saving numbers. Instant turnstile check-in receipts, personalized workout PDFs, and fee renewal links via Meta Cloud API.',
        icon: Icons.chat_rounded,
        tag: 'CRM & MESSAGING',
      ),
      (
        title: 'Workout Splits & Biometric Tracking',
        desc: 'Coach routine prescription builder with 7-day splits, rest timers, body measurement logs, BMI tracking, and personal milestone reviews.',
        icon: Icons.fitness_center_rounded,
        tag: 'FITNESS ENGINE',
      ),
      (
        title: 'UPI Billing & GST Invoices',
        desc: 'Audit-logged payment collections across Cash, UPI QR, and Card channels with automated GST-compliant tax invoices included in the ₹2,000 plan.',
        icon: Icons.receipt_long_rounded,
        tag: 'FINANCIAL LEDGER',
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete operations platform',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Engineered for gym owners, managers & strength coaches',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: DesignTokens.space24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isGrid = constraints.maxWidth >= 720;
                  final width = isGrid ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: modules.map((m) {
                      return SizedBox(
                        width: width,
                        child: GlassCard(
                          padding: const EdgeInsets.all(DesignTokens.space24),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.raised(isDark),
                                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                      border: Border.all(color: AppColors.border(isDark)),
                                    ),
                                    child: Icon(m.icon, size: 20, color: AppColors.primary),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.raised(isDark),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      m.tag,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                        color: AppColors.textMuted(isDark),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: DesignTokens.space16),
                              Text(
                                m.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                m.desc,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 5. Multi-Branch Real-Time Telemetry ---
  Widget _buildMultiBranchTelemetry(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enterprise Multi-Tenancy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cross-facility oversight with strict tenant isolation',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: DesignTokens.space24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTwoCol = constraints.maxWidth >= 720;
                  final branch1 = _buildBranchCard(
                    title: 'Downtown Flagship',
                    code: 'DT-01',
                    members: 342,
                    occupancy: _simulatedOccupancy,
                    maxCapacity: 120,
                    isDark: isDark,
                  );
                  final branch2 = _buildBranchCard(
                    title: 'Westside Wellness',
                    code: 'WS-02',
                    members: 198,
                    occupancy: 28,
                    maxCapacity: 80,
                    isDark: isDark,
                  );

                  if (isTwoCol) {
                    return Row(
                      children: [
                        Expanded(child: branch1),
                        const SizedBox(width: DesignTokens.space16),
                        Expanded(child: branch2),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        branch1,
                        const SizedBox(height: DesignTokens.space16),
                        branch2,
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchCard({
    required String title,
    required String code,
    required int members,
    required int occupancy,
    required int maxCapacity,
    required bool isDark,
  }) {
    final pct = ((occupancy / maxCapacity) * 100).toInt();

    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space20),
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary(isDark),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Branch code: $code',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.space8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.raised(isDark),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Text(
                  '$occupancy / $maxCapacity on floor ($pct%)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space16),
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            child: LinearProgressIndicator(
              value: (occupancy / maxCapacity).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.raised(isDark),
              valueColor: AlwaysStoppedAnimation<Color>(pct > 80 ? AppColors.warning : AppColors.primary),
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$members Registered Athletes',
                style: TextStyle(
                  fontSize: 12,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  // --- 6. Pricing & ROI Calculator ---
  Widget _buildPricingSection(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Transparent SaaS Tiers',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '1-Month Free Trial, Then ₹2,000 Only',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  'Try free for 1 month with full feature access. No payment or credit card needed to register. After 1 month, full platform access continues at ₹2,000 only. Cancel anytime with zero penalty.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary(isDark)),
                ),
              ),
              const SizedBox(height: DesignTokens.space32),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isTwoCol = constraints.maxWidth >= 720;
                  final starter = _buildPricingCard(
                    name: 'Full Platform Access',
                    price: '₹2,000',
                    priceUnit: ' only after 1 month trial',
                    subtitle: '₹0 Due Today • Free billing for 30 days • Cancel anytime',
                    features: [
                      '1-Month 100% Free Trial with full unrestricted access',
                      'No payment needed for registration (₹0 today)',
                      'Cancel anytime with 1 click & zero penalties',
                      'Flat ₹2,000 only charged after 30-day trial completion',
                      '1-on-1 Individual WhatsApp messaging for any member (Meta Cloud API)',
                      'Turnstile RFID & QR attendance integration (99.98% uptime)',
                      '7-Day workout routine splits builder & exercise movement library',
                      'Member biometrics, BMI progress & body composition tracking',
                      'Automated UPI QR payments & GST tax invoice PDF generation',
                      'Unlimited active gym members, trainers & staff logins',
                    ],
                    isFeatured: true,
                    isDark: isDark,
                    buttonText: 'Start 1-Month Free Trial (₹0 Today)',
                    onPressed: () => _showTrialDialog(context, isDark),
                  );

                  final enterprise = _buildPricingCard(
                    name: 'Multi-Branch & Enterprise',
                    price: 'Custom',
                    priceUnit: ' / enterprise rollout',
                    subtitle: 'For franchise networks, multi-location gym chains & custom hardware setups',
                    features: [
                      'Everything in Full Platform Access included',
                      'Centralized multi-branch HQ dashboard with cross-branch roaming',
                      'Custom turnstile hardware bridge integration (Facial, RFID & QR)',
                      'Priority WhatsApp support SLA with dedicated technical manager',
                      'White-glove database migration assistance from legacy software',
                      'Custom staff permission roles & franchise financial audit reporting',
                    ],
                    isFeatured: false,
                    isDark: isDark,
                    buttonText: 'Book a Live Demo',
                    onPressed: () => _showDemoDialog(context, isDark),
                  );

                  if (isTwoCol) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: starter),
                        const SizedBox(width: DesignTokens.space16),
                        Expanded(child: enterprise),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        starter,
                        const SizedBox(height: DesignTokens.space16),
                        enterprise,
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String name,
    required String price,
    String priceUnit = ' / mo',
    required String subtitle,
    required List<String> features,
    required bool isFeatured,
    required bool isDark,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space24),
      borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      borderColor: isFeatured ? AppColors.primary.withOpacity(0.4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFeatured)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: const Text(
                'TRY 1 MONTH FREE (₹2,000 AFTER)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  priceUnit,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted(isDark)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
          ),
          const SizedBox(height: DesignTokens.space20),
          Divider(color: AppColors.border(isDark)),
          const SizedBox(height: DesignTokens.space16),
          ...features.map((f) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: DesignTokens.space20),
          AppButton(
            text: buttonText,
            isFullWidth: true,
            variant: isFeatured ? ButtonVariant.primary : ButtonVariant.secondary,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  // --- 7. Call To Action Banner ---
  Widget _buildCtaBanner(BuildContext context, bool isDark, AuthState authState) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space24),
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.space32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF19191B) : const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to modernize your gym facility?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start your 1-month free trial today. After 1 month, full platform access continues at ₹2,000 only. For custom demos, contact our engineering team at ekametechnologie@gmail.com.',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary(isDark)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    AppButton(
                      text: 'Start 1-Month Free Trial',
                      icon: Icons.card_giftcard_rounded,
                      size: ButtonSize.md,
                      variant: ButtonVariant.primary,
                      onPressed: () => _showTrialDialog(context, isDark),
                    ),
                    AppButton(
                      text: 'WhatsApp: 8374386604',
                      icon: Icons.chat_bubble_rounded,
                      size: ButtonSize.md,
                      variant: ButtonVariant.secondary,
                      onPressed: () {
                        final uri = Uri.parse('https://wa.me/918374386604?text=Hi%2C+I%27m+interested+in+GimXSoft+for+my+gym');
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                    ),
                    AppButton(
                      text: 'Email Demo',
                      icon: Icons.mail_outline_rounded,
                      size: ButtonSize.md,
                      variant: ButtonVariant.secondary,
                      onPressed: () => _showDemoDialog(context, isDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 8. Enterprise Footer ---
  Widget _buildFooter(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.space32, horizontal: DesignTokens.space24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkDeepest : Colors.white,
        border: Border(top: BorderSide(color: AppColors.border(isDark))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GimXSoft SaaS Platform',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: DesignTokens.space16),
              Flexible(
                child: Text(
                  'WhatsApp: +91 83743 86604 • Demo & Inquiries: ekametechnologie@gmail.com • Built for Gym Franchises & Modern Clubs',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
