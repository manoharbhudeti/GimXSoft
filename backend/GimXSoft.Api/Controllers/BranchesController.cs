using GimXSoft.Api.Data;
using GimXSoft.Api.DTOs;
using GimXSoft.Api.Entities;
using GimXSoft.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GimXSoft.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BranchesController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public BranchesController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet]
    public async Task<ActionResult<List<BranchDto>>> GetBranches()
    {
        var branches = await _context.Branches
            .OrderBy(b => b.Name)
            .Select(b => new BranchDto(
                b.Id,
                b.TenantId,
                b.Name,
                b.Code,
                b.Address,
                b.City,
                b.Phone,
                b.Email,
                b.IsActive,
                b.CreatedAt
            ))
            .ToListAsync();

        return Ok(branches);
    }

    [HttpPost]
    public async Task<ActionResult<BranchDto>> CreateBranch([FromBody] CreateBranchRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();

        var branch = new Branch
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            Name = request.Name.Trim(),
            Code = request.Code.Trim().ToUpper(),
            Address = request.Address ?? "",
            City = request.City ?? "",
            Phone = request.Phone ?? "",
            Email = request.Email ?? "",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.Branches.Add(branch);
        await _context.SaveChangesAsync();

        return Ok(new BranchDto(
            branch.Id,
            branch.TenantId,
            branch.Name,
            branch.Code,
            branch.Address,
            branch.City,
            branch.Phone,
            branch.Email,
            branch.IsActive,
            branch.CreatedAt
        ));
    }
}

