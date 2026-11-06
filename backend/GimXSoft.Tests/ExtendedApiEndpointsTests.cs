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

public class ExtendedApiEndpointsTests
{
    private ApplicationDbContext CreateInMemoryContext(ICurrentTenantService tenantService, string dbName)
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: dbName)
            .Options;

        return new ApplicationDbContext(options, tenantService);
    }

    [Fact]
    public async Task LeadsApi_ShouldSupportFullPipeline_AndConversionToMember()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var branchId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        context.Tenants.Add(new Tenant { Id = tenantId, Name = "Titan Gym", Slug = "titan-gym" });
        context.Branches.Add(new Branch { Id = branchId, TenantId = tenantId, Name = "Downtown Flagship", Code = "DT01" });
        await context.SaveChangesAsync();

        var controller = new LeadsController(context, tenantService);

        // 1. Create Lead via Staff API
        var createResult = await controller.CreateLead(new CreateLeadRequest(
            BranchId: branchId,
            FullName: "Rohit Sharma",
            Email: "rohit@cricket.com",
            Phone: "9876543210",
            Source: LeadSource.WalkIn,
            AssignedStaffId: null,
            Notes: "Interested in strength training",
            NextFollowUpDate: DateTime.UtcNow.AddDays(2),
            EstimatedValue: 2000m
        ));

        var created = Assert.IsType<CreatedAtActionResult>(createResult.Result);
        var leadDto = Assert.IsType<LeadDto>(created.Value);
        Assert.Equal("Rohit Sharma", leadDto.FullName);
        Assert.Equal("New", leadDto.Stage);

        // 2. Add Activity
        var actResult = await controller.AddActivity(leadDto.Id, new AddLeadActivityRequest("Call", "Spoke on phone, scheduled trial"));
        var actOk = Assert.IsType<OkObjectResult>(actResult.Result);
        var actDto = Assert.IsType<LeadActivityDto>(actOk.Value);
        Assert.Equal("Call", actDto.ActivityType);

        // 3. Update Stage
        var stageResult = await controller.UpdateLeadStage(leadDto.Id, new UpdateLeadStageRequest(LeadStage.TrialScheduled, "Trial booked for tomorrow"));
        Assert.IsType<OkObjectResult>(stageResult);

        // 4. Convert Lead to Member
        var convResult = await controller.ConvertToMember(leadDto.Id, new ConvertLeadRequest(
            InitialPlanId: null,
            BranchId: branchId,
            EmergencyContactName: "Pooja Sharma",
            EmergencyContactPhone: "9876543211",
            Address: "Mumbai Stadium Area"
        ));

        var memberResult = Assert.IsType<OkObjectResult>(convResult.Result);
        var memberDto = Assert.IsType<MemberDto>(memberResult.Value);
        Assert.Equal("Rohit", memberDto.FirstName);
        Assert.Equal("Sharma", memberDto.LastName);
        Assert.StartsWith("GIX-", memberDto.MemberCode);

        // Verify lead is marked Converted
        var updatedLead = await context.Leads.FindAsync(leadDto.Id);
        Assert.NotNull(updatedLead);
        Assert.Equal(LeadStage.Converted, updatedLead.Stage);
    }

    [Fact]
    public async Task LeadsApi_PublicInquiry_ShouldRecordLeadWithoutAuth()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();

        using var context = CreateInMemoryContext(tenantService, dbName);
        context.Tenants.Add(new Tenant { Id = tenantId, Name = "Titan Gym", Slug = "titan-gym" });
        context.Branches.Add(new Branch { Id = Guid.NewGuid(), TenantId = tenantId, Name = "Flagship", Code = "FS" });
        await context.SaveChangesAsync();

        var controller = new LeadsController(context, tenantService);

        var result = await controller.SubmitPublicInquiry(new PublicInquiryRequest(
            FullName: "Kavita Rao",
            Email: "kavita@studio.in",
            Phone: "9988776655",
            GymName: "Zenith Crossfit",
            MemberRange: "200-800",
            Message: "Need turnstile integration demo"
        ));

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.NotNull(ok.Value);

        var lead = await context.Leads.FirstOrDefaultAsync(l => l.Email == "kavita@studio.in");
        Assert.NotNull(lead);
        Assert.Equal("Kavita Rao", lead.FullName);
        Assert.Contains("Zenith Crossfit", lead.Notes);
    }

    [Fact]
    public async Task WhatsAppApi_ToggleTrigger_AndQuickSend_ShouldOperateCorrectly()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        // 1. Toggle Trigger
        var toggleResult = await controller.ToggleTrigger(new ToggleTriggerRequest("check_in_welcome", true));
        var ok = Assert.IsType<OkObjectResult>(toggleResult);
        Assert.NotNull(ok.Value);

        var rule = await context.WhatsAppTriggerRules.FirstOrDefaultAsync(r => r.TriggerEvent == "check_in_welcome");
        Assert.NotNull(rule);
        Assert.True(rule.IsEnabled);

        // 2. Quick Send Message
        var quickResult = await controller.QuickSend(new QuickSendWhatsAppRequest(
            RecipientPhone: "+91 98765 00000",
            RecipientName: "Athlete Test",
            Message: "Workout reminder for leg day",
            MemberId: null
        ));

        Assert.IsType<OkObjectResult>(quickResult);
        var msg = await context.WhatsAppMessages.FirstOrDefaultAsync(m => m.RecipientPhone == "919876500000");
        Assert.NotNull(msg);
        Assert.Equal(WhatsAppMessageStatus.Sent, msg.Status);
    }

    [Fact]
    public async Task PaymentsApi_TaxInvoice_ShouldCalculateIndianGstCorrectly()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var paymentId = Guid.NewGuid();
        var memberId = Guid.NewGuid();
        var branchId = Guid.NewGuid();

        context.Tenants.Add(new Tenant { Id = tenantId, Name = "GimXSoft Titan Club", Slug = "titan" });
        context.Branches.Add(new Branch { Id = branchId, TenantId = tenantId, Name = "Main Branch", Code = "MB" });
        context.Members.Add(new Member
        {
            Id = memberId,
            TenantId = tenantId,
            BranchId = branchId,
            MemberCode = "GIX-1001",
            FirstName = "Ananya",
            LastName = "Iyer",
            Email = "ananya@test.com",
            Phone = "9876543210"
        });

        context.PaymentTransactions.Add(new PaymentTransaction
        {
            Id = paymentId,
            TenantId = tenantId,
            BranchId = branchId,
            MemberId = memberId,
            InvoiceNumber = "INV-2026-1001",
            Amount = 2000.00m,
            PaymentMethod = PaymentMethod.UPI,
            Status = PaymentStatus.Completed,
            Notes = "1-Month SaaS Membership",
            CreatedAt = DateTime.UtcNow
        });
        await context.SaveChangesAsync();

        var controller = new PaymentsController(context, tenantService);

        // Get Tax Invoice
        var result = await controller.GetTaxInvoice(paymentId);
        var ok = Assert.IsType<OkObjectResult>(result.Result);
        var invoice = Assert.IsType<TaxInvoiceDto>(ok.Value);

        Assert.Equal("INV-2026-1001", invoice.InvoiceNumber);
        Assert.Equal(2000.00m, invoice.TotalAmount);
        Assert.Equal("999723", invoice.SacCode); // Gymnasium / fitness services SAC
        Assert.True(invoice.Subtotal > 0 && invoice.Subtotal < 2000.00m);
        Assert.Equal(invoice.CgstAmount, invoice.SgstAmount); // 9% CGST + 9% SGST
        Assert.Equal(2000.00m, invoice.Subtotal + invoice.CgstAmount + invoice.SgstAmount);
    }

    [Fact]
    public async Task AttendanceApi_LiveOccupancy_AndSimulation_ShouldReturnAccurateTelemetry()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new AttendanceController(context, tenantService);

        // 1. Live Occupancy
        var occupancyResult = await controller.GetLiveOccupancy(null);
        var ok = Assert.IsType<OkObjectResult>(occupancyResult.Result);
        var live = Assert.IsType<LiveOccupancyDto>(ok.Value);

        Assert.True(live.CurrentOccupancy > 0);
        Assert.Equal(120, live.MaximumCapacity);
        Assert.NotNull(live.Status);

        // 2. Simulate Turnstile Scan
        var scanResult = await controller.SimulateScan(new SimulateScanRequest(null, "TURNSTILE_01"));
        var scanOk = Assert.IsType<OkObjectResult>(scanResult.Result);
        var scan = Assert.IsType<SimulateScanResponse>(scanOk.Value);

        Assert.True(scan.AccessGranted);
        Assert.NotNull(scan.MemberName);
        Assert.NotNull(scan.MemberCode);
        Assert.True(scan.NewOccupancy > live.CurrentOccupancy);
    }

    [Fact]
    public void ReportsApi_RoiCalculator_ShouldCalculateAccurateRevenueRecovery()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantService = new CurrentTenantService();

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new ReportsController(context, tenantService);

        var result = controller.CalculateRoi(new RoiCalculationRequest(
            MemberCount: 500,
            AverageMonthlyFee: 2000.00m,
            CurrentChurnRatePercent: 5.0m
        ));

        var ok = Assert.IsType<OkObjectResult>(result.Result);
        var roi = Assert.IsType<RoiCalculationResultDto>(ok.Value);

        Assert.Equal(500, roi.TotalMembers);
        Assert.Equal(2000.00m, roi.AverageMonthlyFee);
        Assert.Equal(40, roi.EquivalentRetainedMembersYearly); // 500 * (4.2% + 3.8%) = 40 members
        Assert.Equal(960000.00m, roi.AnnualRevenueRecovered); // 40 * 2000 * 12 = 960,000
        Assert.Equal(2000.00m, roi.PlatformCostAnnual);
        Assert.Equal(480.0m, roi.NetRoiMultiple); // 960,000 / 2,000 = 480x ROI!
    }

    [Fact]
    public async Task AuditLogsApi_ShouldRecordAndQuerySystemEvents()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new AuditLogsController(context, tenantService);

        // 1. Create Audit Log
        var createResult = await controller.CreateAuditLog(new CreateAuditLogRequest(
            Action: "TurnstileConfigured",
            EntityName: "TurnstileTerminal",
            EntityId: "GATE_01",
            Details: "Baud rate set to 9600, RFID anti-passback enabled"
        ));

        var created = Assert.IsType<CreatedAtActionResult>(createResult.Result);
        var logDto = Assert.IsType<AuditLogDto>(created.Value);
        Assert.Equal("TurnstileConfigured", logDto.Action);

        // 2. Query Audit Logs
        var listResult = await controller.GetAuditLogs(null, null, null, null, null);
        var ok = Assert.IsType<OkObjectResult>(listResult.Result);
        var logs = Assert.IsType<List<AuditLogDto>>(ok.Value);
        Assert.Single(logs);
        Assert.Equal("TurnstileTerminal", logs[0].EntityName);
    }
}
