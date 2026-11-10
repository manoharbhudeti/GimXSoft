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

public class WhatsAppOnboardingTests
{
    private static ApplicationDbContext CreateInMemoryContext(ICurrentTenantService tenantService, string dbName)
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: dbName)
            .Options;

        return new ApplicationDbContext(options, tenantService);
    }

    [Fact]
    public async Task InitiateOnboarding_ValidPhone_CreatesVerificationSessionAndReturnsMaskedPhone()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        var request = new InitiateOnboardingRequest(
            CountryCode: "+91",
            PhoneNumber: "9876543210",
            BusinessName: "Powerhouse Gym",
            VerificationMethod: "SMS"
        );

        var actionResult = await controller.InitiateOnboarding(request);
        var okResult = Assert.IsType<OkObjectResult>(actionResult.Result);
        var response = Assert.IsType<InitiateOnboardingResponse>(okResult.Value);

        Assert.True(response.Success);
        Assert.False(string.IsNullOrWhiteSpace(response.SessionId));
        Assert.False(string.IsNullOrWhiteSpace(response.VerificationCode));
        Assert.Contains("+91", response.MaskedPhoneNumber);

        // Verify stored in DB
        var integration = await context.WhatsAppIntegrations.FirstOrDefaultAsync(i => i.TenantId == tenantId);
        Assert.NotNull(integration);
        Assert.Equal("+919876543210", integration.DisplayPhoneNumber);
        Assert.Equal(WhatsAppConnectionStatus.VerificationPending, integration.ConnectionStatus);
        Assert.Equal("Powerhouse Gym", integration.BusinessPortfolioName);
        Assert.Equal(response.VerificationCode, integration.VerificationCode);
    }

    [Fact]
    public async Task InitiateOnboarding_InvalidPhoneNumber_ReturnsBadRequest()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        var request = new InitiateOnboardingRequest(
            CountryCode: "+91",
            PhoneNumber: "123", // too short
            BusinessName: "Test Gym"
        );

        var actionResult = await controller.InitiateOnboarding(request);
        Assert.IsType<BadRequestObjectResult>(actionResult.Result);
    }

    [Fact]
    public async Task VerifyOtpCode_ValidCode_RegistersNumberAndMarksConnected()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        // Step 1: Initiate
        var initResult = await controller.InitiateOnboarding(new InitiateOnboardingRequest("+91", "9876543210", "Iron Gym"));
        var initResponse = Assert.IsType<InitiateOnboardingResponse>(((OkObjectResult)initResult.Result!).Value);

        // Step 2: Verify with correct OTP
        var verifyResult = await controller.VerifyOtpCode(new VerifyOtpRequest(
            SessionId: initResponse.SessionId,
            Code: initResponse.VerificationCode!,
            RegistrationPin: "654321"
        ));

        var okVerify = Assert.IsType<OkObjectResult>(verifyResult.Result);
        var verifyResponse = Assert.IsType<VerifyOtpResponse>(okVerify.Value);

        Assert.True(verifyResponse.Success);
        Assert.NotNull(verifyResponse.Integration);
        Assert.Equal("Connected", verifyResponse.Integration.ConnectionStatus);
        Assert.Equal("HEALTHY", verifyResponse.Integration.HealthStatus);
        Assert.Equal("OPERATIONAL", verifyResponse.Integration.WebhookStatus);

        // Check DB state
        var integration = await context.WhatsAppIntegrations.FirstAsync(i => i.TenantId == tenantId);
        Assert.Equal(WhatsAppConnectionStatus.Connected, integration.ConnectionStatus);
        Assert.Null(integration.VerificationCode); // code cleared
        Assert.Null(integration.VerificationSessionId); // session cleared
    }

    [Fact]
    public async Task VerifyOtpCode_InvalidCode_ReturnsBadRequest()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        // Step 1: Initiate
        var initResult = await controller.InitiateOnboarding(new InitiateOnboardingRequest("+91", "9876543210", "Iron Gym"));
        var initResponse = Assert.IsType<InitiateOnboardingResponse>(((OkObjectResult)initResult.Result!).Value);

        // Step 2: Verify with wrong OTP
        var verifyResult = await controller.VerifyOtpCode(new VerifyOtpRequest(
            SessionId: initResponse.SessionId,
            Code: "000000" // wrong
        ));

        Assert.IsType<BadRequestObjectResult>(verifyResult.Result);
    }

    [Fact]
    public async Task ResendOtpCode_ActiveSession_RegeneratesOtp()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        // Step 1: Initiate
        var initResult = await controller.InitiateOnboarding(new InitiateOnboardingRequest("+91", "9876543210", "Iron Gym"));
        var initResponse = Assert.IsType<InitiateOnboardingResponse>(((OkObjectResult)initResult.Result!).Value);
        var firstOtp = initResponse.VerificationCode;

        // Step 2: Resend
        var resendResult = await controller.ResendOtpCode(new ResendOtpRequest(initResponse.SessionId, "SMS"));
        var okResend = Assert.IsType<OkObjectResult>(resendResult.Result);
        var resendResponse = Assert.IsType<InitiateOnboardingResponse>(okResend.Value);

        Assert.True(resendResponse.Success);
        Assert.NotNull(resendResponse.VerificationCode);
    }

    [Fact]
    public async Task GetConnectionHealth_ReturnsOperationalStatus()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        // Seed an active integration
        context.WhatsAppIntegrations.Add(new WhatsAppIntegration
        {
            TenantId = tenantId,
            ConnectionStatus = WhatsAppConnectionStatus.Connected,
            HealthStatus = "HEALTHY",
            MessagingLimitTier = "TIER_10K",
            WebhookStatus = "OPERATIONAL"
        });
        await context.SaveChangesAsync();

        var healthResult = await controller.GetConnectionHealth();
        var ok = Assert.IsType<OkObjectResult>(healthResult.Result);
        var health = Assert.IsType<ConnectionHealthDto>(ok.Value);

        Assert.Equal("Connected", health.Status);
        Assert.Equal("HEALTHY", health.HealthRating);
        Assert.True(health.WebhooksOperational);
        Assert.Equal(10000, health.DailyLimit);
    }

    [Fact]
    public async Task DisconnectConfig_SetsDisconnectedStatus()
    {
        var dbName = Guid.NewGuid().ToString();
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, dbName);
        var controller = new WhatsAppController(context, tenantService, NullLogger<WhatsAppController>.Instance);

        context.WhatsAppIntegrations.Add(new WhatsAppIntegration
        {
            TenantId = tenantId,
            ConnectionStatus = WhatsAppConnectionStatus.Connected,
            HealthStatus = "HEALTHY"
        });
        await context.SaveChangesAsync();

        var result = await controller.DisconnectConfig();
        Assert.IsType<OkObjectResult>(result);

        var integration = await context.WhatsAppIntegrations.FirstAsync(i => i.TenantId == tenantId);
        Assert.Equal(WhatsAppConnectionStatus.Disconnected, integration.ConnectionStatus);
        Assert.Equal("DISCONNECTED", integration.HealthStatus);
    }
}

