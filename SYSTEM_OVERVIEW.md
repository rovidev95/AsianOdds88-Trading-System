# AsianOdds88 Trading System — System overview

High-level description of the **AsianOdds88 Trading System**: purpose, pipeline, technologies, and deployment. No implementation details that could be used to replicate the system are included.

---

## 1. Purpose

AsianOdds88 Trading System is an **automated execution pipeline** for **live sports betting**. It:

1. **Discovers opportunities** (value, mispricings, positive EV) in real time from betting feeds.
2. **Validates** each signal before execution: liquidity, slippage, price freshness.
3. **Evaluates** mathematical edge (e.g. vs sharp consensus).
4. **Executes** orders via the **AsianOdds88** API with risk and concurrency controls.

The system runs in **LIVE** mode with configurable stake (e.g. fixed stake) and daily loss limits and losing-streak protection.

---

## 2. Technology stack

| Aspect | Description |
|--------|-------------|
| **Architecture** | Event-driven pipeline with validation and risk gates |
| **Language** | Python (async) |
| **Message / state** | Redis (queues, state, heartbeats) |
| **Betting API** | AsianOdds88 (Login, GetFeeds, PlaceBet, GetAccountSummary) |
| **Deployment** | Local (e.g. Windows) or cloud (e.g. AWS EC2) |

---

## 3. Pipeline (high-level)

- **Ingest** — Fetches live odds and feeds from AsianOdds88; writes raw signals and account data.
- **Validation** — Checks liquidity, slippage, and filters; only valid signals continue.
- **Edge evaluation** — Computes expected value and compares to sharp consensus; confirms or rejects.
- **Execution** — Applies concurrency limits, stake rules, and risk checks; sends orders to AsianOdds88.
- **Dashboard** — Web UI (port 8080): balance, outstanding, PnL today, confirmed/rejected counts, heartbeats, alerts.

Exact queue names, Redis keys, and script names are part of the packaged product and are not disclosed in this overview.

---

## 4. Risk and safety

- Daily loss limit and losing-streak protection.
- Configurable max slippage and minimum liquidity.
- Fixed or EV-proportional stake; global throttle and per-event cooldowns where applicable.

---

## 5. Deployment

- **Local:** Run the start script from the package; set `EXECUTION_MODE`, stake, and Redis in `.env`.
- **Server (e.g. EC2):** Deploy the package to your host, configure license and credentials, and run the provided start script. Open the dashboard at `http://<your-server-IP>:8080`.

---

## 6. License

A valid license (JWT) is required. Set it via `KETER_LICENSE_KEY` or `local/.keter_license`. If the license is missing, expired, or invalid, the system will not start and will show the link to get or renew a license. See [docs/LICENSE_INFO.md](docs/LICENSE_INFO.md).

---

**AsianOdds88 Trading System** — Rovidev · 2026
