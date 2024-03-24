# mySQL db

![alt text](image.png)
*Iteration 2*

## Description of this iteration:

### Appliance table
This holds a house device like washing machine etc or a AC or heatpump besic information. Connection prefixed fields holds needed information to connect the device for reading or writing a data. For example connection protocol is something like ModbusSerial, ModbusTCP, MQTT or more convinient REST API if available/implemented. All in LAN.

### Sensor table
Related table with Appliance, holds possible many endpoints / sensors in that appliance and a current value. Value depends on the sensor. It may be something like %, mV, Celsius etc. depends on purpose. That purpose and unit is also what is classification and is used to dataprofiling. Profiled data is simply executed all the time when sensor data is transferred to cloud - for AI to do some clever things to it :


``` 
SELECT name
	,value
	,description
	,manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'humidy' AS measure_type
FROM `sensor`
WHERE description = '%'
	AND name LIKE '%humidity%'

UNION ALL

SELECT name
	,value
	,description
	,manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Activve' STATUS
	,'mySQLOnPrem' AS source
	,'batterylevel' AS measure_type
FROM `sensor`
WHERE description = '%'
	AND name LIKE '%battery%'

UNION ALL

SELECT name
	,value
	,description
	,'Apple' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'storege % left' AS measure_type
FROM `sensor`
WHERE description = '% available'
	AND name LIKE '%storage%'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Consumption Power reading' AS measure_type
FROM `sensor`
WHERE description = 'W'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Noise dB' AS measure_type
FROM `sensor`
WHERE description = 'dB'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Noise dB' AS measure_type
FROM `sensor`
WHERE description = 'floors'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Temperature Celsius' AS measure_type
FROM `sensor`
WHERE description = '°C'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Pressure' AS measure_type
FROM `sensor`
WHERE description = 'hPa'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Wind' AS measure_type
FROM `sensor`
WHERE description = 'km/h'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Distance' AS measure_type
FROM `sensor`
WHERE description = 'm'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Battery voltage left' AS measure_type
FROM `sensor`
WHERE description = 'mV'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Person Activity' AS measure_type
FROM `sensor`
WHERE description = 'steps'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'co2' AS measure_type
FROM `sensor`
WHERE description = 'ppm'

UNION ALL

SELECT name
	,value
	,description
	,'' manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,1 enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Sun azimuth or Sun elevation' AS measure_type
FROM `sensor`
WHERE description = '°'

UNION ALL

SELECT name
	,value
	,description
	,manufactorer
	,create_time
	,CURRENT_TIMESTAMP AS update_time
	,'1' enabled
	,'Active' STATUS
	,'mySQLOnPrem' AS source
	,'Not profiled' AS measure_type
FROM `sensor`
WHERE description <> '%'
	AND description <> '% available'
	AND description <> 'W'
	AND description <> 'dB'
	AND description <> 'floors'
	AND description <> '°C'
	AND description <> 'hPa'
	AND description <> 'km/h'
	AND description <> 'm'
	AND description <> 'mV'
	AND description <> 'steps'
	AND description <> 'ppm'
	AND description <> '°'
ORDER BY 10
```
