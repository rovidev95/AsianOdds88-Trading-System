# AsianOdds88 Trading System

**The #1 system to win automatically with Asian Odds 88.** For sports trading professionals and individuals who want automated execution, mathematical edge, and risk control without watching the screen.

Automated trading system, sports betting software, AsianOdds88, Asian Odds 88 — real-time execution, liquidity validation, expected value (EV) vs sharp consensus, daily loss limits, and live dashboard. **A valid license is required to run the system.** Without a license the system will show you where to get one; with it, you configure your environment and start.

---

## Why choose AsianOdds88 Trading System

- **Win automatically:** Full pipeline: real-time odds ingest, signal validation, mathematical edge (sharp bookies), controlled execution, and dashboard. No guesswork: institutional-style logic, clear limits, and a panel for balance, PnL, and alerts.
- **For professionals and individuals:** Same engine for serious operators and for those who want to automate without complexity. Redis, run locally or in the cloud (e.g. AWS EC2), optional Prometheus and Grafana.
- **Full control:** Fixed or EV-proportional stake, daily loss limit, losing streak protection, cooldowns and blacklists. Web dashboard (port 8080): balance, outstanding, confirmed, rejected, heartbeats.

Keywords: automated betting, odds trading, live odds, AsianOdds88 license, betting automation, edge detection, risk controls, Rovidev, sports trading, mathematical edge, execution engine, real-time feeds.

---

## Install with one command (no code in this repo)

The system is distributed as **binaries only**; this repository contains **no source code**—just the installer and docs. One command installs the latest version from GitHub Releases.

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/rovidev95/AsianOdds88-Trading-System/main/install.ps1 | iex
```

**Linux / macOS:**
```bash
curl -sSL https://raw.githubusercontent.com/rovidev95/AsianOdds88-Trading-System/main/install.sh | bash
```

This downloads and extracts the package for your OS. Then: set your **license** (see [Get started](GET_STARTED.md)), copy `.env.example` → `.env`, ensure **Redis** is running, and run `start.bat` (Windows) or `./start.sh` (Linux).

---

## What you need to run it

- **License:** Required to start. Get it at **[AsianOdds88 – Get license](https://rovidev.com/asianodds88/)**. Without it, the system shows the link when you run it.
- **Environment:** Redis (port 6379), AsianOdds88 account with API (Login, GetFeeds, PlaceBet, GetAccountSummary).
- **Optional:** Ubuntu server, ports 22 (SSH) and 8080 (dashboard).

---

## Get started

1. **Get your license** — **[Get license →](https://rovidev.com/asianodds88/)** (required to run).
2. **Install** — Run the one command above (Windows or Linux). Or download from [Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases) and extract manually.
3. **Configure** — In the installed `AsianOdds88` folder: set license (`KETER_LICENSE_KEY` or `local/.keter_license`), copy `.env.example` → `.env`, and set Redis/AsianOdds88 as needed.
4. **Run** — `start.bat` (Windows) or `./start.sh` (Linux). Dashboard: `http://<your-IP>:8080`.

**Ready?** → **[Get license and download →](https://rovidev.com/asianodds88/)**

---

## Documentation

| Link | Content |
|------|---------|
| [**Get started — Download and run**](GET_STARTED.md) | Three steps: get license, download, configure and run |
| [Quick install](docs/INSTALL.md) | Installation and first run |
| [License](docs/LICENSE_INFO.md) | How to set your license and where to get it |
| [System overview](SYSTEM_OVERVIEW.md) | Pipeline, flow, and architecture (high-level) |

---

## Legal notice

- AsianOdds88 Trading System is used under license. See [docs/LICENSE_INFO.md](docs/LICENSE_INFO.md) and the [LICENSE](LICENSE) file.
- For adults only. Betting may be restricted in your jurisdiction; the user is responsible for complying with local law.
- Software is provided "as is"; Rovidev is not liable for financial losses or misuse.

---

**AsianOdds88 Trading System** — Rovidev · 2026 · [rovidev.com](https://rovidev.com) · Support: rovidev95@gmail.com
