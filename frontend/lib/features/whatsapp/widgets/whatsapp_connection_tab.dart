import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/states/feedback/app_state_handler.dart';
import '../../../core/states/success/app_toast.dart';
import '../../../core/states/success/confirmation_dialog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../whatsapp_models.dart';
import '../whatsapp_provider.dart';

class WhatsAppConnectionTab extends ConsumerStatefulWidget {
  final bool isDark;
  const WhatsAppConnectionTab({super.key, required this.isDark});

  @override
  ConsumerState<WhatsAppConnectionTab> createState() => _WhatsAppConnectionTabState();
}

class _WhatsAppConnectionTabState extends ConsumerState<WhatsAppConnectionTab> {
  final _wabaCtrl = TextEditingController();
  final _phoneIdCtrl = TextEditingController();
  final _displayPhoneCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _timeZoneCtrl = TextEditingController(text: 'Asia/Kolkata');
  final _appIdCtrl = TextEditingController();
  final _appSecretCtrl = TextEditingController();

  bool _isSaving = false;
  bool _isRegistering = false;

  void _populate(WhatsAppIntegrationModel config) {
    if (_wabaCtrl.text.isEmpty) _wabaCtrl.text = config.wabaId;
    if (_phoneIdCtrl.text.isEmpty) _phoneIdCtrl.text = config.phoneNumberId;
    if (_displayPhoneCtrl.text.isEmpty) _displayPhoneCtrl.text = config.displayPhoneNumber;
    if (_portfolioCtrl.text.isEmpty) _portfolioCtrl.text = config.businessPortfolioName;
    if (_timeZoneCtrl.text.isEmpty) _timeZoneCtrl.text = config.timeZoneId;
    if (_appIdCtrl.text.isEmpty && config.appId != null) _appIdCtrl.text = config.appId!;
  }

  void _showRegisterPinDialog() {
    final pinCtrl = TextEditingController(text: '123456');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          side: BorderSide(color: AppColors.border(widget.isDark)),
        ),
        title: Row(
          children: [
            const Icon(Icons.pin_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              'Register Number with 6-Digit PIN',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-digit two-step verification PIN configured for your WhatsApp Business Account:',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: '6-Digit PIN',
              controller: pinCtrl,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted(widget.isDark))),
          ),
          AppButton(
            label: 'Register Number',
            icon: Icons.check_circle_rounded,
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isRegistering = true);
              final ok = await ref.read(whatsAppActionProvider).registerPhoneNumber(pinCtrl.text.trim());
              setState(() => _isRegistering = false);
              if (ok) {
                ref.read(toastProvider.notifier).success('Registration Confirmed', message: 'Phone number registered with Meta Cloud API.');
              } else {
                ref.read(toastProvider.notifier).error('Registration Failed', message: 'Could not register phone number.');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(whatsAppConfigProvider);

    return configAsync.buildStateWidget(
      context,
      onRetry: () => ref.refresh(whatsAppConfigProvider),
      onData: (config) {
        _populate(config);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Connection Health Card
              Container(
                padding: const EdgeInsets.all(DesignTokens.space20),
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(color: AppColors.border(widget.isDark)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          ),
                          child: const Center(
                            child: Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 32),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  config.businessPortfolioName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(widget.isDark),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(status: config.connectionStatus),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phone: ${config.displayPhoneNumber}  •  Verified: ${config.verifiedName}',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AppButton(
                          label: _isRegistering ? 'Registering...' : 'Register PIN',
                          icon: Icons.pin_rounded,
                          variant: AppButtonVariant.secondary,
                          isLoading: _isRegistering,
                          onPressed: _showRegisterPinDialog,
                        ),
                        const SizedBox(width: 10),
                        AppButton(
                          label: 'Disconnect',
                          icon: Icons.link_off_rounded,
                          variant: AppButtonVariant.danger,
                          onPressed: () async {
                            final confirm = await SystemConfirmationDialog.show(
                              context: context,
                              title: 'Disconnect WhatsApp Business Account',
                              message: 'This will pause automated WhatsApp check-in alerts and campaigns until reconnected.',
                              confirmLabel: 'Disconnect WABA',
                              isDestructive: true,
                            );
                            if (confirm == true) {
                              final ok = await ref.read(whatsAppActionProvider).disconnectConfig();
                              if (ok) {
                                ref.read(toastProvider.notifier).success('Account Disconnected', message: 'WABA disconnected.');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space20),

              // 2. Meta Cloud API Credentials Form
              GlassCard(
                padding: const EdgeInsets.all(DesignTokens.space24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meta WhatsApp Cloud API Credentials',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(widget.isDark),
                      ),
                    ),
                    Text(
                      'Obtained from your Meta App Dashboard under WhatsApp > API Setup',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'WhatsApp Business Account ID (WABA ID)',
                            controller: _wabaCtrl,
                            hint: 'e.g. 109283746592837',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            label: 'Phone Number ID',
                            controller: _phoneIdCtrl,
                            hint: 'e.g. 105938472910482',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Display Phone Number',
                            controller: _displayPhoneCtrl,
                            hint: 'e.g. +1 555-0199',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            label: 'Business Portfolio / Gym Brand Name',
                            controller: _portfolioCtrl,
                            hint: 'e.g. Titan Athletic Club',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Access Token
                    AppTextField(
                      label: 'System User Permanent Access Token',
                      controller: _tokenCtrl,
                      isPassword: true,
                      hint: 'EAAG... (Never shared publicly or stored in client)',
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Meta App ID (For Embedded Signup)',
                            controller: _appIdCtrl,
                            hint: 'e.g. 592817492817492',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            label: 'App Secret (For Webhook HMAC Verification)',
                            controller: _appSecretCtrl,
                            isPassword: true,
                            hint: 'App secret from App Settings > Basic',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    AppButton(
                      label: 'Save & Verify Meta Credentials',
                      icon: Icons.save_rounded,
                      isLoading: _isSaving,
                      onPressed: () async {
                        setState(() => _isSaving = true);
                        final ok = await ref.read(whatsAppActionProvider).updateConfig(
                              wabaId: _wabaCtrl.text.trim(),
                              phoneNumberId: _phoneIdCtrl.text.trim(),
                              displayPhoneNumber: _displayPhoneCtrl.text.trim(),
                              businessPortfolioName: _portfolioCtrl.text.trim(),
                              accessToken: _tokenCtrl.text.trim(),
                              timeZoneId: _timeZoneCtrl.text.trim(),
                              appId: _appIdCtrl.text.trim().isEmpty ? null : _appIdCtrl.text.trim(),
                              appSecret: _appSecretCtrl.text.trim().isEmpty ? null : _appSecretCtrl.text.trim(),
                            );
                        setState(() => _isSaving = false);

                        if (ok) {
                          ref.read(toastProvider.notifier).success('Configuration Saved', message: 'Credentials updated and verified with Meta.');
                        } else {
                          ref.read(toastProvider.notifier).error('Update Failed', message: 'Could not update Meta configuration.');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space20),

              // 3. Webhook Configuration Details
              GlassCard(
                padding: const EdgeInsets.all(DesignTokens.space24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Webhook Configuration for Inbound Events',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(widget.isDark),
                      ),
                    ),
                    Text(
                      'Configure this callback URL in Meta Developer Portal under WhatsApp > Configuration',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.raised(widget.isDark),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                              border: Border.all(color: AppColors.border(widget.isDark)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Callback URL', style: TextStyle(fontSize: 10, color: AppColors.textMuted(widget.isDark))),
                                const SizedBox(height: 2),
                                SelectableText(
                                  config.webhookUrl,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.raised(widget.isDark),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                              border: Border.all(color: AppColors.border(widget.isDark)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Verify Token', style: TextStyle(fontSize: 10, color: AppColors.textMuted(widget.isDark))),
                                const SizedBox(height: 2),
                                SelectableText(
                                  config.webhookVerifyToken,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary(widget.isDark)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
