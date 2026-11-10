using Microsoft.AspNetCore.SignalR;

namespace GimXSoft.Api.Hubs;

public interface IWhatsAppHubClient
{
    Task ReceiveIncomingMessage(object message);
    Task MessageStatusUpdated(string messageId, string wamId, string status);
    Task CampaignProgressUpdated(Guid campaignId, int sent, int delivered, int read, int failed, string status);
    Task ConnectionHealthChanged(string connectionStatus, string healthStatus, string? qualityRating);
}

public class WhatsAppHub : Hub<IWhatsAppHubClient>
{
    private readonly ILogger<WhatsAppHub> _logger;

    public WhatsAppHub(ILogger<WhatsAppHub> logger)
    {
        _logger = logger;
    }

    public async Task JoinTenantGroup(string tenantId)
    {
        if (string.IsNullOrWhiteSpace(tenantId)) return;
        await Groups.AddToGroupAsync(Context.ConnectionId, $"Tenant_{tenantId}");
        _logger.LogInformation("Connection {ConnectionId} joined tenant group {TenantGroup}", Context.ConnectionId, $"Tenant_{tenantId}");
    }

    public async Task LeaveTenantGroup(string tenantId)
    {
        if (string.IsNullOrWhiteSpace(tenantId)) return;
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"Tenant_{tenantId}");
        _logger.LogInformation("Connection {ConnectionId} left tenant group {TenantGroup}", Context.ConnectionId, $"Tenant_{tenantId}");
    }
}

