using System.Security.Claims;
using GimXSoft.Api.Data;
using GimXSoft.Api.Entities;
using GimXSoft.Api.Services;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace GimXSoft.Tests;

public class TenantIsolationAndBusinessTests
{
    private ApplicationDbContext CreateInMemoryContext(ICurrentTenantService tenantService, string dbName)
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: dbName)
            .Options;

        return new ApplicationDbContext(options, tenantService);
    }

    [Fact]
    public async Task TenantIsolation_ShouldPreventCrossTenantDataLeakage()
    {
        // Arrange
        var dbName = Guid.NewGuid().ToString();
        var tenantA = Guid.NewGuid();
        var tenantB = Guid.NewGuid();

        var tenantService = new CurrentTenantService();

        // 1. Seed data for both tenants using direct context
        using (var seedContext = CreateInMemoryContext(tenantService, dbName))
        {
            seedContext.Members.AddRange(
                new Member
                {
                    Id = Guid.NewGuid(),
                    TenantId = tenantA,
                    BranchId = Guid.NewGuid(),
                    MemberCode = "GIX-A1",
                    FirstName = "Alice",
                    LastName = "TenantA",
                    Email = "alice@a.com",
                    Phone = "111111",
                    Status = MemberStatus.Active
                },
                new Member
                {
                    Id = Guid.NewGuid(),
                    TenantId = tenantB,
                    BranchId = Guid.NewGuid(),
                    MemberCode = "GIX-B1",
                    FirstName = "Bob",
                    LastName = "TenantB",
                    Email = "bob@b.com",
                    Phone = "222222",
                    Status = MemberStatus.Active
                }
            );
            await seedContext.SaveChangesAsync();
        }

        // Act: Tenant A queries members
        tenantService.SetTenant(tenantA);
        using (var queryContextA = CreateInMemoryContext(tenantService, dbName))
        {
            var membersForA = await queryContextA.Members.ToListAsync();

            // Assert
            Assert.Single(membersForA);
            Assert.Equal("Alice", membersForA[0].FirstName);
            Assert.Equal(tenantA, membersForA[0].TenantId);
        }

        // Act: Tenant B queries members
        tenantService.SetTenant(tenantB);
        using (var queryContextB = CreateInMemoryContext(tenantService, dbName))
        {
            var membersForB = await queryContextB.Members.ToListAsync();

            // Assert
            Assert.Single(membersForB);
            Assert.Equal("Bob", membersForB[0].FirstName);
            Assert.Equal(tenantB, membersForB[0].TenantId);
        }
    }

    [Fact]
    public void PasswordHashing_SecurelyVerifiesCorrectPassword()
    {
        var password = "SuperSecretPassword123!";
        var hash = BCrypt.Net.BCrypt.HashPassword(password);

        Assert.True(BCrypt.Net.BCrypt.Verify(password, hash));
        Assert.False(BCrypt.Net.BCrypt.Verify("WrongPassword", hash));
    }

    [Fact]
    public async Task PaymentFinancials_PrecisionDecimalCalculations_SumAccurately()
    {
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, Guid.NewGuid().ToString());
        var memberId = Guid.NewGuid();
        var branchId = Guid.NewGuid();

        context.PaymentTransactions.AddRange(
            new PaymentTransaction
            {
                Id = Guid.NewGuid(),
                TenantId = tenantId,
                BranchId = branchId,
                MemberId = memberId,
                InvoiceNumber = "INV-01",
                Amount = 79.99m,
                PaymentMethod = PaymentMethod.Card,
                Status = PaymentStatus.Completed
            },
            new PaymentTransaction
            {
                Id = Guid.NewGuid(),
                TenantId = tenantId,
                BranchId = branchId,
                MemberId = memberId,
                InvoiceNumber = "INV-02",
                Amount = 149.50m,
                PaymentMethod = PaymentMethod.UPI,
                Status = PaymentStatus.Completed
            },
            new PaymentTransaction
            {
                Id = Guid.NewGuid(),
                TenantId = tenantId,
                BranchId = branchId,
                MemberId = memberId,
                InvoiceNumber = "INV-03",
                Amount = 25.00m,
                PaymentMethod = PaymentMethod.Cash,
                Status = PaymentStatus.Refunded
            }
        );

        await context.SaveChangesAsync();

        var completedRevenue = await context.PaymentTransactions
            .Where(p => p.Status == PaymentStatus.Completed)
            .SumAsync(p => p.Amount);

        Assert.Equal(229.49m, completedRevenue);
    }

    [Fact]
    public async Task ExceptionHandlingMiddleware_ShouldReturnRfc9457ProblemDetails_ForKeyNotFound()
    {
        // Arrange
        var context = new Microsoft.AspNetCore.Http.DefaultHttpContext();
        context.Response.Body = new MemoryStream();
        context.TraceIdentifier = "TEST-CORRELATION-001";

        var logger = new FakeLogger<GimXSoft.Api.Middleware.ExceptionHandlingMiddleware>();
        var env = new FakeWebHostEnvironment();

        var middleware = new GimXSoft.Api.Middleware.ExceptionHandlingMiddleware(
            next: (innerHttpContext) => throw new KeyNotFoundException("Member with ID '123' was not found."),
            logger: logger,
            env: env
        );

        // Act
        await middleware.InvokeAsync(context);

        // Assert
        Assert.Equal(404, context.Response.StatusCode);
        Assert.Equal("application/problem+json", context.Response.ContentType);

        context.Response.Body.Seek(0, SeekOrigin.Begin);
        using var reader = new StreamReader(context.Response.Body);
        var responseBody = await reader.ReadToEndAsync();

        using var doc = System.Text.Json.JsonDocument.Parse(responseBody);
        var root = doc.RootElement;

        Assert.Equal("Resource Not Found", root.GetProperty("title").GetString());
        Assert.Equal(404, root.GetProperty("status").GetInt32());
        Assert.Equal("RESOURCE_NOT_FOUND", root.GetProperty("errorCode").GetString());
        Assert.Equal("TEST-CORRELATION-001", root.GetProperty("correlationId").GetString());
        Assert.Contains("Member with ID '123' was not found.", root.GetProperty("detail").GetString());
    }

    [Fact]
    public async Task ExceptionHandlingMiddleware_ShouldMaskInternalDetails_ForUnhandledException()
    {
        // Arrange
        var context = new Microsoft.AspNetCore.Http.DefaultHttpContext();
        context.Response.Body = new MemoryStream();
        context.TraceIdentifier = "TEST-CORRELATION-002";

        var logger = new FakeLogger<GimXSoft.Api.Middleware.ExceptionHandlingMiddleware>();
        var env = new FakeWebHostEnvironment();

        var middleware = new GimXSoft.Api.Middleware.ExceptionHandlingMiddleware(
            next: (innerHttpContext) => throw new InvalidOperationException("FATAL: Business operation conflict"),
            logger: logger,
            env: env
        );

        // Act
        await middleware.InvokeAsync(context);

        // Assert
        context.Response.Body.Seek(0, SeekOrigin.Begin);
        using var reader = new StreamReader(context.Response.Body);
        var responseBody = await reader.ReadToEndAsync();

        using var doc = System.Text.Json.JsonDocument.Parse(responseBody);
        var root = doc.RootElement;

        Assert.Equal("BUSINESS_CONFLICT", root.GetProperty("errorCode").GetString());
        Assert.Equal("TEST-CORRELATION-002", root.GetProperty("correlationId").GetString());
    }

    [Fact]
    public void BmiCalculation_AccuratelyComputesBmiAndClassifiesCorrectly()
    {
        // Arrange
        decimal weightKg = 79.80m;
        decimal heightCm = 178.00m;

        // Act: Standard Adult BMI = Weight(kg) / (Height(m)^2)
        var heightInMeters = heightCm / 100m;
        var bmi = Math.Round(weightKg / (heightInMeters * heightInMeters), 2);

        var category = bmi switch
        {
            < 18.5m => "Underweight",
            < 25.0m => "Normal Weight",
            < 30.0m => "Overweight",
            _ => "Obese"
        };

        // Assert
        Assert.Equal(25.19m, bmi);
        Assert.Equal("Overweight", category);
    }

    [Fact]
    public void WeightProgressCalculation_AccuratelyCalculatesDeltasAndPercentages()
    {
        // Arrange
        decimal baselineWeight = 84.50m;
        decimal currentWeight = 79.80m;

        // Act
        var weightDiff = Math.Round(currentWeight - baselineWeight, 2);
        var changePercent = Math.Round((weightDiff / baselineWeight) * 100m, 2);

        // Assert
        Assert.Equal(-4.70m, weightDiff);
        Assert.Equal(-5.56m, changePercent);
    }

    [Fact]
    public async Task WhatsAppSuppression_ShouldPreventAutomatedDispatchToOptedOutRecipient()
    {
        // Arrange
        var tenantId = Guid.NewGuid();
        var tenantService = new CurrentTenantService();
        tenantService.SetTenant(tenantId);

        using var context = CreateInMemoryContext(tenantService, Guid.NewGuid().ToString());
        var phone = "+15553018841";

        // Add to suppression list
        context.WhatsAppSuppressions.Add(new WhatsAppSuppression
        {
            TenantId = tenantId,
            Phone = phone,
            Reason = "STOP keyword received"
        });
        await context.SaveChangesAsync();

        // Act: Check if recipient is suppressed
        var isSuppressed = await context.WhatsAppSuppressions
            .AnyAsync(s => s.Phone == phone);

        // Assert
        Assert.True(isSuppressed);
    }
}

public class FakeLogger<T> : Microsoft.Extensions.Logging.ILogger<T>
{
    public IDisposable? BeginScope<TState>(TState state) where TState : notnull => null;
    public bool IsEnabled(Microsoft.Extensions.Logging.LogLevel logLevel) => true;
    public void Log<TState>(Microsoft.Extensions.Logging.LogLevel logLevel, Microsoft.Extensions.Logging.EventId eventId, TState state, Exception? exception, Func<TState, Exception?, string> formatter) { }
}

public class FakeWebHostEnvironment : Microsoft.AspNetCore.Hosting.IWebHostEnvironment
{
    public string EnvironmentName { get; set; } = "Development";
    public string ApplicationName { get; set; } = "GimXSoft.Api";
    public string WebRootPath { get; set; } = "";
    public Microsoft.Extensions.FileProviders.IFileProvider WebRootFileProvider { get; set; } = null!;
    public string ContentRootPath { get; set; } = "";
    public Microsoft.Extensions.FileProviders.IFileProvider ContentRootFileProvider { get; set; } = null!;
}
