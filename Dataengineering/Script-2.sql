--select * from sensor s 
--ALTER TABLE smarthome.sensor ADD CONSTRAINT `PRIMARY` PRIMARY KEY (id);
--ALTER TABLE example.sensor ADD CONSTRAINT `PRIMARY_test` PRIMARY KEY (id);
INSERT INTO example.sensor (name,value,description,manufactorer,create_time,update_time,enabled,status,location,precise_location) VALUES
	 ('outlet_2_power',0.0,'W','Legrand','2025-03-28 10:07:07',NULL,1,NULL,'House','Between East Windows'),
	 ('outlet_4_power',0.0,'W','Legrand','2025-03-28 10:09:20',NULL,1,'','House','East South Corner'),
	 ('outlet_9_power',0.0,'W','Legrand','2025-03-28 10:13:00',NULL,1,NULL,'House','Left From West Door'),
	 ('outlet_11_power',0.0,'W','Legrand','2025-03-28 10:14:33',NULL,1,NULL,'House','Leftmost Next To AC Power'),
	 ('outlet_12_power',0.0,'W','Legrand','2025-03-28 10:16:44',NULL,1,NULL,'House','Loftmost Up In Staircase'),
	 ('outlet_7_power',0.0,'W','Legrand','2025-03-28 10:18:09',NULL,1,NULL,'House','Middle of South Windows'),
	 ('outlet_10_power',0.0,'W','Legrand','2025-03-28 10:22:32',NULL,1,NULL,'House','Rightmost Next to AC Power'),
	 ('outlet_13_power',0.0,'W','Legrand','2025-03-28 10:23:58',NULL,1,NULL,'House','Rightmost Up In Staricase'),
	 ('ipad_3_battery_level',65.0,'%','Apple','2025-03-27 21:47:24',NULL,0,NULL,'Anu iPad','Mobile'),
	 ('iphone13_arvo_battery_level',90.0,'%','Apple','2025-03-27 21:47:24',NULL,0,NULL,'Arvo iPhone','Mobile');
INSERT INTO example.sensor (name,value,description,manufactorer,create_time,update_time,enabled,status,location,precise_location) VALUES
	 ('ruuvitag_0c90_humidity',26.24745750427246,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Korvausilma tulo vallox'),
	 ('ruuvitag_ad37_pressure',993.7012939453125,'hPa','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Insulate middle top'),
	 ('ruuvitag_81dd_pressure',992.93212890625,'hPa','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Insulete N top'),
	 ('ruuvitag_386c_humidity',24.60137939453125,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','on prem inside east'),
	 ('outlet_6_power',8.397727012634277,'W','Legrand','2025-03-27 21:47:24',NULL,1,NULL,'House','Left From South Windows'),
	 ('weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent',18.5,'%','Netatmo','2025-03-27 21:47:24',NULL,0,NULL,'Generator room','Room center'),
	 ('ruuvitag_396d_humidity',48.720088958740234,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house SE'),
	 ('weather_station_2_pressure',1008.85791015625,'hPa','Netatmo','2025-03-27 21:47:24',NULL,0,NULL,'Generator room','Room center'),
	 ('iphone13_arvo_storage',16.3266658782959,'% available','Apple','2025-03-27 21:47:24',NULL,0,NULL,NULL,'Mobile'),
	 ('ruuvitag_ad37_humidity',36.72968292236328,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Insulate middle top');
INSERT INTO example.sensor (name,value,description,manufactorer,create_time,update_time,enabled,status,location,precise_location) VALUES
	 ('ruuvitag_0c90_pressure',993.1911010742188,'hPa','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Korvausilma tulo vallox'),
	 ('outlet_5_power',55.5,'W','Legrand','2025-03-27 21:47:24',NULL,1,NULL,'House','Left From South Door'),
	 ('ruuvitag_81dd_humidity',34.7807731628418,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Insulete N top'),
	 ('ipad_3_storage',7.059999942779541,'% available','Apple','2025-03-27 21:47:24',NULL,0,NULL,NULL,'Mobile'),
	 ('ruuvitag_9786_humidity',70.19454193115234,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house NW'),
	 ('ruuvitag_c921_humidity',55.006500244140625,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Rooftop S'),
	 ('ruuvitag_f6d6_humidity',63.70381164550781,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house NE'),
	 ('weather_station_2_noise',64.33333587646484,'dB','Netatmo','2025-03-27 21:47:24',NULL,0,NULL,'Generator room','Room center'),
	 ('outlet_8_power',16.977527618408203,'W','Legrand','2025-03-27 21:47:24',NULL,1,NULL,'House','Refridgerator Freezed'),
	 ('outlet_3_power',83.625,'W','Legrand','2025-03-27 21:47:24',NULL,1,NULL,'House','Right From South Door');
INSERT INTO example.sensor (name,value,description,manufactorer,create_time,update_time,enabled,status,location,precise_location) VALUES
	 ('ruuvitag_0c90_voltage',2865.696533203125,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Korvausilma tulo vallox'),
	 ('ruuvitag_a187_humidity',50.39700698852539,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house SW'),
	 ('ruuvitag_386c_pressure',993.9220581054688,'hPa','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','on prem inside east'),
	 ('ruuvitag_5b26_humidity',46.22858428955078,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Rooftop N'),
	 ('ruuvitag_8d93_humidity',40.265533447265625,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Rooftop middle'),
	 ('ruuvitag_b2dd_humidity',96.78147888183594,'%','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house West door'),
	 ('ruuvitag_386c_voltage',2996.14404296875,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','on prem inside east'),
	 ('weather_station_2_humidity',39.880001068115234,'%','Netatmo','2025-03-27 21:47:24',NULL,0,NULL,'Generator room','Room center'),
	 ('ruuvitag_81dd_voltage',2501.867431640625,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Insulete N top'),
	 ('iphone13_arvo_distance',152.0,'m','Apple','2025-03-27 21:47:24',NULL,0,NULL,NULL,'Mobile');
INSERT INTO example.sensor (name,value,description,manufactorer,create_time,update_time,enabled,status,location,precise_location) VALUES
	 ('ruuvitag_a187_voltage',2545.4384765625,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house SW'),
	 ('weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_humidity',48.5,'%','Netatmo','2025-03-27 21:47:24',NULL,0,NULL,'Generator room','Near Engine'),
	 ('outlet_1_power',3.0,'W','Legrand','2025-03-27 21:47:24',NULL,1,NULL,'House','Outlet1'),
	 ('ruuvitag_8d93_voltage',2922.34130859375,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Rooftop middle'),
	 ('ruuvitag_ad37_voltage',2757.215087890625,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Insulate middle top'),
	 ('iphone13_arvo_average_active_pace',2.0,'m/s','Apple','2025-03-27 21:47:24',NULL,0,NULL,NULL,'Mobile'),
	 ('ruuvitag_9786_voltage',2235.75,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house NW'),
	 ('ruuvitag_b2dd_voltage',2603.362060546875,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house West door'),
	 ('iphone13_arvo_steps',198.5,'steps','Apple','2025-03-27 21:47:24',NULL,0,NULL,NULL,'Mobile'),
	 ('sun_solar_azimuth',179.323486328125,'°','HA','2025-03-27 21:47:24',NULL,0,NULL,NULL,'General');
INSERT INTO example.sensor (name,value,description,manufactorer,create_time,update_time,enabled,status,location,precise_location) VALUES
	 ('ruuvitag_5b26_voltage',2681.88818359375,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Rooftop N'),
	 ('ruuvitag_396d_temperature',6.891170024871826,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house SE'),
	 ('ruuvitag_81dd_temperature',15.59546184539795,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Insulete N top'),
	 ('ruuvitag_396d_voltage',2600.909423828125,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house SE'),
	 ('ruuvitag_9786_temperature',0.33000001311302185,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house NW'),
	 ('ruuvitag_5b26_temperature',12.101531982421875,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Rooftop N'),
	 ('ruuvitag_c921_voltage',2640.66357421875,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Rooftop S'),
	 ('ruuvitag_ad37_temperature',13.381865501403809,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Insulate middle top'),
	 ('ruuvitag_f6d6_temperature',2.967327833175659,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house NE'),
	 ('ruuvitag_386c_temperature',26.331562042236328,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','on prem inside east');
INSERT INTO example.sensor (name,value,description,manufactorer,create_time,update_time,enabled,status,location,precise_location) VALUES
	 ('weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_temperature',5.400000095367432,'°C','Netatmo','2025-03-27 21:47:24',NULL,0,NULL,'Generator room','Near Engine'),
	 ('weather_station_2_co2',617.1376342773438,'ppm','Netatmo','2025-03-27 21:47:24',NULL,0,NULL,'Generator room','Room center'),
	 ('ruuvitag_c921_temperature',7.593024730682373,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Rooftop S'),
	 ('weather_station_2_temperature',10.58227825164795,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'Generator room','Room center'),
	 ('ruuvitag_f6d6_voltage',2594.30859375,'mV','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house NE'),
	 ('ruuvitag_8d93_temperature',13.24083423614502,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Rooftop middle'),
	 ('sun_solar_elevation',10.842206954956055,'°','HA','2025-03-27 21:47:24',NULL,0,NULL,NULL,'General'),
	 ('ruuvitag_0c90_temperature',22.31393051147461,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Korvausilma tulo vallox'),
	 ('ruuvitag_a187_temperature',7.482626438140869,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house SW'),
	 ('ruuvitag_b2dd_temperature',-0.39032670855522156,'°C','Ruuvitag','2025-03-27 21:47:24',NULL,0,NULL,'House','Under the house West door');
