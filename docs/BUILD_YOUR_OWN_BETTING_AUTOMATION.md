# How to Build a Sports Betting Automation System in Python

This guide explains the core concepts and design choices behind building a sports betting automation system: sportsbook APIs, odds feeds, polling vs streaming, parsing and normalization, execution safety, risk controls, scheduling, and logging. The AsianOdds88 Trading System repository is used as a concrete example of how these pieces fit together in a production-style pipeline.

---

## Sportsbook APIs: What You Get and What You Need

Most sportsbooks that offer programmatic access expose a **sportsbook API**: a set of HTTP (or sometimes WebSocket) endpoints that return odds, markets, account balance, and allow placing bets. Typically you need to authenticate (username/password or token), then call endpoints such as “get events,” “get markets for event,” “get odds,” “place bet,” and “get account summary.” Response formats are usually JSON or XML; documentation quality varies. Before building an **odds ingestion** layer, you must understand the API’s auth model (session vs long-lived token), rate limits, and the exact schema of the responses you will parse.

**Authentication.** Many APIs use session-based auth: you POST or GET a login endpoint with credentials, receive a token and sometimes a “key” or session ID, and then pass these in headers or query parameters on subsequent requests. Sessions often expire after a period of inactivity or a fixed TTL. Your ingest or execution layer must detect expiry (e.g. 401 or a specific error code) and re-authenticate. Storing the token in a shared store (e.g. Redis) allows multiple processes (ingest and execution) to use the same session without each logging in separately.

**Rate limits and quotas.** APIs may limit requests per minute or per hour. Polling too aggressively can get you throttled or banned. Design your **odds ingestion** interval and batch sizes to stay under limits; use exponential backoff on 429 or similar responses. The AsianOdds88 Trading System’s ingest layer handles session refresh and polling interval as part of its design; you can mirror this pattern in your own system.

---

## Odds Feeds: Structure and Semantics

An **odds feed** is the stream of odds (and sometimes market/event metadata) that your system consumes. In practice this often means “the response of a get-odds or get-markets API call.” The feed may include: event id, market type (e.g. match odds, over/under), selection id, price (decimal or fractional), timestamp, and bookmaker or source id. You need a clear mapping from the API’s fields to your internal representation so that downstream logic (e.g. **trading decision engine**) does not depend on API-specific quirks.

**Stale and missing data.** Feeds can have gaps (missing markets for a period) or stale prices (server delay, caching). Your **parsing** and **normalization** layer should attach timestamps to every odds update and optionally reject or flag data older than a threshold. This avoids building decisions on outdated prices.

**Multiple bookmakers.** If you aggregate from several sportsbooks, you face **normalization problems**: different event ids, market naming, and price formats. A common approach is to define a canonical schema (event_uid, market_type, selection_id, decimal_price, updated_at) and map each bookmaker’s response into it. The AsianOdds88 system normalizes a single API into Redis keys like `odds:latest:{event_uid}:{selection_id}`; the same idea applies when adding more feeds.

---

## Polling vs Streaming

**Polling** means periodically calling the API (e.g. every 5 or 10 seconds) and processing the full or incremental response. Pros: simple, works with any HTTP API, easy to add retries and backoff. Cons: latency is at least one poll interval; you may miss short-lived opportunities. Many **sportsbook API** integrations are polling-based because the API does not offer streaming.

**Streaming** means a long-lived connection (e.g. WebSocket or SSE) where the server pushes updates. Pros: lower latency, fewer redundant requests. Cons: requires API support, more complex connection and reconnection logic, and often more complex parsing (incremental updates). The current AsianOdds88 Trading System uses polling; if the API offered streaming, the ingest layer could be extended to consume a stream and still write the same normalized structures to Redis.

When building your own system, choose based on what the API supports and your latency requirements. For **real-time sports data pipeline** semantics, even polling every 1–5 seconds can be sufficient for many strategies.

---

## Parsing Odds and Handling Errors

**Parsing** is the step from raw API response (e.g. JSON string) to structured in-memory data. Use a robust JSON library; validate required fields and types before using them. Malformed or partial responses should not overwrite good state—log the error and skip the update or retry later. The AsianOdds88 pipeline parses API responses and only writes to Redis when the parsed structure passes basic validation; this keeps **failure handling** predictable.

**Idempotency and overwrites.** If the same market is updated twice in one poll, you typically overwrite the previous value with the latest. Use “latest” keys (e.g. by event and selection) so that consumers always read the most recent price. For history (e.g. time series of odds), you would append to a list or stream; that is a separate design from “latest snapshot” ingestion.

---

## Normalization Problems and Canonical Schema

**Normalization** is the process of converting API-specific structures into a canonical schema your pipeline uses internally. Problems you will face: (1) different IDs for the same event across bookmakers, (2) different market names (e.g. “1X2” vs “Match Result”), (3) different price formats (decimal vs fractional vs American). Define a single internal representation (e.g. decimal odds, canonical market type enum) and map every feed into it. The AsianOdds88 system normalizes into a common format before writing to Redis; downstream components never see the raw API shape. In a multi-bookmaker system, you would also need a matching layer (e.g. by team names and start time) to align events across books.

---

## Execution Safety and Retry Handling

**Execution safety** means: do not double-place, do not place with stale prices, and do not ignore risk limits. Implement (1) a concurrency lock per market or selection so only one placement is in flight at a time, (2) a check that the price used for the decision is still valid (or within a tolerance) at placement time, and (3) a final risk check (daily loss, exposure, kill switch) immediately before calling the placement API. The AsianOdds88 Trading System uses an execution lock manager (Redis locks with TTL) and a risk guard; the order router and execution engine perform the final checks and **retry handling**.

**Retry handling** for placement: on transient failures (network timeout, 5xx, rate limit), retry a limited number of times with backoff. On permanent failures (4xx invalid request, auth error), do not retry the same request; invalidate session if needed and log. After max retries, mark the signal as failed and continue so the system does not block. Document timeouts and retry counts in your configuration so operators can tune for their environment.

---

## Risk Controls

**Risk controls** protect capital and enforce operator-defined limits. Common controls: (1) **fixed or max stake** per bet, (2) **daily loss limit** (stop when PnL is below a threshold), (3) **exposure cap** (max total outstanding risk), (4) **cooldowns** (no new bet on the same event/selection for N seconds), (5) **blacklists** (leagues or market types to skip), (6) **kill switch** (global disable of all placement). Implement these in a dedicated component that writes to Redis (e.g. “trading enabled” flag); the execution layer must read and respect them before every placement. The AsianOdds88 system’s risk guard and execution engine are designed this way; your own **python betting automation backend** should enforce risk at a single point so it cannot be bypassed.

---

## Scheduling and Process Layout

**Scheduling** here means how often you poll, and how you run the processes (single script vs multiple processes). A typical layout: one long-running ingest process that polls every N seconds and writes to Redis; one or more decision processes that read from Redis and publish signals; one execution process that consumes signals and places bets. Use a process manager (systemd, supervisord) or container orchestration so that crashed processes restart. The AsianOdds88 Trading System uses separate executables for ingest, validators, execution engine, order router, dashboard, etc., started by a single `start.bat` or `start.sh`; the same idea applies if you build a monolithic script or a microservice-style deployment.

---

## Logging and Observability

**Logging** should be structured (e.g. JSON or key-value) with timestamp, level, component, and message. Include enough context (event id, selection id, outcome) for debugging and audit. Never log full credentials or session tokens. The AsianOdds88 pipeline documents a **logging philosophy** in its architecture: structured logs, no secrets, audit trail for placements. Add a dashboard or metrics (e.g. Prometheus) for production so you can monitor ingest latency, placement success rate, and risk metrics without parsing logs by hand.

---

## Using This Repository as a Real Example

The [AsianOdds88 Trading System](https://github.com/rovidev95/AsianOdds88-Trading-System) repository provides a working example of the above: **sportsbook API** integration (AsianOdds88), **odds ingestion** and normalization into Redis, a **trading decision engine** (validators, edge evaluator), an **execution module** with **retry handling** and risk checks, and **logging** and a dashboard. The public repo contains no source code but includes documentation (README, architecture deep dive, this guide) and one-command installers plus binary releases. You can:

- Install the system and run it in DRY mode to see how odds flow and how signals are produced without placing real bets.
- Read the architecture and configuration docs to see how **parsing**, **normalization**, **execution safety**, and **risk controls** are designed.
- Use the same patterns (Redis keys, lock semantics, env-based config) when building your own **sports betting automation** in Python.

This tutorial has covered **sportsbook APIs**, **odds feeds**, **polling vs streaming**, **parsing odds**, **normalization problems**, **execution safety**, **retry handling**, **risk controls**, **scheduling**, and **logging**. With these concepts and the repository as a reference, you can design and implement a **real-time sports data pipeline** and **python betting automation backend** suited to your own requirements and bookmaker APIs.
