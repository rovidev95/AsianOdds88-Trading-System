# AsianOdds88 Trading System - One-command installer (Windows)
# Downloads the latest release from GitHub and extracts it. No source code in the repo.
# Run: irm https://raw.githubusercontent.com/rovidev95/AsianOdds88-Trading-System/main/install.ps1 | iex
$ErrorActionPreference = "Stop"
$repo = "rovidev95/AsianOdds88-Trading-System"
$assetName = "AsianOdds88-Windows.zip"
$api = "https://api.github.com/repos/$repo/releases/latest"
$branch = "main"

Write-Host "AsianOdds88 Trading System - Installer" -ForegroundColor Cyan
Write-Host "Fetching latest release..."
try {
    $r = Invoke-RestMethod -Uri $api -Headers @{ Accept = "application/vnd.github.v3+json" }
} catch {
    Write-Error "Could not get latest release. Check your connection and that $repo has at least one release."
    exit 1
}
$asset = $r.assets | Where-Object { $_.name -eq $assetName }
if (-not $asset) {
    Write-Error "Asset '$assetName' not found. Available: $($r.assets.name -join ', ')"
    exit 1
}
$destDir = Get-Location
$zipPath = Join-Path $destDir $assetName
Write-Host "Downloading $($asset.browser_download_url) ..."
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -UseBasicParsing
Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath $destDir -Force
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
$folder = Join-Path $destDir "AsianOdds88"
Write-Host ""
Write-Host "Done. Installed to: $folder" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Put your license: set KETER_LICENSE_KEY=your_jwt  OR  paste JWT in $folder\local\.keter_license (one line)"
Write-Host "  2. Copy $folder\.env.example to $folder\.env and set EXECUTION_MODE, REDIS_HOST, etc."
Write-Host "  3. Ensure Redis is running (localhost:6379)."
Write-Host "  4. Run: cd $folder ; .\start.bat"
Write-Host ""
