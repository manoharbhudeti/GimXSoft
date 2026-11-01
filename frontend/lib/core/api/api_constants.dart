class ApiConstants {
  static const String baseUrl = 'http://localhost:5128/api';

  // Auth
  static const String login = '/auth/login';
  static const String registerTenant = '/auth/register-tenant';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  // Dashboard
  static const String dashboardMetrics = '/dashboard/metrics';

  // Members
  static const String members = '/members';
  static const String exportMembers = '/members/export';

  // Memberships
  static const String membershipPlans = '/memberships/plans';
  static const String subscriptions = '/memberships/subscriptions';
  static const String subscribe = '/memberships/subscribe';

  // WhatsApp Messaging API
  static const String whatsAppMetrics = '/whatsapp/metrics';
  static const String whatsAppConversations = '/whatsapp/conversations';
  static const String whatsAppHistory = '/whatsapp/history';
  static const String whatsAppSend = '/whatsapp/send';
  static const String whatsAppBroadcast = '/whatsapp/broadcast';
  static const String whatsAppTemplates = '/whatsapp/templates';
  static const String whatsAppTriggers = '/whatsapp/triggers';
  static const String whatsAppToggleTrigger = '/whatsapp/triggers/toggle';

  // Attendance
  static const String attendanceToday = '/attendance/today-summary';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceCheckIn = '/attendance/check-in';
  static const String attendanceCheckOut = '/attendance/check-out';

  // Payments & Billing
  static const String payments = '/payments';
  static const String collectPayment = '/payments/collect';
  static const String financialSummary = '/payments/financial-summary';

  // Trainers & Workouts
  static const String trainers = '/trainers';
  static const String trainerSessions = '/trainers/sessions';
  static const String workouts = '/workouts';

  // Staff & Branches
  static const String staff = '/staff';
  static const String branches = '/branches';

  // Reports
  static const String reportRevenue = '/reports/revenue-summary';
  static const String reportAttendance = '/reports/attendance-distribution';
  static const String reportRetention = '/reports/retention-metrics';
}

