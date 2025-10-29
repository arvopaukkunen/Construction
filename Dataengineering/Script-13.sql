SELECT CONCAT("ALTER DEFINER='phpadmin'@'host' VIEW ", --'phpadmin@%'@'%'
  table_name, " AS ", view_definition, ";") 
  FROM information_schema.views 
  WHERE table_schema='smarthome';


-- smarthome.CorrectedSensorvalues source

CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `CorrectedSensorvalues` AS
select
    case
        `s`.`name` when left(`s`.`name`, 8) = 'ruuvitag' then 'ruuvitag'
        else 'Unknown'
    end AS `BusinessName`,
    21 AS `AI corrected value`,
    `s`.`name` AS `Sensorname`,
    `s`.`value` AS `CurrentValue`,
    `d`.`create_time` AS `decision_time`,
    `s`.`create_time` AS `CurrentValueTime`
from
    (`sensor` `s`
join `decision` `d` on
    (`s`.`id` = `d`.`id_sensor`))
where
    `s`.`status` = 'Active'
    and `d`.`status` = 'active';

--DEFINER=`phpadmin@%`@`%`
CREATE  TRIGGER before_sensorvalue_update_APPLIANCE
BEFORE UPDATE
ON sensor FOR EACH ROW
BEGIN
INSERT INTO smarthome.appliance (id, name, manufactorer, status) 
SELECT id, name,  manufactorer, status FROM smarthome.sensor
ON DUPLICATE KEY UPDATE name = VALUES(name), 
manufactorer = VALUES(manufactorer),
status = VALUES(status);               
END


select * from smarthome.db_table_daily_size order by table_rows desc

select count(*) from smarthome.event
select *  from smarthome.event order by update_time desc

INSERT INTO event (name, status, description, event, update_time, enabled) 
VALUES ('undefined', undefined, 'undefined', 'undefined', 1746113481, undefined);