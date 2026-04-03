# Home IT on-prem ELT/ETL with MinIO, DuckDB, dbt Core, MQTT, Node-RED, InfluxDB, and MariaDB

## 1. Purpose

This document describes a practical on-prem data platform for Home IT workloads running on small-footprint servers such as Raspberry Pi 4 nodes.

The design goal is to replace cloud-style orchestration with a lightweight, maintainable stack that supports:

- realtime telemetry ingestion
- object-storage-based historical retention
- SQL-based ELT and data quality
- a decision engine for house control
- presentation/reporting in MariaDB

This design is intended for workloads such as:

- Victron off-grid or hybrid energy system telemetry
- room sensors, garden sensors, weather and air quality sensors
- HVAC, ventilation, and hydronic heating controls
- smart plugs, lights, laundry, dishwasher, and other controllable appliances

---

## 2. High-level architecture

```text
Devices / Systems
  -> Node-RED + MQTT
  -> InfluxDB (hot realtime telemetry)
  -> MinIO raw/work/curated lake
  -> DuckDB + dbt Core (ELT / analytics / data quality)
  -> MariaDB decision engine DB
  -> MariaDB presentation marts
  -> Node-RED command execution back to devices
```

### Architectural roles

- **Node-RED**: edge integration, protocol handling, MQTT publishing, and command execution
- **MQTT**: live event bus
- **InfluxDB**: realtime dashboards and recent telemetry
- **MinIO**: replayable data lake with raw and curated object storage
- **Redpanda Connect**: streaming / micro-batch landing from MQTT to MinIO
- **DuckDB + dbt Core**: maintainable ELT, derived models, and decision logic
- **MariaDB decision schema**: control-ready state and command queues
- **MariaDB presentation schema**: dashboard/reporting tables

---

## 3. Node-by-node deployment blueprint

### Node A — Edge ingest and control

Run:

- Node-RED
- Mosquitto MQTT
- optional Modbus / serial helpers

Purpose:

- read device data
- normalize payloads
- publish MQTT events
- write hot telemetry to InfluxDB
- consume command queue and send control commands to devices

### Node B — Hot telemetry and observability

Run:

- InfluxDB 2
- Grafana
- optional Telegraf

Purpose:

- live dashboards
- alerts
- short-term telemetry retention

### Node C — Lake and transforms

Run:

- MinIO
- Redpanda Connect
- DuckDB runner
- dbt Core project
- systemd timers or cron

Purpose:

- raw object landing
- micro-batch shaping
- curated Parquet creation
- ELT, replay, backfills, and derived analytics

### Node D — Serving and decision

Run:

- MariaDB
- decision engine tables
- optional small API service

Purpose:

- decision-ready state
- recommendation queue
- command queue
- reporting and presentation marts

---

## 4. MinIO bucket and prefix design

### Buckets

Recommended buckets:

- `homeit-raw`
- `homeit-curated`
- `homeit-artifacts`
- optional `homeit-backup`

### Raw bucket design

Raw data is immutable and source-shaped.

Examples:

```text
s3://homeit-raw/source=victron/entity=inverter/site=home/year=2026/month=04/day=02/hour=22/part-000001.jsonl
s3://homeit-raw/source=sorel_xhcc/entity=controller_state/site=home/year=2026/month=04/day=02/hour=22/part-000001.jsonl
s3://homeit-raw/source=ruuvi/entity=room_sensor/site=home/room=bedroom/year=2026/month=04/day=02/hour=22/part-000001.jsonl
s3://homeit-raw/source=appliance/entity=device_state/site=home/year=2026/month=04/day=02/hour=22/part-000001.jsonl
```

### Curated bucket design

Curated data is typed, deduplicated, and query-friendly.

Examples:

```text
s3://homeit-curated/domain=energy/entity=energy_1min/site=home/year=2026/month=04/day=02/part-000001.parquet
s3://homeit-curated/domain=climate/entity=room_climate_1min/site=home/year=2026/month=04/day=02/part-000001.parquet
s3://homeit-curated/domain=hvac/entity=heating_state_1min/site=home/year=2026/month=04/day=02/part-000001.parquet
s3://homeit-curated/domain=decision/entity=energy_state_1min/site=home/year=2026/month=04/day=02/part-000001.parquet
```

### Artifacts bucket design

Examples:

```text
s3://homeit-artifacts/dbt-docs/
s3://homeit-artifacts/run-logs/
s3://homeit-artifacts/data-quality/
```

---

## 5. MQTT topic naming

Use a single, predictable convention:

```text
home/{site}/{domain}/{entity}/{device_id}/{signal}
```

Examples:

```text
home/home/energy/victron/inverter_1/power_w
home/home/energy/victron/battery_1/soc_pct
home/home/hvac/sorel_xhcc/controller_1/supply_temp_c
home/home/climate/ruuvi/bedroom_1/temperature_c
home/home/appliance/dishwasher/dw_1/power_w
```

### Control topics

```text
home/home/cmd/hvac/sorel_xhcc/controller_1/set_mode
home/home/cmd/appliance/dishwasher/dw_1/allow_start
home/home/cmd/lighting/netatmo/kitchen_1/set_state
```

### Decision topics

```text
home/home/decision/energy/current_state
home/home/decision/hvac/recommendation
home/home/decision/appliance/recommendation
```

### Standard telemetry payload

```json
{
  "ts": "2026-04-02T21:35:00Z",
  "site": "home",
  "domain": "energy",
  "entity": "victron",
  "device_id": "inverter_1",
  "signal": "power_w",
  "value": 1845.0,
  "unit": "W",
  "quality": "ok",
  "source": "nodered"
}
```

---

## 6. dbt Core model layering

Recommended layers:

- `sources/` or `src_*` for external raw files from MinIO
- `staging/` or `stg_*` for typed normalization
- `intermediate/` or `int_*` for dedupe and reusable business logic
- `decision/` or `dec_*` for control-ready outputs
- `presentation/` or `present_*` for MariaDB serving tables

### Example model families

- `stg_victron_power`
- `int_energy_1min`
- `dec_current_energy_state`
- `present_energy_daily`
- `stg_room_sensor`
- `int_room_climate_1min`
- `dec_air_quality_action`
- `stg_hvac_controller`
- `int_hvac_state_1min`
- `dec_hvac_load_opportunity`
- `stg_appliance_state`
- `int_appliance_usage_1min`
- `dec_appliance_shift_candidate`

---

## 7. Decision engine design

The decision engine should answer:

- Do we currently have surplus production?
- How long is surplus likely to last?
- Which controllable loads are eligible now?
- Which loads should be delayed?
- Which HVAC action improves comfort at the lowest energy cost?
- Which air quality actions override energy optimization?

### MariaDB schemas

Use these schemas:

- `decision`
- `present`
- `ops`

### Core decision tables

- `decision.current_energy_state`
- `decision.device_capability`
- `decision.control_constraint`
- `decision.recommendation_queue`
- `decision.command_queue`
- `decision.command_result`

### Key concepts

#### Current energy state

Derived every minute:

- `produced_kw`
- `consumed_kw`
- `net_kw`
- `battery_soc_pct`
- `surplus_class`
- `available_flexible_kw`

#### Device capability and policy

Per device:

- shiftable vs non-shiftable
- modulating vs binary
- minimum runtime
- allowed start windows
- quiet hours
- manual override

#### Recommendations

Examples:

- allow dishwasher start in next 25 minutes
- preheat living room while surplus remains above threshold
- boost ventilation because CO2 exceeds threshold
- delay laundry because battery reserve is below minimum

---

## 8. Example pipelines

### A. Victron energy pipeline

Flow:

1. Node-RED reads Victron metrics
2. Node-RED publishes MQTT events and writes to InfluxDB
3. Redpanda Connect batches events to `homeit-raw`
4. dbt models compute minute-level energy facts
5. decision model derives `current_energy_state`
6. output is loaded to MariaDB decision schema and presentation schema

### B. HVAC pipeline

Flow:

1. Read Sorel XHCC controller and Sabiana fan coil signals
2. Land raw JSONL to MinIO
3. Normalize and aggregate to minute-level HVAC state
4. Combine with energy state and comfort gap
5. Produce preheat / hold recommendations

### C. Room sensor pipeline

Flow:

1. Read Ruuvi / Netatmo / other room sensor signals
2. Land raw JSONL to MinIO
3. Build minute-level room climate state
4. Detect CO2, humidity, and comfort issues
5. Produce air quality and lighting suggestions

### D. Appliance telemetry pipeline

Flow:

1. Read dishwasher, washing machine, dryer, water heater, smart plugs, lights
2. Land raw JSONL to MinIO
3. Detect cycle state and flexible load opportunities
4. Compare appliance power requirement to current surplus
5. Produce allow-start / delay recommendations

---

## 9. VS Code recommendations

### Recommended extensions

- Python
- Pylance
- YAML
- Docker
- dbt Power User
- dbt snippets
- Ruff
- Markdownlint
- Even Better TOML

### dbt extension choice

For this project, continue using:

- **dbt Core**
- **dbt Power User**

That is the correct fit for a dbt Core workflow.

---

## 10. Dev Containers recommendation

Use Dev Containers on the development machine if you want:

- reproducible tooling
- easy onboarding
- isolation from host Python

Do not treat Dev Containers as the production runtime model for Raspberry Pi nodes.

Recommended split:

- development laptop / workstation: VS Code + Dev Container or Python venv
- Raspberry Pi nodes: Docker Compose + systemd timers

---

## 11. Python venv recommendation

Use a project-local Python venv for dbt Core and helper tools.

Example:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip wheel setuptools
pip install -r requirements.txt
```

Recommended `requirements.txt`:

```txt
dbt-duckdb>=1.9.0
sqlfluff>=3.0.0
sqlfluff-templater-dbt>=3.0.0
pyyaml>=6.0
boto3>=1.34.0
```

---

## 12. Runtime deployment steps

### Step 1 — Host prerequisites

```bash
sudo apt update
sudo apt install -y \
  git curl wget unzip jq \
  python3 python3-venv python3-pip \
  docker.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

### Step 2 — Start per-node stacks

#### Node A

```bash
cd node-a
docker compose up -d
```

#### Node B

```bash
cd ../node-b
docker compose up -d
```

#### Node C

```bash
cd ../node-c
docker compose up -d
```

#### Node D

```bash
cd ../node-d
docker compose up -d
```

### Step 3 — Create Python environment

```bash
cd ~/projects/homeit/homeit-starter-pack
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Step 4 — Configure dbt profile

```bash
mkdir -p ~/.dbt
cp dbt_homeit/profiles.yml.example ~/.dbt/profiles.yml
```

### Step 5 — Run dbt

```bash
cd dbt_homeit
dbt debug
dbt parse
dbt run
dbt test
dbt docs generate
```

---

## 13. systemd timer recommendation

Start with `systemd` timers instead of Airflow.

Suggested cadence:

- decision models: every 1 minute
- staging and intermediate models: every 5 minutes
- raw compaction: every 2–5 minutes
- presentation marts: every 15–60 minutes
- daily summaries: nightly

Example timer unit and service are included in the chat implementation notes and can be added later to the repository.

---

## 14. Data quality and safety gates

### Data quality

Implement dbt tests for:

- uniqueness on `(site, device_id, signal, ts)`
- accepted ranges
- accepted units
- source freshness
- null thresholds
- duplicate-rate monitoring

### Control safety

Always enforce:

- manual override wins
- quiet hours
- max actuation frequency
- fail closed on stale or missing telemetry
- safety, freeze protection, and air-quality overrides

---

## 15. Recommended first implementation scope

Build these first:

1. Node A: Node-RED + MQTT
2. Node B: InfluxDB + Grafana
3. Node C: MinIO + Redpanda Connect + DuckDB/dbt
4. Node D: MariaDB with `decision` and `present`

Then implement these four pipelines first:

1. Victron energy
2. HVAC controller state
3. room climate
4. dishwasher / laundry telemetry

That is enough to create a first closed-loop system.

---

## 16. Repository documentation structure suggestion

Recommended Git repository structure:

```text
homeit-starter-pack/
  README.md
  docs/
    HomeIT_MinIO_ELT_Plan_and_Implementation.md
  node-a/
  node-b/
  node-c/
  node-d/
  dbt_homeit/
  scripts/
  .devcontainer/
```

---

## 17. Deliverables included alongside this document

- starter pack ZIP
- Git-ready Markdown plan and implementation document

---

## 18. Next recommended deliverables

After this documentation baseline, the next best additions are:

- full Node-RED flow exports for Victron, HVAC, room sensors, and appliance telemetry
- MariaDB loader job from dbt outputs into `decision` and `present`
- dbt tests YAML files
- DuckDB export/import macros for curated Parquet
- environment-specific `.env` files and secrets handling

