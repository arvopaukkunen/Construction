/*
use smarthome
=
-
<
?
+
%
''
;:
()
'CA'
    CASE 
        WHEN performance_rating = 'Excellent' THEN salary * 0.20
        WHEN performance_rating = 'Good' THEN salary * 0.10
        ELSE 0
    END AS bonus
*/

WITH s AS 
(
  SELECT * from smarthome.sensor
)
,
e AS 
(
  SELECT * from smarthome.event
)
select s.name, Round(e.old_value,3), Round(e.new_value,3),
case when SUM(Round(e.new_value,3) - Round(e.old_value,3)) < 0
	then 'decreasing'
	when SUM(Round(e.new_value,3) = Round(e.old_value,3))
	then 'no change'
else 'rising'
end as eventDescription,
SUM(Round(e.new_value,3) - Round(e.old_value,3)) as 'By',
s.description,
'in last 5 min'
from s
join e on s.name = e.sensorname
group by s.name
/*WHERE s.precise_location = 'on prem inside east' and s.name like ('%humidity')

select 
s.location, s.precise_location, s.manufactorer, s.description, s.name, 
e.appliance_name, e.old_value, e.new_value 
from s
join e on s.name = e.sensorname
*/
/*
select 
sensor.location, sensor.precise_location, sensor.manufactorer, sensor.description, sensor.name, 
event.appliance_name, event.old_value, event.new_value, 
sum(event.old_value -  event.new_value) as difference
from sensor
join event on sensor.name = event.sensorname
group by 
sensor.location, sensor.precise_location, sensor.manufactorer, sensor.description, sensor.name, 
event.appliance_name, event.old_value, event.new_value
*/

SELECT now();  -- date and time
SELECT curdate(); --date
SELECT curtime(); --time in 24-hour format

Select count(*) from event where update_time is not null
select distinct count(year(update_time))  from event
select distinct count(month(update_time))  from event
select distinct count(day(update_time))  from event where day = 1
month()
select update_time from event limit 1
select distinct day(update_time)  from event where update_time is not null
select * from smarthome.sensor where day(update_time) = 2 
select * from smarthome.sensor where date(update_time) = curdate() 
select sensorname, old_value, new_value, update_time from smarthome.event where date(update_time) = curdate() order by sensorname, update_time
and 
manufactorer != 'Legrand'
and manufactorer != 'Apple'
and manufactorer != 'Ruuvitag'
and manufactorer != 'Netatmo'

INSERT INTO smarthome.appliance (name, manufactorer, status) 
VALUES ('ruuvitag_f6d6_temperature', 'Manufactorername', 'Active') 
ON DUPLICATE KEY UPDATE name = VALUES(name), 
manufactorer = VALUES(manufactorer),
status = VALUES(status)

INSERT INTO smarthome.appliance (id,name) 
VALUES (1, 'ruuvitag_f6d6_temperature') 
ON DUPLICATE KEY UPDATE name = VALUES(name)

INSERT INTO smarthome.appliance (id, name, manufactorer, status) 
SELECT id, name,  manufactorer, status FROM smarthome.sensor
ON DUPLICATE KEY UPDATE name = VALUES(name), 
manufactorer = VALUES(manufactorer),
status = VALUES(status)

select * from smarthome.appliance
select COUNT(*) from smarthome.appliance
delete from smarthome.appliance

CREATE DEFINER='phpadmin@%' TRIGGER before_sensorvalue_update_APPLIANCE
BEFORE UPDATE
ON sensor FOR EACH ROW
BEGIN
INSERT INTO smarthome.appliance (id, name, manufactorer, status) 
SELECT id, name,  manufactorer, status FROM smarthome.sensor
ON DUPLICATE KEY UPDATE name = VALUES(name), 
manufactorer = VALUES(manufactorer),
status = VALUES(status);               
END

select distinct name from smarthome.sensor