import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/auth_provider.dart';
import 'members_provider.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AddMemberDialog(),
    );
  }

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _medicalCtrl = TextEditingController();

  String _gender = 'Male';
  String? _selectedPlanId;
  List<dynamic> _plans = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.dio.get(ApiConstants.membershipPlans);
      if (mounted) {
        setState(() {
          _plans = res.data as List;
          if (_plans.isNotEmpty) {
            _selectedPlanId = _plans.first['id']?.toString();
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _medicalCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authState = ref.read(authProvider);
    final branchId = authState.selectedBranch?.id ??
        (authState.branches.isNotEmpty ? authState.branches.first.id : '');

    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(
        ApiConstants.members,
        data: {
          'branchId': branchId,
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'gender': _gender,
          'address': _addressCtrl.text.trim(),
          'emergencyContactName': _emergencyNameCtrl.text.trim(),
          'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
          'initialPlanId': _selectedPlanId,
          'medicalNotes': _medicalCtrl.text.trim(),
        },
      );

      ref.invalidate(membersListProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member successfully registered!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to create member. Ensure email and phone are unique.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
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
                            child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: DesignTokens.space12),
                          Text(
                            'Register New Member',
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

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.12),
                        borderRadius: DesignTokens.borderMd,
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(fontSize: 13, color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                  ],

                  // First & Last Name
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'First Name *',
                          hint: 'e.g. Liam',
                          controller: _firstNameCtrl,
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      Expanded(
                        child: AppTextField(
                          label: 'Last Name *',
                          hint: 'e.g. Vance',
                          controller: _lastNameCtrl,
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  // Email & Phone
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Email Address *',
                          hint: 'liam@example.com',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (v) => v?.contains('@') != true ? 'Valid email required' : null,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
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
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  // Gender & Initial Membership Plan
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gender',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary(isDark),
                              ),
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
                                  value: _gender,
                                  isExpanded: true,
                                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                                  items: ['Male', 'Female', 'Other'].map((g) {
                                    return DropdownMenuItem(value: g, child: Text(g));
                                  }).toList(),
                                  onChanged: (val) => setState(() => _gender = val ?? 'Male'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enrollment Membership Plan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary(isDark),
                              ),
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
                                  value: _selectedPlanId,
                                  isExpanded: true,
                                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                                  hint: const Text('None (Pay As You Go)'),
                                  items: _plans.map((p) {
                                    return DropdownMenuItem<String>(
                                      value: p['id'].toString(),
                                      child: Text('${p['name']} (\$${p['price']})'),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedPlanId = val),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  // Emergency Contact
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Emergency Contact Name',
                          hint: 'e.g. Jane Vance',
                          controller: _emergencyNameCtrl,
                          prefixIcon: Icons.contact_emergency_outlined,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      Expanded(
                        child: AppTextField(
                          label: 'Emergency Contact Phone',
                          hint: '+1 (555) 999-9999',
                          controller: _emergencyPhoneCtrl,
                          prefixIcon: Icons.phone_callback_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  AppTextField(
                    label: 'Medical or Fitness Notes',
                    hint: 'Any prior injuries, cardiovascular conditions, allergies...',
                    controller: _medicalCtrl,
                    maxLines: 2,
                    prefixIcon: Icons.healing_outlined,
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
                        text: 'Create Member',
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
