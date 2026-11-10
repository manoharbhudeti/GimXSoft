using GimXSoft.Api.Entities;
using GimXSoft.Api.Services;
using Microsoft.EntityFrameworkCore;

namespace GimXSoft.Api.Data;

public class ApplicationDbContext : DbContext
{
    private readonly ICurrentTenantService? _tenantService;

    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options, ICurrentTenantService? tenantService = null)
        : base(options)
    {
        _tenantService = tenantService;
    }

    public DbSet<Tenant> Tenants => Set<Tenant>();
    public DbSet<Branch> Branches => Set<Branch>();
    public DbSet<User> Users => Set<User>();
    public DbSet<Member> Members => Set<Member>();
    public DbSet<MembershipPlan> MembershipPlans => Set<MembershipPlan>();
    public DbSet<MemberSubscription> MemberSubscriptions => Set<MemberSubscription>();
    public DbSet<Lead> Leads => Set<Lead>();
    public DbSet<LeadActivity> LeadActivities => Set<LeadActivity>();
    public DbSet<AttendanceRecord> AttendanceRecords => Set<AttendanceRecord>();
    public DbSet<PaymentTransaction> PaymentTransactions => Set<PaymentTransaction>();
    public DbSet<TrainerProfile> TrainerProfiles => Set<TrainerProfile>();
    public DbSet<TrainerSession> TrainerSessions => Set<TrainerSession>();
    public DbSet<WorkoutPlan> WorkoutPlans => Set<WorkoutPlan>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<WhatsAppMessage> WhatsAppMessages => Set<WhatsAppMessage>();
    public DbSet<WhatsAppTemplate> WhatsAppTemplates => Set<WhatsAppTemplate>();
    public DbSet<WhatsAppTriggerRule> WhatsAppTriggerRules => Set<WhatsAppTriggerRule>();
    public DbSet<WhatsAppIntegration> WhatsAppIntegrations => Set<WhatsAppIntegration>();
    public DbSet<WhatsAppConsent> WhatsAppConsents => Set<WhatsAppConsent>();
    public DbSet<WhatsAppSuppression> WhatsAppSuppressions => Set<WhatsAppSuppression>();
    public DbSet<ScheduledMessage> ScheduledMessages => Set<ScheduledMessage>();
    public DbSet<WhatsAppCampaign> WhatsAppCampaigns => Set<WhatsAppCampaign>();
    public DbSet<WhatsAppCampaignRecipient> WhatsAppCampaignRecipients => Set<WhatsAppCampaignRecipient>();
    public DbSet<WhatsAppWebhookLog> WhatsAppWebhookLogs => Set<WhatsAppWebhookLog>();
    public DbSet<Exercise> Exercises => Set<Exercise>();
    public DbSet<ExerciseCategory> ExerciseCategories => Set<ExerciseCategory>();
    public DbSet<WorkoutTemplate> WorkoutTemplates => Set<WorkoutTemplate>();
    public DbSet<MemberWorkoutSchedule> MemberWorkoutSchedules => Set<MemberWorkoutSchedule>();
    public DbSet<WorkoutCompletion> WorkoutCompletions => Set<WorkoutCompletion>();
    public DbSet<MemberMeasurement> MemberMeasurements => Set<MemberMeasurement>();
    public DbSet<MemberFitnessBaseline> MemberFitnessBaselines => Set<MemberFitnessBaseline>();
    public DbSet<MemberOnboardingJourney> MemberOnboardingJourneys => Set<MemberOnboardingJourney>();
    public DbSet<MemberProgressReview> MemberProgressReviews => Set<MemberProgressReview>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Global Query Filters for Strict Multi-Tenant Isolation
        modelBuilder.Entity<Branch>().HasQueryFilter(b => _tenantService == null || !_tenantService.TenantId.HasValue || b.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<User>().HasQueryFilter(u => _tenantService == null || !_tenantService.TenantId.HasValue || u.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<Member>().HasQueryFilter(m => _tenantService == null || !_tenantService.TenantId.HasValue || m.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<MembershipPlan>().HasQueryFilter(p => _tenantService == null || !_tenantService.TenantId.HasValue || p.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<MemberSubscription>().HasQueryFilter(s => _tenantService == null || !_tenantService.TenantId.HasValue || s.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<Lead>().HasQueryFilter(l => _tenantService == null || !_tenantService.TenantId.HasValue || l.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<LeadActivity>().HasQueryFilter(a => _tenantService == null || !_tenantService.TenantId.HasValue || a.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<AttendanceRecord>().HasQueryFilter(ar => _tenantService == null || !_tenantService.TenantId.HasValue || ar.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<PaymentTransaction>().HasQueryFilter(pt => _tenantService == null || !_tenantService.TenantId.HasValue || pt.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<TrainerProfile>().HasQueryFilter(tp => _tenantService == null || !_tenantService.TenantId.HasValue || tp.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<TrainerSession>().HasQueryFilter(ts => _tenantService == null || !_tenantService.TenantId.HasValue || ts.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WorkoutPlan>().HasQueryFilter(wp => _tenantService == null || !_tenantService.TenantId.HasValue || wp.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<AuditLog>().HasQueryFilter(al => _tenantService == null || !_tenantService.TenantId.HasValue || al.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WhatsAppMessage>().HasQueryFilter(wm => _tenantService == null || !_tenantService.TenantId.HasValue || wm.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WhatsAppTemplate>().HasQueryFilter(wt => _tenantService == null || !_tenantService.TenantId.HasValue || wt.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WhatsAppTriggerRule>().HasQueryFilter(wtr => _tenantService == null || !_tenantService.TenantId.HasValue || wtr.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WhatsAppIntegration>().HasQueryFilter(wi => _tenantService == null || !_tenantService.TenantId.HasValue || wi.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WhatsAppConsent>().HasQueryFilter(wc => _tenantService == null || !_tenantService.TenantId.HasValue || wc.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WhatsAppSuppression>().HasQueryFilter(ws => _tenantService == null || !_tenantService.TenantId.HasValue || ws.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<ScheduledMessage>().HasQueryFilter(sm => _tenantService == null || !_tenantService.TenantId.HasValue || sm.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WhatsAppCampaign>().HasQueryFilter(wc => _tenantService == null || !_tenantService.TenantId.HasValue || wc.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WhatsAppCampaignRecipient>().HasQueryFilter(wcr => _tenantService == null || !_tenantService.TenantId.HasValue || wcr.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<Exercise>().HasQueryFilter(ex => _tenantService == null || !_tenantService.TenantId.HasValue || ex.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<ExerciseCategory>().HasQueryFilter(ec => _tenantService == null || !_tenantService.TenantId.HasValue || ec.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WorkoutTemplate>().HasQueryFilter(wt => _tenantService == null || !_tenantService.TenantId.HasValue || wt.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<MemberWorkoutSchedule>().HasQueryFilter(mws => _tenantService == null || !_tenantService.TenantId.HasValue || mws.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<WorkoutCompletion>().HasQueryFilter(wc => _tenantService == null || !_tenantService.TenantId.HasValue || wc.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<MemberMeasurement>().HasQueryFilter(mm => _tenantService == null || !_tenantService.TenantId.HasValue || mm.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<MemberFitnessBaseline>().HasQueryFilter(mfb => _tenantService == null || !_tenantService.TenantId.HasValue || mfb.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<MemberOnboardingJourney>().HasQueryFilter(moj => _tenantService == null || !_tenantService.TenantId.HasValue || moj.TenantId == _tenantService.TenantId);
        modelBuilder.Entity<MemberProgressReview>().HasQueryFilter(mpr => _tenantService == null || !_tenantService.TenantId.HasValue || mpr.TenantId == _tenantService.TenantId);

        // Relationships & Constraints
        modelBuilder.Entity<Tenant>()
            .HasIndex(t => t.Slug)
            .IsUnique();

        modelBuilder.Entity<Member>()
            .HasIndex(m => new { m.TenantId, m.MemberCode })
            .IsUnique();

        modelBuilder.Entity<PaymentTransaction>()
            .HasIndex(p => new { p.TenantId, p.InvoiceNumber })
            .IsUnique();

        modelBuilder.Entity<User>()
            .HasIndex(u => new { u.TenantId, u.Email })
            .IsUnique();

        modelBuilder.Entity<WhatsAppWebhookLog>()
            .HasIndex(w => w.EventId)
            .IsUnique();

        // High Precision Financial Decimals
        modelBuilder.Entity<MembershipPlan>()
            .Property(p => p.Price)
            .HasPrecision(18, 2);

        modelBuilder.Entity<MembershipPlan>()
            .Property(p => p.RegistrationFee)
            .HasPrecision(18, 2);

        modelBuilder.Entity<MemberSubscription>()
            .Property(s => s.PricePaid)
            .HasPrecision(18, 2);

        modelBuilder.Entity<MemberSubscription>()
            .Property(s => s.DiscountAmount)
            .HasPrecision(18, 2);

        modelBuilder.Entity<PaymentTransaction>()
            .Property(p => p.Amount)
            .HasPrecision(18, 2);

        modelBuilder.Entity<Lead>()
            .Property(l => l.EstimatedValue)
            .HasPrecision(18, 2);

        modelBuilder.Entity<TrainerProfile>()
            .Property(t => t.HourlyRate)
            .HasPrecision(18, 2);
    }
}

