using GimXSoft.Api.Data;
using GimXSoft.Api.Entities;
using Microsoft.EntityFrameworkCore;

namespace GimXSoft.Api.Services;

public class WhatsAppSchedulerBackgroundService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<WhatsAppSchedulerBackgroundService> _logger;

    public WhatsAppSchedulerBackgroundService(
        IServiceProvider serviceProvider,
        ILogger<WhatsAppSchedulerBackgroundService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("WhatsApp Scheduler & Automation Engine background service started.");

        // Initial delay to allow startup migrations and seeding to complete
        await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessPendingScheduledMessagesAsync(stoppingToken);
                await EvaluateAutomatedTriggersAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred during WhatsApp scheduled job execution cycle.");
            }

            // Polling interval: 20 seconds
            await Task.Delay(TimeSpan.FromSeconds(20), stoppingToken);
        }

        _logger.LogInformation("WhatsApp Scheduler background service stopped.");
    }

    private async Task ProcessPendingScheduledMessagesAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var apiClient = scope.ServiceProvider.GetRequiredService<IWhatsAppCloudApiClient>();

        var now = DateTime.UtcNow;
        var pendingMessages = await context.ScheduledMessages
            .IgnoreQueryFilters()
            .Where(m => m.Status == ScheduledMessageStatus.Pending && m.ScheduledForUtc <= now)
            .OrderBy(m => m.ScheduledForUtc)
            .Take(25)
            .ToListAsync(cancellationToken);

        if (pendingMessages.Count == 0) return;

        _logger.LogInformation("Processing {Count} pending scheduled WhatsApp messages.", pendingMessages.Count);

        foreach (var msg in pendingMessages)
        {
            try
            {
                msg.Status = ScheduledMessageStatus.Processing;
                await context.SaveChangesAsync(cancellationToken);

                // 1. Compliance check: Verify recipient is not suppressed (opted-out)
                var isSuppressed = await context.WhatsAppSuppressions
                    .IgnoreQueryFilters()
                    .AnyAsync(s => s.TenantId == msg.TenantId && s.Phone == msg.RecipientPhone, cancellationToken);

                if (isSuppressed)
                {
                    msg.Status = ScheduledMessageStatus.Cancelled;
                    msg.FailureReason = "Recipient opted out (STOP). Suppressed from automated dispatch.";
                    msg.ProcessedAt = DateTime.UtcNow;
                    await context.SaveChangesAsync(cancellationToken);
                    _logger.LogWarning("Cancelled scheduled message {Id} to {Phone} due to suppression list.", msg.Id, msg.RecipientPhone);
                    continue;
                }

                // 2. Consent check: If member exists, verify consent
                if (msg.MemberId.HasValue)
                {
                    var consent = await context.WhatsAppConsents
                        .IgnoreQueryFilters()
                        .FirstOrDefaultAsync(c => c.TenantId == msg.TenantId && c.MemberId == msg.MemberId.Value, cancellationToken);

                    if (consent != null && !consent.HasConsented)
                    {
                        msg.Status = ScheduledMessageStatus.Cancelled;
                        msg.FailureReason = "Member has not consented to WhatsApp communications.";
                        msg.ProcessedAt = DateTime.UtcNow;
                        await context.SaveChangesAsync(cancellationToken);
                        continue;
                    }
                }

                // 3. Dispatch message via Cloud API
                var integration = await context.WhatsAppIntegrations
                    .IgnoreQueryFilters()
                    .FirstOrDefaultAsync(i => i.TenantId == msg.TenantId, cancellationToken);

                var phoneId = integration?.PhoneNumberId ?? "105938472910482";
                var token = integration?.AccessToken ?? "EAAG_MOCK_TOKEN";

                WhatsAppSendResult result;
                if (!string.IsNullOrEmpty(msg.TemplateName))
                {
                    result = await apiClient.SendTemplateMessageAsync(
                        phoneId,
                        token,
                        msg.RecipientPhone,
                        msg.TemplateName,
                        "en_US",
                        new List<string> { msg.RecipientName },
                        cancellationToken
                    );
                }
                else
                {
                    result = await apiClient.SendTextMessageAsync(
                        phoneId,
                        token,
                        msg.RecipientPhone,
                        msg.MessageContent,
                        cancellationToken
                    );
                }

                if (result.Success)
                {
                    msg.Status = ScheduledMessageStatus.Sent;
                    msg.ProcessedAt = DateTime.UtcNow;

                    // Log to permanent message transcript
                    var historyMessage = new WhatsAppMessage
                    {
                        TenantId = msg.TenantId,
                        MemberId = msg.MemberId,
                        RecipientPhone = msg.RecipientPhone,
                        RecipientName = msg.RecipientName,
                        Direction = WhatsAppDirection.Outbound,
                        MessageType = !string.IsNullOrEmpty(msg.TemplateName) ? WhatsAppMessageType.Template : WhatsAppMessageType.Text,
                        TemplateName = msg.TemplateName,
                        MessageContent = msg.MessageContent,
                        WamId = result.WamId,
                        Status = WhatsAppMessageStatus.Delivered,
                        SentAt = DateTime.UtcNow,
                        DeliveredAt = DateTime.UtcNow.AddSeconds(1)
                    };
                    context.WhatsAppMessages.Add(historyMessage);
                }
                else
                {
                    msg.Status = ScheduledMessageStatus.Failed;
                    msg.FailureReason = result.ErrorMessage;
                    msg.ProcessedAt = DateTime.UtcNow;
                }

                await context.SaveChangesAsync(cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to dispatch scheduled message {MessageId}", msg.Id);
                msg.Status = ScheduledMessageStatus.Failed;
                msg.FailureReason = ex.Message;
                msg.ProcessedAt = DateTime.UtcNow;
                await context.SaveChangesAsync(cancellationToken);
            }
        }
    }

    private async Task EvaluateAutomatedTriggersAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var today = DateTime.UtcNow.Date;
        var todayDayName = today.DayOfWeek.ToString(); // e.g. "Monday"

        // 1. Daily Workout Routine Trigger
        var workoutTriggerRule = await context.WhatsAppTriggerRules
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(r => r.TriggerEvent == "OnDailyWorkoutRoutine" && r.IsEnabled, cancellationToken);

        if (workoutTriggerRule != null)
        {
            var schedules = await context.MemberWorkoutSchedules
                .IgnoreQueryFilters()
                .Include(s => s.Member)
                .Where(s => s.IsActive && s.TrainerApproved && s.DayOfWeek == todayDayName)
                .ToListAsync(cancellationToken);

            foreach (var sched in schedules)
            {
                if (sched.Member == null) continue;

                // Check if already dispatched for today
                var alreadySentToday = await context.WhatsAppMessages
                    .IgnoreQueryFilters()
                    .AnyAsync(m => m.MemberId == sched.MemberId && m.SentAt >= today && m.TemplateName == "daily_workout_delivery", cancellationToken);

                if (alreadySentToday) continue;

                // Queue daily workout notification
                var messageContent = sched.IsRestDay
                    ? $"Hi {sched.Member.FirstName}, today is your scheduled Active Recovery & Rest Day. Stay hydrated and prioritize nutrition!"
                    : $"Hi {sched.Member.FirstName}, your workout for today is '{sched.RoutineTitle}'. Get ready to crush it at Titan Fitness!";

                context.ScheduledMessages.Add(new ScheduledMessage
                {
                    TenantId = sched.TenantId,
                    MemberId = sched.MemberId,
                    RecipientPhone = sched.Member.Phone,
                    RecipientName = sched.Member.FullName,
                    TemplateName = "daily_workout_delivery",
                    MessageContent = messageContent,
                    ScheduledForUtc = DateTime.UtcNow,
                    Status = ScheduledMessageStatus.Pending,
                    TriggerType = "DailyWorkout",
                    CreatedAt = DateTime.UtcNow
                });
            }
            await context.SaveChangesAsync(cancellationToken);
        }

        // 2. Membership Expiry Automation Trigger
        var expiryTriggerRule = await context.WhatsAppTriggerRules
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(r => r.TriggerEvent == "OnMembershipExpiring" && r.IsEnabled, cancellationToken);

        if (expiryTriggerRule != null)
        {
            var sevenDaysLater = today.AddDays(7);
            var expiringMembers = await context.MemberSubscriptions
                .IgnoreQueryFilters()
                .Include(s => s.Member)
                .Include(s => s.MembershipPlan)
                .Where(s => s.Status == SubscriptionStatus.Active && s.EndDate.Date == sevenDaysLater)
                .ToListAsync(cancellationToken);

            foreach (var sub in expiringMembers)
            {
                if (sub.Member == null) continue;

                var alreadyNotified = await context.ScheduledMessages
                    .IgnoreQueryFilters()
                    .AnyAsync(m => m.MemberId == sub.MemberId && m.TriggerType == "ExpiryReminder" && m.CreatedAt >= today.AddDays(-6), cancellationToken);

                if (alreadyNotified) continue;

                context.ScheduledMessages.Add(new ScheduledMessage
                {
                    TenantId = sub.TenantId,
                    MemberId = sub.MemberId,
                    RecipientPhone = sub.Member.Phone,
                    RecipientName = sub.Member.FullName,
                    TemplateName = "membership_renewal_reminder",
                    MessageContent = $"Hi {sub.Member.FirstName}, your {sub.MembershipPlan?.Name ?? "Membership"} expires on {sub.EndDate:MMM dd, yyyy}. Contact reception or reply here to renew!",
                    ScheduledForUtc = DateTime.UtcNow,
                    Status = ScheduledMessageStatus.Pending,
                    TriggerType = "ExpiryReminder",
                    CreatedAt = DateTime.UtcNow
                });
            }
            await context.SaveChangesAsync(cancellationToken);
        }
    }
}
