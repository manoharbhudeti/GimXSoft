import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/attendance/attendance_terminal_view.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_view.dart';
import '../../features/branches/branches_view.dart';
import '../../features/dashboard/dashboard_view.dart';
import '../../features/landing/landing_view.dart';
import '../../features/measurements/fitness_progress_view.dart';
import '../../features/whatsapp/whatsapp_messaging_view.dart';
import '../../features/members/members_view.dart';
import '../../features/memberships/memberships_view.dart';
import '../../features/payments/payments_view.dart';
import '../../features/reports/reports_view.dart';
import '../../features/settings/settings_view.dart';
import '../../features/staff/staff_view.dart';
import '../../features/trainers/trainers_view.dart';
import '../../features/workouts/workout_library_view.dart';
import '../../features/workouts/workout_scheduler_view.dart';
import '../../layout/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isLanding = state.matchedLocation == '/' || state.matchedLocation == '/landing';

      if (isLanding) {
        return null;
      }
      if (!isAuth && !isLoggingIn) {
        return '/login';
      }
      if (isAuth && isLoggingIn) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingView(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardView()),
          ),
          GoRoute(
            path: '/members',
            pageBuilder: (context, state) => const NoTransitionPage(child: MembersView()),
          ),
          GoRoute(
            path: '/whatsapp',
            pageBuilder: (context, state) => const NoTransitionPage(child: WhatsAppMessagingView()),
          ),
          GoRoute(
            path: '/memberships',
            pageBuilder: (context, state) => const NoTransitionPage(child: MembershipsView()),
          ),
          GoRoute(
            path: '/attendance',
            pageBuilder: (context, state) => const NoTransitionPage(child: AttendanceTerminalView()),
          ),
          GoRoute(
            path: '/payments',
            pageBuilder: (context, state) => const NoTransitionPage(child: PaymentsView()),
          ),
          GoRoute(
            path: '/trainers',
            pageBuilder: (context, state) => const NoTransitionPage(child: TrainersView()),
          ),
          GoRoute(
            path: '/workouts',
            pageBuilder: (context, state) => const NoTransitionPage(child: WorkoutLibraryView()),
          ),
          GoRoute(
            path: '/workout-library',
            pageBuilder: (context, state) => const NoTransitionPage(child: WorkoutLibraryView()),
          ),
          GoRoute(
            path: '/workout-scheduler',
            pageBuilder: (context, state) => const NoTransitionPage(child: WorkoutSchedulerView()),
          ),
          GoRoute(
            path: '/fitness-progress',
            pageBuilder: (context, state) => const NoTransitionPage(child: FitnessProgressView()),
          ),
          GoRoute(
            path: '/staff',
            pageBuilder: (context, state) => const NoTransitionPage(child: StaffView()),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => const NoTransitionPage(child: ReportsView()),
          ),
          GoRoute(
            path: '/branches',
            pageBuilder: (context, state) => const NoTransitionPage(child: BranchesView()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsView()),
          ),
        ],
      ),
    ],
  );
});
