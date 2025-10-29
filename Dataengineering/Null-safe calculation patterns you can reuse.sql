SELECT
  sensorname,
  FROM_UNIXTIME(FLOOR(UNIX_TIMESTAMP(COALESCE(update_time, create_time))/1800)*1800) AS bucket_start,
  COUNT(*) AS rows_in_bucket,
  COUNT(CAST(NULLIF(new_value,'') AS DECIMAL(16,6))) AS new_non_null,
  COUNT(CAST(NULLIF(old_value,'') AS DECIMAL(16,6))) AS old_non_null
FROM `event`
GROUP BY sensorname, bucket_start
ORDER BY sensorname, bucket_start;
