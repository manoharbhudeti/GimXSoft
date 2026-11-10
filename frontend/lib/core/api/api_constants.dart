class ApiConstants {
  static const String baseUrl = 'http://localhost:5128/api';

  // Auth & Subscription Trial
  static const String login = '/auth/login';
  static const String registerTenant = '/auth/register-tenant';
  static const String registerTrial = '/auth/register-trial';
  static const String trialStatus = '/auth/trial-status';
  static const String cancelSubscription = '/auth/cancel-subscription';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  // Leads & Inquiries
  static const String leads = '/leads';
  static const String publicInquiry = '/leads/public-inquiry';

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
  static const String whatsAppAnalytics = '/whatsapp/analytics';
  static const String whatsAppConversations = '/whatsapp/conversations';
  static const String whatsAppHistory = '/whatsapp/history';
  static const String whatsAppSend = '/whatsapp/send';
  static const String whatsAppBroadcast = '/whatsapp/broadcast';
  static const String whatsAppCampaigns = '/whatsapp/campaigns';
  static const String whatsAppPreviewAudience = '/whatsapp/campaigns/preview-audience';
  static const String whatsAppTemplates = '/whatsapp/templates';
  static const String whatsAppTriggers = '/whatsapp/triggers';
  static const String whatsAppToggleTrigger = '/whatsapp/triggers/toggle';
  static const String whatsAppConfig = '/whatsapp/config';
  static const String whatsAppDisconnect = '/whatsapp/config/disconnect';
  static const String whatsAppRegisterNumber = '/whatsapp/meta/register-number';
  static const String whatsAppOnboardingInitiate = '/whatsapp/onboarding/initiate';
  static const String whatsAppOnboardingVerify = '/whatsapp/onboarding/verify-code';
  static const String whatsAppOnboardingResend = '/whatsapp/onboarding/resend-code';
  static const String whatsAppOnboardingCallback = '/whatsapp/onboarding/embedded-signup-callback';
  static const String whatsAppConnectionHealth = '/whatsapp/connection-health';
  static const String whatsAppSyncTemplates = '/whatsapp/templates/sync';
  static const String whatsAppConsent = '/whatsapp/consent';
  static const String whatsAppOptOut = '/whatsapp/opt-out';
  static const String whatsAppScheduled = '/whatsapp/scheduled';
  static const String whatsAppShareWorkout = '/whatsapp/gym/share-workout';
  static const String whatsAppSendBmi = '/whatsapp/gym/send-bmi-report';
  static const String whatsAppSendExpiry = '/whatsapp/gym/send-expiry-reminder';
  static const String whatsAppShareCatalog = '/whatsapp/gym/share-catalog';

  // Exercises & Workout Catalogue
  static const String exercises = '/exercises';
  static const String exerciseCategories = '/exercises/categories';
  static const String workoutTemplates = '/workouts/templates';
  static const String workoutSchedules = '/workouts/schedules';
  static const String assignWorkoutSchedule = '/workouts/schedules/assign';

  // Member Fitness & Measurement Tracking
  static const String measurements = '/measurements';
  static const String memberMeasurements = '/measurements/member';
  static const String progressCard = '/measurements/progress-card';
  static const String measurementBaseline = '/measurements/baseline';
  static const String onboardingJourney = '/measurements/onboarding';
  static const String onboardingStage = '/measurements/onboarding/stage';

  // Attendance
  static const String attendanceToday = '/attendance/today-summary';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceCheckIn = '/attendance/check-in';
  static const String attendanceCheckOut = '/attendance/check-out';
  static const String liveOccupancy = '/attendance/live-occupancy';
  static const String simulateScan = '/attendance/simulate-scan';

  // Payments & Billing
  static const String payments = '/payments';
  static const String collectPayment = '/payments/collect';
  static const String posCharge = '/payments/pos-charge';
  static const String financialSummary = '/payments/financial-summary';

  // WhatsApp Quick Dispatches & Triggers
  static const String whatsAppQuickSend = '/whatsapp/quick-send';
  static const String whatsAppTestMessage = '/whatsapp/test-message';

  // Trainers & Workouts
  static const String trainers = '/trainers';
  static const String trainerSessions = '/trainers/sessions';
  static const String workouts = '/workouts';

  // Staff & Branches
  static const String staff = '/staff';
  static const String branches = '/branches';

  // Reports & Analytics
  static const String reportRevenue = '/reports/revenue-summary';
  static const String reportAttendance = '/reports/attendance-distribution';
  static const String reportRetention = '/reports/retention-metrics';
  static const String roiCalculator = '/reports/roi-calculator';
  static const String facilityTraffic = '/reports/facility-traffic';
  static const String membershipBreakdown = '/reports/membership-breakdown';

  // Audit Logs
  static const String auditLogs = '/auditlogs';
}

