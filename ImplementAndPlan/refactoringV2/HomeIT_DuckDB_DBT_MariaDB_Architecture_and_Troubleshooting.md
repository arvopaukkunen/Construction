# Home IT Data Pipeline: DuckDB, dbt, MinIO, and MariaDB

## Purpose

This document captures the troubleshooting, decisions, and final architecture for the Home IT data pipeline project.

It covers:

- why the DuckDB location became confusing
- how the `dbt_homeit` project was normalized
- why a second dbt project, `dbt_homeit_mariadb`, was introduced
- how data should move from MinIO and DuckDB into MariaDB
- what each project owns
- how to structure the folders, profiles, scripts, and model dependencies

This is intended to be GitHub-ready reference documentation.

---

## 1. Executive summary

The final design is:

- `dbt_homeit` is the **DuckDB + MinIO/S3 integration dbt project**
- `dbt_homeit_mariadb` is the **MariaDB-side dbt project**
- Python bridge scripts publish selected DuckDB model outputs into MariaDB
- MariaDB-side dbt models treat those published tables as **sources**, not as dbt-managed upstream models

In short:

```text
MinIO -> DuckDB/dbt -> Python publish -> MariaDB -> MariaDB/dbt marts
```

That split is intentional and correct.

---

## 2. Original problem: confusing DuckDB file locations

The project had multiple DuckDB-related files and references:

- `homeit.duckdb`
- `homeit.duckdbcd`
- `dbt_homeit/homeit.duckdb`
- `.dbt/homeit.duckdbcd`
- profile files and scripts pointing to different locations

### What was confusing

DuckDB does not require a specific file extension. So both of these are valid database files:

- `homeit.duckdb`
- `homeit.duckdbcd`

That flexibility caused confusion because multiple parts of the project were pointing to different database files.

### Root cause

The inconsistency came from a combination of:

- one dbt profile pointing to `homeit.duckdbcd`
- example profile content still pointing to `homeit.duckdb`
- Python loader scripts expecting `dbt_homeit/homeit.duckdb`
- an incorrect dbt `--profiles-dir` in the pipeline shell script

### Final decision

A single canonical DuckDB database file was selected:

```text
/workspaces/datapipelinev2/dbt_homeit/homeit.duckdb
```

This is the only DuckDB database file that should be actively used.

### Why this location was chosen

Because it is:

- next to the `dbt_homeit` project that owns it
- aligned with the Python loader scripts
- easier to understand than a file in `.dbt/` or project root
- the cleanest option for devcontainer-based work

---

## 3. Canonical DuckDB configuration

### Canonical file

```text
/workspaces/datapipelinev2/dbt_homeit/homeit.duckdb
```

### Canonical `profiles.yml` path setting

Use an absolute path to avoid ambiguity:

```yaml
path: /workspaces/datapipelinev2/dbt_homeit/homeit.duckdb
```

### Files that should no longer be used

These are duplicates or historical leftovers and should be removed or archived:

- `/workspaces/datapipelinev2/homeit.duckdbcd`
- `/workspaces/datapipelinev2/.dbt/homeit.duckdbcd`

### Historical artifacts that can be ignored for runtime logic

- `.dbt/logs/dbt.log`
- `dbt_homeit/logs/dbt.log`

These are logs only.

---

## 4. References that were found to DuckDB in the project

The following categories of references were identified during cleanup.

### Active config and scripts

- `dbt_homeit/profiles.yml`
- `dbt_homeit/profiles.yml.example`
- `scripts/load_decision_to_mariadb.py`
- `scripts/load_present_to_mariadb.py`
- `scripts/run_pipeline.sh`

### Database files and local artifacts

- `homeit.duckdbcd`
- `.dbt/homeit.duckdbcd`
- `dbt_homeit/homeit.duckdb`

### Logs showing prior runs

- `.dbt/logs/dbt.log`
- `dbt_homeit/logs/dbt.log`

---

## 5. Important pipeline script correction

One hidden issue was not only the DuckDB filename mismatch, but also the `dbt` profiles directory used by the run script.

### Problem

`scripts/run_pipeline.sh` was pointing dbt to:

```text
/workspaces/datapipelinev2/.dbt
```

But the actual `profiles.yml` being used for the project lives under:

```text
/workspaces/datapipelinev2/dbt_homeit
```

That could cause dbt to use the wrong profile context or fail unpredictably.

### Correct approach

The run script should use:

```bash
#!/usr/bin/env bash
set -euo pipefail

cd /workspaces/datapipelinev2/dbt_homeit

dbt run --profiles-dir /workspaces/datapipelinev2/dbt_homeit --select stg_victron_power int_energy_1min dec_current_energy_state present_energy_daily

cd /workspaces/datapipelinev2
python scripts/load_decision_to_mariadb.py
python scripts/load_present_to_mariadb.py
```

### Additional note

The shebang must be the first line of the script:

```bash
#!/usr/bin/env bash
```

not after a `cd` command.

---

## 6. Why one dbt project was not enough

A key design question was whether `dbt_homeit` could also directly target MariaDB.

### Short answer

Not in a clean, maintainable way.

### Why

`dbt_homeit` is built around:

- DuckDB adapter behavior
- MinIO/S3-style file access
- DuckDB SQL dialect and functions
- file/lake-style transforms

MariaDB is a different target system with:

- a different adapter (`dbt-mysql`)
- a different SQL dialect
- different materialization behavior
- different assumptions about object management

### Important clarification

A single dbt project can technically have multiple outputs or targets in a profile, but trying to use one project for both DuckDB and MariaDB would create ongoing maintenance problems because:

- the SQL would drift by target
- macros would become conditional and harder to reason about
- materializations would behave differently
- file-centric modeling and relational serving-layer modeling would mix together

### Final design decision

Use two separate dbt projects:

- `dbt_homeit` for DuckDB + MinIO work
- `dbt_homeit_mariadb` for MariaDB-side serving and marts

This is the correct architecture for the project.

---

## 7. Role of `dbt_homeit`

`dbt_homeit` is the **lake-facing transform project**.

### Target

- DuckDB

### Main responsibilities

- read from MinIO/S3-compatible storage
- perform heavy ELT and time-series transformations
- build staging, intermediate, decision, and presentation layers
- exploit DuckDB's strong support for S3-style file integration

### Typical model layers

- `models/staging/`
- `models/intermediate/`
- `models/decision/`
- `models/presentation/`

### Output behavior

This project builds results in DuckDB and may also export selected outputs.

It does **not** directly manage MariaDB through dbt in the final architecture.

---

## 8. Why Python bridge scripts remain necessary

The project already had two scripts:

- `load_decision_to_mariadb.py`
- `load_present_to_mariadb.py`

These are not a workaround to remove later. They are a valid publishing bridge between the DuckDB project and the MariaDB project.

### Their role

They take selected model outputs from DuckDB and publish them into MariaDB.

### This means the bridge layer owns

- transfer from DuckDB to MariaDB
- table creation or replace/upsert behavior in MariaDB
- the exact write path into serving-layer source tables

### Why this is useful

Because it keeps responsibilities clean:

- DuckDB/dbt does lake and transform work
- Python handles controlled publishing
- MariaDB/dbt models the already-published relational data

---

## 9. Role of `dbt_homeit_mariadb`

`dbt_homeit_mariadb` is the **MariaDB-side dbt project**.

### Target

- external MariaDB on `db2`

### Connection targets

Development:

```text
192.168.123.194:3306 / smarthome
```

Production:

```text
192.168.123.194:3306 / smarthome_prod
```

### Important implementation detail

MariaDB remains external.

It is **not** expected to run in the devcontainer.

The devcontainer only runs dbt and connects over the network to the external MariaDB host.

### Main responsibilities

- read Python-published source tables in MariaDB
- build MariaDB-native staging models
- build marts for reporting and dashboards
- build operational helper models
- provide dbt docs/tests for the MariaDB-side serving layer

### What this project should not own

It should **not** own the creation of upstream source tables that are loaded by Python from DuckDB.

Those are external to this project and should be modeled as dbt `source()` objects.

---

## 10. Why MariaDB is treated as an external database

The design requirement was explicit:

- MariaDB is on `db2`
- it should not run inside the devcontainer

That is the right approach.

### Why

Because the devcontainer is only a development and execution environment for dbt and scripts.

It does not need to host MariaDB itself.

### Correct connectivity model

- dbt runs inside the devcontainer or workspace environment
- MariaDB runs externally on `192.168.123.194:3306`
- dbt connects to it through the `dbt-mysql` adapter

---

## 11. MariaDB adapter and configuration notes

MariaDB support in this setup is through the MySQL adapter family.

### Adapter type used in `profiles.yml`

Even when the backend is MariaDB, the adapter type is:

```yaml
type: mysql
```

### Example target profile

```yaml
dbt_homeit_mariadb:
  target: dev
  outputs:
    dev:
      type: mysql
      server: 192.168.123.194
      port: 3306
      database: smarthome
      schema: smarthome
      username: Smarthome
      password: "{{ env_var('DBT_MARIADB_DEV_PASSWORD') }}"
      ssl_disabled: true

    prod:
      type: mysql
      server: 192.168.123.194
      port: 3306
      database: smarthome_prod
      schema: smarthome_prod
      username: Smarthome
      password: "{{ env_var('DBT_MARIADB_PROD_PASSWORD') }}"
      ssl_disabled: true
```

### Important note on JDBC

A string like:

```text
jdbc:mysql://192.168.123.194:3306/smarthome_prod
```

is a JDBC style connection string.

That is not how dbt is configured here.

For dbt, use explicit profile fields such as:

- `server`
- `port`
- `database`
- `schema`
- `username`
- `password`

---

## 12. dbt/protobuf error during MariaDB setup

During MariaDB project setup, `dbt debug` successfully connected to MariaDB, but then crashed afterward with an event/reporting error.

### Observed result

The connection itself was successful:

- host reachable
- credentials valid
- `Connection test: [OK connection ok]`

### The failure type

The crash happened in dbt's event reporting layer, not in the MariaDB connectivity layer.

### Interpretation

This indicates a Python package compatibility issue rather than a database problem.

### Practical fix applied

Pin `protobuf` to a compatible version:

```text
protobuf==4.25.3
```

### Recommended requirements file

```text
dbt-core==1.7.9
dbt-mysql==1.7.0
protobuf==4.25.3
```

That keeps the MariaDB dbt project stable in the current environment.

---

## 13. Final purpose of the second dbt project

This is the key conceptual point.

### Correct understanding

The second dbt project, `dbt_homeit_mariadb`, exists to use the MariaDB tables loaded by `dbt_homeit`'s Python scripts as **sources**.

Those tables are:

- not built by `dbt_homeit_mariadb`
- not managed upstream by `dbt_homeit_mariadb`
- already present in MariaDB before the MariaDB dbt project runs

### Therefore

Inside `dbt_homeit_mariadb`, those inputs should be declared as dbt sources and read with `source(...)`.

That is exactly the right design.

---

## 14. `source()` versus `ref()` in the MariaDB project

This distinction is fundamental.

### Use `source()` when

- the object already exists
- it is created outside the current dbt project
- it is loaded by Python, Node-RED, SQL scripts, or another pipeline

### Use `ref()` when

- the model is created by the current dbt project itself

### In this architecture

Python-loaded MariaDB tables should be read as:

```sql
select *
from {{ source('smarthome', 'src_present_energy_daily') }}
```

Then downstream MariaDB models can use:

```sql
select *
from {{ ref('stg_present_energy_daily') }}
```

### Dependency chain example

```text
external MariaDB table loaded by Python
        │
        ▼
source('smarthome', 'src_present_energy_daily')
        │
        ▼
stg_present_energy_daily
        │
        ▼
mart_energy_monthly
```

This is the correct model lineage.

---

## 15. Recommended naming convention in MariaDB

It is helpful to distinguish table ownership clearly.

### Recommended Python-loaded source table names

- `src_decision_current_energy_state`
- `src_present_energy_daily`

### Recommended MariaDB dbt model names

- `stg_decision_current_energy_state`
- `stg_present_energy_daily`
- `mart_energy_monthly`
- `mart_energy_7d`
- `ops_latest_energy_state`

### Why this helps

Because ownership is obvious from the name:

- `src_` = externally loaded input table
- `stg_`, `mart_`, `ops_` = dbt-managed MariaDB models

---

## 16. What each layer owns

### `dbt_homeit` owns

- DuckDB models
- MinIO/S3-facing ELT logic
- heavy reshaping
- deduplication
- time-windowing
- decision and presentation outputs before publishing

### Python bridge scripts own

- transfer of selected DuckDB model outputs into MariaDB
- insert/replace/upsert behavior in MariaDB
- publication of serving-layer source tables

### `dbt_homeit_mariadb` owns

- MariaDB staging models over Python-loaded source tables
- MariaDB reporting marts
- serving and operational helper models
- dbt documentation and tests for MariaDB-side outputs

---

## 17. Recommended folder structure

```text
/workspaces/datapipelinev2
│
├── dbt_homeit/                         # Project 1: DuckDB + MinIO/S3 ELT
│   ├── dbt_project.yml
│   ├── profiles.yml
│   ├── homeit.duckdb                  # canonical DuckDB database
│   ├── models/
│   │   ├── staging/                   # raw MinIO -> typed staging
│   │   ├── intermediate/              # dedupe, time grain, reusable transforms
│   │   ├── decision/                  # control-ready facts
│   │   └── presentation/              # daily summaries etc.
│   └── macros/
│
├── scripts/
│   ├── run_pipeline.sh
│   ├── load_decision_to_mariadb.py    # DuckDB -> MariaDB source tables
│   └── load_present_to_mariadb.py     # DuckDB -> MariaDB source tables
│
├── dbt_homeit_mariadb/                # Project 2: MariaDB-side serving/reporting dbt
│   ├── dbt_project.yml
│   ├── profiles.yml
│   └── models/
│       ├── staging/                   # reads Python-loaded MariaDB source tables
│       ├── marts/                     # reporting / dashboard marts
│       └── ops/                       # latest-state / operational helper models
│
└── sql/                               # optional DDL / bootstrap SQL
```

---

## 18. Final data flow diagram

```text
MinIO raw/work/curated
        │
        ▼
   dbt_homeit
   (DuckDB target)
        │
        ├── builds DuckDB models
        │     - staging
        │     - intermediate
        │     - decision
        │     - presentation
        │
        └── selected outputs published by Python
              │
              ▼
      MariaDB on db2
      192.168.123.194:3306
              │
              ├── source tables loaded by Python
              │     - src_decision_current_energy_state
              │     - src_present_energy_daily
              │
              ▼
      dbt_homeit_mariadb
      (MariaDB target)
              │
              ├── staging models from source(...)
              ├── marts via ref(...)
              └── ops / serving models
```

---

## 19. Compact end-to-end example

```text
1. MinIO parquet/json -> dbt_homeit model: dec_current_energy_state
2. load_decision_to_mariadb.py writes MariaDB table: src_decision_current_energy_state
3. dbt_homeit_mariadb source() reads src_decision_current_energy_state
4. stg_decision_current_energy_state standardizes names/types
5. ops_latest_energy_state or marts build downstream outputs
```

This is the intended control flow.

---

## 20. Operating model

### `dbt_homeit` execution flow

1. Read raw or curated data from MinIO
2. Build DuckDB models
3. Produce decision and presentation outputs
4. Run Python publishing scripts to send selected tables to MariaDB

### `dbt_homeit_mariadb` execution flow

1. Read Python-published source tables in MariaDB
2. Build staging models
3. Build marts and operational serving models
4. Support dashboard and application reads

### Result

This creates a stable separation between:

- lake transforms
- publishing into relational storage
- serving-layer relational modeling

---

## 21. Practical recommendations going forward

### Keep `dbt_homeit_mariadb` thin

Do not duplicate heavy business logic in both projects.

Best practice:

- heavy transformation and KPI logic stays in `dbt_homeit`
- MariaDB-side dbt stays relatively thin:
  - staging cleanup
  - name standardization
  - serving marts
  - lightweight aggregations
  - operational views

### Use absolute paths for DuckDB

Avoid relative path ambiguity by keeping:

```yaml
path: /workspaces/datapipelinev2/dbt_homeit/homeit.duckdb
```

### Use clear naming in MariaDB

Prefer `src_` prefixes for Python-loaded inputs.

### Keep MariaDB external

Continue running MariaDB only on `db2`, not inside the devcontainer.

---

## 22. Final architectural statement

The final architecture is:

```text
MinIO -> DuckDB/dbt -> Python publish -> MariaDB -> MariaDB/dbt marts
```

Where:

- `dbt_homeit` is the DuckDB/MinIO project
- Python scripts are the publication bridge
- `dbt_homeit_mariadb` is the MariaDB serving-layer dbt project

This is a sound, maintainable, and well-separated design for the Home IT data pipeline.

