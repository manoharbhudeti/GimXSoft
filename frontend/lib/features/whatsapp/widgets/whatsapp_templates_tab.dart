import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/states/feedback/app_state_handler.dart';
import '../../../core/states/success/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../whatsapp_provider.dart';

class WhatsAppTemplatesTab extends ConsumerStatefulWidget {
  final bool isDark;
  const WhatsAppTemplatesTab({super.key, required this.isDark});

  @override
  ConsumerState<WhatsAppTemplatesTab> createState() => _WhatsAppTemplatesTabState();
}

class _WhatsAppTemplatesTabState extends ConsumerState<WhatsAppTemplatesTab> {
  String _selectedCategory = 'ALL';
  bool _isSyncing = false;

  void _openCreateTemplateDialog() {
    final nameCtrl = TextEditingController();
    final headerCtrl = TextEditingController(text: 'Titan Fitness Notice');
    final bodyCtrl = TextEditingController(
      text: 'Hi {{1}}, Coach {{2}} has assigned your new weekly training split. Review your routine on the member portal or reply to this message.',
    );
    final footerCtrl = TextEditingController(text: 'GimXSoft Athletic Facilities');
    String category = 'UTILITY';
    String language = 'en_US';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: widget.isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            side: BorderSide(color: AppColors.border(widget.isDark)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fact_check_rounded, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Create & Submit Meta Template',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(widget.isDark),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 700,
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Form Inputs
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'Template Name (lowercase, no spaces)',
                          controller: nameCtrl,
                          hint: 'e.g. member_renewal_notice',
                          onChanged: (_) => setDialogState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Category', style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark))),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.raised(widget.isDark),
                                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                      border: Border.all(color: AppColors.border(widget.isDark)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: category,
                                        isExpanded: true,
                                        dropdownColor: widget.isDark ? AppColors.darkCard : Colors.white,
                                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary(widget.isDark)),
                                        items: const [
                                          DropdownMenuItem(value: 'UTILITY', child: Text('UTILITY (Transactional)')),
                                          DropdownMenuItem(value: 'MARKETING', child: Text('MARKETING (Promotional)')),
                                          DropdownMenuItem(value: 'AUTHENTICATION', child: Text('AUTHENTICATION (OTP)')),
                                        ],
                                        onChanged: (val) => setDialogState(() => category = val ?? 'UTILITY'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Language', style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark))),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.raised(widget.isDark),
                                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                      border: Border.all(color: AppColors.border(widget.isDark)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: language,
                                        isExpanded: true,
                                        dropdownColor: widget.isDark ? AppColors.darkCard : Colors.white,
                                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary(widget.isDark)),
                                        items: const [
                                          DropdownMenuItem(value: 'en_US', child: Text('English (US)')),
                                          DropdownMenuItem(value: 'en_GB', child: Text('English (UK)')),
                                          DropdownMenuItem(value: 'hi_IN', child: Text('Hindi (India)')),
                                          DropdownMenuItem(value: 'es_ES', child: Text('Spanish')),
                                        ],
                                        onChanged: (val) => setDialogState(() => language = val ?? 'en_US'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Header Text (Optional)',
                          controller: headerCtrl,
                          hint: 'e.g. Important Notice',
                          onChanged: (_) => setDialogState(() {}),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Body Text (Use {{1}}, {{2}} for dynamic values)',
                          controller: bodyCtrl,
                          maxLines: 4,
                          hint: 'Type message body...',
                          onChanged: (_) => setDialogState(() {}),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Footer Text (Optional)',
                          controller: footerCtrl,
                          hint: 'e.g. Titan Gym Ops',
                          onChanged: (_) => setDialogState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right: Live Phone Preview
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.raised(widget.isDark),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        border: Border.all(color: AppColors.border(widget.isDark)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.visibility_outlined, size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Live WhatsApp Client Preview',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary(widget.isDark)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Phone bubble
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF005C4B), // WhatsApp dark green
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (headerCtrl.text.isNotEmpty) ...[
                                  Text(
                                    headerCtrl.text,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Text(
                                  bodyCtrl.text
                                      .replaceAll('{{1}}', 'Alex')
                                      .replaceAll('{{2}}', 'Coach Vikram')
                                      .replaceAll('{{3}}', '7'),
                                  style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.35),
                                ),
                                if (footerCtrl.text.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    footerCtrl.text,
                                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('10:45 AM', style: TextStyle(fontSize: 9, color: Colors.white60)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Variable mapping in preview: {{1}} → Member Name, {{2}} → Coach / Details.',
                            style: TextStyle(fontSize: 10, color: AppColors.textMuted(widget.isDark)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.textMuted(widget.isDark))),
            ),
            AppButton(
              label: 'Submit for Meta Approval',
              icon: Icons.check_circle_outline_rounded,
              isLoading: isSubmitting,
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) {
                  ref.read(toastProvider.notifier).error('Validation Error', message: 'Name and Body text are required.');
                  return;
                }

                setDialogState(() => isSubmitting = true);

                final ok = await ref.read(whatsAppActionProvider).createTemplate(
                      name: nameCtrl.text.trim().toLowerCase().replaceAll(' ', '_'),
                      category: category,
                      language: language,
                      headerText: headerCtrl.text.trim().isEmpty ? null : headerCtrl.text.trim(),
                      bodyText: bodyCtrl.text.trim(),
                      footerText: footerCtrl.text.trim().isEmpty ? null : footerCtrl.text.trim(),
                    );

                setDialogState(() => isSubmitting = false);

                if (context.mounted) {
                  Navigator.pop(ctx);
                  if (ok) {
                    ref.read(toastProvider.notifier).success(
                          'Template Submitted',
                          message: 'Template submitted to Meta Graph API for automated validation.',
                        );
                  } else {
                    ref.read(toastProvider.notifier).error(
                          'Submission Failed',
                          message: 'Could not create template on Meta.',
                        );
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
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(whatsAppTemplatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meta Approved WhatsApp Message Templates',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(widget.isDark),
                  ),
                ),
                Text(
                  'Pre-approved utility & marketing templates for outbound member notifications outside 24h window',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                ),
              ],
            ),
            Row(
              children: [
                AppButton(
                  label: _isSyncing ? 'Syncing...' : 'Sync with Meta',
                  icon: Icons.sync_rounded,
                  variant: AppButtonVariant.secondary,
                  isLoading: _isSyncing,
                  onPressed: () async {
                    setState(() => _isSyncing = true);
                    final ok = await ref.read(whatsAppActionProvider).syncTemplates();
                    setState(() => _isSyncing = false);
                    if (ok) {
                      ref.read(toastProvider.notifier).success(
                            'Templates Synchronized',
                            message: 'Synced approved templates with Meta Business Platform.',
                          );
                    }
                  },
                ),
                const SizedBox(width: 10),
                AppButton(
                  label: 'Create Template',
                  icon: Icons.add_rounded,
                  onPressed: _openCreateTemplateDialog,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space16),

        // Category Filter Tabs
        Row(
          children: ['ALL', 'UTILITY', 'MARKETING', 'AUTHENTICATION'].map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = cat),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : (widget.isDark ? AppColors.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border(widget.isDark),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary(widget.isDark),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: DesignTokens.space16),

        // Template Grid
        Expanded(
          child: templatesAsync.buildStateWidget(
            context,
            onRetry: () => ref.refresh(whatsAppTemplatesProvider),
            onData: (templates) {
              final filtered = _selectedCategory == 'ALL'
                  ? templates
                  : templates.where((t) => t.category.toUpperCase() == _selectedCategory).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fact_check_outlined, size: 48, color: AppColors.textMuted(widget.isDark)),
                      const SizedBox(height: 12),
                      Text(
                        'No Templates Found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create templates for workout assignments, payments, or gym welcome flows.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.5,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final t = filtered[index];

                  return GlassCard(
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    t.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary(widget.isDark),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                StatusBadge(
                                  status: t.metaStatus == 'APPROVED' ? 'Active' : 'Pending',
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Category: ${t.category}  •  Lang: ${t.language}',
                              style: TextStyle(fontSize: 10, color: AppColors.textMuted(widget.isDark)),
                            ),
                            const SizedBox(height: 8),
                            if (t.header != null) ...[
                              Text(
                                t.header!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary(widget.isDark),
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              t.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary(widget.isDark)),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.footer ?? 'GimXSoft Automated',
                              style: TextStyle(fontSize: 10, color: AppColors.textMuted(widget.isDark)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 16),
                              color: AppColors.error,
                              splashRadius: 16,
                              tooltip: 'Delete Template',
                              onPressed: () async {
                                final ok = await ref.read(whatsAppActionProvider).deleteTemplate(t.id);
                                if (ok) {
                                  ref.read(toastProvider.notifier).success('Template Deleted', message: 'Removed ${t.name}.');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
