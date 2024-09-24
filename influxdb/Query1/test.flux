  //
  
  sensorMetrics = from(bucket: "sensors")
    //|> range(start: -1y)
    |> range(start: 2023-09-23T13:43:12.767Z, stop: 2023-10-23T13:43:12.767Z)
    |> filter(fn: (r) => r._measurement == "%")
    |> filter(fn: (r) => r["_field"] == "value")
    |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
    |> yield(name: "mean")

