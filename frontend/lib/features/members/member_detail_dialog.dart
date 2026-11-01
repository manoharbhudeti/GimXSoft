import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/status_badge.dart';
import 'member_models.dart';
import 'members_provider.dart';

class MemberDetailDialog extends ConsumerWidget {
  final String memberId;

  const MemberDetailDialog({super.key, required this.memberId});

  static void show(BuildContext context, String memberId) {
    showDialog(
      context: context,
      builder: (context) => MemberDetailDialog(memberId: memberId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(memberDetailProvider(memberId));

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 680),
        child: GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space24),
          child: detailAsync.when(
            loading: () => const Center(child: SkeletonLoader(width: double.infinity, height: 400)),
            error: (err, _) => Center(
              child: Text('Failed to load member profile: $err', style: const TextStyle(color: AppColors.error)),
            ),
            data: (detail) => _MemberDetailContent(detail: detail, isDark: isDark),
          ),
        ),
      ),
    );
  }
}

class _MemberDetailContent extends StatefulWidget {
  final MemberDetailModel detail;
  final bool isDark;

  const _MemberDetailContent({required this.detail, required this.isDark});

  @override
  State<_MemberDetailContent> createState() => _MemberDetailContentState();
}

class _MemberDetailContentState extends State<_MemberDetailContent> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.detail.member;
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryHover,
              child: Text(
                m.firstName.isNotEmpty ? m.firstName[0] : 'M',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: DesignTokens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        m.fullName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(width: 10),
                      StatusBadge(status: m.status),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                          borderRadius: DesignTokens.borderSm,
                          border: Border.all(color: AppColors.border(isDark)),
                        ),
                        child: Text(
                          m.memberCode,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary(isDark)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${m.email} • ${m.phone} • Joined ${DateFormat('MMM yyyy').format(m.joiningDate)}',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted(isDark)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space20),

        // Tabs
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted(isDark),
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Subscriptions'),
            Tab(text: 'Attendance Log'),
            Tab(text: 'Payment History'),
          ],
        ),
        const SizedBox(height: DesignTokens.space16),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(m, isDark),
              _buildSubscriptionsTab(widget.detail.subscriptions, isDark),
              _buildAttendanceTab(widget.detail.recentAttendance, isDark),
              _buildPaymentsTab(widget.detail.recentPayments, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(MemberModel m, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Branch', m.branchName ?? 'Main Facility', isDark),
          _infoRow('Current Membership', m.currentPlanName ?? 'None', isDark),
          _infoRow('Assigned Trainer', m.assignedTrainerName ?? 'Self-Guided Training', isDark),
          _infoRow('Gender', m.gender ?? 'Not Specified', isDark),
          _infoRow('Address', m.address.isNotEmpty ? m.address : 'Not Provided', isDark),
          _infoRow('Emergency Contact', '${m.emergencyContactName} (${m.emergencyContactPhone})', isDark),
          const SizedBox(height: DesignTokens.space16),
          Text(
            'Medical & Fitness Notes',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.space12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
              borderRadius: DesignTokens.borderMd,
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Text(
              m.medicalNotes?.isNotEmpty == true ? m.medicalNotes! : 'No medical conditions or movement restrictions recorded.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsTab(List<dynamic> subs, bool isDark) {
    if (subs.isEmpty) {
      return Center(
        child: Text('No subscription records found.', style: TextStyle(color: AppColors.textMuted(isDark))),
      );
    }
    return ListView.separated(
      itemCount: subs.length,
      separatorBuilder: (_, __) => const Divider(height: 12),
      itemBuilder: (context, idx) {
        final s = subs[idx];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: DesignTokens.borderMd,
            ),
            child: const Icon(Icons.card_membership_rounded, color: AppColors.primary, size: 20),
          ),
          title: Text(s['planName'] ?? 'Plan', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark))),
          subtitle: Text('Start: ${s['startDate']?.toString().split('T').first}  |  End: ${s['endDate']?.toString().split('T').first}'),
          trailing: Text('\$${s['pricePaid']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary(isDark))),
        );
      },
    );
  }

  Widget _buildAttendanceTab(List<dynamic> records, bool isDark) {
    if (records.isEmpty) {
      return Center(
        child: Text('No attendance history found.', style: TextStyle(color: AppColors.textMuted(isDark))),
      );
    }
    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (_, __) => const Divider(height: 12),
      itemBuilder: (context, idx) {
        final a = records[idx];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 20),
          title: Text('Check-in: ${a['checkInTime']?.toString().replaceFirst('T', ' ').split('.').first ?? ''}'),
          subtitle: Text('Method: ${a['method']} • ${a['notes'] ?? 'Gym Floor'}'),
        );
      },
    );
  }

  Widget _buildPaymentsTab(List<dynamic> payments, bool isDark) {
    if (payments.isEmpty) {
      return Center(
        child: Text('No payment transaction history.', style: TextStyle(color: AppColors.textMuted(isDark))),
      );
    }
    return ListView.separated(
      itemCount: payments.length,
      separatorBuilder: (_, __) => const Divider(height: 12),
      itemBuilder: (context, idx) {
        final p = payments[idx];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.receipt_outlined, color: AppColors.accentCyan, size: 20),
          title: Text('Invoice ${p['invoiceNumber']}', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark))),
          subtitle: Text('${p['paymentMethod']} • ${p['createdAt']?.toString().split('T').first}'),
          trailing: Text('\$${p['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 14)),
        );
      },
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.textMuted(isDark))),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary(isDark)),
            ),
          ),
        ],
      ),
    );
  }
}
