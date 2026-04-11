# Home IT – Whole Chat Worklog and Architecture Notes

> This document captures the substance of this chat as a GitHub-friendly working log.
> Some earlier omitted/skipped turns are summarized rather than reproduced verbatim.

## 1. Main architecture direction agreed in this session

### Current reality
- Node-RED is strongest as an integration/orchestration tool:
  - REST
  - MQTT
  - Modbus
  - device/vendor integrations
- InfluxDB2 already works well as:
  - first durable capture
  - hot/raw time-series store
  - realtime dashboarding
  - 1-year retention plus historical bucket strategy

### Agreed target pattern
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

### Important clarification
Node-RED is allowed in two roles only:
1. **source integration** into InfluxDB
2. **thin replay/landing bridge** from InfluxDB into MinIO RAW

Node-RED should **not** be the long-term place for:
- semantic enrichment
- classification logic
- deduplication
- conformance
- SQL-based modeling
- RAW→WORK→CURATED business transformations

## 2. RAW / WORK / CURATED definitions agreed

### RAW
- immutable
- replayable
- source-shaped
- minimal technical metadata only
- no semantic enrichment
- no room/building heuristics
- no business classification

### WORK
- optional technical staging
- compaction / reshaping / partitioning if needed
- not the final business truth
- should stay lighter than current implementation

### CURATED
- typed
- deduplicated
- quality-checked
- conformed
- decision-ready / presentation-ready

### Key principle
CURATED becomes the stable lake source for analytics and decisions.
MariaDB receives selected current-serving outputs from CURATED / dbt models.

## 3. InfluxDB vs MinIO landing decision

### Option chosen
**Option #1** was favored:

- Devices -> Node-RED -> InfluxDB first
- Then replay/read from InfluxDB into MinIO RAW

### Why
- enables replay/backfill
- supports disaster recovery if RAW landing goes wrong
- avoids permanent loss from a failed one-time direct object write
- fits current estate because InfluxDB is already the trusted first durable capture

### Option not chosen as primary pattern
Direct simultaneous write from Node-RED to:
- InfluxDB
- MinIO

This may be added later, but not as the only recovery path.

## 4. DuckDB role clarified

### What DuckDB is in this design
DuckDB is:
- transformation/runtime engine
- local analytical compute layer
- SQL-first engine over MinIO objects
- dbt execution target / helper

### What DuckDB is **not**
DuckDB is **not** the final serving database in this architecture.

### Final serving stores
- InfluxDB = hot/raw capture + replay source
- MinIO = lake storage
- MariaDB = serving/decision queue/presentation layer

### Consequence
DuckDB state can be short-lived or rebuildable.
That is acceptable because it is not the long-term source of truth.

## 5. Dev Container / dbt / DuckDB / MinIO worklog

### Dev Container
- A simplified Dev Container approach worked better.
- `.venv` inside the Dev Container was not necessary.
- Direct install into container Python was accepted.
- `dbt debug` eventually succeeded.

### dbt profile handling
Best practice settled on:
- keep a project-local profile in:
  - `.dbt/profiles.yml`
- optionally mirror to:
  - `~/.dbt/profiles.yml`

Reliable command form:
```bash
dbt debug --profiles-dir /workspaces/datapipelinev2/.dbt
dbt run --profiles-dir /workspaces/datapipelinev2/.dbt
```

### MinIO/dbt troubleshooting milestones
The following issues were found and fixed step by step:
1. unresolved hostname (`db2`)
2. wrong/unknown MinIO bucket
3. no files matching expected path
4. Redpanda Connect not running
5. Redpanda Connect config lint failure (`timestamp_utc`)
6. wrong MQTT broker host in Redpanda Connect config
7. no objects in MinIO until Redpanda Connect and MQTT publish were verified

### Redpanda Connect result
Final good state:
- MQTT input active
- S3 output active
- MinIO raw objects were created successfully
- dbt could read the landed files

## 6. MariaDB worklog

### Prefix naming decision
You chose prefix-based table names instead of schema-separated names.

Examples:
- `decision_current_energy_state`
- `decision_command_queue`
- `present_energy_daily`
- `ops_pipeline_run_log`

### DDL preference
You requested plain:
- `CREATE TABLE`
and not:
- `CREATE TABLE IF NOT EXISTS`

### Loader scripts
Python loader scripts were created for:
- decision table load
- presentation table load

Result reached during the session:
- both loaders inserted 1 row successfully
- repeated runs did not append because the test data hit the same upsert keys and updated existing rows as expected

## 7. Command queue and ACK handling

### Node-RED command queue tab
A working `Decision Command Queue v2` flow was built to:
- poll `decision_command_queue`
- publish MQTT commands
- mark `SENT`
- receive ACKs
- mark `ACKED`
- retry `ERROR`
- log into `ops_pipeline_run_log`

### Important improvement
Outbound MQTT payloads now inject the **database `command_id`** automatically before publish.
This makes ACK correlation reliable.

### Fake ACK simulator
A separate `Fake ACK Simulator` tab was created so the real queue tab/UI does not get disturbed.

It:
- subscribes to `home/home/cmd/#`
- extracts `command_id`
- waits 2 seconds
- publishes ACK to:
  - `home/home/ack/simulated/device/response`

### Current tested command loop
```text
MariaDB decision_command_queue
 -> Node-RED dispatch
 -> MQTT command publish
 -> Fake ACK Simulator
 -> MQTT ACK
 -> Node-RED ACK handler
 -> MariaDB status = ACKED
```

## 8. Important clarification about real device actuation

The current command queue flow does **not** yet do real physical control.

### What it does now
- dispatches generic control intent to MQTT
- handles ACK/status/logging

### What still comes later
A device-specific adapter layer must translate generic control intent into real device protocol actions.

Examples:
- Sabiana / konvektor Modbus register writes
- Sorel XHCC Modbus actions
- AC IR/API commands
- ventilation system commands
- appliance start/allow commands

### Recommended layering
1. **Decision layer**  
   what should happen
2. **Dispatch layer**  
   send generic MQTT command, track SENT/ACKED/ERROR
3. **Device adapter layer**  
   translate generic command into actual device protocol/action

## 9. Ruuvi-first decision

You decided not to move next to device actuation yet.

### New priority
Bring in environmental sensing first, because house and room air-quality decisions depend on:
- temperature
- humidity
- CO2

### Order chosen
1. Ruuvi first
2. Netatmo / Legrand later

### Current Ruuvi source split identified
Two distinct Ruuvi families exist:

#### A. Victron-associated battery room sensors
- `BatteryRoomOutTemp`
- `BatteryRoomInTemp`
- tagged with:
  - `source = "victron_source"`
  - `domain = "victron"`
  - room/building around battery shed / powerplant

These should be treated as **Victron-adjacent environmental sensors**, not generic room Ruuvi sensors.

#### B. General RuuviGTW sensors
All the rest of the Ruuvi tags shown in the sensor dashboard belong here:
- rooftop
- insulation
- indoor house sensors
- other room/outdoor sensors

These should become the first real room-climate pipeline.

## 10. Current Node-RED RAW/WORK issue identified

Two legacy flows were reviewed:

### Step 1 – InfluxToMariaDb (v6)
Current behavior includes much more than ingest:
- Influx query
- SensorMeta lookup
- source renaming
- Victron-specific enrichment
- Netatmo mapping support
- location/room/building heuristics
- RAW lifecycle/classification fields
- MinIO RAW write
- disabled SQL RAW writer path

### Step 2 – MinIO RAW→WORK promotion (v2)
Current behavior includes:
- RAW listing and reading
- parsing JSON
- adding RAW/WORK lifecycle and classification
- `_time` and `time_epoch` normalization
- Ruuvi identity handling
- WORK JSON write
- `work_sensoraverages` SQL write
- RAW deletion after promotion

### Problem statement
These flows make Node-RED act as:
- integration layer
- enrichment engine
- lifecycle manager
- SQL loader
- RAW/WORK/CURATED transformer

That is the architecture bottleneck to remove.

## 11. New direction for Ruuvi pipeline

### Immediate architectural target
Build a **Ruuvi-first** path where:

- Node-RED only lands raw source-shaped records
- dbt/DuckDB starts all semantic work after MinIO RAW

### Suggested new dbt model split
- `stg_ruuvi_gtw`
- `stg_victron_env`
- `int_room_climate_4min`

Later:
- Netatmo / Legrand climate/CO2 models
- decision models for air quality

### Why split `victron_source` and `RuuviGTW`
Because battery-shed temperature sensors should not be treated identically to room comfort/air-quality sensors.

## 12. Recommended Node-RED role wording for documentation

Use this wording:

> Node-RED is responsible only for source integration and thin replay/landing. It integrates field systems and writes hot telemetry into InfluxDB, then optionally replays source-shaped records from InfluxDB into MinIO RAW. All semantic enrichment, deduplication, validation, conformance, and decision-oriented transformation begins only after data has landed in MinIO and is processed by DuckDB/dbt.

## 13. Git issue resolved conceptually

You also hit a recurring Git issue where local `main` and `origin/main` diverged.

Recommended resolution pattern:
```bash
git branch backup-before-rebase
git fetch origin
git rebase origin/main
git push origin main
git config --global pull.rebase true
```

This was recommended so future pulls default to rebase instead of repeatedly stopping on divergence.

## 14. Files/artifacts produced in this session

### Markdown docs created
- `HomeIT_End_to_End_Platform_Documentation.md`
- `HomeIT_NodeRED_Flows_and_SQL_Snippets.md`

## 15. Most important decisions from this chat

### Keep
- Node-RED for device/source integration
- InfluxDB as first durable capture
- MinIO as object lake
- DuckDB/dbt as ELT engine over MinIO
- MariaDB as serving/decision/presentation database

### Change
- stop using Node-RED as semantic ETL/ELT engine
- stop enriching before RAW
- stop using Node-RED for relational RAW/WORK modeling
- stop treating RAW as disposable
- move enrichment/quality/dedup/conformance into dbt/DuckDB

### Prioritize next
- Ruuvi-first room climate pipeline
- then Netatmo/Legrand CO2 and climate fusion
- then air-quality/comfort decision logic
- then later real device adapter flows

## 16. Suggested next implementation plan

1. Freeze current Step 1 and Step 2 as legacy
2. Create a thin InfluxDB -> MinIO RAW bridge path only
3. Define truly raw object contract for:
   - `RuuviGTW`
   - `victron_source` battery-room sensors
4. Build dbt staging:
   - `stg_ruuvi_gtw`
   - `stg_victron_env`
5. Build conformed room climate model:
   - `int_room_climate_4min`
6. Add Netatmo/Legrand later
7. Only after stable room climate modeling, continue toward real actuation adapters

## Appendix A – Example architecture statement

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
 -> Device adapters / actual hardware actions
```

## Appendix B – Example command queue lifecycle

```text
NEW -> SENT -> ACKED
NEW -> ERROR -> NEW
```

## Appendix C – Example Ruuvi-first principle

- `victron_source` battery-room temperatures are environmental/powerplant sensors
- `RuuviGTW` sensors are room/outdoor climate sensors
- do not conflate them too early
- unify them later in conformed climate models where appropriate
