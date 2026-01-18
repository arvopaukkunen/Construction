# Home IT Data Pipeline – Target-State Design and Implementation Plan

**Date:** 2026-01-18  
**Scope:** MinIO + Node-RED + MariaDB + dbt – multi-source ingestion, RAW→WORK→CURATED→ARCHIVE with strict lifecycle and recovery guarantees.

---

## 1. Objectives

The target-state pipeline must:

1. **Receive source data from any sources into MinIO `raw` bucket** (files, events, JSON, CSV, Parquet, blobs).
2. **Receive relational data from any relational database into MariaDB `raw_*` tables** (separate ingestion path).
3. **Perform no deduplication or expensive checks in RAW** (neither MinIO raw nor MariaDB raw).
4. **Enrich and deduplicate only after landing in WORK** (MinIO work and/or MariaDB work).
5. **Promote data to CURATED** (MinIO curated + MariaDB curated) as stable consumer-ready assets.
6. **Write to MinIO ARCHIVE as the “perfect recovery source”**—immutable golden copy sufficient to rebuild curated tables.

---

## 2. Zones, Layers, and Contracts

### 2.1 MinIO Zones (Buckets)

- **`raw/`**  
  - Ingest-only zone.  
  - Minimal/no validation; fastest possible landing.  
  - **Short retention**.

- **`work/`**  
  - First trusted zone.  
  - **Enrichment + dedup** occurs here.  
  - Data is normalized to stable identity keys and time bucketing rules.

- **`curated/`**  
  - Stable, consumer-ready payloads aligned to curated MariaDB tables.  
  - Must be **synchronized** with MariaDB curated state.

- **`archive/`**  
  - Immutable “perfect data” golden copy.  
  - Written **only from CURATED**.  
  - Sufficient to rebuild curated tables and downstream marts.

### 2.2 MariaDB Layers (Schemas/Tables)

- **`raw_*` tables**: append-only, short retention, no dedup.
- **`work_*` tables**: conformed keys, enrichment, dedup; dbt sources should point here.
- **`curated_*` tables**: stable serving layer, synchronized with MinIO curated; rebuildable from archive.

---

## 3. Canonical Dataflows

### 3.1 Path A: Any-source payloads → MinIO RAW

1. Producers write objects into **MinIO `raw`**.
2. MinIO event triggers Node-RED promotion **RAW → WORK**.
3. In WORK:
   - Enrich lifecycle/classification metadata.
   - Normalize time bucketing.
   - Apply dedup policy.
   - Optionally load to MariaDB `work_*` tables.
4. Promote **WORK → CURATED** with quality gates.
5. Promote **CURATED → ARCHIVE** as immutable golden copy.

### 3.2 Path B: Relational sources → MariaDB RAW

1. Relational sources land extracts/CDC into MariaDB **`raw_*`** quickly (append-only).
2. A promotion job (Node-RED or dbt orchestration) moves **raw → work**, applying:
   - Key normalization
   - Enrichment
   - Dedup policy
3. dbt builds curated and marts from WORK/curated as required.

---

## 4. Folder and Naming Convention (MinIO)

A uniform path for all sources:

```
{domain}/{source_system}/{entity}/{format_or_grain}/ingest_date=YYYY-MM-DD/run_id=.../file...
```

Examples:
- `iot/influxdb/sensors/json/ingest_date=2026-01-18/run_id=.../influx_4min_...json`
- `relational/postgres/orders/parquet/ingest_date=2026-01-18/run_id=.../orders_...parquet`
- `api/netatmo/homesdata/json/ingest_date=2026-01-18/run_id=.../homesdata_...json`

---

## 5. Key Design Principles and Non-Negotiables

1. **RAW is transient and append-only**
   - No unique constraints enforcing dedup in RAW.
   - No `ON DUPLICATE KEY UPDATE` in RAW.

2. **WORK enforces the grain and dedup**
   - Example grain: `(time_epoch, entity_id, measurement, source)`
   - Enrichment happens here.

3. **CURATED is a contract**
   - MinIO curated objects and MariaDB curated tables must represent the same data for each partition/run.

4. **ARCHIVE is written only from CURATED**
   - Immutability and long retention.
   - Must be sufficient for recovery.

5. **dbt sources point to WORK**
   - `stg_*` and `md_*` produce stable, quality-checked layers feeding `intermediate_*` and `mart_*`.

---

## 6. Current-State Observations and Required Alignment Change

### 6.1 Current contradiction with the stated requirement

Today, MariaDB `raw_sensoraverages` includes:

- `UNIQUE KEY uq_raw_grain (time_epoch, entity_id, measurement)`
- Node-RED uses `ON DUPLICATE KEY UPDATE`

This performs dedup at RAW, which conflicts with:

> “No duplicate checks is needed to do until data is safely in work buckets or work tables.”

### 6.2 Target fix

To align the implementation with the requirement:

- **Remove RAW uniqueness constraints (recommended)** and treat RAW as append-only.
- Move dedup enforcement to **WORK** (MinIO and MariaDB).

---

## 7. WORK and CURATED Guarantees

### 7.1 WORK must guarantee

- Stable identity fields exist: `entity_id`, `measurement` (long-form metric id), `source`.
- Deterministic time bucketing (e.g., 4-minute boundary).
- Dedup policy is defined and applied.
- Enrichment is performed (SensorMeta, location/room/building normalization, domain normalization).
- Lifecycle and lineage fields (`RAW*`, `WORK*`) are carried forward.

**Important:** measurement should be long-form (typically `_field`) to avoid collisions.

### 7.2 CURATED must guarantee

- Stable, consumer-ready state (quality checked).
- **Synchronized** representation across MinIO curated objects and MariaDB curated tables.
- Rebuildable from archive.

---

## 8. Manifests (Operational Synchronization and Recovery)

Introduce lightweight manifest tables:

- `work_object_manifest`
- `curated_object_manifest`
- `archive_object_manifest`

Each manifest record should include:
- `run_id`
- `source_system`, `entity`
- MinIO object key(s)
- `row_count`, `min_time_epoch`, `max_time_epoch`
- Optional checksum/hash
- Promotion timestamps and statuses

Benefits:
- Deterministic synchronization verification
- Auditable lineage
- Targeted replay/recovery by run or partition

---

## 9. Retention and Lifecycle Policy

### 9.1 MinIO retention

- `raw/`: hours to 1–2 days
- `work/`: 7–30 days (depends on reprocessing needs)
- `curated/`: optional medium retention if archive is perfect
- `archive/`: long retention, immutable

Prefer MinIO lifecycle policies over custom deletes where possible.

### 9.2 MariaDB retention

- `raw_*`: purge aggressively (hours/days)
- `work_*`: retain for analytics + dbt incremental builds
- `curated_*`: retain as serving layer

Implement purge via MariaDB Events, Node-RED scheduled cleanup, or similar operational jobs.

---

## 10. Node-RED Flow Changes Required

### 10.1 Influx → RAW (current “InfluxToMariaDb v6” flow)

To align with “no dedup until WORK”:
- Remove `ON DUPLICATE KEY UPDATE` from RAW inserts.
- Remove UNIQUE constraints from `raw_*` tables (or move them to WORK).

### 10.2 MinIO RAW → WORK promotion (current v2)

This flow already:
- Enriches lifecycle/classification
- Normalizes time bucketing
- Writes to MinIO work and MariaDB work
- Deletes from MinIO raw

Enhance by:
- Writing `work_object_manifest` record per promoted object.

### 10.3 MinIO WORK → CURATED promotion (current clean v1)

This flow already:
- Promotes oldest-first
- Writes to curated bucket and MariaDB curated
- Deletes from work

Enhance by:
- Writing `curated_object_manifest`
- Introducing quarantine handling for rows missing required key fields

### 10.4 Missing flow: CURATED → ARCHIVE

Add a promotion step:
- Copy curated object → archive object
- Only after curated object + curated DB insert succeed
- Write `archive_object_manifest`
- Enforce immutability and partitioning

---

## 11. Security Note

The exported Node-RED flow JSON contains sensitive Netatmo credentials (client secret + refresh token).  
These should be treated as compromised:

- Rotate secrets
- Move secrets to Node-RED credential store or environment variables
- Avoid exporting secrets in flow JSON

---

## 12. Implementation Approach (next steps)

The agreed next step is to implement **flow-by-flow and layer-by-layer**, delivering:

1. **Import-ready Node-RED flows** (one by one)
2. **Copy/paste-ready MariaDB SQL migration scripts** for:
   - RAW uniqueness removal and append-only enablement
   - WORK grain enforcement
   - Manifest table creation
   - Retention/purge mechanisms

---

## Appendix A: Existing Tables (as provided)

### A.1 `smarthome.raw_sensoraverages`

(As currently defined; will be modified to remove dedup-at-RAW.)

### A.2 `smarthome.work_sensoraverages`

WORK table already includes uniqueness on `(time_epoch, entity_id, measurement)`.

### A.3 `smarthome.curated_sensoraverages`

CURATED table includes uniqueness on `(time_epoch, entity_id, measurement, source)`.

---

**End of document**
