WITH binned AS (
  SELECT
    sensorname,
    FROM_UNIXTIME(
      FLOOR(UNIX_TIMESTAMP(COALESCE(update_time, create_time)) / 1800) * 1800
    ) AS bucket_start,
    AVG(CAST(NULLIF(new_value,'') AS DECIMAL(16,6))) AS avg_new
  FROM `event`
  WHERE COALESCE(update_time, create_time) >= NOW() - INTERVAL 24 HOUR
  GROUP BY sensorname, bucket_start
)
SELECT
  sensorname,
  bucket_start,
  ROUND(avg_new,6) AS new_value,
  ROUND(LAG(avg_new) OVER (PARTITION BY sensorname ORDER BY bucket_start),6) AS prev_new,
  ROUND(avg_new - COALESCE(LAG(avg_new) OVER (PARTITION BY sensorname ORDER BY bucket_start), avg_new),6) AS diff_value,
  CASE
    WHEN avg_new > COALESCE(LAG(avg_new) OVER (PARTITION BY sensorname ORDER BY bucket_start), avg_new) THEN 'up'
    WHEN avg_new < COALESCE(LAG(avg_new) OVER (PARTITION BY sensorname ORDER BY bucket_start), avg_new) THEN 'dwn'
    ELSE 'eq'
  END AS trend
FROM binned
ORDER BY sensorname, bucket_start;
