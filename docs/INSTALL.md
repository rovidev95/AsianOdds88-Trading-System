# Quick install — AsianOdds88 Trading System

Minimal guide to get the system ready and running (local or on a server). **AsianOdds88 Trading System** requires a valid license; when you run it without a license, the system will show the link to get one. See [LICENSE_INFO.md](LICENSE_INFO.md).

---

## Prerequisites

- **Redis** running (port 6379). On Windows: WSL or Redis for Windows; on Linux: `redis-server`.
- **AsianOdds88 account** with API access (Login, GetFeeds, PlaceBet). Credentials are set via environment variables or the config used by the package.
- **Valid license** (see [Get started](../GET_STARTED.md)). The binary package does **not** require Python.
- For a **remote server:** AWS or similar, SSH key, instance in your chosen region (e.g. Singapore for AsianOdds88).

---

## 1. Get the package

- **After purchasing a license:** use the download link you receive, or go to the [GitHub Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases) page and download the package for your OS:
  - **Windows:** `AsianOdds88-Windows.zip` (or run `get-package.ps1` from the repo).
  - **Linux:** `AsianOdds88-Linux.tar.gz` (or run `./get-package.sh`).
- The package is **ready-to-run** (no Python or source code required): extract it, set your license and `.env`, and run `start.bat` (Windows) or `./start.sh` (Linux).

---

## 2. Local configuration

- **License:** Set your license with the `KETER_LICENSE_KEY` environment variable or the file `local/.keter_license` (one line with the token). Without a license, the system will show the link to get one when you run it.
- **Environment variables:** Copy the example env file to `.env` and adjust as needed, for example:
  - `EXECUTION_MODE=DRY` for testing without real bets; `LIVE` for production.
  - `FIXED_STAKE` (e.g. 0.30).
  - `REDIS_HOST` / `REDIS_PORT` if Redis is not on localhost:6379.
- **AsianOdds88:** Configure the credentials required by the ingest (env or config as per the package instructions).

---

## 3. Run on your PC (Windows)

- Open the extracted `AsianOdds88` folder and run **start.bat**.
- Ensure Redis is running before starting.

---

## 4. Run on a server (Linux)

1. Copy the extracted `AsianOdds88` folder (or the Linux tarball) to the server.
2. Set license (`KETER_LICENSE_KEY` or `local/.keter_license`), copy `.env.example` to `.env`, and configure as needed.
3. From the `AsianOdds88` folder run **./start.sh**.
4. Open the dashboard (see below) to confirm the system is running.

---

## 5. Dashboard and checks

- **Dashboard:** Open in your browser `http://<your-server-IP>:8080` (on a cloud instance, open port 8080 in the firewall if needed). You will see balance, outstanding, PnL today, confirmed/rejected bets, and heartbeats.
- If something fails, ensure Redis is running (`redis-cli ping` → `PONG`) and that your license and AsianOdds88 credentials are set correctly. Check the logs in the package logs directory.

---

For detailed deployment or troubleshooting, refer to the documentation included in your package.
