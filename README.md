# Real-Time Sports Betting Automation System — Python Odds Trading Engine & Sportsbook API Integration Platform

A production-grade **Real-Time Sports Betting Automation System** implemented as a **Python odds trading engine** and **sportsbook API integration platform**. This repository is the public entry point for the AsianOdds88 Trading System: documentation, one-command installers, and binary releases. The system provides a full **odds ingestion pipeline**, **trading decision engine**, **execution module**, and web dashboard. It is distributed as pre-built binaries (no source code in this repo); the architecture and usage are documented here for developers, researchers, and operators who need **real-time sports data pipeline** infrastructure.

---

## Introduction: The Problem and the Infrastructure

Automated sports betting and odds trading have evolved from manual spreadsheets and ad-hoc scripts into a discipline that requires stable infrastructure: reliable connectivity to **sportsbook APIs**, consistent **odds ingestion**, normalized data models, decision logic that can be tested and tuned, and execution layers with **retry handling** and risk controls. The gap many developers and quantitative researchers face is not a lack of ideas but a lack of **integrated, ready-to-run infrastructure** that connects a real bookmaker API to a **trading decision engine** and an **execution module** without months of integration work.

This project addresses that gap. It is built around a single bookmaker integration (AsianOdds88), which provides odds feeds, account data, and placement endpoints. The value lies in the **architecture**: a modular pipeline that ingests odds, normalizes them into a common representation, validates markets and liquidity, evaluates edge against configurable sharp consensus, applies risk rules (stake limits, daily loss caps, cooldowns, blacklists), and then either executes live or runs in simulation (DRY) mode. That separation—ingest, normalize, validate, decide, execute—makes the system suitable for **research**, **monitoring**, **data science** experiments, **automation testing**, and **infrastructure experimentation** without requiring access to proprietary source code.

**Who this is for.** The system targets developers and technical users who need a working **sportsbook API integration platform** they can run locally or on a server; traders who need **odds ingestion** and execution in one place with clear limits; and researchers who need a **real-time sports data pipeline** for strategy work or backtesting-style runs. A valid license is required to run the distributed binaries; without it, processes exit with a clear message and a link to obtain one. With a license, you configure environment variables (or a `.env` file), point the system at Redis and your bookmaker credentials, and start the processes. No Python installation or source build is required for the standard flow—the package is self-contained.

**Why automation infrastructure matters.** Manual trading on fast-moving lines is inconsistent and hard to scale. A **real-time sports betting automation system** lets you enforce rules (stake size, daily loss caps, cooldowns, blacklists), log every decision, and run continuously if desired. This project provides that infrastructure: a **Python odds trading engine** with configurable risk management and a dashboard for balance, PnL, and heartbeats. It is presented as **engineering and research infrastructure**, not as a profit guarantee or gambling promotion.

**What this repository contains.** The repository you are reading is **public and safe**: it contains **no source code** (no `.py` files, no `src/` or `scripts/` with code) and no private data. Only documentation, install scripts, and an example `.env`. The running system is delivered as **binaries** via [Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases). When you install, you get the full pipeline including the dashboard (port 8080). This keeps the implementation private while giving the community a single place to discover, install, and configure the **sportsbook API integration platform**.

**Technical positioning.** The system is designed as a **real-time sports data pipeline**: data flows from the sportsbook API through an **ingestion pipeline**, is normalized and stored in Redis, consumed by a **trading decision engine**, and then passed to an **execution module** that applies final checks and either places orders (LIVE) or simulates (DRY). **Logging and telemetry** are built in for operational debugging and post-trade analysis. The documentation describes this architecture so that developers can reason about latency, failure handling, and scaling even without access to the source.

---

## Key Features

**Real-time odds ingestion.** The system connects to the AsianOdds88 API and pulls live odds for supported sports and markets. The ingest layer handles session management, reconnection, and writes normalized odds into Redis. Downstream components read from Redis, so the pipeline stays decoupled and testable. This is the foundation of any **odds ingestion system** or **real-time sports data pipeline**.

**Multi-component trading pipeline.** Separate processes handle ingestion, movement tracking, signal density, market validation, edge evaluation, execution locking, execution engine, risk guard, and order routing. Each component has a single responsibility; together they form a **Python odds trading engine** with clear boundaries. This design supports **automation testing** (e.g. DRY mode) and **infrastructure experimentation** with controlled execution.

**Automated execution module.** Orders are placed via the bookmaker API after passing validation and risk checks. Execution mode is configurable (DRY vs LIVE), so you can run the full pipeline without placing real bets. Stake can be fixed or driven by internal logic. The **sportsbook API integration** is centralized in the order router and execution module, with **retry handling** and timeouts documented in the architecture.

**Configurable risk management.** You can set fixed stake, daily loss limits, exposure caps, cooldowns, and league or market blacklists. The risk guard and execution logic enforce these before any order is sent. This makes the system suitable as **sportsbook API trading infrastructure** where control is non-negotiable.

**Redis-backed state and streams.** All shared state (odds snapshots, session tokens, locks, heartbeats) lives in Redis. Components communicate via Redis streams or keys. This allows horizontal scaling of readers and keeps the **odds ingestion pipeline** simple and auditable.

**Web dashboard.** A built-in dashboard (port 8080) shows balance, outstanding exposure, PnL, confirmed and rejected bets, and service heartbeats. Useful for **monitoring** and operational visibility without parsing logs.

**License-gated access.** The system requires a valid JWT license to run. Without it, processes exit with a clear message and link. This keeps the **Real-Time Sports Betting Automation System** under controlled distribution while leaving the repository public for discovery and installation.

**Logging and telemetry.** Structured logs and optional telemetry support operational debugging and post-trade analysis. The architecture is built for **production-grade** use and is documented in the deep-dive and wiki.

---

## System Architecture

The system is structured as a **real-time sports data pipeline** with distinct layers: ingestion, normalization, decision, and execution.

**Ingestion pipeline.** One or more processes connect to the AsianOdds88 API, maintain authentication, and poll for odds and account data. Ingested data is written to Redis (e.g. latest odds per market, account balance, session tokens). This layer is responsible for **sportsbook API integration** at the read side: login, session refresh, and feed polling.

**Odds normalization.** Raw API responses are parsed into a common format. Odds are stored by event and selection so that downstream components can read without knowing the API shape. This supports **real-time sports data pipeline** semantics and keeps the rest of the pipeline API-agnostic.

**Trading decision engine.** Several components consume from Redis and implement the trading logic: movement tracking, signal density, market validation, and mathematical edge evaluation. They apply rules (liquidity, sharp consensus, cooldowns, blacklists) and produce signals or vetoes. No execution happens here—only decisions.

**Execution module.** The execution engine and order router consume validated signals, apply final risk checks and concurrency locks, and call the placement API when in LIVE mode. In DRY mode they simulate or skip placement. **Retry handling** and timeouts are applied here; see the architecture deep-dive for details.

**Logging and telemetry.** The dashboard reads from Redis and serves a web UI. Logs and optional telemetry provide audit trails and debugging. Together they support **monitoring** and operational control of the **Python odds trading engine**.

---

## Installation Guide

The public repository does not contain source code. You install the system by downloading the latest release or by running the one-command installer.

### Prerequisites

- **Redis** running (default port 6379). On Windows use WSL or a Redis build for Windows; on Linux run `redis-server`.
- **AsianOdds88 account** with API access. You will put credentials in `.env`.
- **Valid license** — Required to run. Obtain it from the link shown when running without a license, or from the project's license/landing page.
- **Network** — The machine must reach the AsianOdds88 API and Redis.

### One-Command Install (recommended)

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/rovidev95/AsianOdds88-Trading-System/main/install.ps1 | iex
```

**Linux / macOS:**
```bash
curl -sSL https://raw.githubusercontent.com/rovidev95/AsianOdds88-Trading-System/main/install.sh | bash
```

These scripts fetch the latest release from GitHub, download the Windows ZIP or Linux tarball, and extract it into the current directory.

### Manual Download

1. Open [Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases).
2. Download **AsianOdds88-Windows.zip** (Windows) or **AsianOdds88-Linux.tar.gz** (Linux).
3. Extract the archive. You should see a folder (e.g. `AsianOdds88`) containing executables, `start.bat` or `start.sh`, and `.env.example`.

### Configure and Run

1. **License** — Set your JWT via `KETER_LICENSE_KEY` or in `local/.keter_license` (one line). Without a valid license, executables exit with a message and link.

2. **Environment** — Copy `.env.example` to `.env` in the same folder as the executables. Set at least:
   - `EXECUTION_MODE` — e.g. `DRY` or `LIVE`.
   - `REDIS_HOST` and `REDIS_PORT`.
   - `AO_USER` and `AO_PASS` — Your AsianOdds88 API credentials.

3. **Redis** — Start Redis before starting the system:
   ```bash
   redis-server
   ```

4. **Start** — From the extracted folder:
   - **Windows:** `start.bat`
   - **Linux:** `./start.sh`

   The dashboard is at `http://<your-IP>:8080`.

### Verify

Open the dashboard in a browser; check logs in the `logs` directory for errors. Ensure Redis is reachable and credentials are correct.

---

## Real Use Cases

**Research.** Run the full pipeline in DRY mode with real odds feeds. You get the same signals and logic as in live mode but no real money is placed. Researchers can use this for **infrastructure experimentation**, parameter tuning, or collecting **real-time sports data pipeline** outputs for analysis.

**Monitoring.** Use the ingest and Redis layer as an **odds ingestion** backbone. Downstream you can add your own consumers (dashboards, alerts, custom strategies) that read from the same Redis keys and streams. The system provides a ready-made **sportsbook API integration** and normalization layer.

**Data science.** Change parameters (stake, EV thresholds, cooldowns, blacklists) and run in DRY mode to see how often the **execution module** would have fired. Compare configurations without financial risk. Fits **automation testing** and **python betting automation backend** experiments.

**Live trading experiments.** With a license and proper risk settings, run in LIVE mode on a dedicated account. The **trading decision engine** and risk guard enforce your limits; the dashboard and logs give full visibility. Suitable for controlled **sportsbook API trading infrastructure**.

**Infrastructure experimentation.** Deploy on a VPS or cloud VM, tune Redis and network, and observe latency and failure behavior. The architecture documentation describes **retry handling**, scaling considerations, and **logging** philosophy for such use.

---

## FAQ (20+ Developer Questions)

**Can this system run 24/7?**  
Yes. The processes are designed for long-running operation. Run them under a process manager (e.g. systemd, supervisord) or in a screen/tmux session. Ensure Redis and the machine are stable and monitored.

**Does this support live (in-play) betting?**  
It supports the markets and endpoints exposed by the AsianOdds88 API. If the API provides in-play markets and placement, the system can ingest and trade them subject to the same validation and risk rules. Check the API documentation for live coverage.

**Can I connect other sportsbook APIs?**  
The current release is built for the AsianOdds88 API. The architecture (ingest → Redis → logic → execution) could in principle be extended to other **sportsbook API integration** points, but that would require source-level changes not provided in this public repo. This repository distributes binaries and documentation only.

**Is this suitable for research?**  
Yes. DRY mode and the full pipeline allow **automation testing** and **infrastructure experimentation** without placing real bets. You get **real-time odds processing** and the same logic as live mode.

**Does it include risk control?**  
Yes. Configurable risk management: fixed or logic-driven stake, daily loss limits, exposure caps, cooldowns, and league/market blacklists. The risk guard and execution layer enforce these before any order is sent.

**Do I need to install Python or build from source?**  
No. The distributed package contains pre-built executables. Install Redis, set license and `.env`, and run the start script.

**Where is the source code?**  
This repository is intentionally source-free in the public copy. The running system is delivered as binaries via [Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases). Architecture and configuration are documented in the repo.

**What if I don't have a license?**  
Without a valid license, the executables exit with a clear message and a link to obtain one. There is no way to run the pipeline without a valid license.

**Can I run this on a VPS or cloud server?**  
Yes. Install Redis (or use a managed Redis), download the package, set license and `.env`, and run the start script. Open the dashboard port (8080) in the firewall if you want remote access.

**Does it work on macOS?**  
The one-command installer and documentation support Linux and Windows. A Linux tarball is provided; on macOS you may need to run the Linux build in a compatible environment. Check the Releases page for supported platforms.

**How do I get AsianOdds88 API credentials?**  
You need an account with AsianOdds88 that has API access. Set `AO_USER` and `AO_PASS` in your `.env`. The repository does not provide or manage account creation.

**Is there a backtesting mode?**  
The system is built for live or simulated live runs (DRY mode). It is not a historical backtester; you get **real-time odds processing** and execution (or simulated execution) against the current feed. For backtesting you would need your own historical data and tooling.

**Can I change stake and risk parameters?**  
Yes. Stake, exposure limits, cooldowns, blacklists, and related parameters are configurable via environment variables or `.env`. See the project's configuration documentation for the full list.

**Is the dashboard secure?**  
The dashboard binds to a configurable port (default 8080) and shows balance, PnL, and operational data. Do not expose it to the public internet without authentication or a reverse proxy if the machine is shared or untrusted.

**Who maintains this?**  
The project is maintained by Rovidev. Documentation, installers, and releases are updated from this repository. For support and licensing, use the links provided in the repo and dashboard.

**What is the ingestion pipeline latency?**  
Latency depends on API polling interval, network, and Redis. The architecture deep-dive document discusses **latency considerations** and tuning.

**How does retry handling work?**  
The execution module and order router implement retries and backoff for transient API failures. See **docs/ARCHITECTURE_DEEP_DIVE.md** for **retry handling** and failure strategy.

**Can I contribute?**  
Feedback, documentation improvements, and pull requests that improve README, install scripts, or docs are welcome. The running system is distributed via Releases; forking this repo does not give you source code of the binaries.

**Where is the configuration documented?**  
See **docs/ENV_AND_CONFIG.md** (or equivalent) for environment variables. **docs/WIKI_INDEX.md** links to the configuration guide and architecture.

**How do I troubleshoot failures?**  
Check Redis connectivity, license validity, and credentials. Use the dashboard and logs directory. The wiki includes a troubleshooting section and links to the architecture and FAQ.

---

## Screenshots and Visuals

Placeholder images for documentation. Replace with real screenshots when available.

![System Dashboard](docs/images/dashboard.png)

*Dashboard: balance, PnL, outstanding, and service heartbeats.*

![Logs](docs/images/logs.png)

*Structured logs and runtime output.*

![Console](docs/images/console.png)

*Console startup and process output.*

![Architecture](docs/images/architecture.png)

*High-level pipeline and component diagram.*

![Runtime](docs/images/runtime.png)

*Runtime view: processes and Redis state.*

![Config](docs/images/config.png)

*Configuration example (redact credentials in real screenshots).*

---

## Contributing

We welcome feedback, documentation improvements, and ideas that align with the project's goals. This repository is the public entry point for the AsianOdds88 Trading System and related **sportsbook API integration platform** tooling.

- **Issues** — Use GitHub Issues for bugs, documentation fixes, or clear feature requests related to install, configuration, or documentation. Do not post credentials or license keys.
- **Forks** — You may fork the repository for your own documentation or installer variants. The running system is distributed via Releases; forking this repo does not give you source code of the binaries.
- **Improvements** — Pull requests that improve README, install scripts, or docs are appreciated. Keep the tone professional and avoid hype or profit guarantees.

The project is presented as **enterprise-grade** infrastructure for **odds API trading**, **betting automation**, and **real-time odds processing**. We aim to keep the documentation and install experience at a high standard so that developers and researchers can evaluate and use the **Python odds trading engine** and **odds ingestion system** with confidence.

---

## Documentation and Links

| Resource | Description |
|----------|--------------|
| [Get started](GET_STARTED.md) | Short path: license, download, configure, run |
| [Install guide](docs/INSTALL.md) | Detailed installation and first run |
| [Architecture deep dive](docs/ARCHITECTURE_DEEP_DIVE.md) | Full data flow, components, failure handling |
| [Build your own guide](docs/BUILD_YOUR_OWN_BETTING_AUTOMATION.md) | Educational tutorial on betting automation |
| [License information](docs/LICENSE_INFO.md) | How to set the license and where to get it |
| [System overview](SYSTEM_OVERVIEW.md) | High-level pipeline and architecture |
| [Wiki index](docs/WIKI_INDEX.md) | Central index for docs and guides |
| [Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases) | Binary packages for Windows and Linux |

---

## Legal and Disclaimer

- The AsianOdds88 Trading System is used under license. See [docs/LICENSE_INFO.md](docs/LICENSE_INFO.md) and the repository [LICENSE](LICENSE) file.
- For adults only. Betting may be restricted in your jurisdiction; you are responsible for complying with local laws.
- The software is provided "as is." The maintainers are not liable for financial losses or misuse. This is **engineering and research infrastructure** for **python betting automation backend**, **sportsbook API trading infrastructure**, and **odds ingestion system** use—not a guarantee of profit.

---

## Keywords and Context

This project provides a **Real-Time Sports Betting Automation System** implemented as a **Python odds trading engine** and **sportsbook API integration platform**. It functions as a **real-time sports data pipeline** with an **odds ingestion system**, **trading decision engine**, **execution module** with **retry handling**, and **logging and telemetry** for production use. Use cases include **research**, **monitoring**, **data science**, **automation testing**, and **infrastructure experimentation**. Built for developers and researchers who need a **python betting automation backend** and **sportsbook API trading infrastructure** with clear installation, license gating, and documentation.

---

**AsianOdds88 Trading System** — Rovidev · 2026 · [rovidev.com](https://rovidev.com) · Support: rovidev95@gmail.com
