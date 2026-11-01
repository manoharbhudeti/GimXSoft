import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'app_empty_state.dart';

class NoDataState {
  static Widget members({VoidCallback? onAddMember}) {
    return AppEmptyState(
      icon: Icons.people_outline_rounded,
      iconColor: AppColors.violet,
      title: 'No Members Registered',
      description: 'Your member roster is currently empty. Add your first gym member to begin tracking subscriptions, workouts, and attendance.',
      primaryActionLabel: onAddMember != null ? 'Add First Member' : null,
      primaryActionIcon: Icons.person_add_rounded,
      onPrimaryAction: onAddMember,
    );
  }

  static Widget leads({VoidCallback? onAddLead}) {
    return AppEmptyState(
      icon: Icons.trending_up_rounded,
      iconColor: AppColors.cyan,
      title: 'No CRM Leads in Pipeline',
      description: 'Capture inbound inquiries from your website, walk-ins, and social media to manage prospective fitness clients.',
      primaryActionLabel: onAddLead != null ? 'Create First Lead' : null,
      primaryActionIcon: Icons.add_rounded,
      onPrimaryAction: onAddLead,
    );
  }

  static Widget attendance({VoidCallback? onCheckIn}) {
    return AppEmptyState(
      icon: Icons.qr_code_scanner_rounded,
      iconColor: AppColors.emerald,
      title: 'No Check-Ins Today',
      description: 'The gym check-in ledger is clean for today. Use the reception barcode/member ID scanner above to record member arrivals.',
      primaryActionLabel: onCheckIn != null ? 'Manual Check-In' : null,
      primaryActionIcon: Icons.login_rounded,
      onPrimaryAction: onCheckIn,
    );
  }

  static Widget payments({VoidCallback? onCollectPayment}) {
    return AppEmptyState(
      icon: Icons.receipt_long_rounded,
      iconColor: AppColors.emerald,
      title: 'No Payment Transactions',
      description: 'No billing or membership fees have been collected yet. Collect dues via Card, Cash, UPI, or Bank Wire to start your ledger.',
      primaryActionLabel: onCollectPayment != null ? 'Collect Payment' : null,
      primaryActionIcon: Icons.payment_rounded,
      onPrimaryAction: onCollectPayment,
    );
  }

  static Widget plans({VoidCallback? onAddPlan}) {
    return AppEmptyState(
      icon: Icons.card_membership_rounded,
      iconColor: AppColors.violet,
      title: 'No Membership Plans Defined',
      description: 'Create membership tiers with pricing, duration, and custom benefits to offer to your members.',
      primaryActionLabel: onAddPlan != null ? 'Create Plan' : null,
      primaryActionIcon: Icons.add_rounded,
      onPrimaryAction: onAddPlan,
    );
  }

  static Widget trainers({VoidCallback? onAddTrainer}) {
    return AppEmptyState(
      icon: Icons.fitness_center_rounded,
      iconColor: AppColors.cyan,
      title: 'No Personal Trainers Onboarded',
      description: 'Build your coaching staff by adding personal trainers, their fitness specialties, and hourly rates.',
      primaryActionLabel: onAddTrainer != null ? 'Add Trainer' : null,
      primaryActionIcon: Icons.person_add_alt_1_rounded,
      onPrimaryAction: onAddTrainer,
    );
  }

  static Widget workouts({VoidCallback? onAddWorkout}) {
    return AppEmptyState(
      icon: Icons.sports_gymnastics_rounded,
      iconColor: AppColors.amber,
      title: 'No Workout Plans Created',
      description: 'Design structured workout routines with exercises, set counts, target reps, and rest intervals.',
      primaryActionLabel: onAddWorkout != null ? 'Create Routine' : null,
      primaryActionIcon: Icons.add_rounded,
      onPrimaryAction: onAddWorkout,
    );
  }

  static Widget reports() {
    return const AppEmptyState(
      icon: Icons.analytics_outlined,
      iconColor: AppColors.cyan,
      title: 'Insufficient Data for Analytics',
      description: 'Statistical reporting and retention charts require member check-in and transaction history to render actionable trends.',
    );
  }
}
