# HomeIT DataPipeline V2 Runbook

## Purpose

This runbook documents the current working setup for the Home IT data pipeline.

The pipeline now has two stages:
Before these 2 stages, IoT sensor and appliance integration layer is extracting data and get orchestrated by NodeRed. Nodered is in role, that does not do any data alterations - simply integrates and delivered it to device by device famity - to S3 compatible onprem storage bucket named raw.

1. `dbt_homeit`
   - reads RAW data from MinIO
   - performs enrichment, DQ, aggregation, and CURATED exports
   - writes WORK and CURATED Parquet back to MinIO

2. `dbt_homeit_mariadb`
   - reads CURATED Parquet from MinIO
   - loads relational tables into MariaDB
   - builds serving views for reporting and operational use

---

## Current high-level flow

```text
Devices
 -> Node-RED
 -> InfluxDB
 -> MinIO RAW
 -> dbt_homeit (DuckDB + dbt)
 -> MinIO WORK
 -> MinIO CURATED
 -> load_curated_to_mariadb.py
 -> MariaDB load_* tables
 -> dbt_homeit_mariadb views
```

---

## Folder layout

```text
/workspaces/datapipelinev2/
  dbt_homeit/
  dbt_homeit_mariadb/
  scripts/
  env/
  .dbt/
  .dbt_mariadb/
  RUNBOOK.md
```

### Virtual environments

Keep virtualenvs outside the workspace mount:

```text
/home/vscode/.venvs/dbt_homeit
/home/vscode/.venvs/dbt_homeit_mariadb
```

This avoids the workspace permission issues seen earlier with local `.venv` folders.

---

## Profiles

### `dbt_homeit`

Use:

```text
/workspaces/datapipelinev2/.dbt/profiles.yml
```

### `dbt_homeit_mariadb`

Use:

```text
/workspaces/datapipelinev2/.dbt_mariadb/profiles.yml
```

Always pass the correct `--profiles-dir` explicitly.

---

## Environment files

### `/workspaces/datapipelinev2/env/dbt_homeit.env`

```bash
export MINIO_HOST=192.168.123.194
export MINIO_PORT=9000
export MINIO_ACCESS_KEY=minioadmin
export MINIO_SECRET_KEY='REPLACE_ME'
```

### `/workspaces/datapipelinev2/env/dbt_homeit_mariadb.env`

```bash
export MINIO_HOST=192.168.123.194
export MINIO_PORT=9000
export MINIO_ACCESS_KEY=minioadmin
export MINIO_SECRET_KEY='REPLACE_ME'

export MARIADB_HOST=192.168.123.194
export MARIADB_PORT=3306
export MARIADB_DATABASE=smarthome
export MARIADB_USER=Smarthome
export MARIADB_PASSWORD='REPLACE_ME'
```

Do not commit these files to Git.

---

## Project activation helpers

### `dbt_homeit`

```bash
source /home/vscode/.venvs/dbt_homeit/bin/activate
source /workspaces/datapipelinev2/env/dbt_homeit.env
cd /workspaces/datapipelinev2/dbt_homeit
```

### `dbt_homeit_mariadb`

```bash
source /home/vscode/.venvs/dbt_homeit_mariadb/bin/activate
source /workspaces/datapipelinev2/env/dbt_homeit_mariadb.env
cd /workspaces/datapipelinev2/dbt_homeit_mariadb
```

---

## `dbt_homeit` operational commands

### Validate profile

```bash
cd /workspaces/datapipelinev2/dbt_homeit
source /home/vscode/.venvs/dbt_homeit/bin/activate
source /workspaces/datapipelinev2/env/dbt_homeit.env

dbt debug --profiles-dir /workspaces/datapipelinev2/.dbt
```

### Run models

```bash
cd /workspaces/datapipelinev2/dbt_homeit

dbt run --profiles-dir /workspaces/datapipelinev2/.dbt --select \
  int_ruuvi_env_long \
  int_ruuvi_env_enriched \
  int_ruuvi_dq_metrics \
  cur_ruuvi_5min_avg \
  cur_ruuvi_latest \
  cur_ruuvi_dq_kpi
```

### Export WORK and CURATED

```bash
cd /workspaces/datapipelinev2/dbt_homeit

dbt run-operation export_model_to_parquet --profiles-dir /workspaces/datapipelinev2/.dbt --args '{"model_name":"int_ruuvi_env_enriched","bucket":"work","prefix":"iotv2/sensors/entity=ruuvi_env_long","file_name":"ruuvi_env_long.parquet"}'

dbt run-operation export_model_to_parquet --profiles-dir /workspaces/datapipelinev2/.dbt --args '{"model_name":"int_ruuvi_env_5min_avg","bucket":"work","prefix":"iotv2/sensors/entity=ruuvi_env_5min_avg","file_name":"ruuvi_env_5min_avg.parquet"}'

dbt run-operation export_model_to_parquet --profiles-dir /workspaces/datapipelinev2/.dbt --args '{"model_name":"int_ruuvi_dq_metrics","bucket":"work","prefix":"iotv2/dq/entity=ruuvi_pipeline","file_name":"ruuvi_pipeline_dq_metrics.parquet"}'

dbt run-operation export_model_to_parquet --profiles-dir /workspaces/datapipelinev2/.dbt --args '{"model_name":"cur_ruuvi_5min_avg","bucket":"curated","prefix":"iotv2/sensors/entity=ruuvi_5min_avg","file_name":"ruuvi_5min_avg.parquet"}'

dbt run-operation export_model_to_parquet --profiles-dir /workspaces/datapipelinev2/.dbt --args '{"model_name":"cur_ruuvi_latest","bucket":"curated","prefix":"iotv2/sensors/entity=ruuvi_latest","file_name":"ruuvi_latest.parquet"}'

dbt run-operation export_model_to_parquet --profiles-dir /workspaces/datapipelinev2/.dbt --args '{"model_name":"cur_ruuvi_dq_kpi","bucket":"curated","prefix":"iotv2/dq/entity=ruuvi_pipeline_kpi","file_name":"ruuvi_pipeline_kpi.parquet"}'
```

### Inspect outputs

```bash
cd /workspaces/datapipelinev2/dbt_homeit

dbt show --profiles-dir /workspaces/datapipelinev2/.dbt --select cur_ruuvi_latest --limit 20
dbt show --profiles-dir /workspaces/datapipelinev2/.dbt --select cur_ruuvi_5min_avg --limit 20
dbt show --profiles-dir /workspaces/datapipelinev2/.dbt --select cur_ruuvi_dq_kpi --limit 20
```

---

## `dbt_homeit_mariadb` operational commands

### Validate profile

```bash
cd /workspaces/datapipelinev2/dbt_homeit_mariadb
source /home/vscode/.venvs/dbt_homeit_mariadb/bin/activate
source /workspaces/datapipelinev2/env/dbt_homeit_mariadb.env

dbt debug --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb
```

### Load CURATED Parquet into MariaDB

```bash
cd /workspaces/datapipelinev2
source /home/vscode/.venvs/dbt_homeit_mariadb/bin/activate
source /workspaces/datapipelinev2/env/dbt_homeit_mariadb.env

python /workspaces/datapipelinev2/scripts/load_curated_to_mariadb.py
```

Expected output pattern:

```text
Loaded load_ruuvi_5min_avg: ... rows
Loaded load_ruuvi_latest: ... rows
Loaded load_ruuvi_dq_kpi: ... rows
```

### Build MariaDB serving views

```bash
cd /workspaces/datapipelinev2/dbt_homeit_mariadb

dbt build --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb
```

### Inspect serving views

```bash
cd /workspaces/datapipelinev2/dbt_homeit_mariadb

dbt show --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb --select present_ruuvi_latest --limit 20
dbt show --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb --select present_ruuvi_5min_recent --limit 20
dbt show --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb --select ops_ruuvi_pipeline_status --limit 20
```

---

## Loader / relational serving design

### Physical MariaDB load tables

These are populated by `load_curated_to_mariadb.py`:

- `load_ruuvi_5min_avg`
- `load_ruuvi_latest`
- `load_ruuvi_dq_kpi`

### dbt logical views

These are built by `dbt_homeit_mariadb`:

- `stg_ruuvi_5min_avg`
- `stg_ruuvi_latest`
- `ops_ruuvi_dq_kpi`
- `present_ruuvi_5min_recent`
- `present_ruuvi_latest`
- `ops_ruuvi_pipeline_status`

This naming split avoids recursion between source tables and dbt models.

---

## Scheduled execution

### Recommended schedule

Every 5 minutes is fine for the current micro-batch pattern.

### Important rule

Use a lock to prevent overlapping runs.

### `scripts/run_mariadb_pipeline.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

LOCKFILE="/tmp/run_mariadb_pipeline.lock"
exec 9>"$LOCKFILE"
flock -n 9 || { echo "run_mariadb_pipeline already running"; exit 0; }

source /home/vscode/.venvs/dbt_homeit_mariadb/bin/activate
source /workspaces/datapipelinev2/env/dbt_homeit_mariadb.env

python /workspaces/datapipelinev2/scripts/load_curated_to_mariadb.py

cd /workspaces/datapipelinev2/dbt_homeit_mariadb
dbt build --profiles-dir /workspaces/datapipelinev2/.dbt_mariadb
```

### Recommended full orchestrator

Prefer one master runner that performs:

1. `dbt_homeit`
2. MinIO exports
3. MariaDB load
4. `dbt_homeit_mariadb`

This keeps stage ordering deterministic.

---

## Validation queries

### MariaDB counts

```bash
mysql -h "$MARIADB_HOST" -P "$MARIADB_PORT" -u "$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" -e "
select count(*) as cnt from load_ruuvi_5min_avg;
select count(*) as cnt from load_ruuvi_latest;
select count(*) as cnt from load_ruuvi_dq_kpi;
"
```

### MariaDB samples

```bash
mysql -h "$MARIADB_HOST" -P "$MARIADB_PORT" -u "$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" -e "
select * from load_ruuvi_latest limit 5;
select * from load_ruuvi_dq_kpi limit 5;
"
```

---

## VS Code setup

The cleanest way to avoid dbt Power User confusion is to use **one workspace file per dbt project**.

### `dbt_homeit.code-workspace`

```json
{
  "folders": [
    { "path": "dbt_homeit" }
  ],
  "settings": {
    "python.defaultInterpreterPath": "/home/vscode/.venvs/dbt_homeit/bin/python"
  }
}
```

### `dbt_homeit_mariadb.code-workspace`

```json
{
  "folders": [
    { "path": "dbt_homeit_mariadb" }
  ],
  "settings": {
    "python.defaultInterpreterPath": "/home/vscode/.venvs/dbt_homeit_mariadb/bin/python"
  }
}
```

After opening each workspace:

1. run `Python: Select Interpreter`
2. pick the matching venv
3. configure dbt Power User for that project only

---

## Git guidance

### Do not commit

- `env/*.env`
- `.dbt/profiles.yml`
- `.dbt_mariadb/profiles.yml`
- `target/`
- `*.duckdb`
- local secrets / PATs

### Recommended `.gitignore`

```gitignore
env/*.env
*.env
.dbt/profiles.yml
.dbt_mariadb/profiles.yml

.venv/
.venv*/
__pycache__/
*.pyc
.pytest_cache/

target/
dbt_homeit/target/
dbt_homeit_mariadb/target/
dbt_packages/

*.duckdb
*.duckdb.wal
logs/
*.log

.DS_Store
```

### Devcontainer note

Git config writes from inside the devcontainer can fail on bind-mounted workspaces.

If that happens:
- keep working in the devcontainer
- do `git remote add`, `git pull`, and `git push` from the host terminal instead

---

## Troubleshooting

### `dbt debug` looks in wrong place

Always pass the explicit profiles dir:

- `dbt_homeit` → `--profiles-dir /workspaces/datapipelinev2/.dbt`
- `dbt_homeit_mariadb` → `--profiles-dir /workspaces/datapipelinev2/.dbt_mariadb`

### MinIO export works only with IP, not hostname

Use the resolved MinIO IP in env files and profiles.

### Loader says no Parquet files found

Check that MinIO exports really landed under the expected prefix, for example:

```text
curated/iotv2/sensors/entity=ruuvi_5min_avg/
curated/iotv2/sensors/entity=ruuvi_latest/
curated/iotv2/dq/entity=ruuvi_pipeline_kpi/
```

### MariaDB loader gets column mismatch from MinIO partitions

The current loader drops technical/path-derived columns like:

- `filename`
- `filename_1`
- `entity`
- `run_date`
- `run_ts`
- `_rn`

### MariaDB auth error `1045`

This is usually a MariaDB grant/password issue, not a network issue.

### View recursion in MariaDB dbt project

Use physical load tables named:

- `load_ruuvi_5min_avg`
- `load_ruuvi_latest`
- `load_ruuvi_dq_kpi`

and dbt models named:

- `stg_ruuvi_5min_avg`
- `stg_ruuvi_latest`
- `ops_ruuvi_dq_kpi`

---

## Current milestone status

### `dbt_homeit`

Working:
- RAW read
- enrichment
- DQ
- 5-minute aggregation
- CURATED export to MinIO

### `dbt_homeit_mariadb`

Working:
- CURATED Parquet read
- load into MariaDB
- dbt serving views build successfully
- tests pass

---

## Next recommended improvements

1. Create `scripts/run_pipeline.sh` and `scripts/run_mariadb_pipeline.sh` as locked runners
2. Create one master orchestrator script for both stages
3. Add a `systemd` timer for every-5-minute execution
4. Add more sensors / history and verify expected row volumes
5. Add more serving marts as needed

