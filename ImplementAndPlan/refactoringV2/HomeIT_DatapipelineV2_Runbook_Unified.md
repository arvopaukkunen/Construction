# HomeIT Data Pipeline V2 Runbook

## Scope

Current implemented sensor families:

- RuuviTag
- Netatmo / Legrand

Both use the same platform pattern:

```text
Node-RED / source integration
-> InfluxDB durable capture
-> MinIO RAW
-> dbt_homeit
-> MinIO WORK / CURATED
-> load_curated_to_mariadb.py
-> dbt_homeit_mariadb
-> MariaDB serving views
```

## Repository layout

- `dbt_homeit/` = MinIO / DuckDB / dbt transformation project
- `dbt_homeit_mariadb/` = MariaDB serving-layer dbt project
- `scripts/run_pipeline.sh` = stage 1 runner for dbt_homeit
- `scripts/run_mariadb_pipeline.sh` = stage 2 runner for MariaDB load + dbt serving build
- `scripts/run_all_pipelines.sh` = full orchestrator
- `scripts/load_curated_to_mariadb.py` = loads CURATED Parquet into MariaDB load tables
- `scripts/validate_pipeline.sh` = quick row-count validation
- `.dbt/` = profile for `dbt_homeit`
- `.dbt_mariadb/` = profile for `dbt_homeit_mariadb`
- `env/dbt_homeit.env` = env vars for stage 1
- `env/dbt_homeit_mariadb.env` = env vars for stage 2

## Virtual environments

- `/home/vscode/.venvs/dbt_homeit`
- `/home/vscode/.venvs/dbt_homeit_mariadb`

## Sensor family outputs

### RuuviTag

#### WORK
- `work/iotv2/sensors/entity=ruuvi_env_long`
- `work/iotv2/sensors/entity=ruuvi_env_5min_avg`
- `work/iotv2/dq/entity=ruuvi_pipeline`

#### CURATED
- `curated/iotv2/sensors/entity=ruuvi_5min_avg`
- `curated/iotv2/sensors/entity=ruuvi_latest`
- `curated/iotv2/dq/entity=ruuvi_pipeline_kpi`

### Netatmo / Legrand

#### WORK
- `work/iotv2/netatmo/entity=netatmo_telemetry_long`
- `work/iotv2/netatmo/entity=netatmo_state_long`
- `work/iotv2/netatmo/entity=netatmo_device_admin_long`
- `work/iotv2/netatmo/entity=netatmo_error_events`

#### CURATED
- `curated/iotv2/netatmo/entity=netatmo_telemetry_5min_avg`
- `curated/iotv2/netatmo/entity=netatmo_latest_state`
- `curated/iotv2/netatmo/entity=netatmo_device_health`

## Manual run: stage 1 (`dbt_homeit`)

```bash
source /home/vscode/.venvs/dbt_homeit/bin/activate
source /workspaces/datapipelinev2/env/dbt_homeit.env
cd /workspaces/datapipelinev2
./scripts/run_pipeline.sh
```

This stage:
- builds `dbt_homeit`
- exports Ruuvi WORK
- exports Ruuvi CURATED
- exports Netatmo WORK
- exports Netatmo CURATED

## Manual run: stage 2 (`dbt_homeit_mariadb`)

```bash
source /home/vscode/.venvs/dbt_homeit_mariadb/bin/activate
source /workspaces/datapipelinev2/env/dbt_homeit_mariadb.env
python /workspaces/datapipelinev2/scripts/load_curated_to_mariadb.py
cd /workspaces/datapipelinev2/dbt_homeit_mariadb
dbt build --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb
```

This stage:
- loads Ruuvi curated Parquet into MariaDB
- loads Netatmo curated Parquet into MariaDB
- builds serving views for both families

## Manual run: full process

```bash
cd /workspaces/datapipelinev2
./scripts/run_pipeline.sh
./scripts/run_mariadb_pipeline.sh
./scripts/validate_pipeline.sh
```

## MariaDB physical load tables

### Ruuvi
- `load_ruuvi_5min_avg`
- `load_ruuvi_latest`
- `load_ruuvi_dq_kpi`

### Netatmo
- `load_netatmo_telemetry_5min_avg`
- `load_netatmo_latest_state`
- `load_netatmo_device_health`

## MariaDB serving views

### Ruuvi
- `stg_ruuvi_5min_avg`
- `stg_ruuvi_latest`
- `ops_ruuvi_dq_kpi`
- `present_ruuvi_5min_recent`
- `present_ruuvi_latest`
- `ops_ruuvi_pipeline_status`

### Netatmo
- `stg_netatmo_telemetry_5min_avg`
- `stg_netatmo_latest_state`
- `stg_netatmo_device_health`
- `present_netatmo_telemetry_recent`
- `present_netatmo_latest_state`
- `ops_netatmo_device_health`

## Validation

### Quick load-table counts

```bash
cd /workspaces/datapipelinev2
./scripts/validate_pipeline.sh
```

### dbt serving checks: Ruuvi

```bash
cd /workspaces/datapipelinev2/dbt_homeit_mariadb
dbt show --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb --select present_ruuvi_latest --limit 20
dbt show --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb --select present_ruuvi_5min_recent --limit 20
dbt show --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb --select ops_ruuvi_pipeline_status --limit 20
```

### dbt serving checks: Netatmo

```bash
cd /workspaces/datapipelinev2/dbt_homeit_mariadb
dbt show --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb --select present_netatmo_telemetry_recent --limit 20
dbt show --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb --select present_netatmo_latest_state --limit 20
dbt show --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb --select ops_netatmo_device_health --limit 20
```

## Devcontainer note

This repository is currently developed and tested in a VS Code devcontainer.

That means:
- manual runs are supported
- development and testing are supported
- unattended production scheduling should later move to a real always-on Linux host

## Current milestone status

### Completed
- Ruuvi RAW -> WORK -> CURATED -> MariaDB serving
- Netatmo/Legrand RAW -> WORK -> CURATED -> MariaDB serving

### Next likely refinements
- add `cur_netatmo_error_events`
- add Netatmo-specific DQ rules
- add device-health timestamp conversion for `last_seen`
- later add next sensor families:
  - energy production
  - appliances
  - decision engine / analytics / ML inputs
