SELECT DISTINCT sensorname
FROM `event`
WHERE sensorname IS NOT NULL AND sensorname <> ''
ORDER BY sensorname;
