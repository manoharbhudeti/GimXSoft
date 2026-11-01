using System.Security.Claims;
using GimXSoft.Api.Services;

namespace GimXSoft.Api.Middleware;

public class TenantResolutionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<TenantResolutionMiddleware> _logger;

    public TenantResolutionMiddleware(RequestDelegate next, ILogger<TenantResolutionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context, ICurrentTenantService tenantService)
    {
        // 1. Resolve Tenant ID from Claims (JWT)
        var user = context.User;
        if (user.Identity?.IsAuthenticated == true)
        {
            var tenantClaim = user.FindFirst("tenant_id")?.Value;
            if (!string.IsNullOrEmpty(tenantClaim) && Guid.TryParse(tenantClaim, out var tenantGuid))
            {
                tenantService.SetTenant(tenantGuid);
            }

            var userGuidClaim = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userGuidClaim) && Guid.TryParse(userGuidClaim, out var userGuid))
            {
                tenantService.UserId = userGuid;
            }

            tenantService.UserRole = user.FindFirst(ClaimTypes.Role)?.Value;

            var branchClaim = user.FindFirst("branch_id")?.Value;
            if (!string.IsNullOrEmpty(branchClaim) && Guid.TryParse(branchClaim, out var branchGuid))
            {
                tenantService.SetBranch(branchGuid);
            }
        }

        // 2. Fallback to header if not already resolved from JWT
        if (!tenantService.TenantId.HasValue)
        {
            if (context.Request.Headers.TryGetValue("X-Tenant-Id", out var headerTenant) &&
                Guid.TryParse(headerTenant.ToString(), out var headerTenantGuid))
            {
                tenantService.SetTenant(headerTenantGuid);
            }
        }

        // 3. Fallback or override branch filter from header
        if (context.Request.Headers.TryGetValue("X-Branch-Id", out var headerBranch) &&
            Guid.TryParse(headerBranch.ToString(), out var headerBranchGuid))
        {
            tenantService.SetBranch(headerBranchGuid);
        }

        await _next(context);
    }
}

