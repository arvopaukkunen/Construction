# Home IT End-to-End Platform Documentation

## Purpose

This document describes the full platform from telemetry ingestion to decision generation to command dispatch to device actuation.

It reflects the current architecture:

- Node-RED on `myNodered1`
- InfluxDB on `db1`
- MariaDB + MinIO on `db2`
- MQTT broker on Teltonika router `192.168.123.2`
- Redpanda Connect + DuckDB + dbt on the transform environment

---

# 1. End-to-end architecture

```text
Devices / Sensors / Controllers
        |
        v
Node-RED on myNodered1
  - reads device protocols
  - formats telemetry JSON
  - publishes telemetry to MQTT
        |
        v
MQTT broker on 192.168.123.2
        |
        v
Redpanda Connect
  - subscribes to telemetry topics
  - batches messages
  - writes raw JSONL files into MinIO
        |
        v
MinIO on db2
  - raw bucket for immutable telemetry
        |
        v
DuckDB + dbt
  - reads raw telemetry from MinIO
  - builds staging views
  - builds intermediate tables
  - builds decision tables
  - builds presentation tables
        |
        +------------------------------+
        |                              |
        v                              v
MariaDB on db2                    MinIO curated / artifacts
  - decision_* tables             - optional parquet outputs
  - present_* tables
  - ops_* logs
        |
        v
Node-RED Decision Command Queue flow
  - polls decision_command_queue
  - publishes MQTT commands
  - marks SENT
  - receives ACK
  - marks ACKED
  - logs dispatch / ack / retry
        |
        v
MQTT broker on 192.168.123.2
        |
        v
Device adapter flows
  - translate generic commands
  - write Modbus / HTTP / API / relay / IR / etc.
        |
        v
Real physical devices
  - Konvektor / fan coil
  - AC
  - ventilation
  - dishwasher
  - laundry
  - lighting
```

---

# 2. Telemetry ingest path

## 2.1 Node-RED role

Node-RED on `myNodered1` is the edge integration layer.

Responsibilities:

- read Victron telemetry
- read HVAC / Sorel / Sabiana data
- read room sensor data
- read appliance telemetry
- convert source-specific data into a common JSON payload
- publish to MQTT

Recommended telemetry topic pattern:

```text
home/{site}/{domain}/{entity}/{device_id}/{signal}
```

Example:

```text
home/home/energy/victron/inverter_1/pv_power_w
```

Example payload:

```json
{
  "ts": "2026-04-03T09:00:00Z",
  "site": "home",
  "domain": "energy",
  "entity": "victron",
  "device_id": "inverter_1",
  "signal": "pv_power_w",
  "value": 1845.0,
  "unit": "W",
  "quality": "ok",
  "source": "nodered"
}
```

---

## 2.2 MQTT broker role

The MQTT broker on `192.168.123.2` is the transport layer between:

- telemetry producers
- ingestion/landing services
- decision/command consumers
- device adapter flows

It carries both:

- telemetry topics
- command topics
- ACK topics
- dispatch status topics

---

## 2.3 Redpanda Connect role

Redpanda Connect subscribes to telemetry topics and writes raw objects into MinIO.

Responsibilities:

- subscribe to `home/+/+/+/+/+`
- receive telemetry messages from MQTT
- batch messages into JSONL objects
- write those objects into MinIO raw bucket

Typical output key pattern:

```text
source=<entity>/site=<site>/year=<YYYY>/month=<MM>/day=<DD>/hour=<HH>/part-<uuid>.jsonl
```

Example:

```text
source=victron/site=home/year=2026/month=04/day=03/hour=16/part-1234.jsonl
```

---

## 2.4 MinIO role

MinIO on `db2` is the raw and curated data lake.

Typical buckets:

- `homeit-raw`
- `homeit-curated`
- `homeit-artifacts`

Current proven path:

- telemetry messages are written into `homeit-raw`

---

# 3. Analytical transformation path

## 3.1 DuckDB + dbt role

DuckDB + dbt is the transformation layer.

Responsibilities:

- read raw JSONL telemetry from MinIO
- normalize fields in staging models
- aggregate data in intermediate models
- compute decision outputs
- compute present/reporting outputs

Current proven path includes:

- `stg_victron_power`
- `int_energy_1min`
- `dec_current_energy_state`
- `present_energy_daily`

---

## 3.2 Model layer meaning

### Staging layer

Raw source normalization.

Examples:

- `stg_victron_power`
- `stg_room_sensor`
- `stg_hvac_controller`
- `stg_appliance_state`

### Intermediate layer

Reusable calculations and time-grain alignment.

Examples:

- `int_energy_1min`
- `int_room_climate_1min`
- `int_hvac_state_1min`
- `int_appliance_usage_1min`

### Decision layer

Control-ready facts.

Examples:

- `dec_current_energy_state`
- `dec_air_quality_action`
- `dec_hvac_load_opportunity`
- `dec_appliance_shift_candidate`

### Presentation layer

Reporting-ready aggregates.

Examples:

- `present_energy_daily`

---

# 4. MariaDB role

MariaDB on `db2` is the relational serving and control database.

Prefix-based tables are used instead of schemas.

Examples:

- `decision_current_energy_state`
- `decision_command_queue`
- `present_energy_daily`
- `ops_pipeline_run_log`

## 4.1 Decision tables

Decision tables hold control-ready information.

Examples:

- current energy surplus / deficit state
- decision queue entries for dispatch
- device capability and constraints
- recommendation metadata

## 4.2 Presentation tables

Presentation tables hold dashboard/reporting outputs.

Example:

- daily energy summary

## 4.3 Ops log table

The ops table records execution events such as:

- dispatch sent
- ACK received
- retry queued
- error detected

---

# 5. Decision path

The platform computes decisions in the analytical layer and stores them in MariaDB.

Example decision facts:

- produced energy kW
- consumed energy kW
- net energy kW
- battery SOC
- surplus class
- available flexible kW

These are written into:

```text
decision_current_energy_state
```

This is the basis for deciding:

- whether to start an appliance
- whether to delay a load
- whether to preheat a room
- whether to boost ventilation

---

# 6. Command dispatch path

## 6.1 Decision command queue

Commands are stored in MariaDB table:

```text
decision_command_queue
```

Each row includes:

- `command_id`
- `created_ts`
- `device_id`
- `topic`
- `payload_json`
- `status`
- `sent_ts`
- `ack_ts`

Status lifecycle:

```text
NEW -> SENT -> ACKED
```

Error lifecycle:

```text
NEW -> ERROR -> NEW (retry)
```

---

## 6.2 Node-RED dispatch flow role

The `Decision Command Queue v2` tab in Node-RED performs the command dispatch.

Responsibilities:

- poll `decision_command_queue`
- select rows with `status = 'NEW'`
- parse `payload_json`
- force database `command_id` into outbound MQTT payload
- publish the command to MQTT
- mark the row as `SENT`
- write an ops log row
- receive ACK messages
- mark the row as `ACKED`
- retry `ERROR` rows

---

## 6.3 Why `command_id` is injected into MQTT payload

The database row already has a unique `command_id`.

That ID is injected into the MQTT payload before publish so the ACK handler can map a later ACK back to the exact MariaDB queue row.

Without this, ACK handling becomes unreliable.

---

# 7. ACK handling

## 7.1 ACK input

Node-RED listens for ACKs on:

```text
home/home/ack/+/+/+
```

Example ACK payload:

```json
{
  "command_id": 123,
  "status": "ACKED",
  "device_id": "dw_1",
  "ack_source": "device_or_simulator",
  "ts": "2026-04-03T16:30:00.000Z"
}
```

## 7.2 ACK action

When an ACK is received, Node-RED:

- extracts `command_id`
- updates `decision_command_queue`
- sets `status = 'ACKED'`
- sets `ack_ts = NOW()`
- writes an ops log row
- publishes an ACK status MQTT event

---

# 8. Fake ACK Simulator

## Purpose

The `Fake ACK Simulator` tab is a test-only helper.

It does not change the command queue flow.

It is used to validate the full queue lifecycle without a real physical device.

## Responsibilities

- subscribe to `home/home/cmd/#`
- read command payloads
- extract `command_id`
- wait 2 seconds
- publish an ACK to MQTT

### ACK topic

```text
home/home/ack/simulated/device/response
```

### ACK payload example

```json
{
  "command_id": 123,
  "status": "ACKED",
  "device_id": "dw_1",
  "ack_source": "fake_ack_simulator",
  "ts": "2026-04-03T16:30:00.000Z"
}
```

---

# 9. Where real device actuation happens

This is the key architectural boundary.

## Current implementation

Current implementation ends at:

```text
Decision Command Queue v2 -> MQTT command publish
```

and for testing:

```text
Fake ACK Simulator -> MQTT ACK publish
```

## Real production implementation

In production, the fake simulator is replaced with a **device adapter flow**.

That flow does:

1. subscribe to generic command topics
2. translate generic command payload into the actual device protocol
3. execute the real device action
4. publish an ACK or ERROR back to MQTT

---

## Example: Sabiana konvektor / fan coil

### Generic command

Topic:

```text
home/home/cmd/hvac/sabiana/livingroom_fancoil_1/set_fan_speed
```

Payload:

```json
{
  "command_id": 7001,
  "device_id": "livingroom_fancoil_1",
  "set_fan_speed": 2
}
```

### Device adapter flow translates into

- Modbus register write to Sabiana device

### Then publishes ACK

Topic:

```text
home/home/ack/hvac/sabiana/livingroom_fancoil_1
```

Payload:

```json
{
  "command_id": 7001,
  "status": "ACKED",
  "device_id": "livingroom_fancoil_1"
}
```

---

## Example: AC unit

### Generic command

Topic:

```text
home/home/cmd/ac/bedroom_ac_1/set_state
```

Payload:

```json
{
  "command_id": 7101,
  "device_id": "bedroom_ac_1",
  "set_mode": "cool",
  "set_temp_c": 23
}
```

### Device adapter translates into

- vendor API call
- IR bridge command
- HomeKit action
- ESPHome or MQTT device-specific topic

### Then publishes ACK

---

# 10. Control layering model

A clear control stack is recommended.

## Layer 1: Decision layer

Produces **what should happen**.

Examples:

- start dishwasher
- set fan speed
- preheat living room
- boost ventilation

## Layer 2: Dispatch layer

Moves command rows from MariaDB to MQTT.

Current implementation:

- `Decision Command Queue v2`

## Layer 3: Device adapter layer

Converts generic commands into actual protocol-specific device actions.

This layer is still the next implementation step.

---

# 11. Current implementation status

## Already implemented

- Node-RED telemetry publishing
- MQTT telemetry transport
- Redpanda Connect landing raw files into MinIO
- dbt/DuckDB transformation
- MariaDB decision and presentation loading
- Node-RED decision command queue dispatch
- ACK handling
- ops logging
- fake ACK simulation

## Not yet implemented

- real device adapter flow for Sabiana / konvektor
- real device adapter flow for Sorel XHCC
- real AC adapter flow
- real appliance actuation adapters
- direct physical ACK from actual hardware controllers

---

# 12. Test procedure

## Command dispatch test

1. insert a row into `decision_command_queue`
2. let Node-RED poll `NEW` rows
3. verify MQTT command publish
4. verify row becomes `SENT`
5. verify fake ACK simulator sends ACK
6. verify row becomes `ACKED`
7. verify ops log rows are written

## Expected lifecycle

```text
MariaDB NEW row
    -> Node-RED publishes MQTT command
    -> Node-RED marks SENT
    -> Fake ACK Simulator publishes ACK
    -> Node-RED marks ACKED
    -> Ops log records the actions
```

---

# 13. Recommended next implementation step

The next production-grade step is to replace the fake ACK simulator with one real device adapter flow.

Recommended first target:

- Sabiana / konvektor Modbus adapter
or
- Sorel XHCC adapter

That will turn the current tested dispatch path into real physical control.
