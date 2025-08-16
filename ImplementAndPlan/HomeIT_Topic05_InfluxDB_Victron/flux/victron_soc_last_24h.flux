bucketName = "sensors"
from(bucket: bucketName)
  |> range(start: -24h)
  |> filter(fn: (r) => r._field == "CerboSOCMQTT")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> yield(name: "soc_percent_5m_mean")