# Victron MQTT → InfluxDB Mapping

## Suggested naming
- **measurement:** `victron`
- **fields:** keep hardware semantics: `CerboSOCMQTT`, `mqttGeneratorState`, `input-accharger-DC-Current0..2`
- **tags (examples):** `site="home"`, `device="cerbo-gx"`, `source="mqtt"`

## Broker topics (typical)
- SOC: `N/+/battery/+/Soc` → numeric percent
- DC currents: `R/+/vebus/+/Dc/+/Current` → amps
- Generator state: `N/+/generator/+/State` → 0/1 or state code

## Telegraf options
Start simple: treat payloads as numbers and write them as-is, then rename fields downstream in Flux if needed.

**Example: minimal numeric payloads**
```toml
[[inputs.mqtt_consumer]]
  servers = ["tcp://192.168.123.115:1883"]
  topics = ["N/+/battery/+/Soc","R/+/vebus/+/Dc/+/Current","N/+/generator/+/State"]
  data_format = "value"
  data_type   = "float"

[[outputs.influxdb_v2]]
  urls  = ["http://192.168.123.115:8086"]
  token = "REDACTED"
  organization = "Arvosoft Oy"
  bucket = "sensors"
```

**Advanced mapping (regex ➜ fields)**
```toml
# Attach the topic as a tag, then turn it into a field name:
[[processors.parser]]
  namepass = ["mqtt_consumer"]
  parse_fields = ["topic"]
  data_format = "grok"
  grok_patterns = ["%{GREEDYDATA:topic}"]

[[processors.regex]]
  namepass = ["mqtt_consumer"]
  [[processors.regex.tags]]
    key = "topic"
    pattern = ".*Soc$"
    replacement = "CerboSOCMQTT"
    result_key = "field_name"
```

> If you already have historical data with the exact field names listed above, keep Telegraf simple and do renames only in queries.