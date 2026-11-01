import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import 'leads_provider.dart';

class AddLeadDialog extends ConsumerStatefulWidget {
  const AddLeadDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AddLeadDialog(),
    );
  }

  @override
  ConsumerState<AddLeadDialog> createState() => _AddLeadDialogState();
}

class _AddLeadDialogState extends ConsumerState<AddLeadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _valueCtrl = TextEditingController(text: '199.00');
  final _notesCtrl = TextEditingController();

  String _source = 'WalkIn';
  DateTime? _followUpDate = DateTime.now().add(const Duration(days: 2));
  bool _isLoading = false;

  final List<String> _sources = [
    'WalkIn',
    'Website',
    'Phone',
    'Referral',
    'SocialMedia',
    'Advertisement',
    'Other'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _valueCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final ok = await ref.read(leadsActionProvider).createLead(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          source: _source,
          notes: _notesCtrl.text.trim(),
          followUpDate: _followUpDate,
          estimatedValue: double.tryParse(_valueCtrl.text) ?? 0.0,
        );

    if (mounted) {
      Navigator.of(context).pop();
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lead added to pipeline!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
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
                              color: AppColors.accentOrange.withOpacity(0.12),
                              borderRadius: DesignTokens.borderMd,
                            ),
                            child: const Icon(Icons.person_search_rounded, color: AppColors.accentOrange, size: 20),
                          ),
                          const SizedBox(width: DesignTokens.space12),
                          Text(
                            'Add Prospect / Lead',
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
                    label: 'Prospect Full Name *',
                    hint: 'e.g. Rachel Adams',
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outline,
                    validator: (v) => v?.isEmpty == true ? 'Name required' : null,
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Phone Number *',
                          hint: '+1 (555) 000-0000',
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: (v) => v?.isEmpty == true ? 'Phone required' : null,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      Expanded(
                        child: AppTextField(
                          label: 'Email (Optional)',
                          hint: 'rachel@example.com',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lead Acquisition Source',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary(isDark)),
                            ),
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
                                  value: _source,
                                  isExpanded: true,
                                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                                  items: _sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (val) => setState(() => _source = val ?? 'WalkIn'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      Expanded(
                        child: AppTextField(
                          label: 'Estimated Value (\$)',
                          hint: '199.00',
                          controller: _valueCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  // Next Follow Up Date Picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled Follow-Up Date',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary(isDark)),
                      ),
                      const SizedBox(height: DesignTokens.space6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 2)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) {
                            setState(() => _followUpDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: DesignTokens.borderMd,
                            border: Border.all(color: AppColors.border(isDark)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _followUpDate != null ? DateFormat('EEE, MMM d, yyyy').format(_followUpDate!) : 'Select Date',
                                style: TextStyle(fontSize: 14, color: AppColors.textPrimary(isDark)),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  AppTextField(
                    label: 'Discovery Notes / Interests',
                    hint: 'Goals (weight loss, muscle gain), preferred workout times, previous memberships...',
                    controller: _notesCtrl,
                    maxLines: 3,
                    prefixIcon: Icons.notes_outlined,
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
                        text: 'Add to Pipeline',
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

