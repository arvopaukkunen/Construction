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
  WHERE COALESCE(update_time, create_time) >= '2025-03-01'
    AND COALESCE(update_time, create_time) <  '2025-04-01'
)
SELECT *
FROM base
ORDER BY sensorname, bucket_start;