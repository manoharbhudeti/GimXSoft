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
}
