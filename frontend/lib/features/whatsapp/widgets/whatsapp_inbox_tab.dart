import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/states/feedback/app_state_handler.dart';
import '../../../core/states/success/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../whatsapp_provider.dart';
import 'whatsapp_gym_workflows_dialogs.dart';

class WhatsAppInboxTab extends ConsumerStatefulWidget {
  final bool isDark;
  const WhatsAppInboxTab({super.key, required this.isDark});

  @override
  ConsumerState<WhatsAppInboxTab> createState() => _WhatsAppInboxTabState();
}

class _WhatsAppInboxTabState extends ConsumerState<WhatsAppInboxTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchFilter = '';
  String _activeFilter = 'all'; // 'all', 'unread'
  bool _isSending = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _msgCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage(String memberId) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final sent = await ref.read(whatsAppActionProvider).sendMessage(
          memberId: memberId,
          message: text,
        );

    setState(() => _isSending = false);

    if (sent != null) {
      _msgCtrl.clear();
      _scrollToBottom();
    } else {
      ref.read(toastProvider.notifier).error(
            'Message Delivery Failed',
            message: 'Could not send WhatsApp message. Please check network.',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(whatsAppConversationsProvider);
    final selectedMemberId = ref.watch(selectedMemberIdProvider);

    return conversationsAsync.buildStateWidget(
      context,
      onRetry: () => ref.refresh(whatsAppConversationsProvider),
      onData: (conversations) {
        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.textMuted(widget.isDark)),
                const SizedBox(height: 12),
                Text(
                  'No WhatsApp conversations yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark)),
                ),
                const SizedBox(height: 4),
                Text(
                  'When members check in or message your business, their threads will appear here.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                ),
              ],
            ),
          );
        }

        // Auto select first member if none selected
        final effectiveSelectedId = selectedMemberId ?? conversations.first.memberId;
        final selectedConv = conversations.firstWhere(
          (c) => c.memberId == effectiveSelectedId,
          orElse: () => conversations.first,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // PANEL 1: CONVERSATIONS LIST
            // ==========================================
            SizedBox(
              width: 320,
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Search & Filter header
                    Padding(
                      padding: const EdgeInsets.all(DesignTokens.space12),
                      child: Column(
                        children: [
                          AppTextField(
                            hint: 'Search members or phone...',
                            controller: _searchCtrl,
                            prefixIcon: Icons.search_rounded,
                            onChanged: (val) => setState(() => _searchFilter = val.toLowerCase()),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildFilterChip('All Athletes', 'all', conversations.length),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Unread',
                                'unread',
                                conversations.where((c) => c.unreadCount > 0).length,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Conversation list
                    Expanded(
                      child: ListView.separated(
                        itemCount: conversations.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border(widget.isDark).withOpacity(0.5)),
                        itemBuilder: (context, index) {
                          final conv = conversations[index];
                          if (_searchFilter.isNotEmpty &&
                              !conv.memberName.toLowerCase().contains(_searchFilter) &&
                              !conv.phone.contains(_searchFilter)) {
                            return const SizedBox.shrink();
                          }
                          if (_activeFilter == 'unread' && conv.unreadCount == 0) {
                            return const SizedBox.shrink();
                          }

                          final isSelected = conv.memberId == effectiveSelectedId;

                          return InkWell(
                            onTap: () {
                              ref.read(selectedMemberIdProvider.notifier).select(conv.memberId);
                              _scrollToBottom();
                            },
                            child: Container(
                              color: isSelected
                                  ? AppColors.raised(widget.isDark)
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primary.withOpacity(0.15),
                                    backgroundImage: conv.avatarUrl != null ? NetworkImage(conv.avatarUrl!) : null,
                                    child: conv.avatarUrl == null
                                        ? Text(
                                            conv.memberName.isNotEmpty ? conv.memberName[0] : 'M',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              conv.memberName,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: conv.unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                                                color: AppColors.textPrimary(widget.isDark),
                                              ),
                                            ),
                                            Text(
                                              DateFormat('HH:mm').format(conv.lastMessageTime),
                                              style: TextStyle(fontSize: 10, color: AppColors.textMuted(widget.isDark)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            if (conv.lastMessageDirection.toLowerCase() == 'outbound') ...[
                                              Icon(Icons.done_all_rounded, size: 14, color: AppColors.info),
                                              const SizedBox(width: 4),
                                            ],
                                            Expanded(
                                              child: Text(
                                                conv.lastMessage,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: conv.unreadCount > 0
                                                      ? AppColors.textPrimary(widget.isDark)
                                                      : AppColors.textMuted(widget.isDark),
                                                ),
                                              ),
                                            ),
                                            if (conv.unreadCount > 0)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  '${conv.unreadCount}',
                                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.space16),

            // ==========================================
            // PANEL 2: CENTER CHAT THREAD
            // ==========================================
            Expanded(
              flex: 6,
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Chat header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.raised(widget.isDark),
                        border: Border(bottom: BorderSide(color: AppColors.border(widget.isDark))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary.withOpacity(0.15),
                                child: Text(
                                  selectedConv.memberName.isNotEmpty ? selectedConv.memberName[0] : 'M',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedConv.memberName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary(widget.isDark),
                                    ),
                                  ),
                                  Text(
                                    '${selectedConv.phone}  •  ${selectedConv.planName}',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // 24-hour service window pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                              border: Border.all(color: AppColors.success.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 13, color: AppColors.success),
                                const SizedBox(width: 5),
                                Text(
                                  '24h Service Window Active',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Messages Stream
                    Expanded(
                      child: ref.watch(whatsAppMessagesProvider(effectiveSelectedId)).buildStateWidget(
                            context,
                            onRetry: () => ref.refresh(whatsAppMessagesProvider(effectiveSelectedId)),
                            onData: (messages) {
                              if (messages.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No messages exchanged yet with ${selectedConv.memberName}.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                                  ),
                                );
                              }

                              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                              return ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(DesignTokens.space16),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final msg = messages[index];
                                  final isOutbound = msg.isOutbound;

                                  return Align(
                                    alignment: isOutbound ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      constraints: const BoxConstraints(maxWidth: 440),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isOutbound
                                            ? const Color(0xFF005C4B) // WhatsApp dark green
                                            : AppColors.raised(widget.isDark),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(14),
                                          topRight: const Radius.circular(14),
                                          bottomLeft: Radius.circular(isOutbound ? 14 : 2),
                                          bottomRight: Radius.circular(isOutbound ? 2 : 14),
                                        ),
                                        border: Border.all(
                                          color: isOutbound ? Colors.transparent : AppColors.border(widget.isDark),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (msg.templateName != null) ...[
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.bolt_rounded, size: 12, color: AppColors.primary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Template: ${msg.templateName}',
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                          Text(
                                            msg.messageContent,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isOutbound ? Colors.white : AppColors.textPrimary(widget.isDark),
                                              height: 1.35,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                DateFormat('HH:mm').format(msg.sentAt),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isOutbound ? Colors.white70 : AppColors.textMuted(widget.isDark),
                                                ),
                                              ),
                                              if (isOutbound) ...[
                                                const SizedBox(width: 4),
                                                _buildDeliveryStatusIcon(msg.status),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                    ),

                    // Quick Template Previews & Presets
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
                        border: Border(top: BorderSide(color: AppColors.border(widget.isDark))),
                      ),
                      child: Row(
                        children: [
                          Text('Quick Presets:', style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark))),
                          const SizedBox(width: 8),
                          _buildPresetPill(
                            label: 'Daily Check-in',
                            text: 'Hi ${selectedConv.memberName}, awesome workout today! Don\'t forget to log your recovery hydration.',
                          ),
                          const SizedBox(width: 6),
                          _buildPresetPill(
                            label: 'Locker Notice',
                            text: 'Hi ${selectedConv.memberName}, kindly remember to clear locker #42 before 10 PM closing.',
                          ),
                        ],
                      ),
                    ),

                    // Message Composer
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.space12),
                      decoration: BoxDecoration(
                        color: AppColors.raised(widget.isDark),
                        border: Border(top: BorderSide(color: AppColors.border(widget.isDark))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgCtrl,
                              minLines: 1,
                              maxLines: 4,
                              style: TextStyle(fontSize: 13, color: AppColors.textPrimary(widget.isDark)),
                              decoration: InputDecoration(
                                hintText: 'Type WhatsApp message to ${selectedConv.memberName}...',
                                hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted(widget.isDark)),
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _handleSendMessage(effectiveSelectedId),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Share Workout Split',
                            icon: const Icon(Icons.fitness_center_rounded, size: 20),
                            color: AppColors.primary,
                            onPressed: () => WhatsAppGymWorkflowsDialogs.showShareWorkoutDialog(
                              context: context,
                              ref: ref,
                              memberId: effectiveSelectedId,
                              memberName: selectedConv.memberName,
                              isDark: widget.isDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AppButton(
                            label: 'Send',
                            icon: Icons.send_rounded,
                            isLoading: _isSending,
                            onPressed: () => _handleSendMessage(effectiveSelectedId),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.space16),

            // ==========================================
            // PANEL 3: GYM MEMBER DETAILS (CRM INTEGRATION)
            // ==========================================
            SizedBox(
              width: 290,
              child: GlassCard(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member profile header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.primary.withOpacity(0.15),
                              backgroundImage: selectedConv.avatarUrl != null ? NetworkImage(selectedConv.avatarUrl!) : null,
                              child: selectedConv.avatarUrl == null
                                  ? Text(
                                      selectedConv.memberName.isNotEmpty ? selectedConv.memberName[0] : 'M',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 22),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedConv.memberName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(widget.isDark),
                              ),
                            ),
                            Text(
                              selectedConv.phone,
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted(widget.isDark)),
                            ),
                            const SizedBox(height: 6),
                            const StatusBadge(status: 'Active'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Membership details
                      Text(
                        'Gym Membership Plan',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted(widget.isDark)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.raised(widget.isDark),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          border: Border.all(color: AppColors.border(widget.isDark)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedConv.planName,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text('Renews on 28th of month (₹2,000/mo)', style: TextStyle(fontSize: 11, color: AppColors.textMuted(widget.isDark))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Biometrics quick snapshot
                      Text(
                        'Body Composition & Baselines',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted(widget.isDark)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildBiometricTile('Weight', '76.4 kg'),
                          const SizedBox(width: 8),
                          _buildBiometricTile('BMI', '24.1 (Good)'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Fast CRM WhatsApp Actions
                      Text(
                        'Quick WhatsApp Actions',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted(widget.isDark)),
                      ),
                      const SizedBox(height: 10),
                      _buildActionBtn(
                        label: 'Share Workout Split',
                        icon: Icons.fitness_center_rounded,
                        color: AppColors.primary,
                        onTap: () => WhatsAppGymWorkflowsDialogs.showShareWorkoutDialog(
                          context: context,
                          ref: ref,
                          memberId: effectiveSelectedId,
                          memberName: selectedConv.memberName,
                          isDark: widget.isDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildActionBtn(
                        label: 'Send BMI Progress',
                        icon: Icons.monitor_weight_rounded,
                        color: AppColors.success,
                        onTap: () => WhatsAppGymWorkflowsDialogs.showSendBmiReportDialog(
                          context: context,
                          ref: ref,
                          memberId: effectiveSelectedId,
                          memberName: selectedConv.memberName,
                          isDark: widget.isDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildActionBtn(
                        label: 'Send Expiry Notice',
                        icon: Icons.alarm_on_rounded,
                        color: AppColors.warning,
                        onTap: () => WhatsAppGymWorkflowsDialogs.showSendExpiryReminderDialog(
                          context: context,
                          ref: ref,
                          memberId: effectiveSelectedId,
                          memberName: selectedConv.memberName,
                          isDark: widget.isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _activeFilter == value;
    return InkWell(
      onTap: () => setState(() => _activeFilter = value),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border(widget.isDark),
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary(widget.isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetPill({required String label, required String text}) {
    return InkWell(
      onTap: () => setState(() => _msgCtrl.text = text),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.raised(widget.isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(widget.isDark)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary(widget.isDark)),
        ),
      ),
    );
  }

  Widget _buildBiometricTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.raised(widget.isDark),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          border: Border.all(color: AppColors.border(widget.isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted(widget.isDark))),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary(widget.isDark))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'read':
        return const Icon(Icons.done_all_rounded, size: 14, color: AppColors.info);
      case 'delivered':
        return const Icon(Icons.done_all_rounded, size: 14, color: Colors.white70);
      case 'sent':
        return const Icon(Icons.done_rounded, size: 14, color: Colors.white70);
      case 'failed':
        return const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error);
      default:
        return const Icon(Icons.access_time_rounded, size: 12, color: Colors.white54);
    }
  }
}
