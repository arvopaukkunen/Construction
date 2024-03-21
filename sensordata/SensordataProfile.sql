--HUMIDITY
SELECT name, value, description, manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'humidy' as measure_type
FROM `sensor`
where description = '%' and name like '%humidity%'
UNION ALL
--BATTERY LEVEL 
SELECT name, value, description, manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Activve' status, 'mySQLOnPrem' as source, 'batterylevel' as measure_type
FROM `sensor`
where description = '%' and name like '%battery%'
UNION ALL
--STORAGE (% available)
SELECT name, value, description, 'Apple' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'storege % left' as measure_type
FROM `sensor`
where description = '% available' and name like '%storage%'
UNION ALL
--POWER (W)
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Consumption Power reading' as measure_type
FROM `sensor`
where description = 'W' 
UNION ALL
--Noice (dB)
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Noise dB' as measure_type
FROM `sensor`
where description = 'dB'
UNION ALL
--Floors Ascended
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Noise dB' as measure_type
FROM `sensor`
where description = 'floors'
UNION ALL
--°C
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Temperature Celsius' as measure_type
FROM `sensor`
where description = '°C'
UNION ALL
-- Pressure 
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Pressure' as measure_type
FROM `sensor`
where description = 'hPa'
UNION ALL
-- Wind 
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Wind' as measure_type
FROM `sensor`
where description = 'km/h'
UNION ALL
--Distance m
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Distance' as measure_type
FROM `sensor`
where description = 'm'
UNION ALL
-- Battery voltage left mV
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Battery voltage left' as measure_type
FROM `sensor`
where description = 'mV'
UNION ALL
-- Person Activity steps
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Person Activity' as measure_type
FROM `sensor`
where description = 'steps'
UNION ALL
-- co2 ppm
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'co2' as measure_type
FROM `sensor`
where description = 'ppm'
UNION ALL
-- Sun azimuth or Sun elevation 
SELECT name, value, description, '' manufactorer, create_time, CURRENT_TIMESTAMP as update_time, 1 enabled, 'Active' status, 'mySQLOnPrem' as source, 'Sun azimuth or Sun elevation' as measure_type
FROM `sensor`
where description = '°'
UNION ALL
-- Not profiled
SELECT name, value, description, manufactorer, create_time, CURRENT_TIMESTAMP as update_time, enabled, status, 'mySQLOnPrem' as source, 'Not profiled' as measure_type
FROM `sensor`
where description <> '%' and description <> '% available' and description <> 'W' and description <> 'dB' 
and description <> 'floors' and description <> '°C' and description <> 'hPa' and description <> 'km/h'
and description <> 'm' and description <> 'mV' and description <> 'steps' and description <> 'ppm'
and description <> '°'
ORDER BY 10