# MariaDB (`smarthome`) Governance with dbt (`dw_mariadb`) — Practical Runbook

This document captures the working governance pattern for detecting and controlling **GDPR special‑category personal data** signals in a **single MariaDB database** using **dbt**.  
It is written for the current environment where “schemas” are represented by **table/view name prefixes**.

Generated: 2026-01-01 15:37:36

---

## 1) Governance objective (GDPR special categories)

As a rule, processing of **special categories of personal data** is prohibited unless a valid legal basis and safeguards exist. These categories include data revealing:

- ethnic origin  
- political opinions  
- religion or philosophical beliefs  
- trade union membership  
- health data  
- sexual orientation / activity  
- genetic data  
- biometric data used to uniquely identify a person  

**Governance policy in this solution:**

- Special-category signals **may exist in early zones** (RAW/WORK/CURATED) for ingestion and processing.
- Signals must be **explicitly governed** (declared via dbt meta and/or detected by dictionary scan).
- Signals should be **minimized** before they propagate.
- Signals are **blocked from publish layer** (`dim_` / `fact_`) **unless** there is an **explicit exception** in `gov_exceptions`.

---

## 2) Database & naming conventions

### 2.1 Single MariaDB database
- Database name: **`smarthome`**
- dbt target schema = **`smarthome`** (MariaDB/MySQL adapter treats schema as database)

### 2.2 Zone prefixes (tables and views)
Logical zones are encoded in the relation name:

- `raw_` / `v_raw_`  
- `work_` / `v_work_`  
- `curated_` / `v_curated_`  
- `stg_` / `v_stg_`  
- `md_` / `v_md_`  
- **Publish layer only:** `dim_`, `fact_` (and optionally `v_dim_`, `v_fact_` if views are used)  
- Governance: `gov_`, `v_gov_`  
- (Optional) DQ: `dq_`, `v_dq_`

**Rule:** Views must be prefixed `v_`.

---

## 3) dbt project specifics

- dbt package/project name (as shown in logs): **`dw_mariadb`**
- Target: `dev` (example)
- Governance selection: **`gov+`** (models tagged / named under gov)

---

## 4) Governance components (what gets built)

### 4.1 Seeds (inputs)

1. `gov_sensitive_dictionary`  
   - Pattern dictionary for name-based detection of special-category signals.

2. `gov_exceptions`  
   - Explicit, reviewable exceptions that allow special-category signals in publish layer.
   - Must include **`relation_name`** and **`column_name`** (column can be blank to allow all columns for a relation).

3. (Optional) `raw_device_seed`  
   - Example seed for devices; not required for governance, but used in your dataset.

### 4.2 Core governance models (tables)

- `gov_identity_amplifiers`  
  Flags relations that contain identity-amplifying columns (email, phone, national_id, mac, imei, etc.)

- `gov_sensitive_candidates`  
  Dictionary-based detection: scans `information_schema.columns` and matches against `gov_sensitive_dictionary`.

- `gov_dbt_declared_classifications`  
  Materializes dbt `meta.special_category` declarations into rows.

- `gov_sensitive_findings`  
  Unified findings table (dbt meta + dictionary scan (+ optional external feed)) including:
  - `scan_ts`
  - `relation_name`
  - `column_name`
  - `detected_category`
  - `severity`
  - `confidence`
  - `signal_sources`

### 4.3 Views (reporting)

- `v_gov_publish_layer_violations`  
  Publish-layer gate view: shows `dim_*/fact_*` findings with **no active exception**.

- `v_gov_sensitive_summary`  
  High-level summary counts (implementation-specific).

- `v_gov_sensitive_risk_report`  
  Aggregated report of findings by relation and scan time.

- `v_gov_sensitive_top_findings`  
  “Top findings” view for quick review.

- `v_gov_tot_issues`  
  Count of issues per relation (optionally enriched with identity amplifiers).

---

## 5) Key configuration that must be correct

### 5.1 Seeds configuration key must match dbt package name
Your dbt logs show `dw_mariadb`, so in `dbt_project.yml` seed configs must be under:

```yaml
seeds:
  dw_mariadb:
    ...
```

If you instead use `MariaDbDevContainers:` (or any other name), dbt will warn about **unused configuration paths**.

### 5.2 `gov_exceptions` must include `column_name`
The publish-layer violations view joins exceptions by **relation** and optionally **column**.
Ensure:

- `seeds/gov_exceptions.csv` header contains `column_name`
- `dbt_project.yml` sets column types for `column_name`

Example header:

```csv
relation_name,column_name,approved_by,owner_team,purpose,legal_basis_art6,special_cat_art9,controls,review_date,expires_date,notes,is_active
```

---

## 6) Operational runbook (automation-friendly)

### 6.1 Hourly / frequent governance refresh (recommended)
Use this as the scheduled job:

```bash
dbt seed
dbt run -s gov+
dbt test -s test_publish_layer_no_special_category test_risk_register_no_block
```

### 6.2 Daily (or when seed structure / column types change)
Use `--full-refresh` only when needed:

```bash
dbt seed --full-refresh
dbt run -s gov+
dbt test -s test_publish_layer_no_special_category test_risk_register_no_block
```

### 6.3 After macro/config changes (rare)
```bash
dbt clean
dbt deps
dbt seed --full-refresh
dbt run -s gov+
dbt test -s test_publish_layer_no_special_category test_risk_register_no_block
```

---

## 7) Validation queries (MariaDB)

### 7.1 Confirm seed row counts
```sql
SELECT COUNT(*) FROM smarthome.gov_sensitive_dictionary;
SELECT COUNT(*) FROM smarthome.gov_exceptions;
```

### 7.2 Confirm unified findings
```sql
SELECT * FROM smarthome.gov_sensitive_findings ORDER BY scan_ts DESC LIMIT 50;
```

### 7.3 Confirm publish-layer gate
```sql
SELECT * FROM smarthome.v_gov_publish_layer_violations LIMIT 200;
```

If this returns rows, the dbt test should fail (as intended) unless an active exception exists.

---

## 8) Automation options

### 8.1 On-prem Linux / Raspberry Pi: cron (simple)
Create a script `run_governance.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd /workspaces/MariaDbDevContainers   # adjust to your project path
dbt seed
dbt run -s gov+
dbt test -s test_publish_layer_no_special_category test_risk_register_no_block
```

Add to cron (hourly):

```cron
0 * * * * /opt/dbt/run_governance.sh >> /var/log/dbt_governance.log 2>&1
```

### 8.2 On-prem Linux / Raspberry Pi: systemd timer (preferred over cron)
Use a `dbt-governance.service` + `dbt-governance.timer` for better reliability, logging, and status.

### 8.3 Node-RED orchestration (good for alerting)
- Use an Inject node (schedule) → Exec node (run script)
- Send notifications on non-zero exit code (Slack/Telegram/email/Home Assistant)

### 8.4 Azure orchestration (ADF) — possible but usually overkill here
You can orchestrate dbt via:
- SSH to an on-prem host (Self-hosted IR), or
- A container/VM/Batch job that runs dbt

ADF is appropriate if you already have enterprise monitoring and want governance integrated into it.

---

## 9) Troubleshooting quick-reference (issues seen and fixes)

- **`smarthome_smarthome` database created unexpectedly**  
  Cause: schema concatenation via overrides.  
  Fix: avoid `+schema` overrides; optionally implement `generate_schema_name` macro to prevent concatenation.

- **`No test named 'match' found`**  
  Cause: Jinja `is match(...)` unsupported.  
  Fix: use `modules.re.match(...)`.

- **MariaDB syntax error near `; )` in models**  
  Cause: semicolon at end of model query conflicts with dbt wrapper `create table as (...)`.  
  Fix: remove semicolons in model SQL.

- **`relation_exists` undefined**  
  Fix: implement a `relation_exists` macro using `adapter.get_relation`.

- **Unknown columns: `signals`, `dataset_name`, `scan_ts`, `identity_amplifier`**  
  Cause: column renames / inconsistent schema.  
  Fix: standardize on:
  - `relation_name` (not `dataset_name`)
  - `signal_sources` (not `signals`)
  - add `scan_ts` to findings
  - use `has_identity_amplifier` as created by `gov_identity_amplifiers`

---

## 10) What “success” looks like
A healthy run should show:

- `dbt run -s gov+` completes with **0 errors**
- `dbt test` fails only when you intentionally introduce special-category signals into `dim_`/`fact_` without an approved exception
- Governance views (especially `v_gov_publish_layer_violations`) support quick operational review
