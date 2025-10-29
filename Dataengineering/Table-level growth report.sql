-- Table-level growth report
-- (Run manually as needed)
 SELECT 
     t1.record_date,
     t1.table_name,
     t1.size_mb AS current_size,
     t2.size_mb AS previous_size,
     ROUND(t1.size_mb - t2.size_mb, 2) AS growth_mb
 FROM db_table_daily_size t1
 LEFT JOIN db_table_daily_size t2 
   ON t1.table_name = t2.table_name 
  AND t1.record_date = DATE_ADD(t2.record_date, INTERVAL 1 DAY)
 ORDER BY t1.record_date, t1.table_name;