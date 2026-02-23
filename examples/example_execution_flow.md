# Example Execution Flow

This document describes a single execution path from odds update to placement (or dry-run skip) in the AsianOdds88 Trading System. It is for reference and documentation only.

## Step 1 — Ingest writes latest odds

The ingest process polls the API, parses the response, and writes normalized odds to Redis:

- Key: `odds:latest:{event_uid}:{selection_id}`
- Value: JSON with price, timestamp, bookmaker id, etc.
- Optional: TTL or overwrite-only (no TTL).

## Step 2 — Decision pipeline reads and validates

- Movement tracker and signal density engine read from Redis and may publish or filter signals.
- Market validator reads `odds:latest:*` and checks liquidity, age, and consistency. If checks pass, the signal is allowed to proceed.
- Math edge evaluator applies EV and sharp-consensus rules. If the signal meets thresholds, it is pushed to the execution stream or key.

## Step 3 — Execution lock

- The execution engine or order router receives the signal.
- It attempts to acquire a Redis lock for the (event_uid, selection_id) with a TTL (e.g. 30–60 seconds). If the lock is already held, the signal is skipped or retried later.

## Step 4 — Final risk check

- The risk guard state is read from Redis (e.g. daily PnL, kill switch).
- If the kill switch is set or daily loss limit is exceeded, placement is aborted and the signal is discarded or logged.

## Step 5 — Placement or dry-run

- **DRY mode:** The order router logs that it would have placed (event, selection, stake, price) and does not call the API. Lock is released.
- **LIVE mode:** The order router calls the placement API with timeout and retries. On success, it writes the order id and status to Redis and logs. On permanent failure, it may invalidate the session. On transient failure, it retries with backoff up to the configured max.

## Step 6 — Dashboard and logs

- The dashboard reads balance, outstanding, and recent bets from Redis and displays them.
- All placement attempts (success, failure, dry-run) are written to logs for audit and troubleshooting.

This flow is consistent with the architecture described in **docs/ARCHITECTURE_DEEP_DIVE.md** and the configuration in **examples/example_config.yaml**.
