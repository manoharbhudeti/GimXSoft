# GIMXSOFT - Production Deployment & Runbook Guide

## 1. Prerequisites
- **Frontend**: Flutter SDK 3.44+ with Dart 3.12+
- **Backend**: .NET 9.0 SDK
- **Database**: SQLite (default zero-config local), or SQL Server / Azure SQL / PostgreSQL.

---

## 2. Running Locally (Development Mode)

### Step 1: Start the Backend API
```bash
cd backend/GimXSoft.Api
dotnet run --urls "http://localhost:5128"
```
The API will initialize, execute database migrations/ensure created, and seed default demonstration data.
- API Base URL: `http://localhost:5128/api`
- Interactive Swagger UI: `http://localhost:5128/swagger`

### Step 2: Seed Demonstration Credentials
- **Gym Owner**: `admin@titanfit.com` | Password: `Admin123!`
- **Branch Manager**: `sarah.manager@titanfit.com` | Password: `Manager123!`
- **Reception Desk**: `marcus.desk@titanfit.com` | Password: `Staff123!`
- **Personal Trainer**: `david.trainer@titanfit.com` | Password: `Trainer123!`

### Step 3: Run the Flutter Web Client
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

---

## 3. Production Build Instructions

### Backend (ASP.NET Core Web API)
```bash
cd backend/GimXSoft.Api
dotnet publish -c Release -o ../publish
```
Deploy the published files to Azure App Service, AWS Elastic Beanstalk, Docker container, or Linux VM (systemd + reverse proxy Nginx).

### Frontend (Flutter Web)
```bash
cd frontend
flutter build web --release --wasm # or standard canvas-kit / html
```
Deploy the generated `frontend/build/web/` directory to Azure Static Web Apps, AWS S3/CloudFront, Cloudflare Pages, or Netlify.

---

## 4. Azure Cloud Architecture
- **Web App Service**: Hosting `GimXSoft.Api` container or Windows/Linux runtime.
- **Azure SQL Database**: Set connection string in Azure Application Settings `ConnectionStrings:DefaultConnection`.
- **Azure Static Web App / Blob Storage**: Serving the compiled Flutter Web static bundle with global CDN distribution.
- **Azure Key Vault**: Protecting production JWT signing secrets and database connection strings.

