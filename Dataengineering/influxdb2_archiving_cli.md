
# InfluxDB 2.x archiving with CLI (Arvosoft / sensors → sensor_YYYY)

This page documents how to:

- Configure the InfluxDB 2.x CLI on the Linux host (VSCodde dev container).
- Verify connectivity to the local InfluxDB 2 server.
- Run Flux queries from the CLI to **copy data by day** from the main `sensors` bucket into yearly archive buckets like `sensors_2024`, `sensors_2023`, etc.
- Avoid common errors (`RequestTimedOutError`, bash syntax errors).

The examples assume:

- InfluxDB 2.x is running on `http://db2:8086`
- Organization is: `Arvosoft Oy`
- Online bucket with full data: `sensors`
- Archive buckets per year: `sensors_2024`, `sensors_2023`, `sensors_2022`, `sensors_2021`
- Influx CLI is installed and in `PATH` on the Linux host.

---

## 1. Configure the InfluxDB CLI

First create a named CLI configuration so that you do not need to pass host, org and token every time.

### 1.1. Create a config

```bash
influx config create \
  --config-name ArvosoftWrk1 \
  --host-url http://db2:8086 \
  --org "Arvosoft Oy" \
  --token '<YOUR_LONG_TOKEN_HERE>' \
  --active
```

Notes:

- `--config-name` (or `-n`) is the name of this CLI profile.
- `--host-url` (or `-u`) must be used; `--host` is **not** a valid flag.
- `--token` (or `-t`) is your InfluxDB API token.
- `--active` (or `-a`) marks this config as the default for subsequent `influx` commands.

You can check the configuration file is created in `~/.influxdbv2/configs`.

### 1.2. Verify configuration

List configs:

```bash
influx config list
```

You should see something like:

```text
Active  Name          URL               Org          Token
*       ArvosoftWrk1  http://db2:8086   Arvosoft Oy  ****************
```

Ping the server:

```bash
influx ping
```

List buckets (good quick connectivity check):

```bash
influx bucket list
```

You should see at least:

- `sensors`
- `sensors_2024`
- `sensors_2023`
- `sensors_2022`
- `sensors_2021`

---

## 2. Running Flux from the CLI (important: don’t paste Flux directly into bash)

### 2.1. Why the earlier errors happened

If you paste pure Flux like this into a shell:

```bash
import "influxdata/influxdb/schema"

from(bucket: "sensors")
  |> range(start: 2024-12-30T00:00:00Z, stop: 2024-12-31T00:00:00Z)
  |> keep(columns: ["_time", "_value"])
  |> to(bucket: "sensors_2024")
```

bash will interpret `import`, `from`, and `|>` as shell syntax and you will get errors such as:

- `bash: import: command not found`
- `bash: syntax error near unexpected token '|'`
- `bash: syntax error near unexpected token 'bucket:'`

**Solution:** always send Flux to the `influx query` command, either as:

- A quoted string argument, or
- Stdin via a here-document.

### 2.2. Option A – Inline Flux with `influx query '…'`

Basic pattern:

```bash
influx query '
<Flux script here>
'
```

Example (single-day copy from `sensors` to `sensors_2024`):

```bash
influx query '
import "influxdata/influxdb/schema"

from(bucket: "sensors")
  |> range(start: 2024-12-30T00:00:00Z, stop: 2024-12-31T00:00:00Z)
  |> keep(columns: ["_time", "_value", "_field", "_measurement",
                    "entity_id", "friendly_name", "domain", "source",
                    "location", "room"])
  |> to(bucket: "sensors_2024")
'
```

Because we created and activated the `ArvosoftWrk1` config, we do not need to specify `--host-url`, `--org`, or `--token` each time.

If you want to be explicit about org:

```bash
influx query \
  --org "Arvosoft Oy" \
  '
import "influxdata/influxdb/schema"

from(bucket: "sensors")
  |> range(start: 2024-12-30T00:00:00Z, stop: 2024-12-31T00:00:00Z)
  |> keep(columns: ["_time", "_value", "_field", "_measurement",
                    "entity_id", "friendly_name", "domain", "source",
                    "location", "room"])
  |> to(bucket: "sensors_2024")
'
```

Key points:

- **Everything between the single quotes** is treated as one Flux script.
- Newlines inside the quotes are fine.
- Do not let the shell see bare `|>` operators without quoting.

### 2.3. Option B – Here-document (often easier for longer scripts)

Pattern:

```bash
cat <<'EOF' | influx query
<Flux script here>
EOF
```

Example:

```bash
cat <<'EOF' | influx query
import "influxdata/influxdb/schema"

from(bucket: "sensors")
  |> range(start: 2024-12-30T00:00:00Z, stop: 2024-12-31T00:00:00Z)
  |> keep(columns: ["_time", "_value", "_field", "_measurement",
                    "entity_id", "friendly_name", "domain", "source",
                    "location", "room"])
  |> to(bucket: "sensors_2024")
EOF
```

Notes:

- The `'EOF'` (with quotes) tells bash **not** to interpolate `$VAR` etc. inside the block.
- You can paste multi-line Flux without worrying about shell quoting rules.

---

## 3. One-day archive copy: `sensors` → `sensors_YYYY`

### 3.1. General Flux template (per day, per year)

Use this template to copy one day from the main bucket `sensors` to a yearly bucket such as `sensors_2024`:

```flux
import "influxdata/influxdb/schema"

from(bucket: "sensors")
  |> range(start: YYYY-MM-DDT00:00:00Z, stop: YYYY-MM-(DD+1)T00:00:00Z)
  |> keep(columns: ["_time", "_value", "_field", "_measurement",
                    "entity_id", "friendly_name", "domain", "source",
                    "location", "room"])
  |> to(bucket: "sensors_YYYY")
```

You then run it via CLI as shown above.

### 3.2. Concrete example: 2024-12-30 → `sensors_2024`

```bash
influx query '
import "influxdata/influxdb/schema"

from(bucket: "sensors")
  |> range(start: 2024-12-30T00:00:00Z, stop: 2024-12-31T00:00:00Z)
  |> keep(columns: ["_time", "_value", "_field", "_measurement",
                    "entity_id", "friendly_name", "domain", "source",
                    "location", "room"])
  |> to(bucket: "sensors_2024")
'
```

After it completes, validate in the InfluxDB UI:

- Bucket: `sensors_2024`
- Time range: 2024-12-30
- Check that measurements and tags are present as expected.

---

## 4. Notes on performance and timeouts

### 4.1. Why Node-RED queries timed out

Earlier runs from Node-RED using large time windows (weeks/months) caused:

```text
RequestTimedOutError: Request timed out
```

and, in some cases, the InfluxDB 2 process appeared to restart on the small HP laptop (8 GB RAM).  
Root causes:

- Time window too large → huge number of points scanned.
- Node-RED default HTTP timeouts (20s) too small for big Flux operations.
- CPU and memory pressure on the old laptop.

Moving the copy logic to the **CLI + smaller time ranges (1 day)** reduces:

- Memory pressure.
- Query duration.
- Risk of Node-RED timeouts.

### 4.2. Why per-day windows are safer

Good pattern for resource-constrained InfluxDB:

- Use **daily range windows** when backfilling large archives.
- Run one day at a time (manually or via a shell loop).
- Optionally, throttle by inserting `sleep` between days.

For example, to copy a range of days for 2024 using bash:

```bash
# Example only – dates must be adjusted manually to avoid off-by-one issues.

for day in 01 02 03 04 05; do
  influx query "
import \"influxdata/influxdb/schema\"

from(bucket: \"sensors\")
  |> range(start: 2024-12-${day}T00:00:00Z, stop: 2024-12-$(printf \"%02d\" $((10#$day + 1)))T00:00:00Z)
  |> keep(columns: [\"_time\", \"_value\", \"_field\", \"_measurement\",
                    \"entity_id\", \"friendly_name\", \"domain\", \"source\",
                    \"location\", \"room\"])
  |> to(bucket: \"sensors_2024\")
"
  sleep 5
done
```

(If used, this loop must be carefully tested and adjusted for correct end-dates and month boundaries.)

---

## 5. Troubleshooting

### 5.1. `RequestTimedOutError` (Node-RED / HTTP)

Error example:

```text
RequestTimedOutError: Request timed out
    at ClientRequest.<anonymous> ...
```

Mitigations:

- Reduce time range (e.g. from weeks/months → single day).
- Move heavy archival copy to CLI (`influx query`) instead of Node-RED where possible.
- Increase Node-RED HTTP timeout only if really needed, but it does not fix underlying resource limits.

### 5.2. `flag provided but not defined: -host` / `-name`

If you see:

```text
Incorrect Usage: flag provided but not defined: -host
```

or

```text
flag provided but not defined: -name
```

Correct flags for `influx config create` are:

- `--config-name` or `-n`, **not** `--name` or `-name`
- `--host-url` or `-u`, **not** `--host` or `-host`

Use:

```bash
influx config create \
  --config-name ArvosoftWrk1 \
  --host-url http://db2:8086 \
  --org "Arvosoft Oy" \
  --token '<TOKEN>' \
  --active
```

### 5.3. Bash syntax errors when pasting Flux

If you see:

```text
bash: import: command not found
bash: syntax error near unexpected token `|'
bash: syntax error near unexpected token `bucket:'
```

then Flux was pasted directly into bash.

Always:

- Wrap Flux in `influx query ' ... '`, **or**
- Use the here-document pattern:

  ```bash
  cat <<'EOF' | influx query
  <Flux script>
  EOF
  ```

---

## 6. Summary

- Use `influx config create` to define a stable CLI profile pointing to `http://db2:8086` with org `Arvosoft Oy`.
- Run Flux scripts via `influx query` (quoted string or here-doc), not directly in bash.
- Copy data day-by-day from `sensors` to `sensors_YYYY` to reduce load on the small InfluxDB server.
- Consider cleaning or shortening retention on the main `sensors` bucket once archives are verified in the `sensors_YYYY` buckets.
