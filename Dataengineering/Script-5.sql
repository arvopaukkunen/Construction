DROP TABLE IF EXISTS example.members;

CREATE TABLE example.members (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `birthDate` date DEFAULT NULL,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS example.reminders;

CREATE TABLE example.reminders (
    id INT AUTO_INCREMENT,
    memberId INT,
    message VARCHAR(255) NOT NULL,
    PRIMARY KEY (id,memberId)
);

DELIMITER $$

CREATE TRIGGER after_members_insert
AFTER INSERT
ON example.members FOR EACH ROW
BEGIN
    IF NEW.birthDate IS NULL THEN
        INSERT INTO example.reminders(memberId, message)
        VALUES(new.id,CONCAT('Hi ', NEW.name, ', please update your date of birth.'));
    END IF;
END $$

DELIMITER ;

USE example;
--SHOW GRANTS FOR 'smarthomeadmin'@'%';
--SHOW TRIGGERS;
/*CREATE TRIGGER trigger_name
BEFORE INSERT ON table_name
FOR EACH ROW
BEGIN
    -- trigger logic here
END;
*/
INSERT INTO example.members(name, email, birthDate)
VALUES
    ('John Doe', 'john.doe@example.com', NULL),
    ('Jane Doe', 'jane.doe@example.com','2000-01-01');

SELECT * FROM example.members;  
--delete FROM example.members;
SELECT * FROM example.reminders; 