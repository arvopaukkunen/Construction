option task = {name: "downsample_victron_5m", every: 5m, offset: 0m}

srcBucket = "sensors"
dstBucket = "sensors_agg"
fields = ["CerboSOCMQTT","mqttGeneratorState","input-accharger-DC-Current0","input-accharger-DC-Current1","input-accharger-DC-Current2"]

from(bucket: srcBucket)
  |> range(start: -task.every)
  |> filter(fn: (r) => contains(value: r._field, set: fields))
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> to(bucket: dstBucket)