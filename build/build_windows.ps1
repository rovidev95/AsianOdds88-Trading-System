# Build Windows binary package (PyInstaller). Run from project root.
# Usage: .\build\build_windows.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $root "src"))) {
    Write-Error "Run from project root (parent of build/)."
    exit 1
}
Set-Location $root

$distDir = Join-Path $PSScriptRoot "dist"
$buildDir = Join-Path $PSScriptRoot "build_cache"
$pkgDir = Join-Path $distDir "AsianOdds88"
foreach ($d in $distDir, $buildDir, $pkgDir) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

# Install PyInstaller if missing
$pip = "pip"
& python -c "import PyInstaller" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing PyInstaller..."
    & $pip install pyinstaller
}

# Entry points: "name" -> "path from root"
$entries = @(
    @{ Name = "validate_license"; Path = "scripts/validate_license.py" }
    @{ Name = "asianodds_ingest"; Path = "src/asianodds_ingest.py" }
    @{ Name = "movement_tracker"; Path = "src/movement_tracker.py" }
    @{ Name = "signal_density_engine"; Path = "src/signal_density_engine.py" }
    @{ Name = "market_validator"; Path = "src/market_validator.py" }
    @{ Name = "math_edge_evaluator"; Path = "src/math_edge_evaluator.py" }
    @{ Name = "execution_lock_manager"; Path = "src/execution_lock_manager.py" }
    @{ Name = "execution_engine"; Path = "src/execution_engine.py" }
    @{ Name = "risk_guard"; Path = "src/risk_guard.py" }
    @{ Name = "order_router"; Path = "src/order_router.py" }
    @{ Name = "dashboard_server"; Path = "scripts/dashboard_server.py" }
    @{ Name = "telemetry_daemon"; Path = "scripts/telemetry_daemon.py" }
)

foreach ($e in $entries) {
    Write-Host "Building $($e.Name)..."
    $n = $e.Name
    $p = $e.Path
    $workPath = Join-Path $buildDir $n
    New-Item -ItemType Directory -Force -Path $workPath | Out-Null
    & pyinstaller --onefile --noconfirm `
        --paths=src --paths=. --paths=scripts `
        --hidden-import=license_check `
        --workpath=$workPath --specpath=$workPath --distpath=$workPath `
        --name $n $p
    if ($LASTEXITCODE -ne 0) {
        Write-Error "PyInstaller failed for $n"
        exit 1
    }
    $exe = Join-Path $buildDir $n "$n.exe"
    if (-not (Test-Path $exe)) { $exe = Join-Path $buildDir $n $n "$n.exe" }
    if (Test-Path $exe) {
        Copy-Item $exe -Destination $pkgDir -Force
    } else { Write-Warning "Exe not found for $n" }
}

# Start script
$startBat = @"
@echo off
cd /d "%~dp0"
echo Validating license...
validate_license.exe || exit /b 1
echo Starting AsianOdds88 Trading System...
start /B "" asianodds_ingest.exe
start /B "" movement_tracker.exe
start /B "" signal_density_engine.exe
start /B "" market_validator.exe
start /B "" math_edge_evaluator.exe
start /B "" execution_lock_manager.exe
start /B "" execution_engine.exe
start /B "" risk_guard.exe
start /B "" order_router.exe
start /B "" dashboard_server.exe
start /B "" telemetry_daemon.exe
echo All processes started. Check logs in .\logs\
pause
"@
Set-Content -Path (Join-Path $pkgDir "start.bat") -Value $startBat -Encoding ASCII

# .env.example
$envExample = @"
# Copy to .env and fill in. Do not commit .env.
EXECUTION_MODE=DRY
FIXED_STAKE=0.30
REDIS_HOST=localhost
REDIS_PORT=6379
"@
Set-Content -Path (Join-Path $pkgDir ".env.example") -Value $envExample -Encoding UTF8

# local folder for license
New-Item -ItemType Directory -Force -Path (Join-Path $pkgDir "local") | Out-Null
Set-Content -Path (Join-Path $pkgDir "local" ".keter_license.example") -Value "Paste your JWT license here (one line)" -Encoding UTF8

# Package README
$pkgReadme = @"
AsianOdds88 Trading System - Windows
=====================================
1. Put your license: set KETER_LICENSE_KEY=your_jwt or paste JWT in local\.keter_license (one line).
2. Copy .env.example to .env and set EXECUTION_MODE, REDIS_HOST, etc.
3. Ensure Redis is running (localhost:6379 or your REDIS_HOST).
4. Run start.bat.
"@
Set-Content -Path (Join-Path $pkgDir "PACKAGE_README.txt") -Value $pkgReadme -Encoding UTF8

# Zip (unzip gives AsianOdds88/ folder)
$zipPath = Join-Path $distDir "AsianOdds88-Windows.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path $pkgDir -DestinationPath $zipPath -Force
Write-Host "Done: $zipPath"
