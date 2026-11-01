# GIMXSOFT - System Architecture & Engineering Specification

## 1. Overview
GIMXSOFT is an enterprise-grade, multi-tenant SaaS application designed for modern fitness clubs, gym franchises, boutique studios, and wellness centers. It integrates a Flutter Web frontend with an ASP.NET Core 9 Web API backend.

---

## 2. Architecture Diagram

```mermaid
graph TD
    Client[Flutter Web Client (Desktop / Tablet / Mobile)] -->|HTTPS / REST API + JWT| Gateway[ASP.NET Core Web API 9.0]
    
    subgraph Security & Middleware
        Gateway --> ExMid[ExceptionHandlingMiddleware]
        ExMid --> CorsMid[CORS Policy Engine]
        CorsMid --> JwtAuth[JWT Bearer Authentication]
        JwtAuth --> TenMid[TenantResolutionMiddleware]
    end
    
    subgraph Application Core
        TenMid --> AuthCtrl[AuthController]
        TenMid --> DashCtrl[DashboardController]
        TenMid --> MemCtrl[MembersController]
        TenMid --> PlanCtrl[MembershipsController]
        TenMid --> LeadCtrl[LeadsController]
        TenMid --> AttCtrl[AttendanceController]
        TenMid --> PayCtrl[PaymentsController]
        TenMid --> TrainCtrl[TrainersController]
        TenMid --> WorkCtrl[WorkoutsController]
        TenMid --> StaffCtrl[StaffController]
        TenMid --> RepCtrl[ReportsController]
    end
    
    subgraph Data Access Layer
        AuthCtrl & DashCtrl & MemCtrl & PlanCtrl & LeadCtrl & AttCtrl & PayCtrl & TrainCtrl & WorkCtrl & StaffCtrl & RepCtrl --> EF[Entity Framework Core 9.0]
        EF -->|Global Query Filter: TenantId| DB[(Relational Database: SQLite / SQL Server / PostgreSQL)]
    end
```

---

## 3. Strict Multi-Tenant Isolation
- **Tenant Context Resolution**: Resolved from authenticated JWT claim `tenant_id` or header `X-Tenant-Id`.
- **Query Level Isolation**: Enforced by Entity Framework Core Global Query Filters:
  ```csharp
  modelBuilder.Entity<Member>().HasQueryFilter(m => !_tenantService.TenantId.HasValue || m.TenantId == _tenantService.TenantId.Value);
  ```
  This eliminates any risk of cross-tenant data leakage.

---

## 4. Role-Based Access Control (RBAC)
- `GymOwner`: Complete administrative access across all tenant branches and financial ledgers.
- `BranchManager`: Full management access restricted to their assigned branch.
- `Receptionist`: High-speed desk check-in/out, member enrollment, payment collections.
- `Trainer`: Client assignments, session scheduling, custom workout plan builders.
- `Accountant`: Financial ledgers, invoice audits, revenue reports.

