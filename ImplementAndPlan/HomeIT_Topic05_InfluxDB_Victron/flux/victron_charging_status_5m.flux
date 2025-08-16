bucketName = "sensors"
currents = ["input-accharger-DC-Current0","input-accharger-DC-Current1","input-accharger-DC-Current2"]

// Window, pivot, and compute a "charging" boolean and total current
t = from(bucket: bucketName)
  |> range(start: -24h)
  |> filter(fn: (r) => contains(value: r._field, set: currents))
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> map(fn: (r) => ({
      r with
      totalCurrent: float(v: (if exists r["input-accharger-DC-Current0"] then r["input-accharger-DC-Current0"] else 0.0) +
                              (if exists r["input-accharger-DC-Current1"] then r["input-accharger-DC-Current1"] else 0.0) +
                              (if exists r["input-accharger-DC-Current2"] then r["input-accharger-DC-Current2"] else 0.0)),
      charging: if totalCurrent > 0.5 then 1 else 0
  }))

t |> yield(name: "charging_status_5m")