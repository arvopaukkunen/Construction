bucketName = "sensors"
measurement = "victron"      // change if different
fieldName   = "CerboSOCMQTT" // change if different

from(bucket: bucketName)
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == measurement and r._field == fieldName)
  |> yield(name: "last24h_generic")