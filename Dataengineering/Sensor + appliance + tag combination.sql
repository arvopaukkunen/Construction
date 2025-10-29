SELECT DISTINCT
  sensorname, appliance_name, PropertyTag
FROM `event`
WHERE sensorname IS NOT NULL AND sensorname <> ''
ORDER BY sensorname, appliance_name, PropertyTag;
