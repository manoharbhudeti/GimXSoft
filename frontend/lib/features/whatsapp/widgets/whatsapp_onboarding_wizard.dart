import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/states/success/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../whatsapp_models.dart';
import '../whatsapp_provider.dart';

class WhatsAppOnboardingWizard extends ConsumerStatefulWidget {
  final bool isDark;
  final VoidCallback onConnected;
  final VoidCallback? onCancel;

  const WhatsAppOnboardingWizard({
    super.key,
    required this.isDark,
    required this.onConnected,
    this.onCancel,
  });

  @override
  ConsumerState<WhatsAppOnboardingWizard> createState() => _WhatsAppOnboardingWizardState();
}

class _WhatsAppOnboardingWizardState extends ConsumerState<WhatsAppOnboardingWizard> {
  int _currentStep = 1; // 1: Number entry, 2: OTP verification, 3: Success

  // Step 1 Controllers & State
  String _selectedCountryCode = '+91';
  final _phoneCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController(text: 'Titan Athletic Club');
  String _verificationMethod = 'SMS';
  bool _isInitiating = false;

  // Step 2 Controllers & State
  final _otpCtrl = TextEditingController();
  final _pinCtrl = TextEditingController(text: '123456');
  String? _sessionId;
  String _maskedPhone = '';
  String? _sandboxCode;
  bool _isVerifying = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  // Step 3 State
  WhatsAppIntegrationModel? _connectedIntegration;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'name': 'India (+91)', 'flag': '🇮🇳'},
    {'code': '+1', 'name': 'United States / Canada (+1)', 'flag': '🇺🇸'},
    {'code': '+44', 'name': 'United Kingdom (+44)', 'flag': '🇬🇧'},
    {'code': '+971', 'name': 'United Arab Emirates (+971)', 'flag': '🇦🇪'},
    {'code': '+61', 'name': 'Australia (+61)', 'flag': '🇦🇺'},
    {'code': '+65', 'name': 'Singapore (+65)', 'flag': '🇸🇬'},
  ];

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneCtrl.dispose();
    _businessNameCtrl.dispose();
    _otpCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleInitiate() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      ref.read(toastProvider.notifier).warning(
        'Phone Number Required',
        message: 'Please enter your WhatsApp Business mobile number.',
      );
      return;
    }

    setState(() => _isInitiating = true);
    final result = await ref.read(whatsAppActionProvider).initiateOnboarding(
          countryCode: _selectedCountryCode,
          phoneNumber: phone,
          businessName: _businessNameCtrl.text.trim(),
          verificationMethod: _verificationMethod,
        );
    setState(() => _isInitiating = false);

    if (result != null && result.success) {
      setState(() {
        _sessionId = result.sessionId;
        _maskedPhone = result.maskedPhoneNumber;
        _sandboxCode = result.verificationCode;
        _currentStep = 2;
      });
      _startCountdown();
      ref.read(toastProvider.notifier).success(
        'Verification Dispatched',
        message: 'A 6-digit Meta verification code was dispatched to $_maskedPhone.',
      );
    } else {
      ref.read(toastProvider.notifier).error(
        'Connection Request Failed',
        message: 'Could not reach Meta verification service. Please check number format.',
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpCtrl.text.trim();
    if (code.length != 6) {
      ref.read(toastProvider.notifier).warning(
        'Invalid Code',
        message: 'Please enter the complete 6-digit verification code.',
      );
      return;
    }

    if (_sessionId == null) return;

    setState(() => _isVerifying = true);
    final result = await ref.read(whatsAppActionProvider).verifyOtpCode(
          sessionId: _sessionId!,
          code: code,
          registrationPin: _pinCtrl.text.trim().isNotEmpty ? _pinCtrl.text.trim() : '123456',
        );
    setState(() => _isVerifying = false);

    if (result.success && result.integration != null) {
      _countdownTimer?.cancel();
      setState(() {
        _connectedIntegration = result.integration;
        _currentStep = 3;
      });
      ref.read(toastProvider.notifier).success(
        'Connected Successfully!',
        message: 'Your WhatsApp Business number is registered and active.',
      );
    } else {
      ref.read(toastProvider.notifier).error(
        'Verification Failed',
        message: result.message,
      );
    }
  }

  Future<void> _handleResendOtp() async {
    if (_sessionId == null || _resendCountdown > 0) return;

    final result = await ref.read(whatsAppActionProvider).resendOtpCode(
          sessionId: _sessionId!,
          verificationMethod: _verificationMethod,
        );

    if (result != null && result.success) {
      setState(() {
        _sandboxCode = result.verificationCode;
      });
      _startCountdown();
      ref.read(toastProvider.notifier).info(
        'Code Resent',
        message: 'New Meta verification code sent via $_verificationMethod.',
      );
    } else {
      ref.read(toastProvider.notifier).error(
        'Resend Failed',
        message: 'Could not resend code. Please try again in a few moments.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 820),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stepper Header
          _buildProgressStepper(),
          const SizedBox(height: DesignTokens.space24),

          // Main Step Card
          if (_currentStep == 1) _buildStep1PhoneEntry(),
          if (_currentStep == 2) _buildStep2OtpVerification(),
          if (_currentStep == 3) _buildStep3Success(),
        ],
      ),
    );
  }

  Widget _buildProgressStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: AppColors.border(widget.isDark)),
      ),
      child: Row(
        children: [
          _buildStepPill(1, '1. Enter Number', _currentStep >= 1, _currentStep == 1),
          Expanded(child: Container(height: 2, color: _currentStep >= 2 ? const Color(0xFF25D366) : AppColors.border(widget.isDark))),
          _buildStepPill(2, '2. Verify OTP', _currentStep >= 2, _currentStep == 2),
          Expanded(child: Container(height: 2, color: _currentStep >= 3 ? const Color(0xFF25D366) : AppColors.border(widget.isDark))),
          _buildStepPill(3, '3. Connected', _currentStep == 3, _currentStep == 3),
        ],
      ),
    );
  }

  Widget _buildStepPill(int stepNumber, String label, bool isCompletedOrActive, bool isCurrent) {
    final activeColor = const Color(0xFF25D366);
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompletedOrActive ? activeColor.withOpacity(0.18) : AppColors.raised(widget.isDark),
            border: Border.all(
              color: isCompletedOrActive ? activeColor : AppColors.border(widget.isDark),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Center(
            child: isCompletedOrActive && stepNumber < _currentStep
                ? Icon(Icons.check, size: 16, color: activeColor)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompletedOrActive ? activeColor : AppColors.textMuted(widget.isDark),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCompletedOrActive ? AppColors.textPrimary(widget.isDark) : AppColors.textMuted(widget.isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1PhoneEntry() {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect Your WhatsApp Business Number',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(widget.isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Automate check-in alerts, tax invoices, renewal warnings, and 1-on-1 member chat directly from your CRM.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted(widget.isDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),

          // Business Name
          AppTextField(
            label: 'Gym / Business Brand Name',
            controller: _businessNameCtrl,
            hint: 'e.g. Titan Athletic Club',
          ),
          const SizedBox(height: 16),

          // Phone Number with Country Code Dropdown
          Text(
            'WhatsApp Business Phone Number',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark)),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  border: Border.all(color: AppColors.border(widget.isDark)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    dropdownColor: widget.isDark ? AppColors.darkCard : Colors.white,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(widget.isDark),
                    ),
                    items: _countryCodes.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['code'],
                        child: Text('${item['flag']} ${item['code']}'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCountryCode = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: '',
                  controller: _phoneCtrl,
                  hint: 'Enter 10-digit mobile number',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Verification Method Selection
          Text(
            'Verification Method',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMethodRadio('SMS', 'Text SMS Message', Icons.sms_outlined),
              const SizedBox(width: 16),
              _buildMethodRadio('VOICE', 'Automated Voice Call', Icons.phone_callback_rounded),
            ],
          ),
          const SizedBox(height: 24),

          // Coexistence & Migration Notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              border: Border.all(color: Colors.blue.withOpacity(0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meta Coexistence & Number Eligibility',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• New numbers & WhatsApp Business App numbers connect seamlessly with Coexistence enabled.\n'
                        '• Personal WhatsApp accounts: If active on personal WhatsApp, you can transition to WhatsApp Business Cloud API in under 2 minutes.',
                        style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary(widget.isDark)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.onCancel != null)
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text('Cancel', style: TextStyle(color: AppColors.textMuted(widget.isDark))),
                )
              else
                const SizedBox.shrink(),
              AppButton(
                label: _isInitiating ? 'Initiating Verification...' : 'Connect WhatsApp Business',
                icon: Icons.arrow_forward_rounded,
                isLoading: _isInitiating,
                onPressed: _handleInitiate,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodRadio(String value, String title, IconData icon) {
    final isSelected = _verificationMethod == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _verificationMethod = value),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF25D366).withOpacity(0.12) : widget.isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            border: Border.all(
              color: isSelected ? const Color(0xFF25D366) : AppColors.border(widget.isDark),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? const Color(0xFF25D366) : AppColors.textMuted(widget.isDark)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF25D366) : AppColors.textPrimary(widget.isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2OtpVerification() {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF25D366), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify Your Phone Number',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(widget.isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter the 6-digit Meta verification code dispatched to $_maskedPhone via $_verificationMethod.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted(widget.isDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),

          // Sandbox code hint for testing convenience
          if (_sandboxCode != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bug_report_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dev Sandbox Mode: Your test verification code is $_sandboxCode',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary(widget.isDark)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _otpCtrl.text = _sandboxCode!),
                    child: const Text('Auto-Fill', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // OTP Code Input Field
          AppTextField(
            label: '6-Digit Verification Code',
            controller: _otpCtrl,
            hint: '••••••',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Two-Step Registration PIN
          AppTextField(
            label: 'Two-Step Verification PIN (for Cloud API Registration)',
            controller: _pinCtrl,
            hint: '6-digit PIN (default 123456)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          // Resend Timer & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _resendCountdown == 0 ? _handleResendOtp : null,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  _resendCountdown > 0
                      ? 'Resend Code in ${_resendCountdown}s'
                      : 'Resend Verification Code',
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: Text('Change Phone Number', style: TextStyle(color: AppColors.textMuted(widget.isDark))),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Verify Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: Text('Back', style: TextStyle(color: AppColors.textMuted(widget.isDark))),
              ),
              AppButton(
                label: _isVerifying ? 'Verifying & Registering...' : 'Verify & Complete Connection',
                icon: Icons.check_circle_rounded,
                isLoading: _isVerifying,
                onPressed: _handleVerifyOtp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Success() {
    final integration = _connectedIntegration;
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.space32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF25D366).withOpacity(0.16),
            ),
            child: const Center(
              child: Icon(Icons.check_circle_rounded, color: Color(0xFF25D366), size: 48),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'WhatsApp Business Connected!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(widget.isDark),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your gym is now connected to Meta WhatsApp Cloud API. Webhooks and automated messaging services are initialized.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted(widget.isDark)),
          ),
          const SizedBox(height: 24),

          // Details Card
          Container(
            padding: const EdgeInsets.all(DesignTokens.space20),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(color: AppColors.border(widget.isDark)),
            ),
            child: Column(
              children: [
                _buildSuccessDetailRow('Connected Number', integration?.displayPhoneNumber ?? _phoneCtrl.text),
                const Divider(),
                _buildSuccessDetailRow('Business Display Name', integration?.businessPortfolioName ?? _businessNameCtrl.text),
                const Divider(),
                _buildSuccessDetailRow('Connection Health', 'HEALTHY • OPERATIONAL', isAccent: true),
                const Divider(),
                _buildSuccessDetailRow('Messaging Limit', integration?.messagingLimitTier ?? 'TIER_10K (10,000 conversations/day)'),
                const Divider(),
                _buildSuccessDetailRow('Webhook Status', 'SUBSCRIBED & ACTIVE', isAccent: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Available Services summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366).withOpacity(0.08),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFF25D366), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Available Services: Check-in notifications, Tax invoice dispatches, 7-day renewal warnings, Workout splits, and 1-on-1 member chat.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary(widget.isDark)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Open Dashboard Button
          AppButton(
            label: 'Open WhatsApp Dashboard',
            icon: Icons.dashboard_rounded,
            onPressed: widget.onConnected,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDetailRow(String label, String value, {bool isAccent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textMuted(widget.isDark))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isAccent ? const Color(0xFF25D366) : AppColors.textPrimary(widget.isDark),
            ),
          ),
        ],
      ),
    );
  }
}
