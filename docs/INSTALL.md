# Quick install — AsianOdds88 Trading System

Minimal guide to get the system ready and running (local or on a server). **AsianOdds88 Trading System** requires a valid license; when you run it without a license, the system will show the link to get one. See [LICENSE_INFO.md](LICENSE_INFO.md).

---

## Prerequisites

- **Python 3.10+** installed.
- **Redis** running (port 6379). On Windows: WSL or Redis for Windows; on Linux/Mac: `redis-server`.
- **AsianOdds88 account** with API access (Login, GetFeeds, PlaceBet). Credentials are set via environment variables or the config used by the package.
- For a **remote server:** AWS or similar, SSH key, instance in your chosen region (e.g. Singapore for AsianOdds88).

---

## 1. Get the package and dependencies

- Obtain the package from the link you receive after completing the license process (see [Get started](../GET_STARTED.md)).
- Extract it and install dependencies as described in the package (e.g. `pip install -r requirements.txt` from the package directory).

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

- Run the start script provided in the package (e.g. the main PowerShell or batch start script).
- Ensure Redis is running before starting.

---

## 4. Run on a server (Linux)

1. **Configuration:** Copy the remote config example to your config file and set your server host and SSH key path as indicated in the package.
2. **Deploy and start:** Use the deploy script from your PC if provided, or copy the package to the server and run the start script there (e.g. the main shell script that starts the stack).
3. **Check:** Use the verification script if included, or open the dashboard (see below) to confirm the system is running.

---

## 5. Dashboard and checks

- **Dashboard:** Open in your browser `http://<your-server-IP>:8080` (on a cloud instance, open port 8080 in the firewall if needed). You will see balance, outstanding, PnL today, confirmed/rejected bets, and heartbeats.
- If something fails, ensure Redis is running (`redis-cli ping` → `PONG`) and that your license and AsianOdds88 credentials are set correctly. Check the logs in the package logs directory.

---

For detailed deployment or troubleshooting, refer to the documentation included in your package.
