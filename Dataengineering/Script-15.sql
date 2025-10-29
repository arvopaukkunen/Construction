-- 1) Create the user, allowed from the 192.168.123.* subnet
CREATE USER 'Smarthome'@'192.168.123.%' IDENTIFIED BY 'FiskarsRul3z';

-- 2) Grant full privileges everywhere + ability to grant to others
GRANT ALL PRIVILEGES ON *.* TO 'Smarthome'@'192.168.123.%' WITH GRANT OPTION;

-- 3) Not strictly required (CREATE/GRANT handle it), but harmless:
FLUSH PRIVILEGES;

-- 1) Create the user, allowed from the 192.168.123.* subnet
CREATE USER 'nodered'@'192.168.123.%' IDENTIFIED BY 'FiskarsRul3z';

-- 2) Grant full privileges everywhere + ability to grant to others
GRANT ALL PRIVILEGES ON *.* TO 'nodered'@'192.168.123.%' WITH GRANT OPTION;