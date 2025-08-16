# InfluxDB — 24h Queries & Victron MQTT Mapping

This pack gives you production-ready **Flux queries** for last-24h views plus a clean **Victron MQTT → InfluxDB** mapping.
It matches your HomeIT setup (bucket `sensors`, Mosquitto on 000.000.000.115).

**Included**
- `docs/influx_24h_queries.md` — patterns you can reuse everywhere
- `docs/victron_mapping.md` — field naming, Telegraf MQTT config options
- `flux/*.flux` — ready-to-run scripts for SOC, generator state, charge currents, and a 5‑minute downsample task
- `configs/telegraf_mqtt_consumer_example.toml` — example input/output
- `images/victron_influx_arch.svg` — proper architecture diagram (SVG)

**Quick start**
1. Open InfluxDB ➜ **Data Explorer**.
2. Paste a file from `flux/` into the editor, set `bucketName` if needed.
3. Run, then **Save as Query** or add to a **Dashboard**.
4. Optional: create **Tasks** from `write_downsample_task_5m.flux` (target bucket `sensors_agg`).