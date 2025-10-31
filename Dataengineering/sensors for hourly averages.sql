SELECT
  name,location, precise_location , room,
  DATE_FORMAT(update_time, '%Y-%m-%d %H:00:00') AS hour_start,
  AVG(value) AS avg_value,
  MIN(value) AS min_value,
  MAX(value) AS max_value,
  COUNT(*) AS samples
FROM sensor
WHERE
  update_time >= '2025-04-01'
  AND update_time <  '2025-08-01'
  AND enabled = 1
GROUP BY
  name, location, room,
  DATE_FORMAT(update_time, '%Y-%m-%d %H')
ORDER BY
  name,
  hour_start;
