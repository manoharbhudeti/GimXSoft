import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import 'memberships_provider.dart';

class AddPlanDialog extends ConsumerStatefulWidget {
  const AddPlanDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AddPlanDialog(),
    );
  }

  @override
  ConsumerState<AddPlanDialog> createState() => _AddPlanDialogState();
}

class _AddPlanDialogState extends ConsumerState<AddPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _daysCtrl = TextEditingController(text: '30');
  final _priceCtrl = TextEditingController(text: '79.00');
  final _regFeeCtrl = TextEditingController(text: '0.00');
  final _sessionsCtrl = TextEditingController(text: '0');
  final _benefitInputCtrl = TextEditingController();

  final List<String> _benefits = [
    'Unlimited Gym Floor Access',
    'Standard Locker Access',
  ];

  bool _isPT = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _daysCtrl.dispose();
    _priceCtrl.dispose();
    _regFeeCtrl.dispose();
    _sessionsCtrl.dispose();
    _benefitInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final ok = await ref.read(membershipActionProvider).createPlan(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          durationDays: int.tryParse(_daysCtrl.text) ?? 30,
          price: double.tryParse(_priceCtrl.text) ?? 0.0,
          registrationFee: double.tryParse(_regFeeCtrl.text) ?? 0.0,
          isPersonalTraining: _isPT,
          includedSessions: int.tryParse(_sessionsCtrl.text) ?? 0,
          benefitsJson: jsonEncode(_benefits),
        );

    if (mounted) {
      Navigator.of(context).pop();
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membership plan created!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _addBenefit() {
    final text = _benefitInputCtrl.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _benefits.add(text);
        _benefitInputCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                            child: const Icon(Icons.card_membership_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: DesignTokens.space12),
                          Text(
                            'Create Membership Plan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space16),

                  AppTextField(
                    label: 'Plan Name *',
                    hint: 'e.g. Semi-Annual Performance Pass',
                    controller: _nameCtrl,
                    validator: (v) => v?.isEmpty == true ? 'Name required' : null,
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  AppTextField(
                    label: 'Plan Description',
                    hint: 'Brief overview of who this plan is tailored for...',
                    controller: _descCtrl,
                    maxLines: 2,
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Duration (Days) *',
                          hint: '30, 90, 180, 365',
                          controller: _daysCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.calendar_month_outlined,
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      Expanded(
                        child: AppTextField(
                          label: 'Price (\$) *',
                          hint: '79.00',
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money_rounded,
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      Expanded(
                        child: AppTextField(
                          label: 'Registration Fee (\$) *',
                          hint: '0.00',
                          controller: _regFeeCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.receipt_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  // Personal Training Option
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Includes Dedicated Personal Training (PT)'),
                    subtitle: const Text('Bundle 1-on-1 coaching sessions with this pass', style: TextStyle(fontSize: 12)),
                    value: _isPT,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isPT = val),
                  ),

                  if (_isPT) ...[
                    const SizedBox(height: DesignTokens.space8),
                    AppTextField(
                      label: 'Included Coaching Sessions Count',
                      hint: 'e.g. 10',
                      controller: _sessionsCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.fitness_center_rounded,
                    ),
                  ],
                  const SizedBox(height: DesignTokens.space16),

                  // Benefits builder
                  Text(
                    'Included Amenities & Perks',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary(isDark)),
                  ),
                  const SizedBox(height: DesignTokens.space6),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          hint: 'e.g. Free Sauna & Steam Room Access',
                          controller: _benefitInputCtrl,
                          onSubmitted: (_) => _addBenefit(),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space8),
                      AppButton(
                        text: 'Add',
                        variant: ButtonVariant.secondary,
                        onPressed: _addBenefit,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _benefits.map((b) {
                      return Chip(
                        label: Text(b, style: const TextStyle(fontSize: 12)),
                        onDeleted: () => setState(() => _benefits.remove(b)),
                        deleteIconColor: AppColors.textMuted(isDark),
                        backgroundColor: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: DesignTokens.space24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        text: 'Cancel',
                        variant: ButtonVariant.ghost,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      AppButton(
                        text: 'Save Plan',
                        variant: ButtonVariant.primary,
                        isLoading: _isLoading,
                        onPressed: _submit,
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
  }
}

