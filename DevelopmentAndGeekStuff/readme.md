# ESP8266 ESP-01
ESP8266 ESP-01 with MQ-7 and MQ-5 gas sensors, sending data to InfluxDB 2 using HTTP API.

Here’s a working example for **ESP8266 ESP-01** with **MQ-7** and **MQ-5** gas sensors, sending data to **InfluxDB 2** using HTTP API.

---

### What You Need

* 3x **HiLetgo ESP8266 ESP-01** modules
* 3x **MQ-7** or **MQ-5** gas sensors (can be mixed)
* **Voltage Divider** (to bring MQ analog signal to 0–1V for ESP-01 ADC)
* Access to **InfluxDB 2** (URL, Org, Bucket, Token)
* 3.3V power supply (ESP-01 is picky!)

---

### Basic Concept

Each ESP-01 reads one MQ sensor and sends values over HTTP to your InfluxDB 2 bucket as a `POST` request to the `/api/v2/write` endpoint.

---

### Required Arduino Libraries

Install via Arduino Library Manager:

* `ESP8266WiFi`
* `ESP8266HTTPClient`

---

### Example Code for ESP-01 with MQ-7 or MQ-5

Replace with your **WiFi** and **InfluxDB** details.

```cpp
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

const char* influxHost = "http://192.168.123.115:8086";
const char* influxOrg = "Arvosoft Oy";
const char* influxBucket = "sensors";
const char* influxToken = "your-influxdb-token";

// Replace with actual sensor name (mq7 or mq5) to differentiate
#define SENSOR_NAME "mq7"

void setup() {
  Serial.begin(115200);
  delay(1000);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");
}

void loop() {
  int analogValue = analogRead(A0);
  Serial.println(analogValue);

  if (WiFi.status() == WL_CONNECTED) {
    WiFiClient client;
    HTTPClient http;

    String url = String(influxHost) + "/api/v2/write?org=" + influxOrg + "&bucket=" + influxBucket + "&precision=s";
    http.begin(client, url);
    http.addHeader("Authorization", "Token " + String(influxToken));
    http.addHeader("Content-Type", "text/plain");

    // InfluxDB line protocol format: measurement,tag=value field=value timestamp
    String payload = String(SENSOR_NAME) + ",location=livingroom ppm=" + String(analogValue);
    Serial.println("Payload: " + payload);
    int httpResponseCode = http.POST(payload);

    Serial.print("HTTP Response: ");
    Serial.println(httpResponseCode);
    http.end();
  }

  delay(5000); // Send every 5 seconds
}
```

---

### Wiring Tips for ESP-01 + MQ-x

* **MQ sensors** output 0–5V analog. ESP-01 ADC (A0) only handles **0–1V max!**
* Use a voltage divider (e.g. 10kΩ + 3.3kΩ) to safely scale down.
* ESP-01 has only **1 ADC pin (A0)**. Use **1 sensor per ESP-01**.

---

### Suggested Setup

| ESP-01 | Sensor | InfluxDB Tag        |
| ------ | ------ | ------------------- |
| #1     | MQ-7   | location=livingroom |
| #2     | MQ-5   | location=kitchen    |
| #3     | MQ-5   | location=garage     |

---

### InfluxDB 2 Setup Recap

* Create **bucket**: `sensors`
* Create **API token** with **write access**
* Find your **Org name** (`Arvosoft Oy`)
* Use `http://192.xxx.xxx.xxx:xxxx` as InfluxDB 2 URL

---

Here's how you can set up a **Node-RED dashboard** to visualize the MQ-7 and MQ-5 sensor values from **InfluxDB 2**.

---

## System Overview

* **ESP-01** → sends gas values to **InfluxDB 2**
* **Node-RED** → queries InfluxDB and displays values in **Dashboard UI**
* Optional: Use **charts** and **gauges** for real-time visualization

---

## Prerequisites

* Node-RED running (on Raspberry Pi or elsewhere)
* Dashboard installed:

  * Run this in Node-RED terminal:

    ```
    npm install node-red-dashboard
    ```
* InfluxDB 2 URL, bucket, token, and org
* InfluxDB node:

  * Install via Node-RED → Manage palette → Install:

    ```
    node-red-contrib-influxdb
    ```

---

## Step-by-Step Setup

### 1. Configure InfluxDB Node

Use **"InfluxDB In" node**:

* **Server**: `http://192.xxx.xxx.xxx:xxxx`
* **Version**: `2.x`
* **Token**: Your InfluxDB token
* **Org**: `Arvosoft Oy`
* **Bucket**: `sensors`

---

### 2. Example Query for MQ-7 or MQ-5

Use this Flux query in the **InfluxDB In** node:

```flux
from(bucket: "sensors")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "mq7" or r._measurement == "mq5")
  |> filter(fn: (r) => r._field == "ppm")
  |> aggregateWindow(every: 30s, fn: mean, createEmpty: false)
  |> yield(name: "mean")
```

---

### 3. Dashboard Flow Example

Here's a full **Node-RED flow** to import:

```json
[
  {
    "id": "mq5_dashboard",
    "type": "tab",
    "label": "MQ Sensors Dashboard",
    "disabled": false,
    "info": ""
  },
  {
    "id": "influx_query",
    "type": "influxdb in",
    "z": "mq5_dashboard",
    "influxdb": "influxdb2",
    "name": "Query MQ Sensors",
    "query": "from(bucket: \"sensors\")\n  |> range(start: -5m)\n  |> filter(fn: (r) => r._measurement == \"mq7\" or r._measurement == \"mq5\")\n  |> filter(fn: (r) => r._field == \"ppm\")\n  |> aggregateWindow(every: 30s, fn: mean, createEmpty: false)\n  |> yield(name: \"mean\")",
    "rawOutput": false,
    "precision": "",
    "x": 300,
    "y": 120,
    "wires": [["chart_prep"]]
  },
  {
    "id": "chart_prep",
    "type": "function",
    "z": "mq5_dashboard",
    "name": "Prepare Chart",
    "func": "let mq7 = [];\nlet mq5 = [];\n\nmsg.payload.forEach(row => {\n    let point = {\n        x: new Date(row._time),\n        y: row._value\n    };\n    if (row._measurement === \"mq7\") mq7.push(point);\n    if (row._measurement === \"mq5\") mq5.push(point);\n});\n\nreturn [\n    { payload: mq7, topic: \"MQ-7\" },\n    { payload: mq5, topic: \"MQ-5\" }\n];",
    "outputs": 2,
    "noerr": 0,
    "x": 500,
    "y": 120,
    "wires": [["chart_mq7"], ["chart_mq5"]]
  },
  {
    "id": "chart_mq7",
    "type": "ui_chart",
    "z": "mq5_dashboard",
    "name": "MQ-7 Chart",
    "group": "dashboard_group",
    "order": 1,
    "width": 12,
    "height": 4,
    "label": "MQ-7 Gas (ppm)",
    "chartType": "line",
    "legend": "true",
    "xformat": "HH:mm:ss",
    "interpolate": "linear",
    "nodata": "",
    "dot": false,
    "ymin": "0",
    "ymax": "",
    "removeOlder": 10,
    "removeOlderPoints": "",
    "removeOlderUnit": "60",
    "cutout": 0,
    "useOneColor": false,
    "colors": ["#ff0000", "#00ff00", "#0000ff"],
    "useOldStyle": false,
    "outputs": 1,
    "x": 730,
    "y": 80,
    "wires": [[]]
  },
  {
    "id": "chart_mq5",
    "type": "ui_chart",
    "z": "mq5_dashboard",
    "name": "MQ-5 Chart",
    "group": "dashboard_group",
    "order": 2,
    "width": 12,
    "height": 4,
    "label": "MQ-5 Gas (ppm)",
    "chartType": "line",
    "legend": "true",
    "xformat": "HH:mm:ss",
    "interpolate": "linear",
    "nodata": "",
    "dot": false,
    "ymin": "0",
    "ymax": "",
    "removeOlder": 10,
    "removeOlderPoints": "",
    "removeOlderUnit": "60",
    "cutout": 0,
    "useOneColor": false,
    "colors": ["#ffaa00", "#00ffaa", "#aa00ff"],
    "useOldStyle": false,
    "outputs": 1,
    "x": 730,
    "y": 160,
    "wires": [[]]
  },
  {
    "id": "inject_timer",
    "type": "inject",
    "z": "mq5_dashboard",
    "name": "Every 30s",
    "props": [],
    "repeat": "30",
    "crontab": "",
    "once": true,
    "onceDelay": "1",
    "topic": "",
    "x": 100,
    "y": 120,
    "wires": [["influx_query"]]
  },
  {
    "id": "dashboard_group",
    "type": "ui_group",
    "name": "Gas Sensors",
    "tab": "dashboard_tab",
    "order": 1,
    "disp": true,
    "width": "12"
  },
  {
    "id": "dashboard_tab",
    "type": "ui_tab",
    "name": "MQ Dashboard",
    "icon": "dashboard"
  },
  {
    "id": "influxdb2",
    "type": "influxdb",
    "hostname": "192.168.123.115",
    "port": "8086",
    "protocol": "http",
    "database": "sensors",
    "name": "InfluxDB 2",
    "usetls": false,
    "influxdbVersion": "2.0",
    "url": "http://192.xxx.xxx.xxx:xxxx",
    "token": "YOUR_TOKEN_HERE",
    "org": "Arvosoft Oy"
  }
]
```

👉 Replace `YOUR_TOKEN_HERE` with your actual InfluxDB token.

---

### Access Your Dashboard

Once deployed, open:

```
http://<YOUR_NODE_RED_IP>:1880/ui
```

You’ll see live charts of MQ-7 and MQ-5 gas readings!

---


Add **gauges** for the current values of MQ-7 and MQ-5, and include optional **thresholds/alerts** for high gas levels. These will appear above or alongside the charts in your Node-RED dashboard.

---

## Add Real-Time Gauges + Thresholds

### Function Node (for Gauges)

We'll extend the chart function to also extract the latest value for each sensor and route it to a gauge.

Replace your existing `function` node with this updated version:

```js
let mq7 = [];
let mq5 = [];
let latest_mq7 = null;
let latest_mq5 = null;

msg.payload.forEach(row => {
    let point = {
        x: new Date(row._time),
        y: row._value
    };
    if (row._measurement === "mq7") {
        mq7.push(point);
        latest_mq7 = row._value;
    }
    if (row._measurement === "mq5") {
        mq5.push(point);
        latest_mq5 = row._value;
    }
});

// Send to 4 outputs: 2 charts + 2 gauges
return [
    { payload: mq7, topic: "MQ-7" },
    { payload: mq5, topic: "MQ-5" },
    { payload: latest_mq7 },
    { payload: latest_mq5 }
];
```

Set **Outputs = 4** in the function node.

---

### Add Gauge Widgets

Add two `ui_gauge` nodes:

#### MQ-7 Gauge

* **Label**: MQ-7 PPM
* **Range**: 0 – 1023 (or scale as needed)
* **Unit**: ppm
* **Color thresholds** (optional):

  * Green: 0–300
  * Yellow: 301–600
  * Red: 601–1023

#### MQ-5 Gauge

* Same as above, different label

Connect the third and fourth outputs of your function node to these gauges.

---

### Optional: Alert on High Value

Add a `switch` node after each gauge input:

* **Check** if `msg.payload` > 600 (example)
* Connect to a `ui_text` or `ui_toast` node
* Set message: `"ALERT: High gas level on MQ-7!"`

---

### Flow Overview Diagram

```
[Inject] → [InfluxDB Query]
           ↓
      [Function Node]
      ├─→ [MQ-7 Chart]
      ├─→ [MQ-5 Chart]
      ├─→ [MQ-7 Gauge] ─→ [Alert MQ-7?]
      └─→ [MQ-5 Gauge] ─→ [Alert MQ-5?]
```

---

