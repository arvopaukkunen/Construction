SELECT
*
FROM sensor
WHERE
(room IS NULL OR TRIM(room) = '' OR
precise_location IS NULL OR TRIM(precise_location) = '' OR
location IS NULL OR TRIM(location) = '');
  
Select * from sensor where precise_location = 'Left From South Door'
Select * from sensor where name like 'cottage%'
select count(*) from sensor

