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

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Global Query Filters for Strict Multi-Tenant Isolation
        modelBuilder.Entity<Branch>().HasQueryFilter(b => !_tenantService!.TenantId.HasValue || b.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<User>().HasQueryFilter(u => !_tenantService!.TenantId.HasValue || u.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<Member>().HasQueryFilter(m => !_tenantService!.TenantId.HasValue || m.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<MembershipPlan>().HasQueryFilter(p => !_tenantService!.TenantId.HasValue || p.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<MemberSubscription>().HasQueryFilter(s => !_tenantService!.TenantId.HasValue || s.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<Lead>().HasQueryFilter(l => !_tenantService!.TenantId.HasValue || l.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<LeadActivity>().HasQueryFilter(a => !_tenantService!.TenantId.HasValue || a.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<AttendanceRecord>().HasQueryFilter(ar => !_tenantService!.TenantId.HasValue || ar.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<PaymentTransaction>().HasQueryFilter(pt => !_tenantService!.TenantId.HasValue || pt.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<TrainerProfile>().HasQueryFilter(tp => !_tenantService!.TenantId.HasValue || tp.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<TrainerSession>().HasQueryFilter(ts => !_tenantService!.TenantId.HasValue || ts.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<WorkoutPlan>().HasQueryFilter(wp => !_tenantService!.TenantId.HasValue || wp.TenantId == _tenantService.TenantId.Value);
        modelBuilder.Entity<AuditLog>().HasQueryFilter(al => !_tenantService!.TenantId.HasValue || al.TenantId == _tenantService.TenantId.Value);

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

