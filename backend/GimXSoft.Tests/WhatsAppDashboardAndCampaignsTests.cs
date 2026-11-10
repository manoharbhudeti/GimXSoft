using System.Text.Json;
using GimXSoft.Api.Controllers;
using GimXSoft.Api.Data;
using GimXSoft.Api.DTOs;
using GimXSoft.Api.Entities;
using GimXSoft.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace GimXSoft.Tests;

public class WhatsAppDashboardAndCampaignsTests
{
    private static ApplicationDbContext CreateInMemoryContext(ICurrentTenantService tenantService, string dbName)
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: dbName)
            .Options;

        return new ApplicationDbContext(options, tenantService);
    }

    [Fact]
    public async Task WhatsAppApi_GetDashboardAnalytics_ShouldReturnAggregatedMetricsAndDailyTrends()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        // Seed messages
        context.WhatsAppMessages.AddRange(
            new WhatsAppMessage
            {
                TenantId = tenantId,
                RecipientPhone = "919876543210",
                RecipientName = "Rohan Sharma",
                Direction = WhatsAppDirection.Outbound,
                Status = WhatsAppMessageStatus.Delivered,
                SentAt = DateTime.UtcNow
            },
            new WhatsAppMessage
            {
                TenantId = tenantId,
                RecipientPhone = "919876543210",
                RecipientName = "Rohan Sharma",
                Direction = WhatsAppDirection.Inbound,
                Status = WhatsAppMessageStatus.Read,
                SentAt = DateTime.UtcNow
            }
        );
        await context.SaveChangesAsync();

        var result = await controller.GetDashboardAnalytics(days: 7);
        var ok = Assert.IsType<OkObjectResult>(result.Result);
        var analytics = Assert.IsType<WhatsAppDashboardAnalyticsDto>(ok.Value);

        Assert.NotNull(analytics);
        Assert.Equal("Titan Fitness Club", analytics.VerifiedName);
        Assert.Equal("GREEN", analytics.QualityRating);
        Assert.True(analytics.TotalSent > 0);
        Assert.True(analytics.DailyTrends.Count >= 7);
    }

    [Fact]
    public async Task WhatsAppApi_CampaignCreation_ShouldTargetMembersAndGenerateRecipients()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        // Seed 2 active members
        context.Members.AddRange(
            new Member
            {
                TenantId = tenantId,
                FirstName = "Vikram",
                LastName = "Patel",
                Email = "vikram@gym.com",
                Phone = "919876511111",
                MemberCode = "GIX-101",
                Status = MemberStatus.Active
            },
            new Member
            {
                TenantId = tenantId,
                FirstName = "Ananya",
                LastName = "Deshmukh",
                Email = "ananya@gym.com",
                Phone = "919876522222",
                MemberCode = "GIX-102",
                Status = MemberStatus.Active
            }
        );
        await context.SaveChangesAsync();

        var createResult = await controller.CreateCampaign(new CreateCampaignRequest(
            Name: "Weekend BootCamp",
            Description: "Special outdoor conditioning invite",
            AudienceSegment: "AllActive",
            SpecificPlanId: null,
            TemplateName: "bootcamp_invite",
            TemplateLanguage: "en_US",
            MessageContent: "Hi {{name}}, join our Sunday Bootcamp at 7 AM!",
            ScheduledAtUtc: null
        ));

        var ok = Assert.IsType<OkObjectResult>(createResult.Result);
        var campaignDto = Assert.IsType<WhatsAppCampaignDto>(ok.Value);

        Assert.Equal("Weekend BootCamp", campaignDto.Name);
        Assert.Equal(2, campaignDto.TotalRecipients);
        Assert.Equal(2, campaignDto.SentCount);

        var recipients = await context.WhatsAppCampaignRecipients
            .Where(r => r.CampaignId == campaignDto.Id)
            .ToListAsync();

        Assert.Equal(2, recipients.Count);
        Assert.Contains(recipients, r => r.RecipientPhone == "919876511111");
        Assert.Contains(recipients, r => r.RecipientPhone == "919876522222");
    }

    [Fact]
    public async Task WhatsAppApi_CreateAndSyncTemplates_ShouldValidateAndPersist()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        var createResult = await controller.CreateTemplate(new CreateWhatsAppTemplateRequest(
            Name: "Monthly Renewal Reminder",
            Category: "UTILITY",
            Language: "en_US",
            HeaderText: "Membership Notice",
            BodyText: "Hi {{1}}, your plan renews soon. Tap below to pay.",
            FooterText: "GimXSoft Gym",
            Buttons: new List<string> { "Pay Online", "Contact Desk" }
        ));

        var ok = Assert.IsType<OkObjectResult>(createResult.Result);
        var template = Assert.IsType<WhatsAppTemplateDto>(ok.Value);

        Assert.Equal("monthly_renewal_reminder", template.Name);
        Assert.Equal("UTILITY", template.Category);

        var inDb = await context.WhatsAppTemplates.FirstOrDefaultAsync(t => t.Name == "monthly_renewal_reminder");
        Assert.NotNull(inDb);
    }

    [Fact]
    public async Task WhatsAppApi_GymWorkflows_ShareWorkoutAndBmiReport_ShouldDispatch()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        var member = new Member
        {
            TenantId = tenantId,
            FirstName = "Karan",
            LastName = "Mehta",
            Email = "karan@gym.com",
            Phone = "919876599999",
            MemberCode = "GIX-105",
            Status = MemberStatus.Active
        };
        context.Members.Add(member);
        await context.SaveChangesAsync();

        // 1. Share Workout Split
        var workoutResult = await controller.ShareWorkoutSplit(new ShareWorkoutSplitRequest(
            MemberId: member.Id,
            SplitTitle: "Hypertrophy Push Split",
            Exercises: new List<string> { "Incline Dumbbell Press (4x10)", "Overhead Triceps Extension (3x12)" },
            TrainerNotes: "Keep elbow flares under 45 degrees."
        ));
        Assert.IsType<OkObjectResult>(workoutResult);

        // 2. Send BMI Report
        var bmiResult = await controller.SendBmiReport(new SendBmiReportRequest(
            MemberId: member.Id,
            WeightKg: 78.5m,
            HeightCm: 180m,
            Bmi: 24.2m,
            BodyFatPercentage: 14.5m,
            AssessmentSummary: "Lean mass gained +1.2kg."
        ));
        Assert.IsType<OkObjectResult>(bmiResult);

        var messages = await context.WhatsAppMessages.Where(m => m.MemberId == member.Id).ToListAsync();
        Assert.Equal(2, messages.Count);
        Assert.Contains(messages, m => m.MessageContent.Contains("Hypertrophy Push Split"));
        Assert.Contains(messages, m => m.MessageContent.Contains("Titan Fitness Biometrics Update"));
    }

    [Fact]
    public async Task WhatsAppApi_WebhookReceiver_ShouldBeIdempotentAndProcessInboundMessages()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        var member = new Member
        {
            TenantId = tenantId,
            FirstName = "Sneha",
            LastName = "Kapoor",
            Email = "sneha@gym.com",
            Phone = "919876500123",
            MemberCode = "GIX-109",
            Status = MemberStatus.Active
        };
        context.Members.Add(member);
        await context.SaveChangesAsync();

        var webhookJson = @"{
            ""object"": ""whatsapp_business_account"",
            ""entry"": [
                {
                    ""id"": ""109283746592837"",
                    ""changes"": [
                        {
                            ""value"": {
                                ""messaging_product"": ""whatsapp"",
                                ""messages"": [
                                    {
                                        ""from"": ""919876500123"",
                                        ""id"": ""wamid.INBOUND_TEST_101"",
                                        ""timestamp"": ""1710000000"",
                                        ""text"": {
                                            ""body"": ""Can I book a personal training slot tomorrow?""
                                        },
                                        ""type"": ""text""
                                    }
                                ]
                            },
                            ""field"": ""messages""
                        }
                    ]
                }
            ]
        }";

        using var doc = JsonDocument.Parse(webhookJson);

        // 1. First execution: should ingest message
        var firstResult = await controller.ReceiveWebhook(doc.RootElement);
        var ok1 = Assert.IsType<OkObjectResult>(firstResult);

        var storedMsg = await context.WhatsAppMessages.FirstOrDefaultAsync(m => m.WamId == "wamid.INBOUND_TEST_101");
        Assert.NotNull(storedMsg);
        Assert.Equal("Can I book a personal training slot tomorrow?", storedMsg.MessageContent);
        Assert.Equal(WhatsAppDirection.Inbound, storedMsg.Direction);
        Assert.Equal(member.Id, storedMsg.MemberId);

        // 2. Second execution with identical message id: should be idempotent (prevent duplicate)
        var secondResult = await controller.ReceiveWebhook(doc.RootElement);
        var ok2 = Assert.IsType<OkObjectResult>(secondResult);

        var count = await context.WhatsAppMessages.CountAsync(m => m.WamId == "wamid.INBOUND_TEST_101");
        Assert.Equal(1, count); // Exactly 1, no duplicate
    }
}
