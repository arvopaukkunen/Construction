# ADR – InfluxDB as First Durable Capture, Thin Node-RED RAW Bridge, and DuckDB/dbt Starting After MinIO RAW

- **Status:** Accepted
- **Date:** 2026-04-06
- **Context:** Home IT on-prem data platform

## 1. Context

The current platform has these characteristics:

- Node-RED is strong at source and device integration:
  - REST
  - MQTT
  - Modbus
  - mixed on-prem and cloud device APIs
- InfluxDB2 already serves successfully as:
  - realtime monitoring source
  - first durable capture of telemetry
  - hot/raw operational history
  - replayable history within retention windows
- MinIO is the intended object lake for:
  - RAW
  - WORK
  - CURATED
- dbt with DuckDB has already been proven to read MinIO successfully.
- MariaDB is the chosen serving database for:
  - decision tables
  - presentation tables
  - command queue
  - ops logs

The main problem identified is that Node-RED has grown into an ETL/ELT engine. It currently performs too much enrichment and transformation before and during RAW→WORK promotion.

## 2. Decision

We adopt the following architecture:

```text
Devices
 -> Node-RED
 -> InfluxDB   (first durable capture, hot + replay source)
 -> Node-RED   (thin bridge only)
 -> MinIO RAW
 -> DuckDB/dbt (normalize, dedup, validate, conform)
 -> MinIO CURATED
 -> MariaDB decision_* and present_* latest-serving tables
 -> Node-RED command queue / MQTT dispatch
 -> Device adapters / real actuation
```

## 3. Node-RED role

Node-RED is explicitly limited to two operational roles:

1. **Source integration**
   - collect data from devices and services
   - write hot telemetry into InfluxDB

2. **Thin replay/landing bridge**
   - read source-shaped telemetry from InfluxDB
   - land source-shaped records into MinIO RAW
   - perform no business enrichment

Node-RED must not remain the long-term place for:
- semantic enrichment
- lifecycle/business classification
- deduplication
- conformance
- relational RAW/WORK modeling
- decision logic

## 4. Why InfluxDB is the first durable capture

InfluxDB is chosen as the first durable capture because it already exists and already works.

This gives:
- replay/backfill capability
- ability to rebuild RAW landings
- ability to recover from MinIO landing errors
- lower risk than one-time direct object writes from Node-RED

This is preferred over direct simultaneous write from Node-RED to both InfluxDB and MinIO as the primary design.

## 5. Why MinIO RAW is built from InfluxDB

MinIO RAW is intended to be:
- replayable
- immutable
- source-shaped
- minimal in technical metadata
- free of business enrichment

Using InfluxDB as the replay source allows RAW to be rebuilt if:
- landing goes wrong
- enrichment logic changes
- backfill is needed
- disaster recovery is required

## 6. Why DuckDB/dbt starts after MinIO RAW

DuckDB/dbt is not the first landing tool in this architecture.

DuckDB/dbt starts **after** MinIO RAW because its role is:
- normalize
- deduplicate
- validate
- conform
- materialize curated outputs

DuckDB is used as a transformation engine, not as the final serving database.

## 7. Data layer definitions

### RAW
- immutable
- source-shaped
- replayable
- no semantic enrichment

### WORK
- optional technical staging
- reshaping / compaction only
- not the final business truth

### CURATED
- typed
- deduplicated
- quality-checked
- conformed
- decision-ready

CURATED becomes the stable analytical source.
MariaDB receives selected current-serving outputs from CURATED/dbt models.

## 8. Serving layer

MariaDB remains the serving database for:
- `decision_*`
- `present_*`
- `ops_*`
- `decision_command_queue`

This avoids using DuckDB as the final serving system.

## 9. Consequences

### Positive
- Node-RED is reduced back to what it does best
- replay and backfill are available through InfluxDB
- RAW becomes meaningfully raw
- enrichment and conformance become testable in dbt
- CURATED becomes the stable analytical source
- MariaDB remains the operational serving database

### Negative / trade-offs
- Node-RED still exists in two places in the path
- there is a two-step persistence path:
  - first to InfluxDB
  - then to MinIO RAW
- a small bridge/orchestration layer remains necessary until a better direct export path is adopted

## 10. Immediate implementation priority

The next priority is **Ruuvi-first environmental modeling**, not device actuation.

Order:
1. `RuuviGTW`
2. `victron_source` battery-room temperatures
3. conformed room climate model
4. later Netatmo/Legrand CO2 and climate fusion
5. later decision logic for air quality / comfort
6. later real device adapters

## 11. Implementation guidance

### Near-term
- freeze current legacy Node-RED ETL-heavy flows
- create thin InfluxDB -> MinIO RAW landing flow
- stop semantic enrichment before RAW
- stop SQL RAW/WORK loading from Node-RED

### dbt models to build next
- `stg_ruuvi_gtw`
- `stg_victron_env`
- `int_room_climate_4min`

## 12. Final statement

Node-RED is allowed as a **thin RAW bridge**, but all meaningful transformation begins only after MinIO RAW and is handled by DuckDB/dbt. CURATED is the stable analytical source, and MariaDB remains the latest-serving operational database.
