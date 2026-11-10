# ==============================================================================
# GimXSoft Localhost Orchestrator (Windows PowerShell)
# ==============================================================================
# Builds and launches both the ASP.NET Core 8 Web API (Port 5128) and
# the Flutter Web App via Reverse Proxy (Port 3000) locally.
# ==============================================================================

param (
    [switch]$BuildWeb = $false,
    [switch]$Watch = $false,
    [int]$ApiPort = 5128,
    [int]$WebPort = 3000
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "         GimXSoft Gym Operations CRM - Local Host             " -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check Prerequisites
Write-Host "[1/4] Checking environment prerequisites..." -ForegroundColor Yellow

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error ".NET SDK 8.0 is required but not found in PATH."
}
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js is required but not found in PATH."
}

Write-Host "  ✓ .NET SDK: $(dotnet --version)" -ForegroundColor Green
Write-Host "  ✓ Node.js:  $(node --version)" -ForegroundColor Green

# 2. Build or verify Web distribution
$WebBuildDir = Join-Path $RootDir "frontend\build\web"
$NeedBuild = $BuildWeb -or (-not (Test-Path (Join-Path $WebBuildDir "index.html")))

if ($NeedBuild) {
    Write-Host "[2/4] Building Flutter Web production release..." -ForegroundColor Yellow
    Push-Location (Join-Path $RootDir "frontend")
    try {
        flutter build web --release
        Write-Host "  ✓ Flutter web build complete." -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
} else {
    Write-Host "[2/4] Web assets already built at frontend\build\web" -ForegroundColor Green
}

# 3. Start ASP.NET Core Backend
Write-Host "[3/4] Launching ASP.NET Core Backend on http://localhost:$ApiPort ..." -ForegroundColor Yellow
$BackendDir = Join-Path $RootDir "backend\GimXSoft.Api"

$BackendJob = Start-Job -ScriptBlock {
    param($Dir, $Port)
    Set-Location $Dir
    $env:ASPNETCORE_ENVIRONMENT = "Development"
    dotnet run --urls "http://+:$Port"
} -ArgumentList $BackendDir, $ApiPort

# Wait for backend readiness
$BackendReady = $false
for ($i = 0; $i -lt 15; $i++) {
    Start-Sleep -Seconds 1
    try {
        $res = Invoke-WebRequest -Uri "http://localhost:$ApiPort/swagger/v1/swagger.json" -UseBasicParsing -TimeoutSec 1 -ErrorAction SilentlyContinue
        if ($res.StatusCode -eq 200 -or $res.StatusCode -eq 401) {
            $BackendReady = $true
            break
        }
    } catch {
        # Waiting for startup
    }
}

if ($BackendReady) {
    Write-Host "  ✓ Backend API is live on http://localhost:$ApiPort" -ForegroundColor Green
} else {
    Write-Host "  ! Backend is starting up in the background (Job ID: $($BackendJob.Id))." -ForegroundColor Yellow
}

# 4. Start Web Reverse-Proxy Server
Write-Host "[4/4] Starting Web Server on http://localhost:$WebPort ..." -ForegroundColor Yellow
$env:PORT = "$WebPort"

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "  GimXSoft is running on Localhost!                           " -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "  - Public Landing Page: http://localhost:$WebPort/" -ForegroundColor Cyan
Write-Host "  - CRM Dashboard App:   http://localhost:$WebPort/?app=true" -ForegroundColor Cyan
Write-Host "  - Backend API:         http://localhost:$ApiPort/swagger" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop all services."
Write-Host ""

node (Join-Path $ScriptDir "serve-web.js")
