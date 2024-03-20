--HUMIDITY
SELECT name, value, description, manufactorer, create_time, CURRENT_TIMESTAMP as update_time, enabled, status, 'mySQLOnPrem' as source, 'humidy' as measure_type
FROM `sensor`
where description = '%' and name like '%humidity%';

--BATTERY LEVEL 
SELECT name, value, description, manufactorer, create_time, CURRENT_TIMESTAMP as update_time, enabled, status, 'mySQLOnPrem' as source, 'batterylevel' as measure_type
FROM `sensor`
where description = '%' and name like '%battery%';

--
SELECT name, value, description, manufactorer, create_time, CURRENT_TIMESTAMP as update_time, enabled, status, 'mySQLOnPrem' as source, 'batterylevel' as measure_type
FROM `sensor`
where description = '%' and name not like '%battery%' and name not like '%battery%' and name not like '%humidity%';