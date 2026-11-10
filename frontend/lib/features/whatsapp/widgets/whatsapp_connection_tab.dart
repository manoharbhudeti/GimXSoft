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
import 'whatsapp_onboarding_wizard.dart';

class WhatsAppConnectionTab extends ConsumerStatefulWidget {
  final bool isDark;
  const WhatsAppConnectionTab({super.key, required this.isDark});

  @override
  ConsumerState<WhatsAppConnectionTab> createState() => _WhatsAppConnectionTabState();
}

class _WhatsAppConnectionTabState extends ConsumerState<WhatsAppConnectionTab> {
  bool _showWizard = false;
  bool _isDisconnecting = false;

  // Advanced controllers
  final _wabaCtrl = TextEditingController();
  final _phoneIdCtrl = TextEditingController();
  final _displayPhoneCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _timeZoneCtrl = TextEditingController(text: 'Asia/Kolkata');
  final _appIdCtrl = TextEditingController();
  final _appSecretCtrl = TextEditingController();
  bool _isSavingAdvanced = false;

  @override
  void dispose() {
    _wabaCtrl.dispose();
    _phoneIdCtrl.dispose();
    _displayPhoneCtrl.dispose();
    _portfolioCtrl.dispose();
    _tokenCtrl.dispose();
    _timeZoneCtrl.dispose();
    _appIdCtrl.dispose();
    _appSecretCtrl.dispose();
    super.dispose();
  }

  void _populateAdvanced(WhatsAppIntegrationModel config) {
    if (_wabaCtrl.text.isEmpty) _wabaCtrl.text = config.wabaId;
    if (_phoneIdCtrl.text.isEmpty) _phoneIdCtrl.text = config.phoneNumberId;
    if (_displayPhoneCtrl.text.isEmpty) _displayPhoneCtrl.text = config.displayPhoneNumber;
    if (_portfolioCtrl.text.isEmpty) _portfolioCtrl.text = config.businessPortfolioName;
    if (_timeZoneCtrl.text.isEmpty) _timeZoneCtrl.text = config.timeZoneId;
    if (_appIdCtrl.text.isEmpty && config.appId != null) _appIdCtrl.text = config.appId!;
  }

  void _showTestMessageDialog(WhatsAppIntegrationModel config) {
    final destinationCtrl = TextEditingController(text: config.displayPhoneNumber);
    final msgCtrl = TextEditingController(text: 'Hello from GimXSoft! Your WhatsApp Business Cloud API integration is verified and operational.');

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
            const Icon(Icons.send_rounded, color: Color(0xFF25D366), size: 20),
            const SizedBox(width: 10),
            Text(
              'Send Test WhatsApp Message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispatch a test message to verify outbound connectivity with Meta Cloud API servers:',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Destination Phone Number',
              controller: destinationCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Test Message',
              controller: msgCtrl,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted(widget.isDark))),
          ),
          AppButton(
            label: 'Send Test',
            icon: Icons.send_rounded,
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(whatsAppActionProvider).sendTestMessage(
                    destinationPhone: destinationCtrl.text.trim(),
                    testMessage: msgCtrl.text.trim(),
                  );
              if (ok) {
                ref.read(toastProvider.notifier).success('Test Message Sent', message: 'Delivered to ${destinationCtrl.text.trim()}');
              } else {
                ref.read(toastProvider.notifier).error('Send Failed', message: 'Could not deliver test message.');
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
        _populateAdvanced(config);

        final isConnected = config.isConnected;

        // If not connected or user explicitly opened the wizard, show the Onboarding Wizard
        if (!isConnected || _showWizard) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showWizard && isConnected) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextButton.icon(
                      onPressed: () => setState(() => _showWizard = false),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Back to Connection Dashboard'),
                    ),
                  ),
                ],
                WhatsAppOnboardingWizard(
                  isDark: widget.isDark,
                  onConnected: () {
                    setState(() => _showWizard = false);
                    ref.invalidate(whatsAppConfigProvider);
                    ref.invalidate(whatsAppConnectionHealthProvider);
                  },
                  onCancel: isConnected ? () => setState(() => _showWizard = false) : null,
                ),
              ],
            ),
          );
        }

        // Connected State: Full Connection Management Screen
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Connection Header & Status Card
              Container(
                padding: const EdgeInsets.all(DesignTokens.space24),
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(color: AppColors.border(widget.isDark)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                            ),
                            child: const Center(
                              child: Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 32),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        config.businessPortfolioName.isNotEmpty ? config.businessPortfolioName : 'Titan Athletic Club',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(widget.isDark),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const StatusBadge(status: 'Connected'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Phone: ${config.displayPhoneNumber}  •  Verified: ${config.verifiedName}',
                                  style: TextStyle(fontSize: 13, color: AppColors.textMuted(widget.isDark)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        AppButton(
                          label: 'Send Test Message',
                          icon: Icons.send_rounded,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => _showTestMessageDialog(config),
                        ),
                        const SizedBox(width: 10),
                        AppButton(
                          label: 'Reconnect Number',
                          icon: Icons.sync_rounded,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => setState(() => _showWizard = true),
                        ),
                        const SizedBox(width: 10),
                        AppButton(
                          label: _isDisconnecting ? 'Disconnecting...' : 'Disconnect',
                          icon: Icons.link_off_rounded,
                          variant: AppButtonVariant.danger,
                          isLoading: _isDisconnecting,
                          onPressed: () async {
                            final confirm = await SystemConfirmationDialog.show(
                              context: context,
                              title: 'Disconnect WhatsApp Business Account',
                              message: 'This will pause automated check-in notifications and campaigns until reconnected.',
                              confirmLabel: 'Disconnect WABA',
                              isDestructive: true,
                            );
                            if (confirm == true) {
                              setState(() => _isDisconnecting = true);
                              final ok = await ref.read(whatsAppActionProvider).disconnectConfig();
                              setState(() => _isDisconnecting = false);
                              if (ok) {
                                ref.read(toastProvider.notifier).success('Account Disconnected', message: 'WhatsApp integration disconnected.');
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

              // 2. Metrics & Health Diagnostics Row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Account Quality Rating',
                      config.qualityRating,
                      'Based on customer feedback and read velocity',
                      Icons.verified_rounded,
                      config.qualityRating.toLowerCase() == 'green' ? const Color(0xFF25D366) : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      'Daily Messaging Tier',
                      config.messagingLimitTier,
                      'Maximum daily business-initiated conversations',
                      Icons.speed_rounded,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      'Webhook Synchronization',
                      config.webhookStatus,
                      'Receiving inbound athlete messages & delivery receipts',
                      Icons.sensors_rounded,
                      const Color(0xFF25D366),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space20),

              // 3. Webhook Callback & Verification Card
              GlassCard(
                padding: const EdgeInsets.all(DesignTokens.space24),
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
                                'Automated Webhook Subscriptions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(widget.isDark),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Subscribed automatically to Meta Graph API event triggers (messages, message_template_status_update)',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.check_circle, size: 14, color: Color(0xFF25D366)),
                              SizedBox(width: 6),
                              Text('Active & Subscribed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF25D366))),
                            ],
                          ),
                        ),
                      ],
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
              const SizedBox(height: DesignTokens.space20),

              // 4. Advanced Settings Accordion (Optional / Developer configuration)
              Material(
                color: widget.isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(color: AppColors.border(widget.isDark)),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                    title: Text(
                      'Advanced Meta Cloud API Configuration',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark)),
                    ),
                    subtitle: Text(
                      'WABA ID, Phone Number ID, App ID, and System User Permanent Token settings',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark)),
                    ),
                    childrenPadding: const EdgeInsets.all(DesignTokens.space20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'WhatsApp Business Account ID (WABA ID)',
                              controller: _wabaCtrl,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Phone Number ID',
                              controller: _phoneIdCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Display Phone Number',
                              controller: _displayPhoneCtrl,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Business Portfolio Name',
                              controller: _portfolioCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'System User Permanent Access Token',
                        controller: _tokenCtrl,
                        isPassword: true,
                        hint: 'EAAG... (Stored securely on backend)',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Meta App ID',
                              controller: _appIdCtrl,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'App Secret (For HMAC Webhook Signature)',
                              controller: _appSecretCtrl,
                              isPassword: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      AppButton(
                        label: _isSavingAdvanced ? 'Saving...' : 'Update Advanced Configuration',
                        icon: Icons.save_rounded,
                        isLoading: _isSavingAdvanced,
                        onPressed: () async {
                          setState(() => _isSavingAdvanced = true);
                          final ok = await ref.read(whatsAppActionProvider).updateConfig(
                                wabaId: _wabaCtrl.text.trim(),
                                phoneNumberId: _phoneIdCtrl.text.trim(),
                                displayPhoneNumber: _displayPhoneCtrl.text.trim(),
                                businessPortfolioName: _portfolioCtrl.text.trim(),
                                accessToken: _tokenCtrl.text.trim(),
                                timeZoneId: _timeZoneCtrl.text.trim(),
                                appId: _appIdCtrl.text.trim().isNotEmpty ? _appIdCtrl.text.trim() : null,
                                appSecret: _appSecretCtrl.text.trim().isNotEmpty ? _appSecretCtrl.text.trim() : null,
                              );
                          setState(() => _isSavingAdvanced = false);
                          if (ok) {
                            ref.read(toastProvider.notifier).success('Configuration Saved', message: 'Meta credentials updated.');
                          } else {
                            ref.read(toastProvider.notifier).error('Update Failed', message: 'Could not save credentials.');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: AppColors.border(widget.isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted(widget.isDark))),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(widget.isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark))),
        ],
      ),
    );
  }
}
