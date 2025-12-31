# MariaDB (smarthome) + dbt Governance Gate for GDPR Special-Category Personal Data

This document describes the practical, enforceable governance pattern implemented for the **`smarthome`** MariaDB database using **dbt project `MariaDbDevContainers`**.

The design matches the “single database, logical zones via name prefixes” approach used in this environment.

---

## 1. Goals and scope

### 1.1 What we are governing
We want to detect and control potential exposure of **GDPR special-category personal data** (Article 9 categories), such as:

- ethnic origin
- political opinions
- religion / philosophical beliefs
- trade union membership
- health data
- sexual orientation / activity
- genetic data
- biometric data used to uniquely identify a person

### 1.2 Core rule
Special-category data **may exist in early zones** (e.g., `raw_`, `work_`) but must be:

1) **explicitly governed** (detected and/or declared),  
2) **minimized** before it propagates, and  
3) **blocked from publish layer** (`dim_` / `fact_`) unless an **approved exception** is documented.

---

## 2. Environment conventions

### 2.1 Database and “schema” model
- MariaDB database name: **`smarthome`**
- dbt target “schema” maps to the database name (MariaDB/MySQL behavior).

### 2.2 Logical zones as name prefixes
Logical layers are expressed with table/view name prefixes inside a single MariaDB database:

- Early zones: `raw_`, `work_`, `curated_`
- Transformation zones: `stg_`, `md_`
- Publish/MART layer (only): `dim_`, `fact_`
- Governance objects: `gov_`
- Optional DQ objects: `dq_`
- Views: **must** start with `v_` (e.g., `v_dim_location`)

### 2.3 dbt folder structure
Publish models are organized as:

- `models/mart/dim/`  → all dimension models
- `models/mart/fact/` → all fact models

---

## 3. Governance implementation overview

This solution is implemented via:

1) **Governance tables and procedures** in MariaDB (`gov_*`)
2) **dbt models** that materialize metadata and findings
3) **dbt tests** that hard-fail the build if special-category data reaches publish layer without an exception

### 3.1 Key governance tables (in `smarthome`)
- `gov_sensitive_dictionary`  
  Dictionary of column-name patterns to detect likely special-category data.

- `gov_sensitive_findings`  
  Unified findings table combining:
  - dbt metadata declarations (explicit)
  - dictionary scan (defensive)
  - optional external classification feed (`gov_purview_classifications`)

- `gov_exceptions`  
  Approved exceptions that allow special-category data in publish layer (rare; requires justification and controls).

- `gov_grants_snapshot`  
  Historical snapshot of SQL grants (exposure surface).

- `gov_scan_run`  
  Optional scan-run tracking (audit trail).

### 3.2 Stored procedures
- `CALL gov_snapshot_grants('smarthome');`  
  Captures current table/column privileges into `gov_grants_snapshot`.

- `CALL gov_apply_zone_grants('smarthome');`  
  Applies grants to objects based on prefix (per-object grants, because MariaDB/MySQL do not support wildcard grants by pattern).

---

## 4. dbt metadata declarations (explicit governance)

### 4.1 Declaring special-category columns in model YAML
Declare a column as special-category via `meta.special_category`:

```yaml
models:
  - name: dim_person
    columns:
      - name: diagnosis_code
        meta:
          special_category: health
          confidence: high   # optional: low|medium|high
```

Supported categories:

- `ethnic`
- `political`
- `religion`
- `union`
- `health`
- `sexual`
- `genetic`
- `biometric`

dbt declarations are materialized into SQL by:

- `models/gov/gov_dbt_declared_classifications.sql`

---

## 5. Detection and findings pipeline

### 5.1 Dictionary scan (defensive detection)
The model:

- `models/gov/gov_sensitive_candidates.sql`

scans `information_schema.columns` for relations in scope (raw/work/curated/stg/md/dim/fact and their `v_` views) and matches column names against `gov_sensitive_dictionary`.

### 5.2 Unified findings
The model:

- `models/gov/gov_sensitive_findings.sql`

unifies three inputs into a single findings table:

1. dbt meta declarations (`DBT_META`)
2. dictionary scan (`DICT_NAME`)
3. optional external feed (`PURVIEW`) if `gov_purview_classifications` exists

---

## 6. Publish-layer gate (dim_/fact_ only)

### 6.1 Rule
Any special-category signal (`severity >= 5`) found in **`dim_*`** or **`fact_*`** relations is a **build-breaking violation** unless there is a matching active exception in `gov_exceptions`.

### 6.2 Where violations are computed
- `models/gov/v_gov_publish_layer_violations.sql`

### 6.3 Hard-failing dbt tests
- `tests/test_publish_layer_no_special_category.sql`  
  Fails if `v_gov_publish_layer_violations` returns rows.

- `tests/test_risk_register_no_block.sql`  
  Fails if the risk register marks any publish-layer relation as `BLOCK`.

### 6.4 Generic per-model gate test macro (optional but available)
You can also attach the generic test to a specific model:

```yaml
models:
  - name: dim_device
    tests:
      - gov_mart_gate: {}
```

Macro: `macros/gov/test_gov_mart_gate.sql`

---

## 7. Auto-attaching the `gov_mart_gate` test to all dim/fact models

Place the following file at:

- `models/mart/schema.yml`

It attaches `gov_mart_gate` to **all models** located in `models/mart/dim/` and `models/mart/fact/` automatically:

```yaml
version: 2

models:
{% for node in graph.nodes.values()
   if node.resource_type == 'model'
   and (
     node.original_file_path.startswith('models/mart/dim/')
     or node.original_file_path.startswith('models/mart/fact/')
   )
%}
  - name: {{ node.name }}
    tests:
      - gov_mart_gate: {}
{% endfor %}
```

Notes:
- dbt renders Jinja in `.yml` files, so this expands into a concrete model list at parse time.
- This is preferred over manually listing each `dim_*` and `fact_*` model.

---

## 8. Risk register (single-pane-of-glass)

The model:

- `models/gov/gov_risk_register.sql`

computes a governance register per relation combining:

- special-category findings (count + max confidence)
- publish-layer status (`OK`, `REVIEW`, `BLOCK`, `APPROVED_EXCEPTION`)
- exposure surface from current SQL grants
- a numeric risk score (0–100) designed to prioritize remediation

This is intended as the operational reporting surface for governance.

---

## 9. Exceptions (documented, reviewable, expirable)

### 9.1 Default posture
Special-category data is **not allowed** in publish layer (dim/fact) by default.

### 9.2 How to allow an exception
Add a row to `gov_exceptions` (typically managed via dbt seed `seeds/gov_exceptions.csv`).

Minimum expectations for an exception entry:
- documented purpose
- lawful basis reference (Art. 6) and Art. 9 condition reference
- controls (e.g., restricted roles, masking, aggregation/minimization)
- review date and (optionally) expiry date

After adding/activating an exception:
```bash
dbt seed -s gov_exceptions
dbt run -s gov+
dbt test -s test_publish_layer_no_special_category test_risk_register_no_block
```

---

## 10. Installation and runbook

### 10.1 One-time database setup (DBeaver)
Run the governance DDL in `smarthome`:

- `scripts/governance/01_gov_ddl_smarthome.sql`

Optional after dbt creates objects:
```sql
CALL gov_apply_zone_grants('smarthome');
CALL gov_snapshot_grants('smarthome');
```

### 10.2 dbt run sequence
Recommended sequence:

```bash
dbt seed
dbt run -s gov+
dbt test -s test_publish_layer_no_special_category test_risk_register_no_block
```

If you want gating as part of every publish build, run tests after `dbt run` in CI.

---

## 11. Notes and operational guidance

- The naming test is scoped to **dbt-managed relations** so legacy/manual tables (e.g., non-prefixed tables) do not break your build.
- Start with **dictionary scan + explicit dbt meta**. If you later add external classification output, load it into `gov_purview_classifications`.
- Avoid logging raw sample values for sensitive detection. Keep evidence aggregated or omitted.

---

## Appendix A — Seed files

### A.1 `seeds/gov_sensitive_dictionary.csv`
This is the starter pattern list for name-based detection. Extend it for your domain.

### A.2 `seeds/gov_exceptions.csv`
Leave empty by default. Populate only when you intentionally allow publish-layer special-category columns.

---

Generated: 2025-12-30 21:38:00
