# Download the latest AsianOdds88 Trading System package for Windows from GitHub Releases.
# Run from the folder where you want the package (e.g. your desktop or project folder).
# Requires: PowerShell 5.1+ (Windows).
$repo = "rovidev95/AsianOdds88-Trading-System"
$assetName = "AsianOdds88-Windows.zip"
$api = "https://api.github.com/repos/$repo/releases/latest"
Write-Host "Fetching latest release..."
try {
    $r = Invoke-RestMethod -Uri $api -Headers @{ Accept = "application/vnd.github.v3+json" }
} catch {
    Write-Error "Could not get latest release. Check your connection and that $repo has at least one release."
    exit 1
}
$asset = $r.assets | Where-Object { $_.name -eq $assetName }
if (-not $asset) {
    Write-Error "Asset '$assetName' not found in latest release. Available: $($r.assets.name -join ', ')"
    exit 1
}
$outPath = Join-Path (Get-Location) $assetName
Write-Host "Downloading $($asset.browser_download_url) ..."
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $outPath -UseBasicParsing
Write-Host "Saved: $outPath"
Write-Host "Extract the ZIP, then: set license (KETER_LICENSE_KEY or local\.keter_license), copy .env.example to .env, and run start.bat"
