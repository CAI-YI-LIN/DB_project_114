/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-12.3.2-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: classroom_borrow
-- ------------------------------------------------------
-- Server version	12.3.2-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `AuditLog`
--

DROP TABLE IF EXISTS `AuditLog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `AuditLog` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `req_id` int(11) NOT NULL,
  `admin_id` varchar(15) NOT NULL,
  `action` varchar(10) NOT NULL,
  `reason` varchar(200) DEFAULT NULL,
  `timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`log_id`),
  KEY `req_id` (`req_id`),
  KEY `admin_id` (`admin_id`),
  CONSTRAINT `1` FOREIGN KEY (`req_id`) REFERENCES `BorrowRequest` (`req_id`),
  CONSTRAINT `2` FOREIGN KEY (`admin_id`) REFERENCES `User` (`user_id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`action` in ('Approve','Reject')),
  CONSTRAINT `CONSTRAINT_2` CHECK (`action` = 'Approve' or `action` = 'Reject' and `reason` is not null and trim(`reason`) <> '')
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AuditLog`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `AuditLog` WRITE;
/*!40000 ALTER TABLE `AuditLog` DISABLE KEYS */;
INSERT INTO `AuditLog` VALUES
(11,11,'A001','Approve',NULL,'2026-06-02 10:00:00'),
(12,12,'A001','Approve',NULL,'2026-06-06 09:00:00'),
(13,14,'A001','Approve',NULL,'2026-05-21 09:00:00'),
(14,15,'A001','Reject','教室BGC0513目前維修中，無法核准借用申請','2026-06-09 10:00:00'),
(15,17,'A001','Approve',NULL,'2026-05-26 08:30:00'),
(16,11,'A001','Approve',NULL,'2026-06-02 10:30:00'),
(17,12,'A001','Approve',NULL,'2026-06-06 09:30:00'),
(18,14,'A001','Reject','申請時間與其他課程衝突，請重新選擇時段','2026-05-21 10:00:00'),
(19,15,'A001','Reject','申請人資格不符，學生不得借用維修中教室','2026-06-09 11:00:00'),
(20,17,'A001','Approve',NULL,'2026-05-26 09:00:00');
/*!40000 ALTER TABLE `AuditLog` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `BorrowRequest`
--

DROP TABLE IF EXISTS `BorrowRequest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `BorrowRequest` (
  `req_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(15) NOT NULL,
  `room_id` varchar(10) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `weekday` int(11) DEFAULT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `purpose` varchar(100) NOT NULL,
  `borrow_type` varchar(10) NOT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'Pending',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `is_cleared` char(1) NOT NULL DEFAULT 'N',
  `cleared_at` datetime DEFAULT NULL,
  PRIMARY KEY (`req_id`),
  KEY `user_id` (`user_id`),
  KEY `room_id` (`room_id`),
  CONSTRAINT `1` FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`),
  CONSTRAINT `2` FOREIGN KEY (`room_id`) REFERENCES `Room` (`room_id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`start_date` <= `end_date`),
  CONSTRAINT `CONSTRAINT_2` CHECK (`start_time` < `end_time`),
  CONSTRAINT `CONSTRAINT_3` CHECK (`start_time` >= '08:10:00' and `end_time` <= '22:30:00'),
  CONSTRAINT `CONSTRAINT_4` CHECK (`borrow_type` = 'ShortTerm' and `weekday` is null or `borrow_type` = 'LongTerm' and `weekday` between 1 and 7),
  CONSTRAINT `CONSTRAINT_5` CHECK (`borrow_type` in ('ShortTerm','LongTerm')),
  CONSTRAINT `CONSTRAINT_6` CHECK (`status` in ('Pending','Approved','Rejected','Cancelled')),
  CONSTRAINT `CONSTRAINT_7` CHECK (`reviewed_at` is null or `reviewed_at` >= `created_at`),
  CONSTRAINT `CONSTRAINT_8` CHECK (`cancelled_at` is null or `cancelled_at` >= `created_at`),
  CONSTRAINT `CONSTRAINT_9` CHECK (`status` <> 'Cancelled' or `cancelled_at` is not null),
  CONSTRAINT `CONSTRAINT_10` CHECK (`is_cleared` in ('Y','N')),
  CONSTRAINT `CONSTRAINT_11` CHECK (`cleared_at` is null or `cleared_at` >= `created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BorrowRequest`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `BorrowRequest` WRITE;
/*!40000 ALTER TABLE `BorrowRequest` DISABLE KEYS */;
INSERT INTO `BorrowRequest` VALUES
(11,'S41243101','BGC0614','2026-06-10','2026-06-10',NULL,'09:00:00','12:00:00','期末專題報告練習','ShortTerm','Approved','2026-06-01 09:00:00','2026-06-02 10:00:00',NULL,'N',NULL),
(12,'S41243102','BCB0303','2026-06-15','2026-06-15',NULL,'13:00:00','15:00:00','小組討論','ShortTerm','Approved','2026-06-05 14:00:00','2026-06-06 09:00:00',NULL,'N',NULL),
(13,'S41243103','BGC0501','2026-06-20','2026-06-20',NULL,'10:00:00','12:00:00','電路實驗課補課','ShortTerm','Pending','2026-06-10 08:30:00',NULL,NULL,'N',NULL),
(14,'T001','BRA0102','2026-06-01','2026-06-30',2,'08:10:00','10:00:00','人工智慧課程每週二上課','LongTerm','Approved','2026-05-20 10:00:00','2026-05-21 09:00:00',NULL,'N',NULL),
(15,'S41243104','BGC0513','2026-06-18','2026-06-18',NULL,'14:00:00','16:00:00','生物資訊實驗補課','ShortTerm','Rejected','2026-06-08 11:00:00','2026-06-09 10:00:00',NULL,'N',NULL),
(16,'S41243105','BGC0601','2026-06-25','2026-06-25',NULL,'09:00:00','11:00:00','系統設計期末測試','ShortTerm','Pending','2026-06-12 15:00:00',NULL,NULL,'N',NULL),
(17,'T002','BCB0305','2026-06-01','2026-07-31',4,'10:10:00','12:00:00','數位邏輯每週四課程','LongTerm','Approved','2026-05-25 09:00:00','2026-05-26 08:30:00',NULL,'N',NULL),
(18,'S41243106','BRA0201','2026-06-22','2026-06-22',NULL,'13:00:00','15:00:00','資安競賽準備','ShortTerm','Cancelled','2026-06-11 10:00:00',NULL,'2026-06-12 09:00:00','N',NULL),
(19,'S41243107','BGC0402','2026-06-28','2026-06-28',NULL,'15:00:00','17:00:00','小組報告彩排','ShortTerm','Pending','2026-06-15 13:00:00',NULL,NULL,'N',NULL),
(20,'S41243101','BCB0303','2026-07-05','2026-07-05',NULL,'08:10:00','10:00:00','暑期自習','ShortTerm','Pending','2026-06-18 09:00:00',NULL,NULL,'N',NULL);
/*!40000 ALTER TABLE `BorrowRequest` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_check_overlap
BEFORE INSERT ON BorrowRequest
FOR EACH ROW
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt
    FROM BorrowRequest
    WHERE room_id = NEW.room_id
      AND start_date = NEW.start_date
      AND status = 'Approved'
      AND NEW.start_time < end_time
      AND NEW.end_time > start_time;
    IF cnt > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '該時段已有核准的借用申請，時間衝突無法新增';
    END IF;
END 
*/;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_check_maintenance
BEFORE INSERT ON BorrowRequest
FOR EACH ROW
BEGIN
    DECLARE room_status VARCHAR(20);
    SELECT status INTO room_status
    FROM Room
    WHERE room_id = NEW.room_id;
    IF room_status = 'UnderMaintenance' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '該教室目前維修中，無法新增借用申請';
    END IF;
END 
*/;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Equipment`
--

DROP TABLE IF EXISTS `Equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Equipment` (
  `eq_id` int(11) NOT NULL AUTO_INCREMENT,
  `eq_name` varchar(30) NOT NULL,
  `eq_desc` varchar(100) DEFAULT NULL,
  `room_id` varchar(10) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Available',
  PRIMARY KEY (`eq_id`),
  UNIQUE KEY `eq_name` (`eq_name`,`room_id`),
  KEY `room_id` (`room_id`),
  CONSTRAINT `1` FOREIGN KEY (`room_id`) REFERENCES `Room` (`room_id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`status` in ('Available','UnderMaintenance','Disabled'))
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Equipment`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Equipment` WRITE;
/*!40000 ALTER TABLE `Equipment` DISABLE KEYS */;
INSERT INTO `Equipment` VALUES
(1,'投影機','EPSON EB-X51','BGC0501','Available'),
(2,'麥克風','無線麥克風組','BGC0501','Available'),
(3,'白板','磁性白板','BGC0501','Available'),
(4,'學生電腦','ASUS 桌上型電腦 x30','BGC0501','Available'),
(5,'投影機','EPSON EB-X51','BGC0513','UnderMaintenance'),
(6,'麥克風','無線麥克風組','BGC0513','Available'),
(7,'白板','磁性白板','BGC0513','Available'),
(8,'學生電腦','ASUS 桌上型電腦 x30','BGC0513','UnderMaintenance'),
(9,'投影機','EPSON EB-X51','BGC0601','Available'),
(10,'麥克風','無線麥克風組','BGC0601','Available'),
(11,'白板','磁性白板','BGC0601','Available'),
(12,'學生電腦','ASUS 桌上型電腦 x30','BGC0601','Available'),
(13,'投影機','EPSON EB-X51','BGC0614','Available'),
(14,'麥克風','無線麥克風組','BGC0614','Available'),
(15,'白板','磁性白板','BGC0614','Available'),
(16,'投影機','EPSON EB-X51','BCB0303','Available'),
(17,'麥克風','無線麥克風組','BCB0303','Available'),
(18,'白板','磁性白板','BCB0303','Available'),
(19,'學生電腦','ASUS 桌上型電腦 x30','BCB0303','Available'),
(20,'投影機','EPSON EB-X51','BCB0305','Available'),
(21,'麥克風','無線麥克風組','BCB0305','Available'),
(22,'白板','磁性白板','BCB0305','Available'),
(23,'學生電腦','ASUS 桌上型電腦 x30','BCB0305','Available'),
(24,'投影機','EPSON EB-X51','BRA0102','Available'),
(25,'麥克風','無線麥克風組','BRA0102','Available'),
(26,'白板','磁性白板','BRA0102','Available'),
(27,'投影機','EPSON EB-X51','BRA0201','Available'),
(28,'麥克風','無線麥克風組','BRA0201','Available'),
(29,'白板','磁性白板','BRA0201','Available'),
(30,'學生電腦','ASUS 桌上型電腦 x30','BRA0201','Available');
/*!40000 ALTER TABLE `Equipment` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `Room`
--

DROP TABLE IF EXISTS `Room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Room` (
  `room_id` varchar(10) NOT NULL,
  `room_name` varchar(20) NOT NULL,
  `location` varchar(50) DEFAULT NULL,
  `capacity` int(11) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Available',
  PRIMARY KEY (`room_id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`capacity` between 1 and 100),
  CONSTRAINT `CONSTRAINT_2` CHECK (`status` in ('Available','UnderMaintenance','Disabled'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Room`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Room` WRITE;
/*!40000 ALTER TABLE `Room` DISABLE KEYS */;
INSERT INTO `Room` VALUES
('BCB0303','資工科普通教室','跨領域實作館3樓',60,'Available'),
('BCB0305','數位邏輯實驗室','跨領域實作館3樓',60,'Available'),
('BGC0402','BGC0402','綜三館4樓',15,'Available'),
('BGC0501','基本電學與證照實驗室','綜三館5樓',60,'Available'),
('BGC0508','BGC0508','綜三館5樓',15,'Available'),
('BGC0513','生物資訊實驗室','綜三館5樓',60,'UnderMaintenance'),
('BGC0601','系統設計實驗室','綜三館6樓',60,'Available'),
('BGC0614','多功能教學實驗室','綜三館6樓',60,'Available'),
('BRA0102','人工智慧創新實驗室','科研大樓1樓',60,'Available'),
('BRA0201','智慧運算與資訊安全實驗室','科研大樓2樓',60,'Available');
/*!40000 ALTER TABLE `Room` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `User` (
  `user_id` varchar(15) NOT NULL,
  `name` varchar(50) NOT NULL,
  `phone` varchar(10) DEFAULT NULL,
  `role` char(1) NOT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`user_id` regexp '^[STA][0-9]+$'),
  CONSTRAINT `CONSTRAINT_2` CHECK (`role` in ('S','T','A')),
  CONSTRAINT `CONSTRAINT_3` CHECK (`phone` is null or `phone` regexp '^09[0-9]{8}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `User` WRITE;
/*!40000 ALTER TABLE `User` DISABLE KEYS */;
INSERT INTO `User` VALUES
('A001','管理員','0912345678','A'),
('S41243101','林小華','0945678901','S'),
('S41243102','王大明','0956789012','S'),
('S41243103','張雅婷','0967890123','S'),
('S41243104','李建宏','0978901234','S'),
('S41243105','吳宜臻','0989012345','S'),
('S41243106','鄭凱文','0910111213','S'),
('S41243107','劉佳穎','0921222324','S'),
('T001','陳志明','0923456789','T'),
('T002','黃淑芬','0934567890','T');
/*!40000 ALTER TABLE `User` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Temporary table structure for view `v_audit_history`
--

DROP TABLE IF EXISTS `v_audit_history`;
/*!50001 DROP VIEW IF EXISTS `v_audit_history`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_audit_history` AS SELECT
 NULL AS `log_id`,
 NULL AS `審核時間`,
 NULL AS `審核管理員`,
 NULL AS `動作`,
 NULL AS `拒絕原因`,
 NULL AS `申請編號`,
 NULL AS `申請人`,
 NULL AS `教室`,
 NULL AS `start_date`,
 NULL AS `end_date`,
 NULL AS `start_time`,
 NULL AS `end_time` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_available_rooms`
--

DROP TABLE IF EXISTS `v_available_rooms`;
/*!50001 DROP VIEW IF EXISTS `v_available_rooms`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_available_rooms` AS SELECT
 NULL AS `room_id`,
 NULL AS `room_name`,
 NULL AS `location`,
 NULL AS `capacity` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_borrow_summary`
--

DROP TABLE IF EXISTS `v_borrow_summary`;
/*!50001 DROP VIEW IF EXISTS `v_borrow_summary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_borrow_summary` AS SELECT
 NULL AS `req_id`,
 NULL AS `申請人`,
 NULL AS `角色`,
 NULL AS `教室`,
 NULL AS `教室容量`,
 NULL AS `start_date`,
 NULL AS `end_date`,
 NULL AS `start_time`,
 NULL AS `end_time`,
 NULL AS `borrow_type`,
 NULL AS `purpose`,
 NULL AS `status`,
 NULL AS `created_at` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_pending_requests`
--

DROP TABLE IF EXISTS `v_pending_requests`;
/*!50001 DROP VIEW IF EXISTS `v_pending_requests`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_pending_requests` AS SELECT
 NULL AS `req_id`,
 NULL AS `申請人`,
 NULL AS `聯絡電話`,
 NULL AS `教室`,
 NULL AS `start_date`,
 NULL AS `end_date`,
 NULL AS `start_time`,
 NULL AS `end_time`,
 NULL AS `purpose`,
 NULL AS `borrow_type`,
 NULL AS `created_at` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_room_borrow_stats`
--

DROP TABLE IF EXISTS `v_room_borrow_stats`;
/*!50001 DROP VIEW IF EXISTS `v_room_borrow_stats`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_room_borrow_stats` AS SELECT
 NULL AS `room_id`,
 NULL AS `room_name`,
 NULL AS `總申請數`,
 NULL AS `核准數`,
 NULL AS `拒絕數`,
 NULL AS `待審數`,
 NULL AS `取消數` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_room_equipment`
--

DROP TABLE IF EXISTS `v_room_equipment`;
/*!50001 DROP VIEW IF EXISTS `v_room_equipment`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_room_equipment` AS SELECT
 NULL AS `room_id`,
 NULL AS `room_name`,
 NULL AS `教室狀態`,
 NULL AS `設備名稱`,
 NULL AS `設備描述`,
 NULL AS `設備狀態` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_user_borrow_stats`
--

DROP TABLE IF EXISTS `v_user_borrow_stats`;
/*!50001 DROP VIEW IF EXISTS `v_user_borrow_stats`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_user_borrow_stats` AS SELECT
 NULL AS `user_id`,
 NULL AS `name`,
 NULL AS `role`,
 NULL AS `總申請數`,
 NULL AS `核准數`,
 NULL AS `拒絕數`,
 NULL AS `取消數` */;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_audit_history`
--

/*!50001 DROP VIEW IF EXISTS `v_audit_history`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_audit_history` AS select `al`.`log_id` AS `log_id`,`al`.`timestamp` AS `審核時間`,`u_admin`.`name` AS `審核管理員`,`al`.`action` AS `動作`,`al`.`reason` AS `拒絕原因`,`br`.`req_id` AS `申請編號`,`u_user`.`name` AS `申請人`,`r`.`room_name` AS `教室`,`br`.`start_date` AS `start_date`,`br`.`end_date` AS `end_date`,`br`.`start_time` AS `start_time`,`br`.`end_time` AS `end_time` from ((((`AuditLog` `al` join `BorrowRequest` `br` on(`al`.`req_id` = `br`.`req_id`)) join `User` `u_admin` on(`al`.`admin_id` = `u_admin`.`user_id`)) join `User` `u_user` on(`br`.`user_id` = `u_user`.`user_id`)) join `Room` `r` on(`br`.`room_id` = `r`.`room_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_available_rooms`
--

/*!50001 DROP VIEW IF EXISTS `v_available_rooms`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_available_rooms` AS select `Room`.`room_id` AS `room_id`,`Room`.`room_name` AS `room_name`,`Room`.`location` AS `location`,`Room`.`capacity` AS `capacity` from `Room` where `Room`.`status` = 'Available' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_borrow_summary`
--

/*!50001 DROP VIEW IF EXISTS `v_borrow_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_borrow_summary` AS select `br`.`req_id` AS `req_id`,`u`.`name` AS `申請人`,`u`.`role` AS `角色`,`r`.`room_name` AS `教室`,`r`.`capacity` AS `教室容量`,`br`.`start_date` AS `start_date`,`br`.`end_date` AS `end_date`,`br`.`start_time` AS `start_time`,`br`.`end_time` AS `end_time`,`br`.`borrow_type` AS `borrow_type`,`br`.`purpose` AS `purpose`,`br`.`status` AS `status`,`br`.`created_at` AS `created_at` from ((`BorrowRequest` `br` join `User` `u` on(`br`.`user_id` = `u`.`user_id`)) join `Room` `r` on(`br`.`room_id` = `r`.`room_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_pending_requests`
--

/*!50001 DROP VIEW IF EXISTS `v_pending_requests`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_pending_requests` AS select `br`.`req_id` AS `req_id`,`u`.`name` AS `申請人`,`u`.`phone` AS `聯絡電話`,`r`.`room_name` AS `教室`,`br`.`start_date` AS `start_date`,`br`.`end_date` AS `end_date`,`br`.`start_time` AS `start_time`,`br`.`end_time` AS `end_time`,`br`.`purpose` AS `purpose`,`br`.`borrow_type` AS `borrow_type`,`br`.`created_at` AS `created_at` from ((`BorrowRequest` `br` join `User` `u` on(`br`.`user_id` = `u`.`user_id`)) join `Room` `r` on(`br`.`room_id` = `r`.`room_id`)) where `br`.`status` = 'Pending' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_room_borrow_stats`
--

/*!50001 DROP VIEW IF EXISTS `v_room_borrow_stats`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_room_borrow_stats` AS select `r`.`room_id` AS `room_id`,`r`.`room_name` AS `room_name`,count(`br`.`req_id`) AS `總申請數`,sum(case when `br`.`status` = 'Approved' then 1 else 0 end) AS `核准數`,sum(case when `br`.`status` = 'Rejected' then 1 else 0 end) AS `拒絕數`,sum(case when `br`.`status` = 'Pending' then 1 else 0 end) AS `待審數`,sum(case when `br`.`status` = 'Cancelled' then 1 else 0 end) AS `取消數` from (`Room` `r` left join `BorrowRequest` `br` on(`r`.`room_id` = `br`.`room_id`)) group by `r`.`room_id`,`r`.`room_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_room_equipment`
--

/*!50001 DROP VIEW IF EXISTS `v_room_equipment`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_room_equipment` AS select `r`.`room_id` AS `room_id`,`r`.`room_name` AS `room_name`,`r`.`status` AS `教室狀態`,`e`.`eq_name` AS `設備名稱`,`e`.`eq_desc` AS `設備描述`,`e`.`status` AS `設備狀態` from (`Room` `r` join `Equipment` `e` on(`r`.`room_id` = `e`.`room_id`)) order by `r`.`room_id`,`e`.`eq_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user_borrow_stats`
--

/*!50001 DROP VIEW IF EXISTS `v_user_borrow_stats`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_borrow_stats` AS select `u`.`user_id` AS `user_id`,`u`.`name` AS `name`,`u`.`role` AS `role`,count(`br`.`req_id`) AS `總申請數`,sum(case when `br`.`status` = 'Approved' then 1 else 0 end) AS `核准數`,sum(case when `br`.`status` = 'Rejected' then 1 else 0 end) AS `拒絕數`,sum(case when `br`.`status` = 'Cancelled' then 1 else 0 end) AS `取消數` from (`User` `u` left join `BorrowRequest` `br` on(`u`.`user_id` = `br`.`user_id`)) group by `u`.`user_id`,`u`.`name`,`u`.`role` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-06-20  3:20:04
