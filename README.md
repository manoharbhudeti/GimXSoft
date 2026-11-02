# GIMXSOFT - Smarter Fitness. Simpler Management.

> **Production-Ready SaaS Web Application for Modern Gyms, Fitness Franchises & Boutique Studios**

GIMXSOFT is an enterprise-grade gym management, operations, and CRM web application architected with **Flutter Web** and **ASP.NET Core 9 Web API**. It features strict multi-tenant isolation, real-time KPI metrics, responsive desktop-first layout, a Linear/Stripe-inspired design system with selective glassmorphism, and dual light/dark themes.

---

## 🌟 Key Functional Modules

1. **Executive Dashboard**: Real-time business intelligence with live calculations for Active Members, Monthly Revenue, Today's Attendance, Renewal Rates, Lead Conversion, interactive FL Charts (Revenue Line Chart, Peak Days Bar Chart), Upcoming Expirations, and Live Activity Streams.
2. **Member Management**: Comprehensive lifecycle directory with search, filter, Add Member dialog with input validation, and full Member Profile dialog with 4 distinct tabs (Overview, Subscriptions, Attendance Log, Payment History).
3. **Leads & CRM Pipeline**: 7-stage visual Kanban board (New, Contacted, Interested, Trial Scheduled, Trial Completed, Converted, Lost) with stage transitions, estimated deal values, follow-up scheduling, and activity logs.
4. **Memberships & Subscriptions**: Plan tier catalog (Monthly, Quarterly, Annual, PT bundles), benefits builder, active subscription ledger, and freeze/pause mechanisms with automatic date extension upon unfreezing.
5. **Reception Fast Check-In Terminal**: High-speed desk terminal with barcode/QR code scan support, member code & phone quick-search, live gym capacity monitor, duplicate check-in prevention (less than 1 hour), and one-click departure check-out.
6. **Payments & Billing**: Financial transaction ledger, multiple payment channels (Cash, UPI, Card, Bank Wire), printable invoice / payment receipt modal, and audit-logged refund processing.
7. **Personal Trainers & Workouts**: Trainer rosters with specialization tags, session booking, and a workout plan prescription builder with exercises, sets, reps, and rest timers.
8. **Staff & RBAC**: Role-based access control supporting `GymOwner`, `BranchManager`, `Receptionist`, `Trainer`, and `Accountant` with clearly defined permissions.
9. **Multi-Branch Operations**: Facility locations, codes, and centralized multi-branch oversight.
10. **Reports & Analytics**: Trajectory analytics, hourly facility traffic distribution, and member retention vs. churn rates.
11. **Settings & Themes**: Multi-tenant SaaS profile, tenant slug, instant Light/Dark mode switcher, and cryptographic password updates.

---

## 🏗️ Technology Stack

- **Frontend**: Flutter Web (Dart 3.x), Riverpod state management, GoRouter declarative routing, Dio HTTP client, FL Chart, Google Fonts (Inter).
- **Backend**: ASP.NET Core 9 / 10 Web API, Entity Framework Core, PostgreSQL (Npgsql) / SQLite, JWT Bearer Authentication, Swagger / OpenAPI.
- **Database & Containerization**: PostgreSQL 16, Docker / Podman Compose, Multi-stage Dockerfile.
- **Security**: BCrypt password hashing, dual JWT token rotation, Entity Framework Core Global Query Filters enforcing strict multi-tenant database isolation.

---

## 🚀 Quick Start Guide

### 1. Launch with Docker Compose (PostgreSQL + Backend API)
```bash
# Start PostgreSQL and Backend API with one command:
podman compose up -d
# or with docker:
docker compose up -d
```
The database schema and sample data will automatically initialize and seed in PostgreSQL.
- API Base URL: `http://localhost:5128/api`
- Swagger UI: `http://localhost:5128/swagger`

### 2. Alternative: Launch Locally with .NET CLI
```bash
cd backend/GimXSoft.Api
dotnet run --urls "http://localhost:5128"
```

### 3. Pre-Seeded One-Click Demo Accounts
On the login screen, click any of the quick-fill chips or use:
- **Gym Owner**: `admin@titanfit.com` | `Admin123!`
- **Branch Manager**: `sarah.manager@titanfit.com` | `Manager123!`
- **Reception Desk**: `marcus.desk@titanfit.com` | `Staff123!`
- **Personal Trainer**: `david.trainer@titanfit.com` | `Trainer123!`

### 3. Launch Flutter Web
```bash
cd frontend
flutter run -d chrome
```

---

## 🧪 Automated Test Verification

- **Backend Unit & Integration Tests**:
  ```bash
  dotnet test backend/GimXSoft.Tests
  ```
  *(Tests tenant isolation query filters, password hashing, and financial precision calculations)*

- **Frontend Widget & Theme Tests**:
  ```bash
  cd frontend
  flutter test
  ```
  *(Tests design tokens, status badges, glass cards, and metric stat cards)*

- **Static Analysis**:
  ```bash
  cd frontend
  dart analyze lib
  ```

