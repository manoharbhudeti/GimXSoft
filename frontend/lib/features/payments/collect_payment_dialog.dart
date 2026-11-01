import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/states/success/app_toast.dart';
import '../members/member_models.dart';
import 'payments_provider.dart';

class CollectPaymentDialog extends ConsumerStatefulWidget {
  const CollectPaymentDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const CollectPaymentDialog(),
    );
  }

  @override
  ConsumerState<CollectPaymentDialog> createState() => _CollectPaymentDialogState();
}

class _CollectPaymentDialogState extends ConsumerState<CollectPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController(text: '79.00');
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController(text: 'Monthly membership dues payment');

  String? _selectedMemberId;
  int _selectedMethod = 2; // 0: Cash, 1: UPI, 2: Card, 3: BankTransfer
  List<MemberModel> _members = [];
  bool _isLoadingMembers = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.dio.get(ApiConstants.members);
      final list = (res.data as List).map((m) => MemberModel.fromJson(m)).toList();
      if (mounted) {
        setState(() {
          _members = list;
          _isLoadingMembers = false;
          if (_members.isNotEmpty) {
            _selectedMemberId = _members.first.id;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMembers = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedMemberId == null) return;

    setState(() => _isSubmitting = true);

    final ok = await ref.read(paymentsActionProvider).collectPayment(
          memberId: _selectedMemberId!,
          amount: double.tryParse(_amountCtrl.text) ?? 0.0,
          paymentMethod: _selectedMethod,
          reference: _refCtrl.text.isNotEmpty ? _refCtrl.text.trim() : null,
          notes: _notesCtrl.text.trim(),
        );

    if (mounted) {
      Navigator.of(context).pop();
      if (ok) {
        ref.read(toastProvider.notifier).success(
          'Payment Collected',
          message: 'Transaction recorded and invoice generated.',
        );
      } else {
        ref.read(toastProvider.notifier).error(
          'Collection Failed',
          message: 'Could not record payment. Please check inputs and retry.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final methodLabels = ['Cash', 'UPI', 'Credit/Debit Card', 'Bank Wire'];

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
                              color: AppColors.secondary.withOpacity(0.12),
                              borderRadius: DesignTokens.borderMd,
                            ),
                            child: const Icon(Icons.point_of_sale_rounded, color: AppColors.secondary, size: 20),
                          ),
                          const SizedBox(width: DesignTokens.space12),
                          Text(
                            'Collect Payment / Issue Receipt',
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

                  // Member Dropdown
                  Text(
                    'Select Member *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary(isDark)),
                  ),
                  const SizedBox(height: DesignTokens.space6),
                  if (_isLoadingMembers)
                    const LinearProgressIndicator()
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: DesignTokens.borderMd,
                        border: Border.all(color: AppColors.border(isDark)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMemberId,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                          items: _members.map((m) {
                            return DropdownMenuItem<String>(
                              value: m.id,
                              child: Text('${m.fullName} (${m.memberCode})'),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedMemberId = val),
                        ),
                      ),
                    ),
                  const SizedBox(height: DesignTokens.space16),

                  // Amount & Method
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Amount Collected (\$) *',
                          hint: '79.00',
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money_rounded,
                          validator: (v) => v?.isEmpty == true ? 'Amount required' : null,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Channel',
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
                                child: DropdownButton<int>(
                                  value: _selectedMethod,
                                  isExpanded: true,
                                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                                  items: List.generate(
                                    methodLabels.length,
                                    (idx) => DropdownMenuItem(value: idx, child: Text(methodLabels[idx])),
                                  ),
                                  onChanged: (val) => setState(() => _selectedMethod = val ?? 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  AppTextField(
                    label: 'Transaction Reference ID (Optional)',
                    hint: 'e.g. UPI-TXN-9981 or Card Auth #4412',
                    controller: _refCtrl,
                    prefixIcon: Icons.tag_rounded,
                  ),
                  const SizedBox(height: DesignTokens.space12),

                  AppTextField(
                    label: 'Notes / Invoice Memo',
                    hint: 'Details regarding payment terms, registration or product addon...',
                    controller: _notesCtrl,
                    maxLines: 2,
                    prefixIcon: Icons.description_outlined,
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
                        text: 'Record Payment',
                        variant: ButtonVariant.primary,
                        isLoading: _isSubmitting,
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

