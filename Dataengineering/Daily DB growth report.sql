-- Daily DB growth report
-- (Run manually as needed)
 SELECT 
     a.record_date,
     a.total_size_mb,
     ROUND(a.total_size_mb - b.total_size_mb, 2) AS growth_mb
 FROM db_daily_size a
 LEFT JOIN db_daily_size b ON a.record_date = DATE_ADD(b.record_date, INTERVAL 1 DAY)
 ORDER BY a.record_date;