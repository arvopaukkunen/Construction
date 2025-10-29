INSERT INTO 
example.sensor 
(name, value,description, manufactorer, update_time, enabled, status) 
VALUES 
('ipad_3_battery_level', 15, '%', '', current_timestamp(), 1, NULL) 
ON DUPLICATE KEY UPDATE value = 
VALUES
(value), description = VALUES(description), update_time = CURRENT_TIMESTAMP(), enabled = VALUES(enabled), status = VALUES(status); 

select * from example.sensor where name = 'ipad_3_battery_level'

--------

--SELECT @@version;--10.11.11-MariaDB-0+deb12u1

INSERT INTO example.sensor (name, value,description, update_time, enabled, status) 
VALUES ('ipad_3_battery_level', 5, '%', current_timestamp(), 1, NULL) 
ON DUPLICATE KEY UPDATE value = 
VALUES(value), description = VALUES(description), update_time = CURRENT_TIMESTAMP(), enabled = VALUES(enabled), status = VALUES(status);

--Test final NR generated:
INSERT INTO smarthome.sensor (name, value,description, update_time, enabled, status) 
VALUES ('iphone13_arvo_battery_level', 100, '%', current_timestamp(), 1, NULL) 
ON DUPLICATE KEY UPDATE value = VALUES(value), description = VALUES(description), update_time = CURRENT_TIMESTAMP(), enabled = VALUES(enabled), status = VALUES(status);


--Triggers:
DELIMITER $$

CREATE TRIGGER before_sensorvalue_update
BEFORE UPDATE
ON smarthome.sensor FOR EACH ROW
BEGIN

INSERT INTO smarthome.event
(new_value, old_value, sensorname)
VALUES( NEW.value, OLD.value, NEW.name);               
;
END $$

DELIMITER ;