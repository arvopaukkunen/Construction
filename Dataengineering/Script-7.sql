use smarthome

WITH s AS
(
  SELECT * from sensor
)
,
e AS 
(
  SELECT * from event 
)

select e.name , e.old_value, s.location, s.precise_location
from s
inner join event on s.name = e.sensorname

select 
sensor.location, sensor.precise_location, sensor.manufactorer, sensor.description, sensor.name, 
event.appliance_name, event.old_value, event.new_value, 
sum(event.old_value -  event.new_value) as difference
from sensor
join event on sensor.name = event.sensorname
group by 
sensor.location, sensor.precise_location, sensor.manufactorer, sensor.description, sensor.name, 
event.appliance_name, event.old_value, event.new_value
