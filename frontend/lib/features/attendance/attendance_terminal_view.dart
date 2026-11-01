import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/status_badge.dart';
import 'attendance_provider.dart';

class AttendanceTerminalView extends ConsumerStatefulWidget {
  const AttendanceTerminalView({super.key});

  @override
  ConsumerState<AttendanceTerminalView> createState() => _AttendanceTerminalViewState();
}

class _AttendanceTerminalViewState extends ConsumerState<AttendanceTerminalView> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  String? _lastMessage;
  bool _isSuccess = true;
  bool _isCheckingIn = false;

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn([String? code]) async {
    final query = (code ?? _codeController.text).trim();
    if (query.isEmpty) return;

    setState(() {
      _isCheckingIn = true;
      _lastMessage = null;
    });

    final res = await ref.read(attendanceActionProvider).checkIn(query);

    setState(() {
      _isCheckingIn = false;
      _isSuccess = res.success;
      _lastMessage = res.message;
      if (res.success) {
        _codeController.clear();
      }
    });

    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(attendanceTodaySummaryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reception Fast Check-In Terminal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'High-throughput desk check-in interface with barcode & QR support',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                AppButton(
                  text: 'Refresh Feed',
                  icon: Icons.refresh_rounded,
                  variant: ButtonVariant.ghost,
                  onPressed: () => ref.refresh(attendanceTodaySummaryProvider),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space20),

            // 1. Reception Scanner Box
            GlassCard(
              padding: const EdgeInsets.all(DesignTokens.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: DesignTokens.borderMd,
                        ),
                        child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Barcode or Search Member',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Scan key fob, enter Member ID (e.g. GIX-1001), or enter phone number',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space20),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          focusNode: _focusNode,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary(isDark),
                          ),
                          onSubmitted: (_) => _handleCheckIn(),
                          decoration: InputDecoration(
                            hintText: 'Enter Member Code (e.g. GIX-1001) or phone...',
                            prefixIcon: const Icon(Icons.qr_code_2_rounded, size: 22, color: AppColors.primary),
                            suffixIcon: _codeController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => _codeController.clear(),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space16),
                      AppButton(
                        text: 'Check-In Member',
                        size: ButtonSize.lg,
                        icon: Icons.check_circle_outline_rounded,
                        isLoading: _isCheckingIn,
                        onPressed: () => _handleCheckIn(),
                      ),
                    ],
                  ),

                  // Quick test shortcuts chips
                  const SizedBox(height: DesignTokens.space12),
                  Row(
                    children: [
                      Text(
                        'QUICK SCAN TEST:',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted(isDark)),
                      ),
                      const SizedBox(width: 8),
                      _quickChip('GIX-1001', 'James Wilson', isDark),
                      const SizedBox(width: 6),
                      _quickChip('GIX-1002', 'Sophia Chen', isDark),
                      const SizedBox(width: 6),
                      _quickChip('GIX-1003', 'Liam O\'Connor', isDark),
                      const SizedBox(width: 6),
                      _quickChip('GIX-1004', 'Olivia Martinez', isDark),
                    ],
                  ),

                  // Feedback Alert Banner
                  if (_lastMessage != null) ...[
                    const SizedBox(height: DesignTokens.space16),
                    AnimatedContainer(
                      duration: DesignTokens.durationFast,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: (_isSuccess ? AppColors.success : AppColors.error).withOpacity(0.12),
                        borderRadius: DesignTokens.borderMd,
                        border: Border.all(
                          color: (_isSuccess ? AppColors.success : AppColors.error).withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                            color: _isSuccess ? AppColors.success : AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: DesignTokens.space12),
                          Expanded(
                            child: Text(
                              _lastMessage!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isSuccess ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space24),

            // 2. Daily Attendance KPI Metrics
            summaryAsync.when(
              loading: () => Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SkeletonLoader(width: double.infinity, height: 110),
                    ),
                  ),
                ),
              ),
              error: (err, _) => const SizedBox.shrink(),
              data: (summary) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth > 1000
                        ? (constraints.maxWidth - (3 * 16)) / 4
                        : (constraints.maxWidth - 16) / 2;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Total Check-Ins Today',
                            value: '${summary.totalCheckInsToday}',
                            subtitle: 'Daily check-in aggregate',
                            icon: Icons.group_rounded,
                            iconColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Currently On Floor',
                            value: '${summary.currentlyInGym}',
                            subtitle: 'Active workout sessions',
                            icon: Icons.fitness_center_rounded,
                            iconColor: AppColors.secondary,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Morning Traffic Peak',
                            value: '${summary.morningPeakCount}',
                            subtitle: '06:00 - 11:00 AM volume',
                            icon: Icons.wb_sunny_rounded,
                            iconColor: AppColors.accentOrange,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricStatCard(
                            title: 'Evening Prime Peak',
                            value: '${summary.eveningPeakCount}',
                            subtitle: '16:00 - 21:00 PM volume',
                            icon: Icons.nights_stay_rounded,
                            iconColor: AppColors.accentPurple,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: DesignTokens.space24),

            // 3. Live Check-In Stream Table
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Check-In Activity Stream',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),

            summaryAsync.when(
              loading: () => SkeletonLoader(width: double.infinity, height: 260),
              error: (err, _) => Center(child: Text('Error loading activity: $err')),
              data: (summary) {
                if (summary.recentCheckIns.isEmpty) {
                  return GlassCard(
                    padding: const EdgeInsets.all(DesignTokens.space32),
                    child: Center(
                      child: Text('No check-ins recorded yet today.', style: TextStyle(color: AppColors.textMuted(isDark))),
                    ),
                  );
                }

                return GlassCard(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width - 300,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? const Color(0xFF162032) : const Color(0xFFF8FAFC),
                        ),
                        horizontalMargin: DesignTokens.space20,
                        columnSpacing: DesignTokens.space24,
                        columns: const [
                          DataColumn(label: Text('MEMBER')),
                          DataColumn(label: Text('MEMBER CODE')),
                          DataColumn(label: Text('CHECK-IN TIME')),
                          DataColumn(label: Text('CHECK-OUT TIME')),
                          DataColumn(label: Text('METHOD')),
                          DataColumn(label: Text('STATUS / ACTION')),
                        ],
                        rows: summary.recentCheckIns.map((rec) {
                          final isCurrentlyIn = rec.checkOutTime == null;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  rec.memberName,
                                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                                    borderRadius: DesignTokens.borderSm,
                                  ),
                                  child: Text(
                                    rec.memberCode,
                                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  DateFormat('HH:mm:ss').format(rec.checkInTime),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                Text(
                                  rec.checkOutTime != null
                                      ? DateFormat('HH:mm:ss').format(rec.checkOutTime!)
                                      : 'In Facility',
                                  style: TextStyle(
                                    color: rec.checkOutTime != null ? AppColors.textSecondary(isDark) : AppColors.secondary,
                                    fontWeight: rec.checkOutTime == null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              DataCell(StatusBadge(status: rec.method, isPill: false)),
                              DataCell(
                                isCurrentlyIn
                                    ? AppButton(
                                        text: 'Check Out',
                                        size: ButtonSize.sm,
                                        variant: ButtonVariant.outline,
                                        onPressed: () async {
                                          await ref.read(attendanceActionProvider).checkOut(rec.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${rec.memberName} checked out.')),
                                          );
                                        },
                                      )
                                    : const Text('Completed', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(String code, String name, bool isDark) {
    return InkWell(
      onTap: () => _handleCheckIn(code),
      borderRadius: DesignTokens.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9),
          borderRadius: DesignTokens.borderSm,
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Text(
          '$code ($name)',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark)),
        ),
      ),
    );
  }
}
