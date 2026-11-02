import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final String path;
  final IconData icon;
  final int? badgeCount;

  const NavigationItem({
    required this.title,
    required this.path,
    required this.icon,
    this.badgeCount,
  });
}

const List<NavigationItem> kNavigationItems = [
  NavigationItem(
    title: 'Dashboard',
    path: '/dashboard',
    icon: Icons.dashboard_rounded,
  ),
  NavigationItem(
    title: 'Members',
    path: '/members',
    icon: Icons.people_alt_rounded,
  ),
  NavigationItem(
    title: 'Memberships',
    path: '/memberships',
    icon: Icons.card_membership_rounded,
  ),
  NavigationItem(
    title: 'Attendance',
    path: '/attendance',
    icon: Icons.how_to_reg_rounded,
  ),
  NavigationItem(
    title: 'Payments',
    path: '/payments',
    icon: Icons.receipt_long_rounded,
  ),
  NavigationItem(
    title: 'WhatsApp Centre',
    path: '/whatsapp',
    icon: Icons.chat_rounded,
    badgeCount: 2,
  ),
  NavigationItem(
    title: 'Workout Library',
    path: '/workout-library',
    icon: Icons.fitness_center_rounded,
  ),
  NavigationItem(
    title: 'Workout Scheduler',
    path: '/workout-scheduler',
    icon: Icons.event_note_rounded,
  ),
  NavigationItem(
    title: 'Fitness Progress',
    path: '/fitness-progress',
    icon: Icons.monitor_weight_rounded,
  ),
  NavigationItem(
    title: 'Trainers',
    path: '/trainers',
    icon: Icons.sports_gymnastics_rounded,
  ),
  NavigationItem(
    title: 'Staff',
    path: '/staff',
    icon: Icons.badge_rounded,
  ),
  NavigationItem(
    title: 'Reports',
    path: '/reports',
    icon: Icons.analytics_rounded,
  ),
  NavigationItem(
    title: 'Settings',
    path: '/settings',
    icon: Icons.tune_rounded,
  ),
];

