# Architecture Deep Dive — AsianOdds88 Trading System

This document describes the full architecture of the Real-Time Sports Betting Automation System: data flow from sportsbook API to execution, component responsibilities, latency considerations, failure handling strategy, scaling approach, configuration system, logging philosophy, and monitoring model. It is written as documentation for a production-grade trading platform.

---

## Full Data Flow: Sportsbook API to Execution

Data flows in a single direction through the pipeline: from the sportsbook API into Redis, then through decision components, and finally to the execution module when a signal is validated and risk checks pass.

**Phase 1 — API connection and authentication.** The ingest process establishes a session with the AsianOdds88 API. It sends credentials (username and password, or pre-obtained token/key when supported), receives a session token and key, and stores them in Redis under a well-known key set (e.g. `ao:session:token`, `ao:session:key`, `ao:session:url`, `ao:session:timestamp`). Other components that need to call the API (e.g. execution) can restore the session from Redis or trigger a fresh login. Session expiry is handled by the ingest; when the API invalidates the session, the ingest re-authenticates and writes the new tokens to Redis. This centralizes **sportsbook API integration** at the read and write boundaries.

**Phase 2 — Odds polling and raw response handling.** The ingest polls the API at a configurable interval for odds and market data. Raw responses are parsed and validated. Malformed or empty responses are logged and do not overwrite existing state. Each successful response is transformed into a normalized structure: event identifiers, market identifiers, selection identifiers, odds values, and metadata (e.g. bookmaker id, last update time). This **odds normalization** step is critical: downstream components depend on a stable schema and key layout (e.g. `odds:latest:{event_uid}:{selection_id}`) so that the **trading decision engine** does not need to know the API’s native format.

**Phase 3 — Writing to Redis.** Normalized odds are written to Redis with appropriate keys and optional TTLs. Latest odds per (event, selection) are typically stored as JSON or a serialized structure. Account balance and summary data (when polled) are written to separate keys. Heartbeats (e.g. `heartbeat:ingest:flow` with a timestamp) allow other components to detect ingest liveness. All writes use the same Redis instance (or cluster) so that the **execution module** and dashboard share the same view of the world.

**Phase 4 — Decision pipeline.** Multiple processes consume from Redis. Movement tracking, signal density, market validator, and math edge evaluator read latest odds and internal state (e.g. lock keys, last trade keys). They apply business rules: liquidity thresholds, sharp consensus, cooldowns, league and market blacklists, EV thresholds. Outputs are either signals (e.g. “place a bet on event X, selection Y, at price Z”) or vetoes. Signals are published to Redis streams or keys that the execution engine and order router consume. No component in this layer calls the placement API; they only read and write Redis. This keeps **latency** and **failure handling** concerns localized: if the API is slow or down, the decision pipeline can continue to run and queue or drop signals as designed.

**Phase 5 — Execution and placement.** The execution engine and order router pop or read signals, apply a final risk check (e.g. daily PnL, exposure cap, kill switch), acquire a concurrency lock if required, and then call the placement API when in LIVE mode. In DRY mode they simulate or skip the call and optionally log what would have been placed. **Retry handling** is applied at this stage: transient network or API errors trigger retries with backoff; after a maximum number of failures the signal is discarded or dead-lettered and the process continues. Successful placement is written back to Redis (e.g. order id, status) and reflected in the dashboard and logs.

**Phase 6 — Observability.** The dashboard reads from Redis (balance, outstanding, PnL, heartbeats, recent bets) and serves a web UI. Logs are written by each process to stdout or to files; optional telemetry can send metrics to an external system. This completes the **full data flow** from sportsbook API to execution and into **logging and telemetry**.

---

## Component Responsibilities

**Ingest process.** Owns API authentication, session refresh, odds polling, parsing, normalization, and writing to Redis. It must tolerate API downtime and network blips; reconnection and backoff are part of its contract. It does not make trading decisions or place orders.

**Movement tracker.** Consumes odds updates from Redis and tracks price movement and volatility. It may publish derived signals (e.g. movement-based triggers) for downstream use. Responsibility: movement and volatility metrics only.

**Signal density engine.** Regulates how often signals are produced per event or selection (e.g. re-entry cooldowns, density limits). Prevents the **execution module** from being flooded by repeated signals for the same market.

**Market validator.** Validates that a signal meets liquidity, age, and consistency checks before it is eligible for execution. It reads latest odds and lock state and either approves or vetoes. Responsibility: pre-execution validation only.

**Math edge evaluator.** Computes expected value and sharp consensus metrics. Produces or filters signals based on configurable EV thresholds and sharp source whitelist. Does not place orders.

**Execution lock manager.** Ensures at most one execution per (event, selection) (or per configurable key) for a period of time. Uses Redis locks with TTL. Prevents double placement and coordinates with the **execution module**.

**Execution engine.** Consumes validated signals, applies final risk checks (e.g. global throttle, daily loss limit), and in LIVE mode calls the placement API. In DRY mode it simulates. It is responsible for **retry handling**, timeouts, and writing placement results back to Redis.

**Risk guard.** Monitors PnL and exposure, can set a kill switch in Redis (e.g. `trading_enabled` = 0) to stop all execution. May consume trade outcome streams to update internal state. Responsibility: global risk and circuit breaker.

**Order router.** Orchestrates the placement flow: prepare request, call API, parse response, handle retries, update Redis and logs. May invalidate session in Redis on auth failures so that the ingest or execution re-logs in.

**Dashboard server.** Reads from Redis and serves HTML/JSON for balance, PnL, outstanding, confirmed/rejected bets, and heartbeats. No business logic; read-only and presentational.

**Telemetry daemon (optional).** Collects metrics or logs and forwards them to an external system. Does not affect trading logic.

---

## Latency Considerations

**End-to-end latency** from an odds update to a placement decision depends on: (1) API polling interval, (2) time to parse and write to Redis, (3) time for decision components to read and process, (4) time for execution to acquire lock and call API, (5) network RTT to the bookmaker. The system is designed for polling-based ingestion; streaming would require a different ingest design. For many use cases, sub-second or few-second latency from odds change to decision is sufficient; the architecture does not assume microsecond-level requirements.

**Redis latency.** All shared state goes through Redis. Local Redis (same host) typically adds sub-millisecond latency per operation. Remote Redis adds network RTT. For low-latency requirements, run Redis on the same host or in the same datacenter as the processes.

**Lock contention.** The execution lock manager uses Redis locks. Contention on the same (event, selection) serializes execution; that is intentional to avoid double placement. Lock TTL prevents deadlocks if a process crashes after acquiring a lock.

**API timeouts.** The execution module and order router use configurable timeouts for placement calls. Too short and valid requests fail; too long and the system stalls under API slowness. Timeouts and **retry handling** are documented in configuration so operators can tune for their environment.

---

## Failure Handling Strategy

**API unreachable.** The ingest retries connection and authentication with backoff. If the session expires, it re-logs in. Stale odds in Redis may remain until the next successful poll; decision components can use timestamps to ignore data that is too old.

**Session invalidation.** If the placement API returns an auth error, the order router or execution can delete session keys in Redis. The next placement attempt (or the ingest) will trigger a new login. This avoids indefinite retries with a bad token.

**Transient placement failures.** The execution module and order router implement **retry handling**: a configurable number of retries with exponential (or configurable) backoff. After max retries, the signal is logged as failed and the process continues. No infinite retry loops.

**Redis unavailability.** If Redis is down, all components that depend on it will fail (read/write errors). The design assumes Redis is highly available (single instance with persistence, or a managed cluster). Process managers (systemd, supervisord) can restart processes when they exit; Redis should be restarted or failed over separately.

**Process crash.** If an ingest or execution process crashes, other processes continue. Locks held by the crashed process expire via TTL. Restart the failed process; the ingest will re-establish session and resume writing, and the execution will resume consuming from streams or keys.

**Kill switch.** The risk guard or operator can set a key in Redis (e.g. `trading_enabled` = 0) to disable all placement. The execution engine checks this before placing; no code path bypasses it when implemented as documented.

---

## Scaling Approach

**Vertical scaling.** Run Redis and all processes on a single machine with sufficient CPU and memory. For moderate load (one bookmaker feed, hundreds of markets), a single VM is often enough.

**Horizontal scaling of readers.** Multiple instances of stateless decision components (e.g. market validator, edge evaluator) can read from the same Redis. Care must be taken with lock keys and idempotency: only one execution should handle a given signal. The execution lock manager and single consumer per stream (or key) help enforce that.

**Redis scaling.** For higher throughput or availability, use Redis Cluster or a managed Redis service. Application code must use cluster-compatible key layout and commands. Session and odds keys should be designed so that related data can be co-located if required.

**Ingest scaling.** Typically one ingest process per bookmaker (or per feed) is sufficient. Multiple ingests for the same API could duplicate writes; use a single writer per feed unless the design explicitly supports sharding (e.g. by sport or region).

---

## Configuration System

Configuration is delivered via environment variables or a `.env` file in the same directory as the executables (when running as packaged binaries). No hardcoded credentials; the operator sets `AO_USER`, `AO_PASS`, `REDIS_HOST`, `REDIS_PORT`, `EXECUTION_MODE`, stake and risk parameters, and optional tuning (timeouts, retries, EV thresholds, cooldowns). The repository provides `.env.example` as a template. License is provided via `KETER_LICENSE_KEY` or a file (e.g. `local/.keter_license`). This keeps the **configuration system** simple and portable: same variables work in development and production with different values.

---

## Logging Philosophy

**Structured logs.** Components emit log lines (e.g. JSON or key-value) with timestamps, level, source, and message. Optional fields include event id, selection id, outcome (success/failure), and error codes. This supports grep, log aggregation, and post-trade analysis without parsing free text.

**Sensitive data.** Passwords and tokens are never logged in full. Session tokens may be truncated (e.g. first 8 characters + "...") in logs. Credentials stay in environment or `.env` only.

**Audit trail.** Placement attempts (success and failure) are logged with enough context to reconstruct what was tried and why. This supports **monitoring** and compliance-style review.

**Log rotation and retention.** The packaged system may write to stdout or to a `logs/` directory. Operators are responsible for log rotation and retention (e.g. logrotate, or forwarding to a central system). The architecture does not assume infinite disk.

---

## Monitoring Model

**Health signals.** Heartbeats in Redis (e.g. `heartbeat:ingest:flow`, process-specific keys) indicate liveness. The dashboard displays them so operators can see at a glance whether ingest and other services are updating. Missing heartbeats suggest a crashed or stuck process.

**Dashboard.** The built-in dashboard shows balance, outstanding exposure, PnL, and recent bets. It is read-only and does not replace a full observability stack (metrics, alerting, tracing). For production, consider exporting metrics to Prometheus/Grafana or equivalent and alerting on Redis connectivity, API errors, and kill switch state.

**Alerts.** The system may support optional webhook or Telegram alerts for events (e.g. placement failure, session expiry). Configuration is documented in the env/config guide. Alerts are best-effort and do not replace monitoring of the underlying infrastructure (Redis, network, API status).

---

This architecture deep dive, together with the installation guide and wiki, provides a complete picture of the **full data flow**, **component responsibilities**, **latency considerations**, **failure handling strategy**, **scaling approach**, **configuration system**, **logging philosophy**, and **monitoring model** for the AsianOdds88 Trading System as a production-grade trading platform.
