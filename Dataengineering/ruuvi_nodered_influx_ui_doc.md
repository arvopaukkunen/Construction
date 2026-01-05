# Ruuvi Gateway → Node-RED → InfluxDB2 (raw) + Debug UI (Dashboard 1)

This document captures the assistant-side implementation guidance from the chat: enriching Ruuvi sensor data “at birth”, writing to InfluxDB2, and building a minimal but readable Node-RED Dashboard UI for gateway/sensor liveness diagnostics, plus options to reduce Influx write volume.

---

## Target architecture

- Ruuvi Gateway `/history` polled by Node-RED on a schedule
- Node-RED enriches each sensor record with:
  - Canonical sensor name from suffix map (`global.ruuviSuffixMap`)
  - Natural name from full MAC map (`sensor_natural_name`)
- Node-RED writes points to InfluxDB2 bucket `sensors`, measurement `ruuvi`
- Node-RED Dashboard (node-red-dashboard 3.6.6) renders:
  - Sensor liveness (green/red) using a 60 second threshold
  - Battery proxy from voltage (debug heuristic)
  - A readable table with cell borders and sticky header

---

## Why the flow JSON “embeds code”

In Node-RED exports, a `type: "function"` node contains its JavaScript under the JSON field `func`. Importing the JSON creates the node and installs the code into that Function node automatically.

Example structure:

```json
{
  "id": "fn_set_suffix_map",
  "type": "function",
  "name": "Set global.ruuviSuffixMap",
  "func": "/* JavaScript stored inside the flow export */"
}
```

---

## 1) Initialize suffix → name map (global context)

Create a Function node named **Set global.ruuviSuffixMap**, triggered once on startup (Inject node with `once = true`).

```javascript
// Map by last 4 hex digits of tag MAC (lowercase), e.g. ...:0C:90 -> "0c90"
// Location for mapped sensors is "House". Unmapped sensors will be tagged "not known".

global.set("ruuviSuffixMap", {
  "0c90": { name: "RuuviTag 0C90", location: "House", room: "" },
  "386c": { name: "RuuviTag 386C", location: "House", room: "" },
  "396d": { name: "RuuviTag 396D", location: "House", room: "" },

  "4830": { name: "Ruuvi etelä 1", location: "House", room: "" },
  "5b26": { name: "rooftop north", location: "House", room: "" },
  "81dd": { name: "insulate north top", location: "House", room: "" },
  "8d93": { name: "rooftop middle", location: "House", room: "" },

  "a187": { name: "RuuviTag A187", location: "House", room: "" },
  "ad37": { name: "insulate middle top", location: "House", room: "" },
  "b2dd": { name: "RuuviTag B2DD", location: "House", room: "" },
  "c921": { name: "RuuviTag C921", location: "House", room: "" },

  "e464": { name: "router case1", location: "House", room: "" },
  "f6d6": { name: "RuuviTag F6D6", location: "House", room: "" }
});

return { payload: { ok: true, suffixCount: Object.keys(global.get("ruuviSuffixMap")).length } };
```

---

## 2) Transform: Ruuvi Gateway payload → InfluxDB2 batch points

This Function node enriches tags and builds InfluxDB2 “batch points” payload:

- Input: `msg.payload.tags` object from the Ruuvi gateway node
- Output: `msg.payload = [ [fields, tags], ... ]`
- Adds tags:
  - `sensor_name` (suffix map preferred)
  - `sensor_natural_name` (full MAC map)
  - `sensor_suffix`, `sensor_mac`, `gateway_mac`, `location`, etc.

```javascript
// Natural name map (full MAC -> name) for "born" enrichment.
// Normalize MAC to lowercase with ":".
const macNaturalNameMap = {
  "de:b3:a3:95:f6:d6": "Bottom-northEastF6D6",
  "db:b4:24:c6:b2:dd": "Bottom-westdoorB2DD",
  "e8:e4:53:71:97:86": "bottomNw",
  "e1:8d:c1:55:39:6d": "BottomSE",
  "c9:4d:c9:9d:a1:87": "BottomSW",
  "c1:ab:0e:2e:0c:90": "korvausilma-tulo-vallox",
  "dc:9e:e4:29:38:6c": "on-premises-inside-Ruuvi itä 1",
  "ec:c3:14:4d:a0:8a": "MISSÄ-inside-Ruuvi Pohj1",
  "d9:5a:11:a2:48:30": "on-premises-inside-Ruuvi-etelä-1",
  "d5:53:ae:fe:e4:64": "outside-in-a-router case1",
  "c0:17:91:b3:5b:26": "rooftop north",
  "e5:ba:e0:6c:81:dd": "insulate north top",
  "ea:0e:1e:54:8d:93": "rooftop middle",
  "fa:84:0a:bf:ad:37": "insulate middle top",
  "c8:85:07:b5:c9:21": "rooftop south",
  "d2:15:2b:2b:13:77": "insulate south top"
};

const p = msg.payload || {};
const tagsObj = p.tags || {};
const gwMac = p.gw_mac || "";
const gwTs = p.timestamp ? new Date(p.timestamp * 1000) : new Date();

const suffixMap = global.get("ruuviSuffixMap") || {};

function normMac(mac) {
  return (mac || "").trim().toLowerCase();
}

function macSuffix4(mac) {
  const hex = (mac || "").replace(/:/g, "").toLowerCase();
  return hex.length >= 4 ? hex.slice(-4) : "----";
}

function addField(fields, key, val) {
  if (val === null || val === undefined) return;
  if (typeof val === "number" && Number.isNaN(val)) return;
  fields[key] = val;
}

const batch = [];

for (const [macRaw, t] of Object.entries(tagsObj)) {
  const macNorm = normMac(macRaw);
  const suffix = macSuffix4(macNorm);

  const meta = suffixMap[suffix] || null;
  const naturalName = macNaturalNameMap[macNorm] || null;

  // Canonical sensor_name: prefer suffix map, then natural map, then fallback
  const sensorName = (meta && meta.name) ? meta.name : (naturalName || "not known");
  // Always keep explicit natural name tag for traceability
  const sensorNaturalName = naturalName || sensorName;

  const location = (meta && meta.location) ? meta.location : "not known";
  const room = (meta && meta.room) ? meta.room : "";

  // TAGS (2nd element in the pair)
  const tags = {
    source: "NodeRed",
    gateway_mac: gwMac,
    sensor_mac: macRaw,
    sensor_suffix: suffix,
    sensor_name: sensorName,
    sensor_natural_name: sensorNaturalName,
    location: location
  };
  if (room) tags.room = room;

  // FIELDS (1st element in the pair)
  const fields = {};
  addField(fields, "temperature", t.temperature);
  addField(fields, "humidity", t.humidity);
  addField(fields, "pressure", t.pressure);
  addField(fields, "voltage", t.voltage);
  addField(fields, "rssi", t.rssi);
  addField(fields, "accelX", t.accelX);
  addField(fields, "accelY", t.accelY);
  addField(fields, "accelZ", t.accelZ);
  addField(fields, "movementCounter", t.movementCounter);
  addField(fields, "txPower", t.txPower);
  addField(fields, "measurementSequenceNumber", t.measurementSequenceNumber);

  // Timestamp (precision "s")
  const ts = t.timestamp ? new Date(t.timestamp * 1000) : gwTs;
  fields.time = Math.floor(ts.getTime() / 1000);

  if (Object.keys(fields).length <= 1) continue; // only "time" present => skip

  batch.push([fields, tags]);
}

msg.measurement = "ruuvi";
msg.payload = batch;
return msg;
```

---

## 3) UI state preparation (alive/stale at 60 seconds)

This Function node consumes the same batch and produces:
- Output 1: an array of sensor rows for a table UI
- Output 2: a gateway status object

It computes:
- `alive` for each sensor: `age_s <= 60`
- `battery_pct` and `battery_state` from voltage (debug heuristic)
- `gwStale`: gateway red if poll stale OR any sensor stale

```javascript
// Input: msg.payload = batch array of [fields, tags] from Transform node
const batch = Array.isArray(msg.payload) ? msg.payload : [];
const now = Date.now();

// Thresholds
const ALIVE_THRESHOLD_S = 60;        // per-sensor alive threshold
const GW_STALE_THRESHOLD_MS = 15000; // gateway poll stale threshold (15s)

const state = flow.get("ruuviUiStateV2") || { gw: {}, sensors: {} };

// Update gateway info on every poll
state.gw.last_poll_ms = now;
state.gw.gateway_mac = (batch[0] && batch[0][1] && batch[0][1].gateway_mac)
  ? batch[0][1].gateway_mac
  : (state.gw.gateway_mac || "");
state.gw.sensor_count_last_batch = batch.length;

// Update per-sensor latest from batch
for (const item of batch) {
  const fields = item[0] || {};
  const tags = item[1] || {};

  const mac = tags.sensor_mac || "unknown";
  const displayName = tags.sensor_name || tags.sensor_natural_name || tags.sensor_suffix || mac;

  const lastSeenMs = (typeof fields.time === "number") ? fields.time * 1000 : now;
  const ageS = Math.max(0, Math.round((now - lastSeenMs) / 1000));
  const alive = ageS <= ALIVE_THRESHOLD_S;

  const voltage = fields.voltage;
  let battPct = null;
  let battState = "";
  if (typeof voltage === "number") {
    // Debug heuristic only (not calibrated): 2.0V -> 0%, 3.0V -> 100%
    battPct = Math.max(0, Math.min(100, Math.round(((voltage - 2.0) / (3.0 - 2.0)) * 100)));
    battState = voltage < 2.4 ? "LOW" : (voltage < 2.6 ? "WARN" : "OK");
  }

  state.sensors[mac] = {
    display_name: displayName,
    sensor_name: tags.sensor_name || "",
    sensor_natural_name: tags.sensor_natural_name || "",
    sensor_mac: mac,
    sensor_suffix: tags.sensor_suffix || "",
    location: tags.location || "",
    gateway_mac: tags.gateway_mac || "",

    temperature: fields.temperature,
    humidity: fields.humidity,
    pressure: fields.pressure,
    voltage: voltage,
    battery_pct: battPct,
    battery_state: battState,
    rssi: fields.rssi,

    last_seen_ms: lastSeenMs,
    age_s: ageS,
    alive: alive
  };
}

flow.set("ruuviUiStateV2", state);

// Rows (sorted)
const rows = Object.values(state.sensors)
  .sort((a, b) => (a.display_name || "").localeCompare(b.display_name || ""));

// Counts + any-stale flag
let okCount = 0;
let staleCount = 0;
for (const r of rows) {
  if (r.alive) okCount++;
  else staleCount++;
}
const anySensorStale = staleCount > 0;

// Gateway stale if poll stale OR any sensor stale
const gwPollStale = (now - (state.gw.last_poll_ms || 0)) > GW_STALE_THRESHOLD_MS;
const gwStale = gwPollStale || anySensorStale;
const staleReason = gwPollStale ? "poll stale" : (anySensorStale ? "sensor stale" : "");

// Output 2: gateway payload
const gwStatus = {
  gateway_mac: state.gw.gateway_mac || "",
  last_poll_ms: state.gw.last_poll_ms || 0,
  stale: gwStale,
  stale_reason: staleReason,
  sensor_count_last_batch: state.gw.sensor_count_last_batch || 0,
  ok_count: okCount,
  stale_count: staleCount,
  alive_threshold_s: ALIVE_THRESHOLD_S
};

return [{ payload: rows }, { payload: gwStatus }];
```

---

## 4) Dashboard UI templates

### 4.1 Gateway status (background red/green)

Paste into a **ui_template** node (Gateway Status group):

```html
<div style="padding:8px"
     ng-style="{'background-color': (msg.payload.stale ? '#f2dede' : '#dff0d8')}">

  <div><b>Gateway MAC:</b> {{msg.payload.gateway_mac || 'n/a'}}</div>
  <div><b>Last poll:</b> {{msg.payload.last_poll_ms | date:'yyyy-MM-dd HH:mm:ss'}}</div>
  <div><b>Sensors in last batch:</b> {{msg.payload.sensor_count_last_batch}}</div>

  <div style="margin-top:6px">
    <b>Sensor health:</b>
    OK {{msg.payload.ok_count}} / STALE {{msg.payload.stale_count}}
  </div>

  <div style="margin-top:6px">
    <b>Status:</b>
    <span ng-style="{'color': (msg.payload.stale ? 'red' : 'green'), 'font-weight': 'bold'}">
      {{msg.payload.stale ? 'STALE' : 'OK'}}
    </span>
    <span style="margin-left:8px; font-size:12px; opacity:0.85" ng-if="msg.payload.stale">
      (reason: {{msg.payload.stale_reason}})
    </span>
  </div>

  <div style="margin-top:6px; font-size:12px; opacity:0.8">
    Rule: Gateway is STALE if poll is stale OR any sensor age &gt; {{msg.payload.alive_threshold_s}}s.
  </div>
</div>
```

### 4.2 Sensors table (readable borders + sticky header + Natural name)

Paste into a **ui_template** node (Sensors group):

```html
<style>
  .ruuvi-table-wrap { padding: 8px; overflow: auto; }
  .ruuvi-summary { margin-bottom: 8px; font-size: 14px; }

  table.ruuvi-table {
    width: 100%;
    border-collapse: collapse;
    border: 1px solid #cfcfcf;
    font-size: 13px;
  }

  table.ruuvi-table thead th {
    position: sticky;
    top: 0;
    z-index: 1;
    background: #f7f7f7;
    border: 1px solid #cfcfcf;
    padding: 6px 8px;
    text-align: left;
    white-space: nowrap;
  }

  table.ruuvi-table tbody td {
    border: 1px solid #cfcfcf;
    padding: 6px 8px;
    vertical-align: top;
  }

  .ruuvi-center { text-align: center; white-space: nowrap; }
  .ruuvi-left { text-align: left; }

  table.ruuvi-table tbody tr:nth-child(even) td {
    box-shadow: inset 0 0 0 9999px rgba(0,0,0,0.02);
  }
</style>

<div class="ruuvi-table-wrap">

  <div class="ruuvi-summary">
    <b>OK:</b> {{ (msg.payload | filter:{alive:true}).length }}
    &nbsp; | &nbsp;
    <b>STALE:</b> {{ (msg.payload | filter:{alive:false}).length }}
    <span style="margin-left:12px; font-size:12px; opacity:0.8">
      Alive threshold: 60 seconds (age ≤ 60s = OK)
    </span>
  </div>

  <table class="ruuvi-table">
    <thead>
      <tr>
        <th class="ruuvi-left">Sensor</th>
        <th class="ruuvi-left">Natural name</th>
        <th class="ruuvi-left">MAC</th>
        <th class="ruuvi-center">Alive</th>
        <th class="ruuvi-center">Age (s)</th>
        <th class="ruuvi-center">Temp</th>
        <th class="ruuvi-center">Hum</th>
        <th class="ruuvi-center">Pres</th>
        <th class="ruuvi-center">Volt</th>
        <th class="ruuvi-center">Battery</th>
        <th class="ruuvi-center">RSSI</th>
      </tr>
    </thead>

    <tbody>
      <tr ng-repeat="r in msg.payload track by r.sensor_mac"
          ng-style="{'background-color': (r.alive ? '#dff0d8' : '#f2dede')}">
        <td class="ruuvi-left">{{r.display_name}}</td>
        <td class="ruuvi-left">{{r.sensor_natural_name || ''}}</td>
        <td class="ruuvi-left">{{r.sensor_mac}}</td>

        <td class="ruuvi-center">
          <span ng-style="{'color': (r.alive ? 'green' : 'red'), 'font-weight': 'bold'}">
            {{r.alive ? 'OK' : 'STALE'}}
          </span>
        </td>

        <td class="ruuvi-center">{{r.age_s}}</td>
        <td class="ruuvi-center">{{r.temperature}}</td>
        <td class="ruuvi-center">{{r.humidity}}</td>
        <td class="ruuvi-center">{{r.pressure}}</td>
        <td class="ruuvi-center">{{r.voltage}}</td>

        <td class="ruuvi-center">
          <span ng-if="r.battery_pct !== null">{{r.battery_pct}}% ({{r.battery_state}})</span>
          <span ng-if="r.battery_pct === null">n/a</span>
        </td>

        <td class="ruuvi-center">{{r.rssi}}</td>
      </tr>
    </tbody>
  </table>

</div>
```

### 4.3 Narrower sensor table variant (columns removed)

To reduce width, remove **RSSI**, **Pres**, and **Sensor** columns:

```html
<style>
  .ruuvi-table-wrap { padding: 8px; overflow: auto; }
  .ruuvi-summary { margin-bottom: 8px; font-size: 14px; }

  table.ruuvi-table {
    width: 100%;
    border-collapse: collapse;
    border: 1px solid #cfcfcf;
    font-size: 13px;
  }

  table.ruuvi-table thead th {
    position: sticky;
    top: 0;
    z-index: 1;
    background: #f7f7f7;
    border: 1px solid #cfcfcf;
    padding: 6px 8px;
    text-align: left;
    white-space: nowrap;
  }

  table.ruuvi-table tbody td {
    border: 1px solid #cfcfcf;
    padding: 6px 8px;
    vertical-align: top;
  }

  .ruuvi-center { text-align: center; white-space: nowrap; }
  .ruuvi-left { text-align: left; }

  table.ruuvi-table tbody tr:nth-child(even) td {
    box-shadow: inset 0 0 0 9999px rgba(0,0,0,0.02);
  }
</style>

<div class="ruuvi-table-wrap">

  <div class="ruuvi-summary">
    <b>OK:</b> {{ (msg.payload | filter:{alive:true}).length }}
    &nbsp; | &nbsp;
    <b>STALE:</b> {{ (msg.payload | filter:{alive:false}).length }}
    <span style="margin-left:12px; font-size:12px; opacity:0.8">
      Alive threshold: 60 seconds (age ≤ 60s = OK)
    </span>
  </div>

  <table class="ruuvi-table">
    <thead>
      <tr>
        <th class="ruuvi-left">Natural name</th>
        <th class="ruuvi-left">MAC</th>
        <th class="ruuvi-center">Alive</th>
        <th class="ruuvi-center">Age (s)</th>
        <th class="ruuvi-center">Temp</th>
        <th class="ruuvi-center">Hum</th>
        <th class="ruuvi-center">Volt</th>
        <th class="ruuvi-center">Battery</th>
      </tr>
    </thead>

    <tbody>
      <tr ng-repeat="r in msg.payload track by r.sensor_mac"
          ng-style="{'background-color': (r.alive ? '#dff0d8' : '#f2dede')}">
        <td class="ruuvi-left">{{r.sensor_natural_name || ''}}</td>
        <td class="ruuvi-left">{{r.sensor_mac}}</td>

        <td class="ruuvi-center">
          <span ng-style="{'color': (r.alive ? 'green' : 'red'), 'font-weight': 'bold'}">
            {{r.alive ? 'OK' : 'STALE'}}
          </span>
        </td>

        <td class="ruuvi-center">{{r.age_s}}</td>
        <td class="ruuvi-center">{{r.temperature}}</td>
        <td class="ruuvi-center">{{r.humidity}}</td>
        <td class="ruuvi-center">{{r.voltage}}</td>

        <td class="ruuvi-center">
          <span ng-if="r.battery_pct !== null">{{r.battery_pct}}% ({{r.battery_state}})</span>
          <span ng-if="r.battery_pct === null">n/a</span>
        </td>
      </tr>
    </tbody>
  </table>

</div>
```

---

## 5) Dashboard width behavior (how to make the table fill space)

Dashboard 1 layout is **group/grid** based:
- Widget width fills only its **ui_group** width
- If another group is visible on the same tab row, it can reserve columns even if a widget inside it is disabled

Recommended:
- Set `ui_group_sensors_v2.width = "12"`
- Set `ui_tpl_sensors_v2.width = "12"`
- Hide/remove/move other groups (e.g., gateway group) so the Sensors group can occupy the full row

---

## 6) Troubleshooting: table disappears

If the Sensors table renders as blank:
- Most common cause: the `ui_template` HTML is truncated or missing closing tags / table markup.
- Validate by temporarily setting template content to:

```html
<pre>{{msg.payload | json}}</pre>
```

If JSON appears, your data is fine and the issue is HTML/template syntax.

---

## 7) InfluxDB2 write frequency and resource optimization

### Current behavior (as implemented originally)
- Poll interval: every **5 seconds**
- Writes: every poll (batch includes all sensors)
- Writes occur even when values do not change

### Immediate reduction lever
- Increase the inject repeat from 5 seconds to 60 seconds (or more).

### Better approach: write only on change + hourly heartbeat
Insert a Function node between Transform and Influx out that:
- Tracks last written values per sensor
- Emits a point only when temperature/humidity/etc change beyond a threshold
- Forces at least one write per hour per sensor (heartbeat)

```javascript
// Input: msg.payload is batch: [ [fields, tags], ... ]
const batch = Array.isArray(msg.payload) ? msg.payload : [];
const nowMs = Date.now();

// Heartbeat: ensure at least one point per sensor per hour
const HEARTBEAT_S = 3600;

// Change thresholds (tune as needed)
const EPS = {
  temperature: 0.05, // °C
  humidity: 0.2,     // %RH
  pressure: 0.5,     // hPa
  voltage: 0.005     // V
};

function changedEnough(key, newVal, oldVal) {
  if (newVal === undefined || newVal === null) return false;
  if (oldVal === undefined || oldVal === null) return true;

  if (typeof newVal === "number" && typeof oldVal === "number") {
    const eps = (EPS[key] !== undefined) ? EPS[key] : 0;
    return Math.abs(newVal - oldVal) > eps;
  }
  return newVal !== oldVal;
}

const state = flow.get("ruuviWriteFilter") || {}; // per sensor_mac
const out = [];

for (const item of batch) {
  const fields = item[0] || {};
  const tags = item[1] || {};

  const mac = tags.sensor_mac || "unknown";
  const tsS = fields.time; // epoch seconds from transform

  if (typeof tsS !== "number") continue;

  const prev = state[mac] || { lastVals: {}, lastWriteS: 0 };

  const ageSinceWriteS = tsS - (prev.lastWriteS || 0);
  const forceHeartbeat = ageSinceWriteS >= HEARTBEAT_S;

  let hasMeaningfulChange = false;
  for (const k of ["temperature", "humidity", "pressure", "voltage"]) {
    if (changedEnough(k, fields[k], prev.lastVals[k])) {
      hasMeaningfulChange = true;
      break;
    }
  }

  if (hasMeaningfulChange || forceHeartbeat) {
    prev.lastWriteS = tsS;
    for (const k of ["temperature", "humidity", "pressure", "voltage"]) {
      if (fields[k] !== undefined && fields[k] !== null) prev.lastVals[k] = fields[k];
    }
    state[mac] = prev;

    out.push(item);
  }
}

flow.set("ruuviWriteFilter", state);

msg.payload = out;
if (out.length === 0) return null; // avoids empty write calls

return msg;
```

This yields:
- Dramatically fewer writes when sensor readings are stable
- Predictable “at least once per hour” points per sensor
- The foundation for later per-sensor frequency tuning (e.g., 1-minute for indoor control sensors)

---

## Notes

- node-red-dashboard 3.6.6 is suitable for simple diagnostic UI and can be retained for this use case.
- The battery percentage calculation from voltage is a simple heuristic for debugging only; calibrate if you need a true state-of-charge estimate.
