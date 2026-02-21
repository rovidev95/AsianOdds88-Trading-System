# KETER Trading System — Resumen Completo (para Opus)

**Documento de alto nivel** que describe el sistema completo de ejecución de apuestas deportivas. Pensado para que un modelo como Opus comprenda arquitectura, flujo de datos, tecnologías y objetivos en una sola lectura.

---

## 1. Objetivo del Sistema

**KETER** es un *pipeline de ejecución institucional* para **apuestas deportivas en vivo**. El objetivo es:

1. **Descubrir oportunidades** de valor (mispricings, presión de mercado, EV positivo) en tiempo real mediante feeds de casas de apuestas.
2. **Validar** cada señal antes de ejecutar: liquidez, slippage, frescura del precio.
3. **Evaluar** el edge matemático (Poisson, consenso de bookies sharp).
4. **Ejecutar** órdenes en la API de **AsianOdds88** (broker principal) con control de riesgo y concurrencia.

El sistema opera de forma **automatizada** en modo LIVE, usando stake fijo (p. ej. 0.30 unidades) y límites de pérdida diaria y racha perdedora.

---

## 2. Paradigma y Stack Tecnológico

| Aspecto | Detalle |
|---------|---------|
| **Arquitectura** | Pipeline descentralizado, event-driven, con gates de seguridad |
| **Lenguaje** | Python 3.x (asyncio) |
| **Broker de mensajería** | **Redis** (Listas, Sets, Hashes, Streams opcionales) |
| **Broker de apuestas** | **AsianOdds88** (API REST: Login, GetFeeds, PlaceBet, GetAccountSummary) |
| **Feed secundario** | **Betfair** (streaming, BookieCode BFX) para liquidez y presión de mercado |
| **Persistencia fría** | JSONL (telemetría, trazabilidad) |
| **Entorno** | Windows 11 (local) y **AWS EC2** (Singapore, ap-southeast-1) en producción |

---

## 3. Flujo de Señales (High-Level)

```
[Fuentes de datos]
    AsianOdds Ingest (polling API)  ──┐
    Betfair Streamer (WebSocket)   ──┤
                                     │
[Descubrimiento / Análisis]          │
    Movement Tracker (feed_data) ──────┼──► raw_signals_queue_legacy
                                     │         │
                                     └─────────┘
                                              ▼
[Validación]                    Market Validator (liquidez >800, slippage <1.2%)
                                              │
                                              ▼
                                    validated_signals_queue_legacy
                                              │
[Evaluación de edge]              Math Edge Evaluator (Poisson, Sharp Whitelist)
                                              │
                                              ▼
                                 final_execution_confirmed_legacy
                                              │
[Control de concurrencia]         Lock Manager (SETNX, throttle global)
                                              │
[Decisión de stake]               Execution Engine (prioridad, stake, exposure)
                                              │
[Ejecución real]                  Order Router (PlaceBet API AsianOdds88)
                                              │
                                              ▼
                                    [Logs / Telemetría / Risk Guard]
```

---

## 4. Módulos Activos (por orden en el stack)

| # | Módulo | Script | Función |
|---|--------|--------|---------|
| 1 | **AsianOdds Ingest** | `src/asianodds_ingest.py` | Login, Register, polling GetFeeds (deportes 1,2,5). Escribe `raw_signals_queue_legacy`, `heartbeat:ingest:flow`, `heartbeat:ao_ingest_ultimate`, `account:balance`, `account:pnl:daily`, `account:outstanding`, `logs/balance_history.jsonl`. |
| 2 | **Movement Tracker** | `src/movement_tracker.py` | Análisis presión/volumen en feeds. Escribe `raw_signals_queue_legacy`. |
| 3 | **Signal Density Engine** | `src/signal_density_engine.py` | Cooldown, límite trades por partido, escalado de stake. |
| 4 | **Market Validator** | `src/market_validator.py` | Liquidez mínima variable, slippage por banda de cuota. Cooldown tras HIGH_SLIPPAGE; blacklists liga/mercado (`LEAGUE_BLACKLIST`, `MARKET_TYPE_BLACKLIST`). Escribe `validated_signals_queue_legacy` o cancela. |
| 5 | **Math Edge Evaluator** | `src/math_edge_evaluator.py` | EV vs consenso sharp (`SHARP_WHITELIST`). `MIN_SHARP_SOURCES`, `MAX_CONSENSUS_SPREAD_PCT`, `MIN_EV_PCT`. Ventana de confirmación (`CONFIRMATION_WINDOW_SEC`), cooldown por evento. Escribe `final_execution_confirmed_legacy`. |
| 6 | **Execution Lock Manager** | `src/execution_lock_manager.py` | SETNX por event/selection, throttle. Consume `final_execution_confirmed_legacy`, escribe `order_submission_queue_legacy`. |
| 7 | **Execution Engine** | `src/execution_engine.py` | Prioridad, stake (FIXED_STAKE o auto_config); opcionalmente proporcional al EV (`EV_MAX_PCT`). Escribe `order_submission_queue_legacy`. |
| 8 | **Risk Guard** | `src/risk_guard.py` | Límite pérdida diaria, racha perdedora, GLOBAL_STOP. |
| 9 | **Order Router** | `src/order_router.py` | GetPlacementInfo + PlaceBet. Recheck EV antes de PlaceBet; cooldown evento en EV_DROPPED (`COOLDOWN_EVENT_SEC`). Backoff exponencial, alertas, `heartbeat:order_router`. Escribe `bet_history.jsonl` (con `ev_at_place`), `would_have_bets.jsonl`. |
| 10 | **Dashboard** | `scripts/dashboard_server.py` | HTTP 8080. Saldo disponible, comprometido, stake máx, PnL hoy, confirmadas/rechazadas, heartbeats, alertas. APIs: `/api/status`, `/api/history`, `/api/alerts`. |

**Nota:** El stack por defecto se arranca con `scripts/aws/restart_all.sh` (no incluye Betfair Streamer ni Telemetry Daemon en el arranque estándar).

---

## 5. Colas Redis Principales

| Cola | Productores | Consumidores |
|------|-------------|--------------|
| `feed_data_legacy` | Betfair Streamer | Movement Tracker |
| `raw_signals_queue_legacy` | AsianOdds Ingest, Movement Tracker | Market Validator |
| `validated_signals_queue_legacy` | Market Validator | Math Edge Evaluator |
| `final_execution_confirmed_legacy` | Math Edge Evaluator | Lock Manager, Execution Engine, Order Router |
| `order_submission_queue_legacy` | Lock Manager, Execution Engine | Signal Density (estado), otros |
| `pressure_signals_legacy` | (legacy / posible bypass) | Signal Density Engine |
| `density_passed_signals_legacy` | Signal Density Engine | (posible consumo por Execution Engine en modo híbrido) |

**Nota**: Lock Manager, Execution Engine y Order Router comparten la misma cola `final_execution_confirmed_legacy`; con `brpop` compiten por cada mensaje. El diseño real puede variar según qué consumidor procesa primero.

---

## 6. Claves Redis Importantes

| Clave | Uso |
|-------|-----|
| `odds:latest:{event_uid}:{selection_id}` | Snapshot precio/liquidez. Validator, Edge, Order Router. |
| `exec_lock:{event_uid}:{selection_id}` | Lock ejecución (SETNX, TTL 20s). |
| `ao:session:token`, `ao:session:key`, `ao:session:url` | Sesión AsianOdds88 (Login/Register desde ingest). |
| `account:balance`, `account:pnl:daily`, `account:outstanding`, `account:max_stake`, `account:last_updated` | Saldo, PnL/Outstanding, comprometido, stake máx (API), última actualización. |
| `heartbeat:ingest:flow`, `heartbeat:ao_ingest_ultimate` (TTL 90s/120s), `heartbeat:order_router` (TTL 60s) | Heartbeats para monitorización; dashboard muestra segundos desde último latido. |
| `alert:order_router_consecutive_timeouts` | Alerta cuando TimeoutError consecutivos > ALERT_CONSECUTIVE_TIMEOUTS. |
| `cooldown:event:{event_uid}` | Cooldown tras EV_DROPPED o HIGH_SLIPPAGE (TTL COOLDOWN_EVENT_SEC). |
| `stats:consecutive_low_ev`, `alert:consecutive_low_ev` | Racha LOW_EV; alerta si ≥ ALERT_LOW_EV_STREAK. |
| `GLOBAL_STOP`, `risk:daily_pnl:{date}` | Risk Guard. |
| Colas: `raw_signals_queue_legacy`, `validated_signals_queue_legacy`, `final_execution_confirmed_legacy`, `order_submission_queue_legacy` | Pipeline de señales. |

---

## 7. APIs Externas

### AsianOdds88 (principal)

- **Login**: `.../Login` → token, key, URL de cluster.
- **GetFeeds**: `.../getfeeds` (o GetFeeds) → ligas, partidos, mercados, odds.
- **PlaceBet**: `POST .../PlaceBet` con body JSON (doc 4.6): GameId, GameType (H|O|X), OddsName, BookieOdds, Amount, PlaceBetId, MarketTypeId, OddsFormat, IsFullTime, SportsType.
- **GetAccountSummary**: Credit, Outstanding.

Códigos de error frecuentes: -1212, -1200 (backend inestable; se reintenta con backoff).

### Betfair

- Streaming de market books (betfairlightweight).
- BookieCode `BFX` en el sistema unificado.

---

## 8. Parámetros de Riesgo y Seguridad

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| Daily Loss Limit | 14 unidades | Paro global automático. |
| Losing Streak | 7 pérdidas consecutivas | Bloqueo temporal ~20 min. |
| Slippage máx. | Por banda (ej. >3: 1%, 2–3: 2%, resto 1.2%) | Market Validator. |
| Liquidez mín. | Variable (base 400, LIQUIDITY_STAKE_MULTIPLIER) | Market Validator. |
| Stake fijo (LIVE) | 0.30 u | FIXED_STAKE; opcional stake ∝ EV (EV_MAX_PCT). |
| Stake máximo duro | 2.5 u | En Order Router. |
| Cooldown evento | 60 s (COOLDOWN_EVENT_SEC) | Tras EV_DROPPED o HIGH_SLIPPAGE. |
| Throttle | 6 trades / 12 s | En Lock Manager. |

---

## 9. Despliegue y Operación

### Local (Windows)

- `start_live_safe_core.ps1`: arranca los módulos en ventanas minimizadas.
- `EXECUTION_MODE=LIVE`, `FIXED_STAKE=0.30`.

### EC2 (Singapore)

- **Host:** `54.255.208.25` (config en `local/remote.config`: REMOTE_HOST).
- Usuario: `ubuntu`. Proyecto: `/home/ubuntu/TradingChino`.
- **Arranque estándar:** `bash scripts/aws/restart_all.sh` (mata procesos previos, lanza 9 módulos + dashboard).
- **Deploy:** `.\scripts\aws\deploy_and_start.ps1` (completo) o SCP de archivos tocados + `bash scripts/aws/remote_restart_and_verify.sh`.
- **Dashboard:** http://54.255.208.25:8080 — Saldo disponible, Comprometido, Stake máx, PnL hoy, Confirmadas/Rechazadas, heartbeats, alertas. APIs: `/api/status`, `/api/history`, `/api/alerts`.

### Configuración remota

- `local/remote.config`: REMOTE_HOST, SSH_USER, REMOTE_PROJECT_PATH. Clave SSH: `TradingChino.pem` o `TradingChinoKey.pem` (raíz).

---

## 10. Logs y Monitoreo

- **logs/live.log**: salida agregada de los 9 módulos; **logs/dashboard.log**: dashboard.
- **logs/bet_history.jsonl** (con ev_at_place), **logs/balance_history.jsonl**: historial de apuestas y saldo (order_router e ingest).
- **logs/would_have_bets.jsonl**: apuestas no colocadas (SKIPPED, EV_DROPPED, LOCK_EXISTS, etc.) para análisis con liquidación futura.
- **view_balance.ps1**: saldo vía Redis; heartbeat desde `heartbeat:ingest:flow` o `heartbeat:ao_ingest_ultimate`.
- **view_logs.ps1**: tail de logs remotos.
- **verify_remote.ps1**: comprueba Redis, heartbeats (ingest + ao_ingest_ultimate), sesión AO, **9 procesos** `python3 -u src/`, **dashboard** en 8080 y `account:balance`.

### Verificación post-deploy (EC2) — última versión activa

1. `.\local\verify_remote.ps1` — debe mostrar Redis PONG, heartbeats recientes, sesión AO, 9 procesos + dashboard, balance.
2. Abrir http://54.255.208.25:8080 — comprobar Saldo disponible, Comprometido, Stake máx/apuesta, Order router (s), alertas si aplica.
3. Si falta algo: subir archivos modificados por SCP y en EC2 ejecutar `bash scripts/aws/restart_all.sh`.

---

## 11. Archivos Clave de Referencia

- **docs/SISTEMA_Y_TECNOLOGIA_COMPLETO.md** — documento único para valoración externa (ChatGPT/Opus): stack, módulos, Redis, order_router, alertas, dashboard, despliegue, verificación.
- **docs/ESCALABILIDAD_EC2.md** — upgrade a t3.medium/c5.large, multi-EC2, ElastiCache.
- `docs/ASIANODDS88_API_RESEARCH_2026.md` — investigación API AsianOdds88.
- `scripts/aws/restart_all.sh` — script estándar de arranque en EC2.

---

## 12. Resumen Ejecutivo (una frase)

**KETER** es un pipeline de apuestas deportivas que ingesta feeds de AsianOdds88, valida señales (liquidez variable, slippage por banda, blacklists liga/mercado, cooldown por evento), evalúa edge matemático (consenso sharp configurable, ventana de confirmación, recheck EV en router) y ejecuta en AsianOdds88 con control de riesgo, backoff ante timeouts, alertas (Redis + webhook opcional), registro de apuestas no colocadas (`would_have_bets.jsonl`) y dashboard con saldo disponible, comprometido y stake máx, usando Redis y Python asyncio.
