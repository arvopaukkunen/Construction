-- Step 1: Create a temporary table to track daily size
DROP TEMPORARY TABLE IF EXISTS smarthome_daily_size;
CREATE TEMPORARY TABLE smarthome_daily_size (
    record_date DATE,
    total_size_mb DOUBLE
);

-- Step 2: Insert historical size per day (based on update_time)
INSERT INTO smarthome_daily_size (record_date, total_size_mb)
SELECT
    DATE(t.UPDATE_TIME) AS record_date,
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS total_size_mb
FROM
    information_schema.tables t
WHERE
    t.table_schema = 'smarthome'
    AND t.UPDATE_TIME IS NOT NULL
GROUP BY DATE(t.UPDATE_TIME)
ORDER BY record_date;

-- Step 3: Select growth per day
SELECT
    a.record_date,
    a.total_size_mb,
    ROUND(a.total_size_mb - b.total_size_mb, 2) AS growth_mb
FROM smarthome_daily_size a
LEFT JOIN smarthome_daily_size b ON a.record_date = DATE_ADD(b.record_date, INTERVAL 1 DAY)
ORDER BY a.record_date;
