# Build AsianOdds88 Trading System (binaries)

This folder contains scripts to build **Windows** and **Linux** binary packages (no source code). The output is used for GitHub Releases so users can run the system without Python or source.

## Requirements

- **Windows build:** Run on Windows; Python 3.10+ with project dependencies installed.
- **Linux build:** Run on Linux (same Python version); produces Linux executables.

## Quick start

### Windows

From the **project root** (parent of `build/`):

```powershell
.\build\build_windows.ps1
```

Output: `build\dist\AsianOdds88-Windows.zip`

### Linux

From the **project root**:

```bash
bash build/build_linux.sh
```

Output: `build/dist/AsianOdds88-Linux.tar.gz`

## What gets built

- One executable per module (ingest, movement_tracker, market_validator, etc.).
- `validate_license` is run first by the start script.
- Package includes: executables, `start.bat` / `start.sh`, `.env.example`, `local/` for license file, and a short README.

## Uploading to GitHub Releases

1. Create a new Release (e.g. tag `v1.0.0`).
2. Attach:
   - `AsianOdds88-Windows.zip`
   - `AsianOdds88-Linux.tar.gz`
3. Users download the asset for their OS or use the repo's `get-package.ps1` / `get-package.sh` to fetch the latest.

## Asset names

The get-package scripts expect these exact asset names:

- `AsianOdds88-Windows.zip`
- `AsianOdds88-Linux.tar.gz`

Do not change them without updating the scripts in the public repo.
