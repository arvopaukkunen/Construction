SELECT
  sensorname,
  COUNT(*) AS rows_24h
FROM `event`
WHERE COALESCE(update_time, create_time) >= NOW() - INTERVAL 24 HOUR
GROUP BY sensorname
ORDER BY rows_24h DESC;
