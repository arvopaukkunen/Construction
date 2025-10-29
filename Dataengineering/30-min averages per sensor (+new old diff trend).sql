/* Averages per 30-min bucket for all sensors.
   Adjust the WHERE window as you like. */
WITH base AS (
  SELECT
    sensorname,
    appliance_name,
    PropertyTag,
    FROM_UNIXTIME(
      FLOOR(UNIX_TIMESTAMP(COALESCE(update_time, create_time)) / 1800) * 1800
    ) AS bucket_start,
    CAST(NULLIF(new_value,'') AS DECIMAL(16,6)) AS new_v,
    CAST(NULLIF(old_value,'') AS DECIMAL(16,6)) AS old_v
  FROM `event`
  WHERE COALESCE(update_time, create_time)
        >= DATE_SUB(NOW(), INTERVAL 5 MONTH) - INTERVAL 24 HOUR  -- ← window (change if needed)
),
agg AS (
  SELECT
    sensorname,
    appliance_name,
    PropertyTag,
    bucket_start,
    AVG(new_v) AS avg_new,          -- AVG ignores NULLs
    AVG(old_v) AS avg_old,
    COUNT(*)  AS rows_in_bucket,
    COUNT(new_v) AS new_non_null,
    COUNT(old_v) AS old_non_null
  FROM base
  GROUP BY sensorname, appliance_name, PropertyTag, bucket_start
)
SELECT
  sensorname,
  appliance_name,
  PropertyTag,
  bucket_start,
  ROUND(avg_new, 6) AS new_value,
  ROUND(avg_old, 6) AS old_value,
  ROUND(COALESCE(avg_new,0) - COALESCE(avg_old,0), 6) AS diff_value,
  CASE
    WHEN COALESCE(avg_new,0) > COALESCE(avg_old,0) THEN 'up'
    WHEN COALESCE(avg_new,0) < COALESCE(avg_old,0) THEN 'dwn'
    ELSE 'eq'
  END AS trend,
  rows_in_bucket,
  new_non_null,
  old_non_null
FROM agg
ORDER BY sensorname, bucket_start;
