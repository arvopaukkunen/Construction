--HUMIDITY
SELECT name, value, description, manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'humidy' as measure_type
FROM `sensor`
where description = '%' and name like '%humidity%';
--UNION ALL
--BATTERY LEVEL 
SELECT name, value, description, manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Activve' status, 'mySQLOnPrem' as source, 'batterylevel' as measure_type
FROM `sensor`
where description = '%' and name like '%battery%';
--UNION ALL
--STORAGE (% available)
SELECT name, value, description, 'Apple' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'storege % left' as measure_type
FROM `sensor`
where description = '% available' and name like '%storage%';
--POWER (W)
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Consumption Power reading' as measure_type
FROM `sensor`
where description = 'W' --and name like '%storage%';
--Noice (dB)
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Noise dB' as measure_type
FROM `sensor`
where description = 'dB'
--Floors Ascended
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Noise dB' as measure_type
FROM `sensor`
where description = 'floors'
--°C
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Temperature Celsius' as measure_type
FROM `sensor`
where description = '°C'
-- ruuvitag_0c90_pressure 
--
SELECT name, value, description, manufactorer, create_time, CURRENT_TIMESTAMP as update_time, enabled, status, 'mySQLOnPrem' as source, 'Floors Ascended' as measure_type
FROM `sensor`
where description <> '%' and description <> '% available' and description <> 'W' and description <> 'dB' and description <> 'floors' and description <> '°C'