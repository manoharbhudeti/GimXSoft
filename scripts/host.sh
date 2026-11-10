#!/usr/bin/env bash
# ==============================================================================
# GimXSoft Localhost Orchestrator (Bash)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
API_PORT="${API_PORT:-5128}"
WEB_PORT="${PORT:-3000}"

echo ""
echo "=============================================================="
echo "         GimXSoft Gym Operations CRM - Local Host             "
echo "=============================================================="
echo ""

echo "[1/4] Checking environment prerequisites..."
command -v dotnet >/dev/null 2>&1 || { echo "Error: .NET SDK 8.0 is required." >&2; exit 1; }
command -v node >/dev/null 2>&1 || { echo "Error: Node.js is required." >&2; exit 1; }

echo "  ✓ .NET SDK: $(dotnet --version)"
echo "  ✓ Node.js:  $(node --version)"

# Build Web if missing
WEB_BUILD_DIR="$ROOT_DIR/frontend/build/web"
if [ ! -f "$WEB_BUILD_DIR/index.html" ]; then
    echo "[2/4] Building Flutter Web production release..."
    cd "$ROOT_DIR/frontend"
    flutter build web --release
    cd "$ROOT_DIR"
else
    echo "[2/4] Web assets already built at frontend/build/web"
fi

# Start Backend API
echo "[3/4] Launching ASP.NET Core Backend on http://localhost:$API_PORT ..."
cd "$ROOT_DIR/backend/GimXSoft.Api"
ASPNETCORE_ENVIRONMENT=Development dotnet run --urls "http://+:$API_PORT" &
BACKEND_PID=$!
cd "$ROOT_DIR"

cleanup() {
    echo ""
    echo "Shutting down GimXSoft services..."
    kill "$BACKEND_PID" 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM

sleep 3

# Start Web Server
echo "[4/4] Starting Web Server on http://localhost:$WEB_PORT ..."
export PORT="$WEB_PORT"

echo ""
echo "=============================================================="
echo "  GimXSoft is running on Localhost!                           "
echo "=============================================================="
echo "  - Public Landing Page: http://localhost:$WEB_PORT/"
echo "  - CRM Dashboard App:   http://localhost:$WEB_PORT/?app=true"
echo "  - Backend API:         http://localhost:$API_PORT/swagger"
echo "=============================================================="
echo "Press Ctrl+C to stop all services."
echo ""

node "$SCRIPT_DIR/serve-web.js"
