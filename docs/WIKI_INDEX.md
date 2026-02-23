# Wiki Index — AsianOdds88 Trading System

Central index for documentation, guides, and troubleshooting. Use this page to find the right document for your task.

---

## Getting Started

Start here if you are new to the project. You will find how to obtain a license, download the package (one-command install or manual), configure environment and Redis, and run the system. The goal is to have the pipeline and dashboard running in under a few minutes.

**Key documents:** [GET_STARTED.md](../GET_STARTED.md) (root), [docs/INSTALL.md](INSTALL.md).

---

## System Architecture

Technical description of the pipeline: ingestion, normalization, decision engine, execution module, and observability. Use this when you need to understand data flow, component responsibilities, latency, failure handling, and scaling.

**Key documents:** [ARCHITECTURE_DEEP_DIVE.md](ARCHITECTURE_DEEP_DIVE.md), [SYSTEM_OVERVIEW.md](../SYSTEM_OVERVIEW.md) (root).

---

## Configuration Guide

How to configure the system via environment variables or `.env`: execution mode, Redis, credentials, stake and risk parameters, timeouts, retries, and optional features. Includes a list of all variables and where to set the license.

**Key documents:** [ENV_AND_CONFIG.md](ENV_AND_CONFIG.md), root [.env.example](../.env.example), [examples/example_config.yaml](../examples/example_config.yaml).

---

## Execution Engine Explained

How the execution and order routing layer works: lock acquisition, risk checks, placement API calls, retry handling, and dry-run vs live behavior. Useful when debugging placement failures or tuning timeouts and retries.

**Key documents:** [ARCHITECTURE_DEEP_DIVE.md](ARCHITECTURE_DEEP_DIVE.md) (execution and failure sections), [examples/example_execution_flow.md](../examples/example_execution_flow.md).

---

## Troubleshooting

Common issues and how to resolve them: license errors, Redis connection failures, API auth failures, missing or stale odds, placement timeouts, and dashboard not loading. Includes where to look in logs and Redis, and how to verify configuration.

**Key documents:** [INSTALL.md](INSTALL.md) (verify section), [ARCHITECTURE_DEEP_DIVE.md](ARCHITECTURE_DEEP_DIVE.md) (failure handling), README [FAQ](../README.md#faq-20-developer-questions).

---

## FAQ

Frequently asked questions: 24/7 operation, live betting, other sportsbook APIs, research use, risk control, Python requirement, source code location, license, VPS deployment, macOS, credentials, backtesting, parameter tuning, dashboard security, and maintenance. Answers are short with pointers to deeper docs.

**Key documents:** [README.md](../README.md) (FAQ section), [LICENSE_INFO.md](LICENSE_INFO.md).
