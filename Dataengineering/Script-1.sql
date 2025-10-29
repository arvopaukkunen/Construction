CREATE TABLE `sensor` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `value` float(38,20) NOT NULL,
  `description` varchar(200) NOT NULL,
  `manufactorer` varchar(200) NOT NULL,
  `create_time` timestamp NULL DEFAULT current_timestamp(),
  `update_time` timestamp NULL DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL,
  `status` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `precise_location` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sensor_name_IDX_2` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1358751 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;