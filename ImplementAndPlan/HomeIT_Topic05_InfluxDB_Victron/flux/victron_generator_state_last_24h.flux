bucketName = "sensors"

// Convert numeric state to text ("On"/"Off").
// If your generator publishes other codes, extend the mapping.
from(bucket: bucketName)
  |> range(start: -24h)
  |> filter(fn: (r) => r._field == "mqttGeneratorState")
  |> aggregateWindow(every: 5m, fn: last, createEmpty: false)
  |> map(fn: (r) => ({ r with state_text: if exists r._value and r._value >= 0.5 then "On" else "Off" }))
  |> yield(name: "generator_state_text_5m")