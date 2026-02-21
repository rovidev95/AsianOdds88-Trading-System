#!/usr/bin/env bash
# Build Linux binary package (PyInstaller). Run from project root.
# Usage: bash build/build_linux.sh
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"
[ -d src ] || { echo "Run from project root (parent of build/)."; exit 1; }

DIST_DIR="$SCRIPT_DIR/dist"
BUILD_DIR="$SCRIPT_DIR/build_cache"
PKG_DIR="$DIST_DIR/AsianOdds88"
mkdir -p "$DIST_DIR" "$BUILD_DIR" "$PKG_DIR"

# PyInstaller
python3 -c "import PyInstaller" 2>/dev/null || pip install pyinstaller

# Entry points
entries=(
    "validate_license:scripts/validate_license.py"
    "asianodds_ingest:src/asianodds_ingest.py"
    "movement_tracker:src/movement_tracker.py"
    "signal_density_engine:src/signal_density_engine.py"
    "market_validator:src/market_validator.py"
    "math_edge_evaluator:src/math_edge_evaluator.py"
    "execution_lock_manager:src/execution_lock_manager.py"
    "execution_engine:src/execution_engine.py"
    "risk_guard:src/risk_guard.py"
    "order_router:src/order_router.py"
    "dashboard_server:scripts/dashboard_server.py"
    "telemetry_daemon:scripts/telemetry_daemon.py"
)

for entry in "${entries[@]}"; do
    name="${entry%%:*}"
    path="${entry#*:}"
    echo "Building $name..."
    pyinstaller --onefile --noconfirm \
        --paths=src --paths=. --paths=scripts \
        --hidden-import=license_check \
        --workpath="$BUILD_DIR/$name" --specpath="$BUILD_DIR/$name" --distpath="$BUILD_DIR/$name" \
        --name "$name" "$path"
    exe="$BUILD_DIR/$name/$name"
    [ -f "$exe" ] && cp "$exe" "$PKG_DIR/"
done

# Start script
cat > "$PKG_DIR/start.sh" << 'START'
#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Validating license..."
./validate_license || exit 1
echo "Starting AsianOdds88 Trading System..."
mkdir -p logs
export EXECUTION_MODE="${EXECUTION_MODE:-LIVE}" FIXED_STAKE="${FIXED_STAKE:-0.30}"
nohup ./asianodds_ingest >> logs/live.log 2>&1 &
nohup ./movement_tracker >> logs/live.log 2>&1 &
nohup ./signal_density_engine >> logs/live.log 2>&1 &
nohup ./market_validator >> logs/live.log 2>&1 &
nohup ./math_edge_evaluator >> logs/live.log 2>&1 &
nohup ./execution_lock_manager >> logs/live.log 2>&1 &
nohup ./execution_engine >> logs/live.log 2>&1 &
nohup ./risk_guard >> logs/live.log 2>&1 &
nohup ./order_router >> logs/live.log 2>&1 &
nohup ./dashboard_server >> logs/dashboard.log 2>&1 &
nohup ./telemetry_daemon >> logs/telemetry.log 2>&1 &
echo "All processes started. Check logs in ./logs/"
START
chmod +x "$PKG_DIR/start.sh"

# .env.example
cat > "$PKG_DIR/.env.example" << 'ENV'
# Copy to .env and fill in. Do not commit .env.
EXECUTION_MODE=DRY
FIXED_STAKE=0.30
REDIS_HOST=localhost
REDIS_PORT=6379
ENV

# local folder
mkdir -p "$PKG_DIR/local"
echo "Paste your JWT license here (one line)" > "$PKG_DIR/local/.keter_license.example"

# Package README
cat > "$PKG_DIR/PACKAGE_README.txt" << 'README'
AsianOdds88 Trading System - Linux
===================================
1. Put your license: export KETER_LICENSE_KEY=your_jwt or paste JWT in local/.keter_license (one line).
2. Copy .env.example to .env and set EXECUTION_MODE, REDIS_HOST, etc.
3. Ensure Redis is running (localhost:6379 or your REDIS_HOST).
4. Run: ./start.sh
README

# Tarball
TARBALL="$DIST_DIR/AsianOdds88-Linux.tar.gz"
rm -f "$TARBALL"
tar czf "$TARBALL" -C "$DIST_DIR" AsianOdds88
echo "Done: $TARBALL"
