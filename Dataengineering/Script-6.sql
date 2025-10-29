select * from sensor

select * from event

INSERT INTO smarthome.sensor (name, value,description, update_time, enabled, status) 
VALUES ('outlet_5_power', 52.5, 'W', current_timestamp(), 1, NULL) 
ON DUPLICATE KEY UPDATE value = VALUES(value), description = VALUES(description), update_time = CURRENT_TIMESTAMP(), enabled = VALUES(enabled), status = VALUES(status);

INSERT INTO smarthome.sensor (name, value,description, update_time, enabled, status) 
VALUES ('outlet_5_power', 52.5, 'W', current_timestamp(), 1, NULL) 
ON DUPLICATE KEY UPDATE 
value = VALUES(value), description = VALUES(description), update_time = CURRENT_TIMESTAMP(), 
enabled = VALUES(enabled), status = VALUES(status);

delete smarthome.event.update_time from event

-- smarthome.event definition

INSERT INTO smarthome.sensor (name, value,description, update_time, enabled, status) 
VALUES ('ruuvitag_c921_humidity', 63.91205742338578, '%', current_timestamp(), 1, NULL) 
ON DUPLICATE KEY UPDATE value = VALUES(value), description = VALUES(description), update_time = CURRENT_TIMESTAMP(), 
enabled = VALUES(enabled), status = VALUES(status);


INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 ('Spa window is closed','active','Decrease temperature, Increase temperature, Decrease humidity, Increase humidity','Change tag based property','2024-03-24 12:43:47',NULL,1,'Temperature, Humidity',NULL,NULL,NULL,NULL,NULL),
	 ('Spa windor is open','active','Decrease temperature, Increase temperature, Decrease humidity, Increase humidity','Change tag based property','2024-03-24 12:43:47',NULL,1,'Temperature, Humidity',NULL,NULL,NULL,NULL,NULL),
	 ('Bathroom window is closed','active','Decrease temperature, Increase temperature, Decrease humidity, Increase humidity','Change tag based property','2024-03-24 12:43:47',NULL,1,'Temperature, Humidity',NULL,NULL,NULL,NULL,NULL),
	 ('Bathroom window is open','active','Decrease temperature, Increase temperature, Decrease humidity, Increase humidity','Change tag based property','2024-03-24 12:43:47',NULL,1,'Temperature, Humidity',NULL,NULL,NULL,NULL,NULL),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'5','5','ipad_3_battery_level'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'100','100','iphone13_arvo_battery_level'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'55.631919860839844','56.28900909423828','ruuvitag_5b26_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'76.12249755859375','76.12249755859375','ruuvitag_9786_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'37.40520477294922','37.13539123535156','ruuvitag_81dd_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'49.762184143066406','50.223628997802734','ruuvitag_8d93_humidity');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'42.32032012939453','42.227420806884766','ruuvitag_ad37_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'55.883846282958984','55.84084701538086','ruuvitag_a187_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'57.57713317871094','57.527687072753906','ruuvitag_396d_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'28.143413543701172','28.243289947509766','ruuvitag_386c_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'29.419090270996094','29.501258850097656','ruuvitag_0c90_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'7.010000228881836','7.010000228881836','ipad_3_storage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'16.809999465942383','16.809999465942383','iphone13_arvo_storage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'45','44.5','weather_station_2_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'66.4123764038086','66.4123764038086','ruuvitag_f6d6_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'55.5','55.5','weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_humidity');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'71.11637878417969','71.7345962524414','ruuvitag_c921_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'0.5','0.5','outlet_1_power'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'6.666666507720947','6.666666507720947','outlet_3_power'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'52.5','52.5','outlet_5_power'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'4.753520965576172','4.820895671844482','outlet_6_power'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'29.653060913085938','29.653060913085938','outlet_7_power'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'994.9591064453125','994.9564208984375','ruuvitag_0c90_pressure'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'45','45','weather_station_2_noise'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'995.3486938476562','995.3473510742188','ruuvitag_386c_pressure'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'17.51785659790039','17.51886749267578','outlet_8_power');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'93','93','iphone13_arvo_distance'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'994.841552734375','994.837158203125','ruuvitag_ad37_pressure'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'1010.7305297851562','1010.7305297851562','weather_station_2_pressure'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'1','1','iphone13_arvo_average_active_pace'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'994.6670532226562','994.6629028320312','ruuvitag_81dd_pressure'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'2878.6416015625','2877.97119140625','ruuvitag_0c90_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'3002.3349609375','3002.049560546875','ruuvitag_386c_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'2621.15625','2621.36767578125','ruuvitag_396d_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'2697.37158203125','2691.6279296875','ruuvitag_5b26_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'2493.0029296875','2490.47705078125','ruuvitag_81dd_voltage');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'2926.947021484375','2924.759033203125','ruuvitag_8d93_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'2594.956298828125','2595.074462890625','ruuvitag_a187_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'2331.60009765625','2331.60009765625','ruuvitag_9786_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'2669.56396484375','2664.40673828125','ruuvitag_c921_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'121','121','iphone13_arvo_steps'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'2760.224853515625','2758.21337890625','ruuvitag_ad37_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'13.492931365966797','12.597515106201172','sun_solar_elevation'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'119.42611694335938','115.01042175292969','sun_solar_azimuth'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'547.0606079101562','550.8571166992188','weather_station_2_co2'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'2633.105712890625','2633.105712890625','ruuvitag_f6d6_voltage');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'24.10284423828125','24.008316040039062','ruuvitag_0c90_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'14.293310165405273','13.751571655273438','ruuvitag_8d93_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'28.17943000793457','28.078014373779297','ruuvitag_386c_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'13.050421714782715','12.361128807067871','ruuvitag_5b26_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'10.031851768493652','10.026671409606934','ruuvitag_396d_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'16.5609073638916','16.363941192626953','ruuvitag_81dd_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'14.911276817321777','14.646669387817383','ruuvitag_ad37_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'10.634900093078613','10.628911018371582','ruuvitag_a187_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'7.405985355377197','7.405985355377197','ruuvitag_f6d6_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'4.671999931335449','4.671999931335449','ruuvitag_9786_temperature');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'9.17010498046875','8.50991439819336','ruuvitag_c921_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'12.96981143951416','13.111764907836914','weather_station_2_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:13',NULL,0,NULL,NULL,NULL,'9.639286041259766','9.496000289916992','weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:44:16',NULL,0,NULL,NULL,NULL,'52.5','52.5','outlet_5_power'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'5','5','ipad_3_battery_level'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'100','100','iphone13_arvo_battery_level'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'29.406986236572266','29.419090270996094','ruuvitag_0c90_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'28.12806510925293','28.143413543701172','ruuvitag_386c_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'57.58415985107422','57.57713317871094','ruuvitag_396d_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'6.666666507720947','6.666666507720947','outlet_3_power');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'55.5','55.5','weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'4.671999931335449','4.671999931335449','ruuvitag_9786_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'12.905555725097656','12.96981143951416','weather_station_2_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'49.69715118408203','49.762184143066406','ruuvitag_8d93_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'7.405985355377197','7.405985355377197','ruuvitag_f6d6_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'17.51785659790039','17.51785659790039','outlet_8_power'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'9.689655303955078','9.639286041259766','weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'66.4123764038086','66.4123764038086','ruuvitag_f6d6_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'2633.105712890625','2633.105712890625','ruuvitag_f6d6_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'76.12249755859375','76.12249755859375','ruuvitag_9786_humidity');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'994.66748046875','994.6670532226562','ruuvitag_81dd_pressure'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'119.92090606689453','119.42611694335938','sun_solar_azimuth'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'1','1','iphone13_arvo_average_active_pace'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'3002.3525390625','3002.3349609375','ruuvitag_386c_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'42.333221435546875','42.32032012939453','ruuvitag_ad37_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'2927.24951171875','2926.947021484375','ruuvitag_8d93_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'2493.279541015625','2493.0029296875','ruuvitag_81dd_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'2698.728271484375','2697.37158203125','ruuvitag_5b26_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'45','45','weather_station_2_noise'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'545.7611694335938','547.0606079101562','weather_station_2_co2');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'55.89097213745117','55.883846282958984','ruuvitag_a187_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'2331.60009765625','2331.60009765625','ruuvitag_9786_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'14.37105655670166','14.293310165405273','ruuvitag_8d93_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'37.44891357421875','37.40520477294922','ruuvitag_81dd_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'994.8423461914062','994.841552734375','ruuvitag_ad37_pressure'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'55.54392623901367','55.631919860839844','ruuvitag_5b26_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'2621.155029296875','2621.15625','ruuvitag_396d_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'10.636075973510742','10.634900093078613','ruuvitag_a187_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'93','93','iphone13_arvo_distance'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'13.58154296875','13.492931365966797','sun_solar_elevation');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'10.033183097839355','10.031851768493652','ruuvitag_396d_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'7.010000228881836','7.010000228881836','ipad_3_storage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'28.193817138671875','28.17943000793457','ruuvitag_386c_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'71.01673889160156','71.11637878417969','ruuvitag_c921_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'16.591283798217773','16.5609073638916','ruuvitag_81dd_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'2669.94970703125','2669.56396484375','ruuvitag_c921_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'9.252937316894531','9.17010498046875','ruuvitag_c921_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'2760.413818359375','2760.224853515625','ruuvitag_ad37_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'0.5','0.5','outlet_1_power'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'29.653060913085938','29.653060913085938','outlet_7_power');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'52.5','52.5','outlet_5_power'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'4.748251914978027','4.753520965576172','outlet_6_power'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'45','45','weather_station_2_humidity'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'995.3487548828125','995.3486938476562','ruuvitag_386c_pressure'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'1010.72705078125','1010.7305297851562','weather_station_2_pressure'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'2878.740966796875','2878.6416015625','ruuvitag_0c90_voltage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'16.809999465942383','16.809999465942383','iphone13_arvo_storage'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'994.959228515625','994.9591064453125','ruuvitag_0c90_pressure'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'121','121','iphone13_arvo_steps'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'24.113937377929688','24.10284423828125','ruuvitag_0c90_temperature');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'13.09473991394043','13.050421714782715','ruuvitag_5b26_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'14.945313453674316','14.911276817321777','ruuvitag_ad37_temperature'),
	 (NULL,NULL,NULL,NULL,'2025-03-29 13:49:13',NULL,0,NULL,NULL,NULL,'2594.9375','2594.956298828125','ruuvitag_a187_voltage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.482045',0,'No Tag','No applicance name','No appliance id','5','5','ipad_3_battery_level'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.483849',0,'No Tag','No applicance name','No appliance id','100','100','iphone13_arvo_battery_level'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.484614',0,'No Tag','No applicance name','No appliance id','27.196800231933594','28.12806510925293','ruuvitag_386c_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.484598',0,'No Tag','No applicance name','No appliance id','57.89958572387695','57.58415985107422','ruuvitag_396d_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.483937',0,'No Tag','No applicance name','No appliance id','50.88829803466797','55.54392623901367','ruuvitag_5b26_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.485833',0,'No Tag','No applicance name','No appliance id','38.68338394165039','37.44891357421875','ruuvitag_81dd_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.486564',0,'No Tag','No applicance name','No appliance id','45.900001525878906','45','weather_station_2_humidity');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.486020',0,'No Tag','No applicance name','No appliance id','76.37999725341797','76.12249755859375','ruuvitag_9786_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.486619',0,'No Tag','No applicance name','No appliance id','56.183467864990234','55.89097213745117','ruuvitag_a187_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.483848',0,'No Tag','No applicance name','No appliance id','28.654796600341797','29.406986236572266','ruuvitag_0c90_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.486993',0,'No Tag','No applicance name','No appliance id','41.90953063964844','42.333221435546875','ruuvitag_ad37_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.487668',0,'No Tag','No applicance name','No appliance id','66.4123764038086','66.4123764038086','ruuvitag_f6d6_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.487724',0,'No Tag','No applicance name','No appliance id','55','55.5','weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.490657',0,'No Tag','No applicance name','No appliance id','995.0372314453125','995.3487548828125','ruuvitag_386c_pressure'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.488978',0,'No Tag','No applicance name','No appliance id','6.666666507720947','6.666666507720947','outlet_3_power'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.491693',0,'No Tag','No applicance name','No appliance id','1010.4520263671875','1010.72705078125','weather_station_2_pressure'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.489562',0,'No Tag','No applicance name','No appliance id','17.977142333984375','17.51785659790039','outlet_8_power');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.486034',0,'No Tag','No applicance name','No appliance id','45.49236297607422','49.69715118408203','ruuvitag_8d93_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.489277',0,'No Tag','No applicance name','No appliance id','29.653060913085938','29.653060913085938','outlet_7_power'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.493326',0,'No Tag','No applicance name','No appliance id','93','93','iphone13_arvo_distance'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.489117',0,'No Tag','No applicance name','No appliance id','4.553398132324219','4.748251914978027','outlet_6_power'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.491418',0,'No Tag','No applicance name','No appliance id','994.5526123046875','994.8423461914062','ruuvitag_ad37_pressure'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.494824',0,'No Tag','No applicance name','No appliance id','1','1','iphone13_arvo_average_active_pace'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.496308',0,'No Tag','No applicance name','No appliance id','2363','2331.60009765625','ruuvitag_9786_voltage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.488310',0,'No Tag','No applicance name','No appliance id','63.91205596923828','71.01673889160156','ruuvitag_c921_humidity'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.494870',0,'No Tag','No applicance name','No appliance id','2622.012939453125','2621.155029296875','ruuvitag_396d_voltage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.496266',0,'No Tag','No applicance name','No appliance id','2779.361328125','2760.413818359375','ruuvitag_ad37_voltage');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.488706',0,'No Tag','No applicance name','No appliance id','52.5','52.5','outlet_5_power'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.496465',0,'No Tag','No applicance name','No appliance id','2519.81494140625','2493.279541015625','ruuvitag_81dd_voltage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.494109',0,'No Tag','No applicance name','No appliance id','2882.580810546875','2878.740966796875','ruuvitag_0c90_voltage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.491172',0,'No Tag','No applicance name','No appliance id','994.3884887695312','994.66748046875','ruuvitag_81dd_pressure'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.502835',0,'No Tag','No applicance name','No appliance id','15.928996086120605','13.09473991394043','ruuvitag_5b26_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.499076',0,'No Tag','No applicance name','No appliance id','10.254142761230469','10.033183097839355','ruuvitag_396d_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.495834',0,'No Tag','No applicance name','No appliance id','2599.501708984375','2594.9375','ruuvitag_a187_voltage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.495874',0,'No Tag','No applicance name','No appliance id','2633.105712890625','2633.105712890625','ruuvitag_f6d6_voltage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.497048',0,'No Tag','No applicance name','No appliance id','12.449342727661133','13.58154296875','sun_solar_elevation'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.496506',0,'No Tag','No applicance name','No appliance id','2696.36865234375','2669.94970703125','ruuvitag_c921_voltage');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.493810',0,'No Tag','No applicance name','No appliance id','3004.818603515625','3002.3525390625','ruuvitag_386c_voltage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.488564',0,'No Tag','No applicance name','No appliance id','16.809999465942383','16.809999465942383','iphone13_arvo_storage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.489834',0,'No Tag','No applicance name','No appliance id','45','45','weather_station_2_noise'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.503921',0,'No Tag','No applicance name','No appliance id','17.093116760253906','14.37105655670166','ruuvitag_8d93_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.489398',0,'No Tag','No applicance name','No appliance id','0.5','0.5','outlet_1_power'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.490172',0,'No Tag','No applicance name','No appliance id','994.641845703125','994.959228515625','ruuvitag_0c90_pressure'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.495872',0,'No Tag','No applicance name','No appliance id','2728.511474609375','2698.728271484375','ruuvitag_5b26_voltage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.499936',0,'No Tag','No applicance name','No appliance id','24.720130920410156','24.113937377929688','ruuvitag_0c90_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.488194',0,'No Tag','No applicance name','No appliance id','7.010000228881836','7.010000228881836','ipad_3_storage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.502056',0,'No Tag','No applicance name','No appliance id','28.9851131439209','28.193817138671875','ruuvitag_386c_temperature');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.497482',0,'No Tag','No applicance name','No appliance id','173.2079315185547','119.92090606689453','sun_solar_azimuth'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.497084',0,'No Tag','No applicance name','No appliance id','121','121','iphone13_arvo_steps'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.496192',0,'No Tag','No applicance name','No appliance id','2940.9833984375','2927.24951171875','ruuvitag_8d93_voltage'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.499728',0,'No Tag','No applicance name','No appliance id','525.4901733398438','545.7611694335938','weather_station_2_co2'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.499969',0,'No Tag','No applicance name','No appliance id','18.747812271118164','16.591283798217773','ruuvitag_81dd_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.505244',0,'No Tag','No applicance name','No appliance id','5.25','4.671999931335449','ruuvitag_9786_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.517146',0,'No Tag','No applicance name','No appliance id','10.960399627685547','10.636075973510742','ruuvitag_a187_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.517789',0,'No Tag','No applicance name','No appliance id','12.117266654968262','9.252937316894531','ruuvitag_c921_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.517146',0,'No Tag','No applicance name','No appliance id','17.30517578125','14.945313453674316','ruuvitag_ad37_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.520037',0,'No Tag','No applicance name','No appliance id','7.405985355377197','7.405985355377197','ruuvitag_f6d6_temperature');
INSERT INTO smarthome.event (name,status,description,event,create_time,update_time,enabled,PropertyTag,appliance_name,appliance_id,new_value,old_value,sensorname) VALUES
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.519915',0,'No Tag','No applicance name','No appliance id','12.272222518920898','12.905555725097656','weather_station_2_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:57:59.522878',0,'No Tag','No applicance name','No appliance id','10.65999984741211','9.689655303955078','weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_temperature'),
	 ('noname','0','nodescription','un_named event',NULL,'2025-03-29 19:59:27.944285',0,'No Tag','No applicance name','No appliance id','63.91205596923828','63.91205596923828','ruuvitag_c921_humidity');
