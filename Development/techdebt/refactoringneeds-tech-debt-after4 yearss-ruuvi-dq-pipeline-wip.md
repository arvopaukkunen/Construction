# Ruuvi Sensor Data Quality and Pipeline Stabilization

_Work in progress design note for GitHub_

Date: 2026-03-22  
Scope: MinIO RAW/WORK/CURATED, InfluxDB2 `sensors`, MariaDB `smarthome`, Node-RED ETL flows  
Focus: Ruuvi data quality, metadata correctness, stage semantics, relational stabilization
Why now: After 4 years of implementing averything directly to production, the expected refactoring and technical debt is must be done. All is working as planned, but when going to full automation there is quite a lot of those things that can not be 'I'll fix them when time is right' - the time is now..
---

## 1. Purpose

This document captures the current state of the home IoT sensor data pipeline, the original intended design, the main implementation drift that has occurred, and a practical stabilization plan.

The immediate target is RuuviTag data quality:

- find all Ruuvi data rows and points across MinIO, InfluxDB2, and MariaDB
- verify source attribution
- verify enrichment correctness
- verify identity and grain consistency
- verify that location metadata is populated and accurate
- establish a staged DQ model that can later be automated with Node-RED

This document is intentionally work-in-progress and should evolve as the pipeline is corrected.

---

## 2. Original intended design

The intended design was:

- **RAW**: ingest source data into MinIO RAW bucket
- **WORK**: enrich RAW data and add lifecycle / classification metadata
- **CURATED**: perform final DQ, remove overlapping timeseries duplication, produce stable final relational staging data
- **MariaDB**: store stable, quality-checked stage data for reporting and downstream use

In words:

- MinIO is the object-based landing zone
- MariaDB is the structured stage/store for validated data
- CURATED should be the authoritative relational truth

This design is still valid.

---

## 3. Current effective behavior

### 3.1 Step 1: InfluxDB2 -> MinIO RAW

Current Node-RED flow already does more than simple raw ingest.

It performs:

- field allowlisting
- aggregation into 4-minute windows
- canonicalization for Netatmo / Legrand rows
- canonicalization for Victron rows
- source rewriting for Ruuvi (`NodeRed` -> `RuuviGTW`)
- metadata lookup from `work_SensorMeta`
- heuristic metadata fallback for Ruuvi-like names
- RAW lifecycle fields
- MinIO JSON write into RAW bucket

### 3.2 Step 2: MinIO RAW -> MinIO WORK + MariaDB WORK

Current Step 2 does:

- list RAW JSON files
- parse RAW objects
- add RAW / WORK lifecycle fields
- normalize `_time` to 4-minute bucket boundary
- compute `time_epoch`
- attempt to normalize Ruuvi identity
- write transformed JSON to WORK bucket
- UPSERT relational rows into `work_sensoraverages`

### 3.3 Step 3: MinIO WORK -> MinIO CURATED

Current Step 3 does:

- list WORK objects
- parse JSON
- add CURATED lifecycle fields
- write JSON to CURATED bucket
- build SQL for `curated_sensoraverages`
- but MariaDB curated inserts are currently commented out / disabled for debugging

Therefore:

- CURATED object data exists or can exist
- CURATED relational truth does **not** currently exist as the final operational truth

### 3.4 Current relational truth

At present, MariaDB writes are actively used only from WORK into MariaDB.

So in practice:

- `work_sensoraverages` is currently the main relational stage
- `curated_sensoraverages` is not yet the active final truth

---

## 4. Main architectural drift

The biggest drift is that **RAW is no longer truly raw**.

### 4.1 Why RAW is not raw

The Step 1 enrichment function already injects or derives:

- `friendly_name`
- `source`
- `domain`
- `location`
- `room`
- `precise_location`
- `building`
- `comment`
- `RAWClassification_Tag`
- `RAWLifecycleName`
- `RAWLifecycle`

This means MinIO RAW is not a source-faithful ingest layer anymore. It is already a standardized and partially enriched business landing layer.

### 4.2 Why this matters

When comparing RAW -> WORK -> CURATED, one would expect:

- RAW = mostly source-shape
- WORK = enrichment introduced
- CURATED = DQ + final stable truth

But current behavior is closer to:

- RAW = standardized + partially enriched
- WORK = more enrichment + first relational truth
- CURATED = intended final layer, not fully enabled yet

This makes DQ interpretation harder unless the stage roles are explicitly redefined.

---

## 5. Current Ruuvi data model vs masterdata model

### 5.1 Current live Ruuvi shape in MinIO / Influx

Observed live Ruuvi row shape:

- `_measurement = "ruuvi"`
- `_field in ("temperature", "humidity", "rssi", "voltage", sometimes "pressure")`
- `source = "RuuviGTW"`
- `sensor_mac`
- `sensor_name`
- `sensor_suffix`
- `friendly_name`
- `location`
- `room`
- `precise_location`
- `building`

This is a gateway-native model.

### 5.2 Existing masterdata model

Existing metadata tables are mostly HA-shaped:

- `entity_id = ruuvitag_a187_temperature`
- `source = HA`
- `measurement` in `md_sensor` and `md_measurement` often stores unit-like or HA-oriented identity
- `md_location` is sparse and not keyed by `sensor_mac`

This is a Home Assistant entity model, not a gateway-native pipeline model.

### 5.3 Consequence

There are effectively two incompatible identity models:

#### Model A: gateway-native / pipeline-native

- measurement family = `ruuvi`
- metric field = `temperature`
- technical identity = `sensor_mac`
- source = `RuuviGTW`

#### Model B: HA-native / masterdata-native

- entity_id = `ruuvitag_a187_temperature`
- source = `HA`
- measurement description often embedded in master rows

These can be mapped, but they cannot be joined directly without a translation rule.

---

## 6. Concrete DQ findings already observed

From sample MinIO JSON and WORK zip inspection:

- Ruuvi rows exist as expected
- `source = RuuviGTW` appears consistently in Ruuvi rows
- `measurement family = ruuvi` and `_field` hold the actual metric
- metadata is present but not always credible

### 6.1 Main metadata quality problem

Many Ruuvi rows appear with:

- `building = House`
- `precise_location = Rooftop`
- `location = room`

Examples observed:

- `location = BottomSW`, `room = BottomSW`, `precise_location = Rooftop`
- `location = on-premises-inside-Ruuvi itä 1`, `precise_location = Rooftop`
- `location = korvausilma-tulo-vallox`, `precise_location = Rooftop`

This strongly suggests that enrichment is partially defaulted rather than sensor-specific.

### 6.2 Root cause in Step 1 flow

The Step 1 enrichment logic uses heuristics such as:

- if name starts with `ruuvitag` / `rooftop` / `insulate`
  - `location = House`
  - `room = Uppstairs`
  - `precise_location = Rooftop`
  - `building = House`

This explains the observed DQ issue directly.

### 6.3 Duplicate grain risk in WORK input set

WORK JSONs can intentionally overlap because source windows are rolling 4-minute windows emitted every 2 minutes.

This is acceptable in object storage and interim processing, but final stable relational stages must prevent duplicate business grain survival.

---

## 7. Canonical business key model

To stabilize the pipeline, a single canonical grain must be defined and preserved through all stages.

### 7.1 Recommended canonical grain for Ruuvi

Use the following business grain:

- `time_epoch` = 4-minute bucket start in milliseconds
- `entity_id` = `sensor_mac`
- `measurement` = `_field`
- `source` = `RuuviGTW`

Interpretation:

- one device
- one metric
- one time bucket
- one source system

### 7.2 Why this is the right fit

This matches the current WORK relational unique key design best:

- `uq_work_grain (time_epoch, entity_id, measurement)`

and the CURATED unique key design reasonably well:

- `ux_curated_sensoravg (time_epoch, entity_id, measurement, source)`

### 7.3 Important mapping rule

For Ruuvi rows:

- MariaDB `entity_id` should be the physical technical device key: `sensor_mac`
- MariaDB `measurement` should be the metric name: `_field`
- `source` should be the true source system: `RuuviGTW`

This should be consistent in both WORK and CURATED.

---

## 8. Stage semantics going forward

To reduce confusion, the stages should be reinterpreted as follows.

### 8.1 RAW

Role:

- standardized landing JSON
- source-windowed extract
- may contain early normalization
- not yet the final quality-controlled truth

### 8.2 WORK

Role:

- enriched intermediate stage
- lifecycle fields applied
- technical key normalization
- first structured relational persistence
- troubleshooting and audit stage

### 8.3 CURATED

Role:

- final DQ-checked truth
- overlap-resolved relational stage
- stable downstream source for reporting and analysis
- authoritative relational layer

This matches the original intent while acknowledging current implementation reality.

---

## 9. Recommended target metadata model for Ruuvi

The current `md_sensor`, `md_measurement`, and `md_location` tables are not sufficient as the sole source of truth for gateway-native Ruuvi enrichment.

### 9.1 Recommended new table

Create a dedicated Ruuvi metadata table:

```sql
CREATE TABLE smarthome.md_ruuvi_sensor (
  sensor_mac varchar(17) NOT NULL,
  sensor_suffix varchar(10) DEFAULT NULL,
  sensor_name varchar(150) DEFAULT NULL,
  friendly_name varchar(150) DEFAULT NULL,
  source varchar(50) DEFAULT 'RuuviGTW',
  domain varchar(50) DEFAULT 'sensor',
  building varchar(100) DEFAULT NULL,
  location varchar(100) DEFAULT NULL,
  room varchar(100) DEFAULT NULL,
  precise_location varchar(150) DEFAULT NULL,
  comment varchar(150) DEFAULT NULL,
  active_flag tinyint DEFAULT 1,
  PRIMARY KEY (sensor_mac)
);
```

### 9.2 Why this is needed

This table solves all of the following:

- stable sensor identity
- sensor-specific location enrichment
- elimination of friendly-name based ambiguity
- source consistency
- simple joins in Node-RED
- better DQ automation

### 9.3 Existing md tables remain useful

The current md tables can still be used for:

- legacy HA mapping
- display naming
- cross-reference to HA entities
- transitional validation

But they should not be the primary technical enrichment source for gateway-native Ruuvi data.

---

## 10. Node-RED change plan

### 10.1 Step 1 changes: Influx -> RAW

Current purpose should be narrowed.

#### Keep

- 4-minute window extraction
- field filtering
- source family extraction
- serialization to MinIO RAW

#### Change

- do not default Ruuvi metadata to generic Rooftop/Uppstairs/House values
- enrich from durable metadata keyed by `sensor_mac`
- preserve `_field` explicitly
- preserve `sensor_mac` explicitly
- if metadata is missing, leave location fields blank and optionally flag them

#### Recommended behavior for missing Ruuvi metadata

Instead of defaulting to guessed values:

- `location = NULL or ''`
- `room = NULL or ''`
- `precise_location = NULL or ''`
- `building = NULL or ''`
- optionally add `comment = 'missing md_ruuvi_sensor mapping'`

This is preferable to silently incorrect enrichment.

### 10.2 Step 2 changes: RAW -> WORK

#### Keep

- `_time` normalization to 4-minute bucket boundary
- `time_epoch` generation
- WORK lifecycle fields
- UPSERT into `work_sensoraverages`

#### Change

For Ruuvi:

- ensure `entity_id = sensor_mac`
- ensure `measurement = _field`
- ensure source remains `RuuviGTW`
- use `md_ruuvi_sensor` for location fields, not `friendly_name`

#### Critical guardrail

If `_field` is missing for a Ruuvi row, do not silently collapse to `measurement='ruuvi'`.
That would cause collisions between temperature, humidity, voltage, and rssi for the same device and time bucket.

### 10.3 Step 3 changes: WORK -> CURATED

#### Keep

- CURATED lifecycle fields
- JSON promotion to CURATED bucket
- manifest tracking

#### Enable after key model is stable

- relational insert / UPSERT into `curated_sensoraverages`

#### CURATED should become authoritative

Once enabled and validated:

- downstream analytics should read from `curated_sensoraverages`
- DQ should be reported against CURATED relational rows

---

## 11. Recommended DQ rules by stage

### 11.1 RAW DQ rules

Goal: confirm extraction and standardization happened.

Checks:

- row exists
- `_time` exists
- `_measurement` exists
- `_field` exists
- `avg_value` exists
- for Ruuvi: `sensor_mac` exists
- source exists

RAW should tolerate incomplete enrichment.

### 11.2 WORK DQ rules

Goal: confirm technical normalization and enrichment.

Checks:

- `time_epoch` exists
- `time_epoch` is aligned to 4-minute bucket boundary
- `entity_id` exists
- `measurement = _field`
- source normalized to expected value
- lifecycle fields present
- no duplicate `(time_epoch, entity_id, measurement)`
- metadata either valid or explicitly missing

### 11.3 CURATED DQ rules

Goal: confirm final stable truth.

Checks:

- no duplicate `(time_epoch, entity_id, measurement, source)`
- location metadata is not generic/defaulted unless truly correct
- lifecycle fields complete
- overlap handled
- final metric identity consistent
- source policy consistent

---

## 12. Immediate SQL validation set

### 12.1 Inspect current WORK Ruuvi rows

```sql
SELECT
  time,
  time_epoch,
  measurement,
  entity_id,
  source,
  friendly_name,
  location,
  room,
  precise_location,
  building,
  avg_value
FROM smarthome.work_sensoraverages
WHERE source = 'RuuviGTW'
   OR friendly_name LIKE 'Ruuvi%'
ORDER BY time DESC
LIMIT 200;
```

### 12.2 Detect duplicate WORK grain

```sql
SELECT
  time_epoch,
  entity_id,
  measurement,
  COUNT(*) AS cnt
FROM smarthome.work_sensoraverages
WHERE source = 'RuuviGTW'
   OR friendly_name LIKE 'Ruuvi%'
GROUP BY time_epoch, entity_id, measurement
HAVING COUNT(*) > 1
ORDER BY cnt DESC, time_epoch DESC;
```

### 12.3 Detect suspicious fallback metadata in WORK

```sql
SELECT
  time,
  entity_id,
  friendly_name,
  measurement,
  location,
  room,
  precise_location,
  building,
  source
FROM smarthome.work_sensoraverages
WHERE (source = 'RuuviGTW' OR friendly_name LIKE 'Ruuvi%')
  AND (
    precise_location = 'Rooftop' OR
    room = 'Uppstairs' OR
    building = 'House'
  )
ORDER BY time DESC;
```

### 12.4 Detect metric collapse in WORK

```sql
SELECT
  time,
  entity_id,
  measurement,
  source,
  friendly_name
FROM smarthome.work_sensoraverages
WHERE (source = 'RuuviGTW' OR friendly_name LIKE 'Ruuvi%')
  AND measurement = 'ruuvi'
ORDER BY time DESC;
```

This should ideally return zero rows.

### 12.5 Distinct Ruuvi mapping count per sensor in WORK

```sql
SELECT
  entity_id,
  friendly_name,
  COUNT(DISTINCT CONCAT_WS('|', location, room, precise_location, building)) AS mapping_count
FROM smarthome.work_sensoraverages
WHERE source = 'RuuviGTW'
   OR friendly_name LIKE 'Ruuvi%'
GROUP BY entity_id, friendly_name
HAVING mapping_count > 1
ORDER BY mapping_count DESC, entity_id;
```

---

## 13. Immediate Flux validation set

### 13.1 Current Ruuvi points in InfluxDB2

```flux
from(bucket: "sensors")
  |> range(start: -30d)
  |> filter(fn: (r) => r._measurement == "ruuvi")
  |> keep(columns: [
      "_time","_measurement","_field","_value",
      "sensor_mac","sensor_name","sensor_suffix",
      "source","friendly_name","domain",
      "location","room","precise_location","building"
  ])
  |> sort(columns: ["_time","sensor_mac","_field"])
```

### 13.2 Distinct Ruuvi field coverage by sensor

```flux
from(bucket: "sensors")
  |> range(start: -30d)
  |> filter(fn: (r) => r._measurement == "ruuvi")
  |> group(columns: ["sensor_mac", "sensor_suffix", "_field"])
  |> count()
  |> keep(columns: ["sensor_mac", "sensor_suffix", "_field", "_value"])
  |> rename(columns: {_value: "point_count"})
  |> sort(columns: ["sensor_mac", "_field"])
```

### 13.3 Detect suspicious defaulted metadata in InfluxDB2

```flux
from(bucket: "sensors")
  |> range(start: -30d)
  |> filter(fn: (r) => r._measurement == "ruuvi")
  |> filter(fn: (r) =>
      r.building == "House" or
      r.precise_location == "Rooftop" or
      r.location == r.room
  )
  |> keep(columns: ["_time","_field","sensor_mac","sensor_suffix","sensor_name","friendly_name","source","location","room","precise_location","building"])
  |> sort(columns: ["sensor_mac","_time"])
```

---

## 14. Translation rule between current Ruuvi shape and HA masterdata

While current md tables are not the right primary metadata source for pipeline enrichment, they still allow transitional mapping.

### 14.1 Bridge rule

Given:

- `sensor_suffix = a187`
- `_field = temperature`

Expected HA entity id:

```text
ruuvitag_a187_temperature
```

In general:

```text
expected_md_entity_id = 'ruuvitag_' + lower(sensor_suffix) + '_' + lower(_field)
```

### 14.2 Use cases for this mapping

- compare gateway-native rows to existing HA metadata
- identify which sensors have legacy HA references
- identify gaps in HA-based masterdata
- support migration to a new `md_ruuvi_sensor` table

---

## 15. Recommended implementation sequence

### Phase 1: stabilize Ruuvi key model

1. create `md_ruuvi_sensor`
2. populate it with current Ruuvi devices
3. change Step 1 / Step 2 lookup logic to use `sensor_mac`
4. remove generic Ruuvi heuristic defaults
5. verify WORK grain stability

### Phase 2: stabilize WORK relational truth

1. confirm every Ruuvi row has:
   - `entity_id = sensor_mac`
   - `measurement = _field`
   - `source = RuuviGTW`
2. confirm no duplicate WORK grain
3. confirm metadata mapping consistency per sensor

### Phase 3: enable CURATED relational truth

1. re-enable curated SQL insert / UPSERT
2. validate no duplicate CURATED grain
3. validate final metadata correctness
4. declare `curated_sensoraverages` the stable downstream truth

### Phase 4: automate DQ with Node-RED

1. run scheduled SQL / Flux checks
2. write DQ results into manifest or dedicated DQ table
3. optionally expose dashboard / reports
4. optionally raise alert on missing metadata or duplicate grains

---

## 16. Recommended DQ issue categories

For future automation, classify DQ findings into these categories.

### 16.1 Completeness

- missing `sensor_mac`
- missing `_field`
- missing `source`
- missing location metadata

### 16.2 Conformity

- invalid source for Ruuvi
- invalid measurement semantics
- unsupported metric names

### 16.3 Consistency

- same sensor mapped to multiple location hierarchies
- same business grain represented differently across stages

### 16.4 Uniqueness

- duplicate WORK grain
- duplicate CURATED grain

### 16.5 Timeliness

- missing lifecycle timestamps
- unexpected delay between RAW / WORK / CURATED transitions

### 16.6 Reasonableness

- impossible humidity / voltage / temperature values
- unexpected `rssi` ranges

---

## 17. Key decisions to adopt

These decisions should be explicitly accepted to stop further drift.

1. **RAW is redefined as standardized landing, not pure raw source copy**
2. **WORK remains the intermediate enriched structured stage**
3. **CURATED becomes the only authoritative relational stage**
4. **For Ruuvi, `entity_id = sensor_mac`**
5. **For Ruuvi, MariaDB `measurement = _field`**
6. **For Ruuvi, operational source is `RuuviGTW`**
7. **Ruuvi metadata enrichment must be keyed by `sensor_mac`, not `friendly_name`**
8. **Generic fallback metadata for Ruuvi should be removed or replaced by missing-value flags**

---

## 18. Open questions

These should be resolved as implementation continues.

1. Should source in final MariaDB represent:
   - source system (`RuuviGTW`), or
   - enrichment engine (`Node-RED`), or
   - legacy semantic origin (`HA`)?

   Recommended answer: `source` should represent the operational source system, e.g. `RuuviGTW`.

2. Should legacy HA mappings remain visible in final relational truth?

   Recommended answer: only as auxiliary metadata, not as primary identity.

3. Should RAW relational storage be re-enabled?

   Recommended answer: only if useful for debugging or audit. It should not be treated as the final DQ basis.

---

## 19. Immediate next actions

### Action 1
Create `md_ruuvi_sensor` and populate one row per active Ruuvi device.

### Action 2
Refactor Step 1 / Step 2 enrichment to use `sensor_mac` lookups.

### Action 3
Remove generic Ruuvi fallback values for:

- `location`
- `room`
- `precise_location`
- `building`

### Action 4
Run the SQL and Flux validation queries in this document and store the first results.

### Action 5
After WORK is stable, re-enable relational CURATED insert path.

---

## 20. Summary

The pipeline concept is still good, but the implementation drifted in three main ways:

- RAW is already enriched
- Ruuvi identity is not consistently represented across all stages
- CURATED relational truth is not yet enabled

The single most important stabilization step is:

> Introduce a dedicated Ruuvi metadata mapping keyed by `sensor_mac` and use it throughout the Node-RED pipeline.

Once this is done, the rest of the DQ framework becomes much more straightforward:

- consistent keys
- accurate location enrichment
- stable relational grain
- meaningful RAW / WORK / CURATED comparisons
- reliable automation of DQ checks

---

## Appendix A. Existing masterdata interpretation

### md_sensor

Useful for:

- legacy HA entity references
- display labels
- cross-checking expected sensor coverage

Not sufficient for:

- current gateway-native Ruuvi enrichment

### md_measurement

Useful for:

- some display/unit lookup

Not sufficient for:

- modern metric identity, because it mixes unit-like semantics into `measurement`

### md_location

Useful for:

- partial enrichment hints

Not sufficient for:

- authoritative sensor-level location mapping, because it is sparse and not keyed by sensor identity

---

## Appendix B. Recommended wording for GitHub issue / next task

> Stabilize Ruuvi pipeline identity and metadata by introducing sensor-level metadata keyed by `sensor_mac`, removing generic Rooftop/Uppstairs fallback enrichment, and re-aligning RAW/WORK/CURATED semantics so that CURATED becomes the authoritative relational truth.

