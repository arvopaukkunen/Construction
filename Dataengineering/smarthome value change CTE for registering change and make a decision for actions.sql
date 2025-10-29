
--TODO:
--Summarize in desired change frequency like every 5 sec ?
--make query to compare 5 sec ago !
--if change is up say going up, if change is down say going down. 
--if up or down is with in range to make event - insrt new event to event table. 
--make decision in decision table if adjusting is needed. 
--Adjusted value needs to be set, and sended to appliance it self or another appliance like
--heating controller, AC or ventilation shutters etc.

--check this - https://dba.stackexchange.com/questions/6089/is-it-possible-to-compare-timestamps-between-rows
--SELECT A.*,B.time FROM reqs A
--INNER JOIN (SELECT user,foo,bar,time FROM reqs) B 
-- USING (user,foo,bar)
--WHERE A.time!=B.time AND ABS(TIMESTAMPDIFF(SECOND, TIMESTAMP(A.time), TIMESTAMP(B.time))) < 60
--GROUP BY A.user,A.foo,A.bar,A.time;
WITH
  cte1 AS (select name, `value`, create_time, update_time, manufactorer, description from sensor),
  cte2 AS (select name, manufactorer from appliance)
SELECT 
	cte1.name sensorName, cte1.value , cte1.create_time, cte1.update_time,
	cte2.name applianceName, cte2.manufactorer 
	FROM cte1 JOIN cte2
WHERE cte1.name = cte2.name
and cte1.manufactorer = 'Legrand' 
and cte1.name = 'outlet_8_power';