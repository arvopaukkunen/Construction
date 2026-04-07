Yes — I think you are seeing the architecture more clearly now, and your instinct is mostly right.

My answer in one sentence:

**Use InfluxDB as the short-term replay source and land from InfluxDB to MinIO RAW first; use DuckDB/dbt as the transformation engine over MinIO, not as your serving database; and let CURATED become the stable analytical source while MariaDB holds the latest decision-serving tables.** 

## 1. Option #1 vs Option #2

I agree with your **Option #1** as the better next move.

### Option #1

Read from InfluxDB2 repeatedly and land to MinIO RAW.

That gives you:

* replay
* reprocessing
* backfill
* disaster recovery from landing mistakes
* ability to redesign RAW/WORK/CURATED without changing device integrations

This fits your current reality because InfluxDB is already the first durable landing point and already works well as your realtime monitoring and historical raw store. Your current Step 1 flow is already pulling from InfluxDB and writing JSON to MinIO RAW, so the pattern exists today.

### Option #2

Write to InfluxDB and MinIO at the same time from Node-RED.

That is possible, but in your situation it is weaker because:

* Node-RED is the current weak link for ETL/ELT
* if the MinIO-side write fails at ingest time, the event is gone unless it was also safely captured elsewhere
* it increases coupling in the part of the stack you are trying to simplify

For IoT/timeseries events, yes: **if the event only exists in one landing path and that path fails, the event does not “happen again.”** So you want one trusted first durable capture. In your case, that is already InfluxDB.

So for now:

### Recommended rule

* **InfluxDB = first durable capture**
* **MinIO RAW = replayable object-lake landing rebuilt from InfluxDB**
* later, if you want lower latency, you can add a second direct-to-MinIO path, but do not make that your only recovery path

---

## 2. The big misunderstanding to avoid: DuckDB’s role

I think the main thing to clarify is this:

**DuckDB is not the final database in this design.**
It is the **compute engine**.

That means DuckDB’s job is to:

* read files from MinIO
* join, deduplicate, normalize, validate
* materialize intermediate results
* write curated outputs back to MinIO
* feed selected latest results into MariaDB

That is why the earlier architecture put:

* **MinIO** as lake storage
* **DuckDB + dbt** as ELT engine
* **MariaDB** as decision/presentation serving layer 

So no, you did not misunderstand entirely — but the frustration comes from expecting DuckDB to also be the serving layer. That is not its intended role here.

### In this architecture:

* **InfluxDB** = hot/raw operational history
* **MinIO RAW/WORK/CURATED** = lake storage
* **DuckDB/dbt** = transformation engine over lake storage
* **MariaDB** = serving database for decisions, dashboards, queues

That is why the Python bridge to MariaDB exists. It is moving selected outputs from the analytical layer into the serving layer.

---

## 3. Should DuckDB live only briefly?

Yes, mostly.

In your setup, DuckDB can be treated as **short-lived or semi-persistent working state**, depending on convenience.

### The important point

The **source of truth should not be DuckDB**.

The source of truth should be:

* InfluxDB for first captured telemetry history
* MinIO RAW for replayable lake landing
* MinIO CURATED for stable conformed analytical datasets
* MariaDB for current decision-serving and presentation-serving tables

DuckDB can be:

* recreated
* rebuilt
* replaced
* rerun from MinIO

That is why it is okay if its lifetime is short.

### Practical interpretation

DuckDB is like:

* a powerful query/transformation runtime
* a local working database for dbt materializations
* a fast analytical scratchpad over MinIO

It does **not** need to be your permanent business database.

---

## 4. Can MinIO webhooks and REST alone do RAW → WORK → CURATED?

No — not by themselves.

MinIO webhooks are useful for:

* triggering processing
* notifying that an object arrived
* kicking off a job

But MinIO itself is not the transformation engine.

So this chain:

```text
MinIO RAW -> MinIO webhook -> MinIO REST -> MinIO WORK -> MinIO CURATED
```

does **not** perform enrichment, deduplication, or data quality correction on its own.

You still need an engine in the middle:

* DuckDB/dbt
* or Redpanda Connect for limited shaping
* or custom Python
* or Spark/Flink/etc.

In your scale and topology, DuckDB/dbt is still the sensible choice for that middle layer. The architecture doc already framed Node C exactly that way: **MinIO + Redpanda Connect + DuckDB/dbt + small scheduler** as the lake and transforms node. 

---

## 5. Where your current flows are overreaching

Your current Node-RED flows already prove the problem.

### Step 1 is not only ingest

Your Step 1 flow:

* queries InfluxDB
* enriches rows from `SensorMeta`
* renames Ruuvi source values
* special-cases Victron sensors
* applies heuristics like location/room/building
* adds RAW lifecycle/classification
* writes RAW JSON to MinIO

That means your RAW is already not truly raw.

### Step 2 is not only promotion

Your Step 2 flow:

* reads RAW
* adds RAW/WORK lifecycle and classification
* normalizes `_time`
* computes `time_epoch`
* fixes Ruuvi identity
* writes WORK JSON
* writes `work_sensoraverages`
* deletes the RAW object afterward

That means WORK is doing modeling work, and RAW is not being preserved as immutable replay source.

So yes: your current weak link is exactly that Node-RED is acting as an ETL/ELT engine.

---

## 6. What I recommend now

## Recommended architecture from here

### A. Keep InfluxDB as first durable landing

Node-RED continues doing what it is best at:

* integrating devices
* writing hot telemetry to InfluxDB
* realtime dashboards / monitoring

### B. Build MinIO RAW from InfluxDB

For now, the safest next move is:

* read from InfluxDB
* land source-shaped JSON/JSONL into MinIO RAW
* do not enrich semantically in Node-RED
* do not write SQL from Node-RED

That gives you recovery and replay.

### C. Treat WORK as optional technical staging

WORK should be:

* optional
* technical
* maybe compaction / technical reshaping
* not business enrichment and not decision logic

### D. Make CURATED the stable analytical truth

Yes — **CURATED should be stable, deduplicated, quality-checked, and ready for decision consumption**.

That is exactly the right target.

### E. Load only selected current-state outputs into MariaDB

MariaDB should receive:

* latest/current decision facts
* command queues
* ACK results
* presentation marts

Not raw or work-stage telemetry tables.

---

## 7. So what should RAW / WORK / CURATED mean?

Use this definition:

### RAW

* immutable
* source-shaped
* no semantic enrichment
* no heuristics
* no lifecycle/business tags beyond technical ingest metadata
* replayable

### WORK

* optional technical staging
* compaction
* normalization helpers
* maybe schema harmonization
* still not final business truth

### CURATED

* deduplicated
* quality-checked
* typed
* conformed
* decision-ready or presentation-ready

Right now your Step 2 flow is mixing WORK and CURATED concerns, and also deleting RAW too early.

---

## 8. What about Ruuvi first?

Your priority is correct.

The room/house air-quality and comfort decisions should not start from energy alone. They should start from:

* temperature
* humidity
* CO2

So yes:

* **Ruuvi first**
* then Netatmo and Legrand
* then conformed room-air-quality model
* then decision models

This also matches the room sensor pipeline direction already laid out: `Ruuvi` and other room sensors flow into `stg_room_sensor` and then `int_room_climate_*`, which then feed `dec_air_quality_action`.

---

## 9. My recommended answer to your core question

### Should data be read from InfluxDB2 to MinIO RAW first?

**Yes.**

For your current estate, that is the safer and more controllable design.

### Should MinIO webhooks alone do the transformations?

**No.**
They can trigger, not transform.

### Do you still need DuckDB?

**Yes, if you want SQL-first lake transformations over MinIO without bringing in heavier infrastructure.**

### Is DuckDB only temporary?

**Yes, conceptually.**
It is a compute/runtime layer, not the long-term serving database.

### Should CURATED be the stable deduplicated source for the decision engine?

**Yes.**
And then from CURATED you load the current/latest control-ready outputs into MariaDB.

---

## 10. Final recommended shape for your current phase

```text
Devices
 -> Node-RED
 -> InfluxDB   (first durable capture, hot + replay source)
 -> MinIO RAW  (rebuilt/read from InfluxDB)
 -> DuckDB/dbt (normalize, dedup, validate, conform)
 -> MinIO CURATED
 -> MariaDB decision_* and present_* latest-serving tables
 -> Node-RED command queue / MQTT dispatch
```

That is the production-sensible version of what you are building. It also matches the earlier target architecture: **InfluxDB for hot telemetry, MinIO for replayable history, DuckDB/dbt for ELT over MinIO, MariaDB for serving and control-ready facts.** 

---

## My recommendation for the next concrete step

Do **not** go to device actuation next.

Go to:

1. redefine RAW as truly raw
2. stop Step 1 semantic enrichment
3. stop Step 2 SQL and lifecycle-heavy business enrichment
4. create `stg_ruuvi_gtw`
5. create `stg_victron_env`
6. create `int_room_climate_4min`
7. only then bring in Netatmo/Legrand CO2

If you want, next I’ll turn this into a **copy-paste architecture decision record** with:

* Option 1 vs Option 2 decision
* final roles of InfluxDB, MinIO, DuckDB, MariaDB
* explicit RAW/WORK/CURATED definitions
* a Ruuvi-first target flow.
