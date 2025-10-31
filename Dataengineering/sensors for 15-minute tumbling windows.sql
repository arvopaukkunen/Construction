SELECT
  name,location, precise_location , room,
  FROM_UNIXTIME(
    FLOOR(UNIX_TIMESTAMP(update_time) / 900) * 900
  ) AS window_start,
  FROM_UNIXTIME(
    FLOOR(UNIX_TIMESTAMP(update_time) / 900) * 900 + 900
  ) AS window_end,
  AVG(value) AS avg_value,
  MIN(value) AS min_value,
  MAX(value) AS max_value,
  COUNT(*)   AS samples
FROM sensor
WHERE
  update_time >= '2025-04-01 00:00:00'
  AND update_time <  '2025-08-01 00:00:00'
  AND enabled = 1
GROUP BY
  name,location, precise_location , room,
  FLOOR(UNIX_TIMESTAMP(update_time) / 900)
ORDER BY
  name,
  window_start;
