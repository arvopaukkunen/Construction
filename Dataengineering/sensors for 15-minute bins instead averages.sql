SELECT
  name,location, precise_location , room,
  FROM_UNIXTIME(FLOOR(UNIX_TIMESTAMP(update_time)/900)*900) AS period_start,  -- 900 s = 15 min
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
  name,location, precise_location , room,
  period_start
ORDER BY
  name,
  period_start;
