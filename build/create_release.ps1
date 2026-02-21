# Create a GitHub Release and attach the Windows (and optionally Linux) package.
# Run from project root after: .\build\build_windows.ps1 (and on Linux: bash build/build_linux.sh)
# Requires: gh (GitHub CLI) logged in, e.g. gh auth login
param(
    [string]$Tag = "v1.0.0",
    [string]$Title = "AsianOdds88 Trading System $Tag",
    [switch]$Draft
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$dist = Join-Path $PSScriptRoot "dist"
$winZip = Join-Path $dist "AsianOdds88-Windows.zip"
$linuxTgz = Join-Path $dist "AsianOdds88-Linux.tar.gz"
if (-not (Test-Path $winZip)) {
    Write-Error "Run .\build\build_windows.ps1 first. Missing: $winZip"
    exit 1
}
$args = @("release", "create", $Tag, "--title", $Title, "--notes", "Binary release. Install with the one-line command from the README.")
if ($Draft) { $args += "--draft" }
$args += "--"  # asset list follows
$args += $winZip
if (Test-Path $linuxTgz) { $args += $linuxTgz }
& gh $args
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "Release $Tag created. Users can now run the install command."
