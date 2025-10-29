/*CREATE TABLE IF NOT EXISTS db_daily_size (
    id INT AUTO_INCREMENT PRIMARY KEY,
    record_date DATE NOT NULL UNIQUE,
    total_size_mb DOUBLE NOT NULL
);

-- Stores size per table per day
CREATE TABLE IF NOT EXISTS db_table_daily_size (
    id INT AUTO_INCREMENT PRIMARY KEY,
    record_date DATE NOT NULL,
    table_name VARCHAR(255),
    table_rows BIGINT,
    size_mb DOUBLE
);*/
DELIMITER //

CREATE PROCEDURE update_db_growth()
BEGIN
  DECLARE today DATE;
  SET today = CURDATE();

  -- Check if already updated today
  IF EXISTS (SELECT 1 FROM db_daily_size WHERE record_date = today) THEN
    LEAVE update_db_growth;
  END IF;

  -- Calculate total size of database
  INSERT INTO db_daily_size (record_date, total_size_mb)
  SELECT
    today,
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS total_size_mb
  FROM information_schema.tables
  WHERE table_schema = 'smarthome';

  -- Log size per table
  INSERT INTO db_table_daily_size (record_date, table_name, table_rows, size_mb)
  SELECT
    today,
    table_name,
    table_rows,
    ROUND((data_length + index_length) / 1024 / 1024, 2)
  FROM information_schema.tables
  WHERE table_schema = 'smarthome';
END //

DELIMITER ;


