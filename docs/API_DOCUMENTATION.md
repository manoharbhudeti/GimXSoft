# GIMXSOFT - API Specification & Endpoint Documentation

Base URL: `http://localhost:5128/api` (Swagger UI available at `http://localhost:5128/swagger`)

## 1. Authentication (`/api/auth`)
- `POST /api/auth/login`: Authenticate staff/owner and receive dual JWT tokens.
  - Body: `{ "email": "admin@titanfit.com", "password": "Admin123!" }`
- `POST /api/auth/register-tenant`: Onboard a new gym organization with primary branch and owner account.
- `POST /api/auth/refresh-token`: Exchange valid refresh token for refreshed access token.
- `GET /api/auth/me`: Current authenticated user profile.
- `POST /api/auth/change-password`: Update password securely.

## 2. Executive Dashboard (`/api/dashboard`)
- `GET /api/dashboard/metrics?branchId={guid}`:
  - Returns real-time aggregate metrics: Total members, active members, monthly revenue, attendance today, renewal rate, lead conversion rate, 6-month historical revenue chart data, attendance trend by day, upcoming expirations.

## 3. Member Management (`/api/members`)
- `GET /api/members`: Paginated member list with search and status filtering.
- `GET /api/members/{id}`: Detailed member profile with subscriptions, attendance history, and payment ledgers.
- `POST /api/members`: Register new member with duplicate detection and optional initial plan.
- `PUT /api/members/{id}`: Update member records.
- `DELETE /api/members/{id}`: Archive/deactivate member.
- `GET /api/members/export`: Export member directory to CSV.

## 4. Memberships & Subscriptions (`/api/memberships`)
- `GET /api/memberships/plans`: List active membership tiers and subscriber counts.
- `POST /api/memberships/plans`: Create new membership plan.
- `GET /api/memberships/subscriptions`: List active subscriptions.
- `POST /api/memberships/subscribe`: Enroll a member in a plan and generate invoice.
- `POST /api/memberships/subscriptions/{id}/freeze`: Pause/freeze a membership.
- `POST /api/memberships/subscriptions/{id}/unfreeze`: Reactivate and auto-extend frozen plan.

## 5. Leads & CRM (`/api/leads`)
- `GET /api/leads`: List prospects across pipeline stages.
- `POST /api/leads`: Create new prospect inquiry.
- `PATCH /api/leads/{id}/stage`: Move lead between stages with audit log.
- `GET /api/leads/{id}/activities`: Timeline of prospect calls, tours, and notes.
- `POST /api/leads/{id}/activities`: Append new activity note.

## 6. Attendance Terminal (`/api/attendance`)
- `GET /api/attendance/today-summary`: Daily live attendance counts and peak metrics.
- `POST /api/attendance/check-in`: Fast member check-in with anti-duplicate prevention.
- `POST /api/attendance/check-out`: Record workout completion and departure timestamp.
- `GET /api/attendance/history`: Historical attendance records.

## 7. Payments & Billing (`/api/payments`)
- `GET /api/payments`: Financial transaction records.
- `POST /api/payments/collect`: Record payment (Cash, UPI, Card, Bank wire) with invoice generation.
- `POST /api/payments/{id}/refund`: Process payment refund with reason.
- `GET /api/payments/financial-summary`: Revenue breakdown by payment method.

## 8. Trainers & Workouts (`/api/trainers`, `/api/workouts`)
- `GET /api/trainers`: List trainer profiles, specializations, hourly rates.
- `POST /api/trainers`: Onboard a new personal trainer.
- `GET /api/workouts`: Member workout routines and exercise prescriptions.
- `POST /api/workouts`: Assign structured workout plan.

## 9. Staff & Roles (`/api/staff`)
- `GET /api/staff`: Staff roster with assigned roles.
- `POST /api/staff`: Add staff member with role assignment.

## 10. Branches (`/api/branches`)
- `GET /api/branches`: Tenant branch locations.
- `POST /api/branches`: Add new facility location.

