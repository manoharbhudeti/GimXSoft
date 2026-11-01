namespace GimXSoft.Api.Services;

public interface ICurrentTenantService
{
    Guid? TenantId { get; set; }
    Guid? BranchId { get; set; }
    Guid? UserId { get; set; }
    string? UserRole { get; set; }
    void SetTenant(Guid tenantId);
    void SetBranch(Guid? branchId);
}

public class CurrentTenantService : ICurrentTenantService
{
    public Guid? TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public Guid? UserId { get; set; }
    public string? UserRole { get; set; }

    public void SetTenant(Guid tenantId)
    {
        TenantId = tenantId;
    }

    public void SetBranch(Guid? branchId)
    {
        BranchId = branchId;
    }
}

