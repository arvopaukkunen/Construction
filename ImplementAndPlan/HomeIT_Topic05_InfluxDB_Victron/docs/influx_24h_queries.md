# 24h Flux Query Patterns

## A) Rolling last 24h (no variables)
```flux
from(bucket: "sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r._field == "CerboSOCMQTT")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> yield(name: "soc_5m_mean")
```

## B) One-hour buckets with last-known value
```flux
from(bucket: "sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "victron")
  |> filter(fn: (r) => r._field == "mqttGeneratorState")
  |> aggregateWindow(every: 1h, fn: last, createEmpty: false)
  |> yield(name: "gen_last_per_hour")
```

## C) Multi-field pivot & computed column
```flux
from(bucket: "sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => contains(value: r._field, set: ["input-accharger-DC-Current0","input-accharger-DC-Current1","input-accharger-DC-Current2"]))
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> map(fn: (r) => ({
      r with
      totalCurrent: float(v: (if exists r["input-accharger-DC-Current0"] then r["input-accharger-DC-Current0"] else 0.0) +
                              (if exists r["input-accharger-DC-Current1"] then r["input-accharger-DC-Current1"] else 0.0) +
                              (if exists r["input-accharger-DC-Current2"] then r["input-accharger-DC-Current2"] else 0.0))
  }))
  |> yield(name: "total_current_5m")
```

## D) Decode simple numeric state to text
```flux
from(bucket: "sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r._field == "mqttGeneratorState")
  |> aggregateWindow(every: 5m, fn: last, createEmpty: false)
  |> map(fn: (r) => ({ r with state_text: if exists r._value and r._value >= 0.5 then "On" else "Off" }))
  |> yield(name: "gen_state_text")
```