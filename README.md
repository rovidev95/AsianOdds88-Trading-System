# Real-Time Automated Sports Betting Trading System — AsianOdds88 (Python, API, Odds Feed, Live Trading Engine)

A production-grade **sports betting bot** and **automated betting system** for real-time odds ingestion, mathematical edge evaluation, and controlled execution. Built for **odds API trading**, **betting automation** with Python, and **sportsbook API integration**. This repository provides the public face of the **AsianOdds88 Trading System**: documentation, one-command installers, and release distribution. The system itself runs as binaries (no source code in this repo); you get a full **real-time odds processing** pipeline, **live trading engine**, configurable risk controls, and a web dashboard.

---

## What This System Does and Why It Exists

Automated sports betting infrastructure has moved from spreadsheets and manual refreshes to programmatic feeds, execution APIs, and risk-managed pipelines. The problem most developers and quantitative traders face is not a lack of ideas but a lack of **integrated, ready-to-run infrastructure**: something that connects to a real **sportsbook API**, ingests **live odds**, applies **trading logic**, and executes (or simulates) bets with clear limits and observability. This project addresses that gap by providing a complete **betting automation** stack—from odds feed to execution and dashboard—designed for **real-time odds processing** and **sportsbook API integration**.

The system is built around a single bookmaker API (AsianOdds88), which supplies odds feeds, account data, and placement endpoints. The value is not in "magic signals" but in the **architecture**: a modular pipeline that ingests odds, validates markets, evaluates edge against sharp consensus, applies risk rules, and then either executes live or runs in dry-run mode for research and backtesting. That separation—ingest, validate, decide, execute—is what makes it suitable both for **betting strategy testing** and for **live trading experiments** under strict controls.

**Who this is for:** Developers and technical users who want a working **automated betting system** they can run locally or on a server; traders who need **odds monitoring** and execution in one place; researchers who need a **betting data pipeline** for strategy work. The system requires a valid license to run; without it, the binaries exit with a clear message and a link to obtain one. With a license, you configure environment variables (or a `.env` file), point the system at Redis and your AsianOdds88 credentials, and start the processes. No need to clone source or install Python dependencies—the distributed package is self-contained.

**Why automated odds trading matters:** Manual trading on fast-moving lines is inconsistent and hard to scale. An **automated wagering infrastructure** lets you enforce rules (stake size, daily loss caps, cooldowns, blacklists), log every decision, and run 24/7 if desired. This project provides that infrastructure: a **real-time odds processing** engine, configurable **risk management**, and a dashboard for balance, PnL, and heartbeats. It is presented as **engineering and research infrastructure**, not as a profit guarantee.

The repository you are reading is **public and safe**: it contains **no source code** (no `.py` files, no `src/` or `scripts/` with code) and no private data. Only documentation, install scripts, and an example `.env`. The actual system is distributed as **binaries** via [Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases). When you install, you get the full pipeline including the dashboard (port 8080)—everything runs from the downloaded package. This keeps the codebase private while giving the community a single place to discover, install, and configure the **sports betting bot** and **automated betting system**.

---

## Key Features

- **Real-time odds ingestion** — The system connects to the AsianOdds88 API and pulls live odds for supported sports and markets. The ingest layer handles session management, reconnection, and writes normalized odds into Redis. Downstream components read from Redis, so the pipeline stays decoupled and testable. This is the foundation of any **odds monitoring system** or **betting data pipeline**.

- **Multi-component trading pipeline** — Separate processes handle ingestion, movement tracking, signal density, market validation, edge evaluation, execution locking, execution engine, risk guard, and order routing. Each component does one job; together they form a **live trading engine** with clear boundaries. This design supports **betting strategy testing** (e.g. dry-run mode) and **live trading experiments** with controlled execution.

- **Automated bet execution engine** — Orders are placed via the bookmaker API after passing validation and risk checks. Execution mode is configurable (e.g. DRY vs LIVE), so you can run the full pipeline without placing real bets. Stake can be fixed or driven by internal logic. The **sportsbook API integration** is centralized in the order router and execution module, making it easier to reason about latency and failures.

- **Configurable risk management** — You can set fixed stake, daily loss limits, exposure caps, cooldowns, and league or market blacklists. The risk guard and execution logic enforce these before any bet is sent. This makes the system suitable for **automated wagering infrastructure** where control is non-negotiable.

- **Redis-backed state and streams** — All shared state (odds snapshots, session tokens, locks, heartbeats) lives in Redis. Components communicate via Redis streams or keys. This allows horizontal scaling of readers and keeps the **real-time odds processing** path simple and auditable.

- **Web dashboard** — A built-in dashboard (port 8080) shows balance, outstanding exposure, PnL, confirmed and rejected bets, and service heartbeats. Useful for **odds monitoring** and operational visibility without touching logs.

- **License-gated access** — The system requires a valid JWT license to run. Without it, processes exit with a clear message and link. This keeps the **automated betting system** under controlled distribution while leaving the repository public for discovery and installation.

- **Logging and telemetry** — Structured logs and optional telemetry support operational debugging and post-trade analysis. The architecture is built for **production-grade** use, not one-off scripts.

---

## System Architecture

The system is structured as a **betting data pipeline** with distinct layers: ingest, processing, decision, and execution. Understanding this helps when configuring or extending the **sports betting bot**.

**Ingest layer** — One or more processes connect to the AsianOdds88 API (or compatible endpoint), maintain authentication, and poll for odds and account data. Ingested data is normalized and written to Redis (e.g. latest odds per market, account balance, session tokens). This layer is responsible for **sportsbook API integration** at the read side: login, session refresh, and feed polling.

**Parsing and normalization** — Raw API responses are parsed into a common format. Odds are stored by event and selection so that downstream components can read without knowing the API shape. This supports **real-time odds processing** and keeps the rest of the pipeline API-agnostic.

**Trading logic layer** — Several components consume from Redis and implement the **betting automation** logic: movement tracking, signal density, market validation, and mathematical edge evaluation. They apply rules (liquidity, sharp consensus, cooldowns, blacklists) and produce signals or vetoes. No execution happens here—only decisions.

**Execution module** — The execution engine and order router consume validated signals, apply final risk checks and concurrency locks, and call the placement API when in LIVE mode. In DRY mode they simulate or skip placement. This is the **automated bet execution engine** in the strict sense: one place where orders hit the **sportsbook API**.

**Monitoring and logging** — The dashboard reads from Redis and serves a web UI. Logs and optional telemetry provide audit trails and debugging. Together they support **odds monitoring** and operational control of the **live trading engine**.

---

## Step-by-Step Installation

The public repository does not contain source code. You install the **automated betting system** by downloading the latest release or by running the one-command installer. All steps below assume you want to run the pre-built binaries.

### Prerequisites

- **Redis** running (default port 6379). On Windows use WSL or a Redis build for Windows; on Linux run `redis-server`.
- **AsianOdds88 account** with API access (Login, GetFeeds, PlaceBet, GetAccountSummary). You will put credentials in `.env`.
- **Valid license** — Required to run. Obtain it from the link shown when running without a license, or from the project's license/landing page.
- **Network** — The machine running the system must reach the AsianOdds88 API and Redis (local or remote).

### Option A: One-Command Install (recommended)

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/rovidev95/AsianOdds88-Trading-System/main/install.ps1 | iex
```

**Linux / macOS:**
```bash
curl -sSL https://raw.githubusercontent.com/rovidev95/AsianOdds88-Trading-System/main/install.sh | bash
```

These scripts fetch the latest release from GitHub, download the Windows ZIP or Linux tarball, and extract it into the current directory. No source code is cloned; you get the binary package only.

### Option B: Manual Download

1. Open [Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases).
2. Download **AsianOdds88-Windows.zip** (Windows) or **AsianOdds88-Linux.tar.gz** (Linux).
3. Extract the archive. You should see a folder (e.g. `AsianOdds88`) containing executables, `start.bat` or `start.sh`, and `.env.example`.

### Configure and Run

1. **License** — Set your JWT license either via the `KETER_LICENSE_KEY` environment variable or by placing the JWT in a file: `local/.keter_license` (one line, no extra text). Without a valid license, the executables will exit with a message and a link to get a license.

2. **Environment** — Copy `.env.example` to `.env` in the same folder as the executables. Edit `.env` and set at least:
   - `EXECUTION_MODE` — e.g. `DRY` (no real bets) or `LIVE`.
   - `REDIS_HOST` and `REDIS_PORT` — Where Redis is running (default `localhost`, `6379`).
   - `AO_USER` and `AO_PASS` — Your AsianOdds88 API credentials.

   See the repository's env/config documentation for the full list of variables.

3. **Redis** — Start Redis before starting the system. For example:
   ```bash
   redis-server
   ```
   Or use an existing Redis instance and set `REDIS_HOST` / `REDIS_PORT` accordingly.

4. **Start the system** — From the extracted folder:
   - **Windows:** Run `start.bat`.
   - **Linux:** Run `./start.sh`.

   The scripts first run the license validator, then start the ingest, execution, and dashboard processes. The dashboard is available at `http://<your-IP>:8080`.

### Verify

- Open the dashboard in a browser; you should see balance, PnL, and heartbeats once the ingest has connected.
- Check logs in the `logs` directory (if present) for errors. Ensure Redis is reachable and credentials are correct if you see connection or auth failures.

---

## Real Use Cases

**Research automation** — Run the full pipeline in DRY (simulation) mode with real odds feeds. You get the same signals and logic as in live mode but no real money is placed. Researchers can use this to test ideas, tune parameters, or collect **betting data pipeline** outputs for analysis. The **odds monitoring system** and execution engine behave identically except for the final placement step.

**Odds monitoring platform** — Use the ingest and Redis layer as a **real-time odds processing** backbone. Downstream you can add your own consumers (dashboards, alerts, custom strategies) that read from the same Redis keys and streams. The system provides a ready-made **sportsbook API integration** and normalization layer so you can focus on monitoring or strategy.

**Betting strategy testing** — Change parameters (stake, EV thresholds, cooldowns, blacklists) and run in DRY mode to see how often the **automated bet execution engine** would have fired and with what sizing. Compare different configurations without financial risk. This fits **betting automation** research and **python sports betting automation** experiments.

**Live trading experiments** — With a license and proper risk settings, run in LIVE mode on a dedicated account or small bankroll. The **live trading engine** and risk guard enforce your limits; the dashboard and logs give full visibility. Suitable for controlled **automated wagering infrastructure** where you want one system handling both feed and execution.

**Sportsbook data analysis** — Ingest and store odds and account data in Redis; export or analyze via your own scripts. The system acts as a stable **betting data pipeline** from AsianOdds88 into your analysis environment, with built-in session handling and retries.

---

## FAQ

**Can this system run 24/7?**  
Yes. The processes are designed for long-running operation. Run them under a process manager (e.g. systemd, supervisord) or in a screen/tmux session if you want continuous **odds monitoring** and execution. Ensure Redis and the machine are stable and monitored.

**Does this support live betting?**  
It supports the markets and endpoints exposed by the AsianOdds88 API. If the API provides live (in-play) markets and placement, the **automated betting system** can ingest and trade them subject to the same validation and risk rules. Check the API documentation for live coverage.

**Can I connect other sportsbook APIs?**  
The current release is built for the AsianOdds88 API. The architecture (ingest → Redis → logic → execution) could in principle be extended to other **sportsbook API integration** points, but that would require source-level changes not provided in this public repo. This repository distributes binaries and documentation only.

**Is this suitable for research?**  
Yes. DRY mode and the full pipeline allow **betting strategy testing** and **sportsbook data analysis** without placing real bets. You get **real-time odds processing** and the same logic as live mode, which is useful for **python sports betting automation** and quantitative research.

**Does it include risk control?**  
Yes. The system includes configurable risk management: fixed or logic-driven stake, daily loss limits, exposure caps, cooldowns, and league/market blacklists. The risk guard and execution layer enforce these before any order is sent, making it suitable as **automated wagering infrastructure** with strict limits.

**Do I need to install Python or build from source?**  
No. The distributed package contains pre-built executables. You do not need Python or the project source to run the **sports betting bot**. Install Redis, set license and `.env`, and run the start script.

**Where is the source code?**  
This repository is intentionally source-free in the public copy. It contains documentation, install scripts, and an example `.env`. The running system is delivered as binaries via [Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases). This keeps the **automated betting system** distributable while protecting the implementation.

**What if I don't have a license?**  
Without a valid license, the executables exit with a clear message and a link to obtain one. There is no way to run the **live trading engine** or **odds API trading** pipeline without a valid license.

**Can I run this on a VPS or cloud server?**  
Yes. Install Redis (or use a managed Redis), download the package, set license and `.env` with your credentials and Redis host/port, and run the start script. Open the dashboard port (8080) in the firewall if you want remote access. Many users run this as **automated wagering infrastructure** on a single VM.

**Does it work on macOS?**  
The one-command installer and documentation support Linux and Windows. A Linux tarball is provided; on macOS you may need to run the Linux build in a compatible environment or use a Windows build under a compatibility layer. Check the Releases page for supported platforms.

**How do I get the AsianOdds88 API credentials?**  
You need an account with AsianOdds88 that has API access. Set `AO_USER` and `AO_PASS` (or the documented alternatives) in your `.env`. The repository does not provide or manage account creation.

**Is there a backtesting mode?**  
The system is built for live or simulated live runs (DRY mode). It is not a historical backtester; you get **real-time odds processing** and execution (or simulated execution) against the current feed. For backtesting you would need to combine this with your own historical data and tooling.

**Can I change stake and risk parameters?**  
Yes. Stake, exposure limits, cooldowns, blacklists, and related parameters are configurable via environment variables or `.env`. See the project's configuration documentation for the full list.

**Is the dashboard secure?**  
The dashboard binds to a configurable port (default 8080) and shows balance, PnL, and operational data. You should not expose it to the public internet without authentication or a reverse proxy if the machine is shared or untrusted. Treat it as internal **odds monitoring** and operational UI.

**Who maintains this?**  
The project is maintained by Rovidev. Documentation, installers, and releases are updated from this repository. For support and licensing, use the links provided in the repo and dashboard.

---

## Screenshots and Visuals

Placeholder images for documentation and SEO. Replace with real screenshots when available.

![System Dashboard](docs/images/dashboard.png)

*Dashboard: balance, PnL, outstanding, and service heartbeats.*

![Installation Complete](docs/images/install-complete.png)

*Post-install folder with executables and start script.*

![Configuration Example](docs/images/config-env.png)

*Example `.env` configuration (redact credentials in real screenshots).*

![Redis and Pipeline](docs/images/redis-pipeline.png)

*Conceptual view of Redis-backed pipeline and components.*

![License and Run](docs/images/license-and-run.png)

*License validation and startup flow.*

---

## Contributing and Community

We welcome feedback, documentation improvements, and ideas that align with the project's goals. This repository is the public entry point for the **AsianOdds88 Trading System** and related **sports betting bot** and **automated betting system** tooling.

- **Issues** — Use GitHub Issues for bugs, documentation fixes, or clear feature requests related to install, configuration, or documentation. Do not post credentials or license keys.
- **Forks** — You may fork the repository for your own documentation or installer variants. The running system is distributed via Releases; forking this repo does not give you source code of the binaries.
- **Improvements** — Pull requests that improve README, install scripts, or docs (e.g. env vars, FAQ, architecture) are appreciated. Keep the tone professional and avoid hype or profit guarantees.

The project is presented as **enterprise-grade** infrastructure for **odds API trading**, **betting automation**, and **real-time odds processing**. We aim to keep the documentation and install experience at a high standard so that developers and researchers can evaluate and use the **live trading engine** and **odds monitoring system** with confidence.

---

## Documentation and Links

| Resource | Description |
|----------|--------------|
| [Get started](GET_STARTED.md) | Short path: license, download, configure, run |
| [Install guide](docs/INSTALL.md) | Detailed installation and first run |
| [License information](docs/LICENSE_INFO.md) | How to set the license and where to get it |
| [System overview](SYSTEM_OVERVIEW.md) | High-level pipeline and architecture |
| [Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases) | Binary packages for Windows and Linux |

---

## Legal and Disclaimer

- The **AsianOdds88 Trading System** is used under license. See [docs/LICENSE_INFO.md](docs/LICENSE_INFO.md) and the repository [LICENSE](LICENSE) file.
- For adults only. Betting may be restricted in your jurisdiction; you are responsible for complying with local laws.
- The software is provided "as is." The maintainers are not liable for financial losses or misuse. This is **engineering and research infrastructure** for **python sports betting automation**, **sportsbook API trading bot**, and **odds monitoring system** use—not a guarantee of profit.

---

## Keywords and Context

This project provides a **real-time automated sports betting trading system** for **odds API trading** and **sportsbook API integration**. It functions as a **sports betting bot** and **automated betting system** with **real-time odds processing**, a **live trading engine**, and configurable risk management. Use cases include **betting automation**, **odds monitoring system** deployment, **betting data pipeline** research, and **automated wagering infrastructure** for **betting strategy testing** and **live trading experiments**. Built for developers and researchers who need **python sports betting automation** and a production-style **sportsbook API trading bot** with clear installation, license gating, and documentation.

---

**AsianOdds88 Trading System** — Rovidev · 2026 · [rovidev.com](https://rovidev.com) · Support: rovidev95@gmail.com
