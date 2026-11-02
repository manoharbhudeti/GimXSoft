import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/states/feedback/app_state_handler.dart';
import '../../core/states/loading/inline_loader.dart';
import '../../core/states/success/app_toast.dart';
import '../../core/states/success/confirmation_dialog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/status_badge.dart';
import 'whatsapp_models.dart';
import 'whatsapp_provider.dart';

class WhatsAppMessagingView extends ConsumerStatefulWidget {
  const WhatsAppMessagingView({super.key});

  @override
  ConsumerState<WhatsAppMessagingView> createState() => _WhatsAppMessagingViewState();
}

class _WhatsAppMessagingViewState extends ConsumerState<WhatsAppMessagingView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchFilter = '';
  bool _isSending = false;

  // Broadcast state
  String _selectedBroadcastAudience = 'all_active';
  final TextEditingController _broadcastMsgCtrl = TextEditingController(
    text: 'Hi {{name}}, friendly reminder that Titan Fitness has new HIIT coaching slots available this week! Book at reception or reply to this message.',
  );
  bool _isBroadcasting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _msgCtrl.dispose();
    _scrollController.dispose();
    _broadcastMsgCtrl.dispose();
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
      ref.read(toastProvider.notifier).success(
            'WhatsApp Message Dispatched',
            message: 'Delivered to ${sent.recipientName}',
          );
      _scrollToBottom();
    } else {
      ref.read(toastProvider.notifier).error(
            'Message Delivery Failed',
            message: 'Could not send WhatsApp message. Please check network.',
          );
    }
  }

  Future<void> _handleBroadcast() async {
    final text = _broadcastMsgCtrl.text.trim();
    if (text.isEmpty) return;

    final confirmed = await SystemConfirmationDialog.show(
      context: context,
      title: 'Confirm WhatsApp Broadcast Blast',
      message:
          'This will dispatch outbound WhatsApp messages to members in the selected audience category. Are you sure you want to proceed?',
      confirmLabel: 'Send Broadcast Blast',
      isDestructive: false,
    );

    if (confirmed != true) return;

    setState(() => _isBroadcasting = true);

    final ok = await ref.read(whatsAppActionProvider).broadcastCampaign(
          audienceFilter: _selectedBroadcastAudience,
          message: text,
        );

    setState(() => _isBroadcasting = false);

    if (ok) {
      ref.read(toastProvider.notifier).success(
            'Broadcast Blast Complete',
            message: 'WhatsApp campaign messages queued for delivery.',
          );
    } else {
      ref.read(toastProvider.notifier).error(
            'Broadcast Failed',
            message: 'Unable to complete broadcast campaign.',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final metricsAsync = ref.watch(whatsAppMetricsProvider);
    final selectedMemberId = ref.watch(selectedMemberIdProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header & Live Metrics Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'WhatsApp Customer Messaging Hub',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF25D366).withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.check_circle_rounded, color: Color(0xFF25D366), size: 13),
                              SizedBox(width: 4),
                              Text(
                                'Meta Cloud API Live',
                                style: TextStyle(
                                  color: Color(0xFF25D366),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Official WhatsApp Business API integration for member receipts, renewal reminders, and member chat',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                AppButton(
                  text: 'Refresh Sync',
                  icon: Icons.refresh_rounded,
                  variant: ButtonVariant.ghost,
                  onPressed: () {
                    ref.invalidate(whatsAppMetricsProvider);
                    ref.invalidate(whatsAppConversationsProvider);
                    if (selectedMemberId != null) {
                      ref.invalidate(whatsAppMessagesProvider(selectedMemberId));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),

            // Metrics Summary Cards
            metricsAsync.when(
              loading: () => const SizedBox(height: 72, child: Center(child: InlineLoader())),
              error: (err, _) => const SizedBox.shrink(),
              data: (metrics) => LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - (DesignTokens.space16 * 3)) / 4;
                  return Row(
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: MetricStatCard(
                          title: 'Messages Sent Today',
                          value: '${metrics.totalSentToday}',
                          subtitle: '${metrics.totalDeliveredToday} delivered successfully',
                          icon: Icons.mark_chat_read_rounded,
                          iconColor: const Color(0xFF25D366),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space16),
                      SizedBox(
                        width: cardWidth,
                        child: MetricStatCard(
                          title: 'Delivery Rate',
                          value: '${metrics.deliveryRate}%',
                          subtitle: 'Meta Cloud API SLA',
                          icon: Icons.done_all_rounded,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space16),
                      SizedBox(
                        width: cardWidth,
                        child: MetricStatCard(
                          title: 'Read / Open Rate',
                          value: '${metrics.readRate}%',
                          subtitle: '${metrics.totalReadToday} member confirmations',
                          icon: Icons.visibility_rounded,
                          iconColor: AppColors.accentCyan,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space16),
                      SizedBox(
                        width: cardWidth,
                        child: MetricStatCard(
                          title: 'Active Threads',
                          value: '${metrics.activeConversationsCount}',
                          subtitle: 'Conversations with gym members',
                          icon: Icons.forum_rounded,
                          iconColor: AppColors.warning,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: DesignTokens.space16),

            // Tab Navigation Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary(isDark),
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                tabs: const [
                  Tab(icon: Icon(Icons.chat_bubble_outline_rounded, size: 18), text: 'Member Direct Chat'),
                  Tab(icon: Icon(Icons.campaign_outlined, size: 18), text: 'Broadcast Campaigns'),
                  Tab(icon: Icon(Icons.auto_mode_rounded, size: 18), text: 'Automated Triggers & Templates'),
                  Tab(icon: Icon(Icons.hub_outlined, size: 18), text: 'Account Connection & Webhook'),
                  Tab(icon: Icon(Icons.schedule_send_rounded, size: 18), text: 'Scheduled Messages'),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space16),

            // 2. Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLiveChatTab(isDark, selectedMemberId),
                  _buildBroadcastTab(isDark),
                  _buildAutomatedTriggersTab(isDark),
                  _buildAccountConnectionTab(isDark),
                  _buildScheduledMessagesTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: LIVE CHAT & CONVERSATIONS
  // ==========================================
  Widget _buildLiveChatTab(bool isDark, String? selectedMemberId) {
    final conversationsAsync = ref.watch(whatsAppConversationsProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Member Conversations List
        SizedBox(
          width: 340,
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.space12),
                  child: AppTextField(
                    hint: 'Filter conversations...',
                    prefixIcon: Icons.search_rounded,
                    onChanged: (val) => setState(() => _searchFilter = val.toLowerCase()),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: conversationsAsync.buildStateWidget(
                    context,
                    onRetry: () => ref.invalidate(whatsAppConversationsProvider),
                    onData: (conversations) {
                      final filtered = conversations.where((c) {
                        if (_searchFilter.isEmpty) return true;
                        return c.memberName.toLowerCase().contains(_searchFilter) ||
                            c.phone.contains(_searchFilter);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text(
                            'No conversations found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      // Auto-select first member if none selected
                      if (selectedMemberId == null && filtered.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(selectedMemberIdProvider.notifier).select(filtered.first.memberId);
                        });
                      }

                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                        ),
                        itemBuilder: (context, index) {
                          final conv = filtered[index];
                          final isSelected = conv.memberId == selectedMemberId;

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: isDark
                                ? AppColors.primary.withOpacity(0.12)
                                : AppColors.primary.withOpacity(0.06),
                            onTap: () {
                              ref.read(selectedMemberIdProvider.notifier).select(conv.memberId);
                              _scrollToBottom();
                            },
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withOpacity(0.15),
                              backgroundImage: conv.avatarUrl != null ? NetworkImage(conv.avatarUrl!) : null,
                              child: conv.avatarUrl == null
                                  ? Text(
                                      conv.memberName.substring(0, 1),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    conv.memberName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(conv.lastMessageTime),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted(isDark),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                if (conv.lastMessageDirection == 'Outbound')
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.done_all_rounded,
                                      size: 14,
                                      color: conv.lastMessageStatus == 'Read'
                                          ? const Color(0xFF34B7F1) // WhatsApp blue ticks
                                          : AppColors.textMuted(isDark),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    conv.lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary(isDark),
                                    ),
                                  ),
                                ),
                                if (conv.unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF25D366),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${conv.unreadCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
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
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.space16),

        // Right Column: Active WhatsApp Chat Window
        Expanded(
          child: selectedMemberId == null
              ? const Center(child: Text('Select a member to view conversation'))
              : _buildChatWindow(isDark, selectedMemberId),
        ),
      ],
    );
  }

  Widget _buildChatWindow(bool isDark, String memberId) {
    final messagesAsync = ref.watch(whatsAppMessagesProvider(memberId));
    final conversationsAsync = ref.watch(whatsAppConversationsProvider);

    final currentConv = conversationsAsync.value?.firstWhere(
      (c) => c.memberId == memberId,
      orElse: () => WhatsAppConversationSummaryModel(
        memberId: memberId,
        memberName: 'Member',
        phone: '',
        planName: 'Active Plan',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        lastMessageStatus: 'Delivered',
        lastMessageDirection: 'Outbound',
        unreadCount: 0,
      ),
    );

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Chat Top Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space20, vertical: DesignTokens.space12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: currentConv?.avatarUrl != null ? NetworkImage(currentConv!.avatarUrl!) : null,
                  child: currentConv?.avatarUrl == null
                      ? Text(
                          currentConv?.memberName.substring(0, 1) ?? 'M',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentConv?.memberName ?? 'Member',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            currentConv?.phone ?? '',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: currentConv?.planName ?? 'Active', isPill: true),
                        ],
                      ),
                    ],
                  ),
                ),
                // Template dropdown picker
                Consumer(
                  builder: (context, ref, _) {
                    final tmpls = ref.watch(whatsAppTemplatesProvider);
                    return PopupMenuButton<WhatsAppTemplateModel>(
                      tooltip: 'Insert Approved Template',
                      icon: const Icon(Icons.text_snippet_rounded, color: AppColors.primary),
                      itemBuilder: (context) {
                        return (tmpls.value ?? []).map((t) {
                          return PopupMenuItem(
                            value: t,
                            child: Text(t.name.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 12)),
                          );
                        }).toList();
                      },
                      onSelected: (template) {
                        final memberFirstName = currentConv?.memberName.split(' ').first ?? 'Member';
                        final filledText = template.body
                            .replaceAll('{{1}}', memberFirstName)
                            .replaceAll('{{2}}', currentConv?.planName ?? 'Membership')
                            .replaceAll('{{3}}', '5 days')
                            .replaceAll('{{4}}', 'Nov 6');
                        _msgCtrl.text = filledText;
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Chat Messages Stream
          Expanded(
            child: messagesAsync.buildStateWidget(
              context,
              onRetry: () => ref.invalidate(whatsAppMessagesProvider(memberId)),
              onData: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages exchanged yet. Send the first message below.'),
                  );
                }

                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageBubble(msg, isDark);
                  },
                );
              },
            ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16, vertical: DesignTokens.space12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    maxLines: 2,
                    minLines: 1,
                    onSubmitted: (_) => _handleSendMessage(memberId),
                    decoration: InputDecoration(
                      hintText: 'Type WhatsApp message or pick template...',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted(isDark)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.space12),
                AppButton(
                  text: 'Send',
                  icon: Icons.send_rounded,
                  isLoading: _isSending,
                  variant: ButtonVariant.primary,
                  onPressed: () => _handleSendMessage(memberId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(WhatsAppMessageModel msg, bool isDark) {
    final isOutbound = msg.isOutbound;

    return Align(
      alignment: isOutbound ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isOutbound
                ? (isDark ? const Color(0xFF075E54) : const Color(0xFFE7FFDB)) // WhatsApp green bubble
                : (isDark ? const Color(0xFF202C33) : Colors.white),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isOutbound ? 12 : 2),
              bottomRight: Radius.circular(isOutbound ? 2 : 12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: isOutbound
                  ? Colors.transparent
                  : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (msg.templateName != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 12, color: Color(0xFF25D366)),
                    const SizedBox(width: 4),
                    Text(
                      'Template: ${msg.templateName}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF25D366),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Text(
                msg.messageContent,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: isOutbound
                      ? (isDark ? Colors.white : const Color(0xFF111B21))
                      : AppColors.textPrimary(isDark),
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
                      fontSize: 10.5,
                      color: isOutbound
                          ? (isDark ? Colors.white70 : const Color(0xFF667781))
                          : AppColors.textMuted(isDark),
                    ),
                  ),
                  if (isOutbound) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: msg.isRead
                          ? const Color(0xFF34B7F1) // WhatsApp blue double tick
                          : (isDark ? Colors.white70 : const Color(0xFF667781)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: BROADCAST CAMPAIGNS
  // ==========================================
  Widget _buildBroadcastTab(bool isDark) {
    return SingleChildScrollView(
      child: GlassCard(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Targeted WhatsApp Broadcast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Broadcast official WhatsApp announcements directly to categorized member segments without risk of spam flags',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
            ),
            const SizedBox(height: DesignTokens.space24),

            // Audience segment choices
            Text(
              'Target Audience Segment',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                ChoiceChip(
                  label: const Text('All Active Members (6)'),
                  selected: _selectedBroadcastAudience == 'all_active',
                  onSelected: (_) => setState(() => _selectedBroadcastAudience = 'all_active'),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                ),
                ChoiceChip(
                  label: const Text('Expiring in 7 Days (2)'),
                  selected: _selectedBroadcastAudience == 'expiring_7_days',
                  onSelected: (_) => setState(() => _selectedBroadcastAudience = 'expiring_7_days'),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                ),
                ChoiceChip(
                  label: const Text('Pending Payment Dues (1)'),
                  selected: _selectedBroadcastAudience == 'pending_dues',
                  onSelected: (_) => setState(() => _selectedBroadcastAudience = 'pending_dues'),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space20),

            // Message Body Composer
            Text(
              'WhatsApp Campaign Message',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _broadcastMsgCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter message text. Use {{name}} to insert member first name automatically.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space24),

            // Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  text: 'Dispatch WhatsApp Broadcast',
                  icon: Icons.send_rounded,
                  size: ButtonSize.lg,
                  isLoading: _isBroadcasting,
                  variant: ButtonVariant.primary,
                  onPressed: _handleBroadcast,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: AUTOMATED TRIGGERS & TEMPLATES
  // ==========================================
  Widget _buildAutomatedTriggersTab(bool isDark) {
    final triggersAsync = ref.watch(whatsAppTriggersProvider);
    final templatesAsync = ref.watch(whatsAppTemplatesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Automated Trigger Rules
          Text(
            'System Trigger Automation Rules',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Configure automatic WhatsApp notifications dispatched on core operational events in real time',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
          ),
          const SizedBox(height: DesignTokens.space16),

          triggersAsync.buildStateWidget(
            context,
            onRetry: () => ref.invalidate(whatsAppTriggersProvider),
            onData: (triggers) {
              return Column(
                children: triggers.map((rule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(DesignTokens.space16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bolt_rounded, color: Color(0xFF25D366), size: 24),
                          ),
                          const SizedBox(width: DesignTokens.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatTriggerTitle(rule.triggerEvent),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Linked Meta Template: ${rule.templateName}',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: rule.isEnabled,
                            activeThumbColor: const Color(0xFF25D366),
                            onChanged: (val) async {
                              await ref
                                  .read(whatsAppActionProvider)
                                  .toggleTrigger(rule.triggerEvent, val);
                              ref.read(toastProvider.notifier).info(
                                    'Trigger Updated',
                                    message: '${_formatTriggerTitle(rule.triggerEvent)} is now ${val ? "enabled" : "disabled"}.',
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: DesignTokens.space24),

          // Approved Templates Preview
          Text(
            'Meta Approved Message Templates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: DesignTokens.space12),

          templatesAsync.buildStateWidget(
            context,
            onRetry: () => ref.invalidate(whatsAppTemplatesProvider),
            onData: (templates) {
              return Column(
                children: templates.map((tmpl) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(DesignTokens.space16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tmpl.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                              StatusBadge(status: tmpl.metaStatus, isPill: true),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tmpl.body,
                              style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary(isDark)),
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
    );
  }

  String _formatTriggerTitle(String triggerEvent) {
    switch (triggerEvent) {
      case 'OnPaymentCompleted':
        return 'Auto-Send Invoice Receipt on Payment';
      case 'OnMembershipExpiring':
        return 'Auto-Send Renewal Reminder (5 Days Before Expiry)';
      case 'OnMemberJoined':
        return 'Auto-Send Welcome & Coach Intro on Registration';
      case 'OnInactivity':
        return 'Auto-Send Motivation Check-in After 7 Days Inactive';
      default:
        return triggerEvent;
    }
  }

  // ==========================================
  // TAB 4: ACCOUNT CONNECTION & WEBHOOK
  // ==========================================
  Widget _buildAccountConnectionTab(bool isDark) {
    final configAsync = ref.watch(whatsAppConfigProvider);

    return SingleChildScrollView(
      child: configAsync.buildStateWidget(
        context,
        onRetry: () => ref.invalidate(whatsAppConfigProvider),
        onData: (config) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status Header Card
              GlassCard(
                padding: const EdgeInsets.all(DesignTokens.space24),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: config.isConnected ? const Color(0xFF25D366).withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        config.isConnected ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: config.isConnected ? const Color(0xFF25D366) : AppColors.error,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                config.businessPortfolioName.isNotEmpty ? config.businessPortfolioName : 'Titan Fitness WhatsApp Business',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark)),
                              ),
                              const SizedBox(width: 10),
                              StatusBadge(status: config.connectionStatus, isPill: true),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: config.healthStatus == 'HEALTHY' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: config.healthStatus == 'HEALTHY' ? Colors.green : Colors.orange),
                                ),
                                child: Text(
                                  'API: ${config.healthStatus}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: config.healthStatus == 'HEALTHY' ? Colors.green : Colors.orange),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Connected Number: ${config.displayPhoneNumber} • WABA ID: ${config.wabaId} • Phone ID: ${config.phoneNumberId}',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      text: 'Sync Meta Templates',
                      icon: Icons.sync_rounded,
                      variant: ButtonVariant.outline,
                      onPressed: () async {
                        final ok = await ref.read(whatsAppActionProvider).syncTemplates();
                        if (ok) {
                          ref.read(toastProvider.notifier).success('Templates Synced', message: 'Meta Cloud API approved templates updated.');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: config.isConnected ? 'Disconnect' : 'Connect',
                      variant: config.isConnected ? ButtonVariant.danger : ButtonVariant.primary,
                      onPressed: () async {
                        if (config.isConnected) {
                          final ok = await ref.read(whatsAppActionProvider).disconnectConfig();
                          if (ok) {
                            ref.read(toastProvider.notifier).info('Account Disconnected', message: 'WhatsApp Business account was disconnected.');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space24),

              // Two Column Settings Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta WABA Settings
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(DesignTokens.space24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Meta Cloud API Credentials', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark))),
                          const SizedBox(height: DesignTokens.space16),
                          AppTextField(label: 'WhatsApp Business Account ID (WABA)', initialValue: config.wabaId),
                          const SizedBox(height: DesignTokens.space12),
                          AppTextField(label: 'Phone Number ID', initialValue: config.phoneNumberId),
                          const SizedBox(height: DesignTokens.space12),
                          AppTextField(label: 'Display Phone Number', initialValue: config.displayPhoneNumber),
                          const SizedBox(height: DesignTokens.space12),
                          AppTextField(label: 'Timezone for Automation', initialValue: config.timeZoneId),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space20),

                  // Webhook Configuration Card
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(DesignTokens.space24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Webhook & Inbound Event Routing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark))),
                          const SizedBox(height: DesignTokens.space8),
                          Text(
                            'Configure these details in the Meta App Dashboard > WhatsApp > Configuration to enable real-time delivery receipts and STOP opt-out processing.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                          ),
                          const SizedBox(height: DesignTokens.space16),
                          AppTextField(
                            label: 'Callback URL',
                            initialValue: config.webhookUrl.isNotEmpty ? config.webhookUrl : 'http://localhost:5128/api/whatsapp/webhook',
                            suffixIcon: Icons.copy_rounded,
                          ),
                          const SizedBox(height: DesignTokens.space12),
                          AppTextField(
                            label: 'Verify Token',
                            initialValue: config.webhookVerifyToken,
                            suffixIcon: Icons.lock_outline_rounded,
                          ),
                          const SizedBox(height: DesignTokens.space16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Webhook verification handshake (hub.challenge) is active and verified with SHA-256 idempotency.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary(isDark)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 5: SCHEDULED MESSAGE QUEUE
  // ==========================================
  Widget _buildScheduledMessagesTab(bool isDark) {
    final scheduledAsync = ref.watch(whatsAppScheduledMessagesProvider);

    return scheduledAsync.buildStateWidget(
      context,
      onRetry: () => ref.invalidate(whatsAppScheduledMessagesProvider),
      onData: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_send_rounded, size: 56, color: AppColors.textSecondary(isDark).withOpacity(0.4)),
                const SizedBox(height: 12),
                Text('Scheduled Queue is Clear', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark))),
                const SizedBox(height: 6),
                Text('Automated workout notifications and expiry reminders will appear here when scheduled.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary(isDark))),
              ],
            ),
          );
        }

        return GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Active Scheduled Queue (${messages.length} Pending)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark))),
                  AppButton(
                    text: 'Refresh Queue',
                    icon: Icons.refresh_rounded,
                    variant: ButtonVariant.ghost,
                    onPressed: () => ref.invalidate(whatsAppScheduledMessagesProvider),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space12),
              Expanded(
                child: ListView.separated(
                  itemCount: messages.length,
                  separatorBuilder: (_, __) => Divider(color: isDark ? Colors.white10 : Colors.black12),
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: msg.isPending ? AppColors.primary.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                        child: Icon(
                          msg.triggerType == 'DailyWorkout' ? Icons.fitness_center_rounded : Icons.alarm_rounded,
                          color: msg.isPending ? AppColors.primary : Colors.grey,
                          size: 20,
                        ),
                      ),
                      title: Text('${msg.recipientName} (${msg.recipientPhone})', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark))),
                      subtitle: Text(
                        'Scheduled: ${DateFormat('MMM dd, hh:mm a').format(msg.scheduledForUtc)} • Trigger: ${msg.triggerType}\n${msg.messageContent}',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary(isDark)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusBadge(status: msg.status, isPill: true),
                          if (msg.isPending) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
                              tooltip: 'Cancel Scheduled Message',
                              onPressed: () async {
                                final ok = await ref.read(whatsAppActionProvider).cancelScheduledMessage(msg.id);
                                if (ok) {
                                  ref.read(toastProvider.notifier).success('Scheduled Message Cancelled');
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
