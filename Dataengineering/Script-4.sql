--Triggers:
DELIMITER $$

CREATE TRIGGER before_sensorvalue_update
BEFORE UPDATE
ON smarthome.sensor FOR EACH ROW
BEGIN

INSERT INTO smarthome.event
(new_value, old_value, sensorname)
VALUES( NEW.value, OLD.value, NEW.name);               
END $$

DELIMITER ;
--'phpadmin@%'@'%'
SELECT CONCAT("ALTER DEFINER='phpadmin'@'%' VIEW ", 
  table_name, " AS ", view_definition, ";") 
  FROM information_schema.VIEWS  
  WHERE table_schema='smarthome';

ALTER DEFINER='phpadmin'@'%' 
VIEW CorrectedSensorvalues AS select case s.name 
when left('s'.'name',8) = 'ruuvitag' 
then 'ruuvitag' 
else 'Unknown' 
end AS 'BusinessName',
21 AS 'AI corrected value',
's'.'name' AS 'Sensorname',
's'.'value' AS 'CurrentValue',
'd'.'create_time' AS 'decision_time','s'.'create_time' AS 'CurrentValueTime' 
from ('smarthome'.'sensor' 's' join 'smarthome'.'decision' 'd' on('s'.'id' = 'd'.'id_sensor')) 
where 's'.'status' = 'Active' and 'd'.'status' = 'active'