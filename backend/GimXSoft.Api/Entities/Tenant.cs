using System.ComponentModel.DataAnnotations;

namespace GimXSoft.Api.Entities;

public class Tenant
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string Slug { get; set; } = string.Empty;

    [MaxLength(255)]
    public string? LogoUrl { get; set; }

    [MaxLength(50)]
    public string SubscriptionPlan { get; set; } = "Enterprise Pro"; // Starter, Growth, Enterprise Pro

    [MaxLength(20)]
    public string SubscriptionStatus { get; set; } = "Active"; // Active, PastDue, Suspended

    public int MaxBranches { get; set; } = 5;
    public int MaxMembers { get; set; } = 2500;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public ICollection<Branch> Branches { get; set; } = new List<Branch>();
    public ICollection<User> Users { get; set; } = new List<User>();
}

public class Branch
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TenantId { get; set; }

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [Required]
    [MaxLength(20)]
    public string Code { get; set; } = string.Empty;

    [MaxLength(200)]
    public string Address { get; set; } = string.Empty;

    [MaxLength(100)]
    public string City { get; set; } = string.Empty;

    [MaxLength(20)]
    public string Phone { get; set; } = string.Empty;

    [MaxLength(100)]
    public string Email { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Tenant? Tenant { get; set; }
}

