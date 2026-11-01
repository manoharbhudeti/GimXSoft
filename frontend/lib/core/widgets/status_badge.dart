import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isPill;

  const StatusBadge({
    super.key,
    required this.status,
    this.isPill = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase().replaceAll(' ', '');

    Color color;
    String display = status;

    if (s == 'active' || s == 'completed' || s == 'converted') {
      color = AppColors.success;
      display = status;
    } else if (s == 'expired' || s == 'lost' || s == 'failed') {
      color = AppColors.error;
    } else if (s == 'frozen' || s == 'receptionist') {
      color = AppColors.accentCyan;
    } else if (s == 'inactive' || s == 'cancelled') {
      color = Colors.grey;
    } else if (s == 'new' || s == 'website' || s == 'branchmanager') {
      color = AppColors.info;
    } else if (s == 'gymowner' || s == 'superadmin') {
      color = AppColors.accentPurple;
    } else if (s == 'trainer') {
      color = AppColors.secondary;
    } else if (s == 'accountant' || s == 'pending' || s == 'interested') {
      color = AppColors.warning;
    } else if (s.contains('trial')) {
      color = AppColors.accentOrange;
    } else {
      color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: isPill ? DesignTokens.borderFull : DesignTokens.borderXs,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            display,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

