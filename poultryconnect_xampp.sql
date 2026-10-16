-- ========================================================
-- PoultryConnect Database Dump for XAMPP (MySQL / MariaDB)
-- Compatible with phpMyAdmin, MariaDB 10.4+, MySQL 5.7/8.0
-- Database: `poultryconnect`
-- Generated with correct AUTO_INCREMENT, FKs, and UTF8MB4
-- ========================================================

SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT;
SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS;
SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION;
SET NAMES utf8mb4;
SET @OLD_TIME_ZONE=@@TIME_ZONE;
SET TIME_ZONE='+00:00';
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

CREATE DATABASE IF NOT EXISTS `poultryconnect` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `poultryconnect`;

-- --------------------------------------------------------
-- Table structure for table `alembic_version`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `alembic_version`;
CREATE TABLE `alembic_version` (
  `version_num` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `alembic_version` (`version_num`) VALUES
('eaa7a095e8bd');

-- --------------------------------------------------------
-- Table structure for table `users`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(64) NOT NULL,
  `email` VARCHAR(120) NOT NULL,
  `password_hash` VARCHAR(256) NOT NULL,
  `role` VARCHAR(13) NOT NULL DEFAULT 'farmer',
  `first_name` VARCHAR(64) DEFAULT NULL,
  `last_name` VARCHAR(64) DEFAULT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `address` VARCHAR(200) DEFAULT NULL,
  `landmark` VARCHAR(255) DEFAULT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `online_status` TINYINT(1) NOT NULL DEFAULT 0,
  `last_seen` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  `subscription_plan` VARCHAR(7) NOT NULL DEFAULT 'free',
  `subscription_end` DATETIME DEFAULT NULL,
  `trial_end` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_users_username` (`username`),
  KEY `ix_users_role` (`role`),
  UNIQUE KEY `ix_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `users`
LOCK TABLES `users` WRITE;
INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `role`, `first_name`, `last_name`, `phone`, `address`, `landmark`, `is_active`, `online_status`, `last_seen`, `created_at`, `updated_at`, `subscription_plan`, `subscription_end`, `trial_end`) VALUES
  (1, 'admin', 'admin@poultryconnect.com', 'scrypt:32768:8:1$IIdRogA4aPBSh6fU$d00ed1353e97632bb89fd164260901fb01407b18126a10e6b03c42172ec79434a89170890f2690c9cdc7afaf4bc0acb6c11f534bf28dbbac0b518b554d7f4b79', 'admin', 'System', 'Admin', '09170000000', NULL, NULL, 1, 1, '2026-10-14 11:22:42.702347', '2026-09-29 07:50:21.481210', '2026-10-14 11:22:42.703238', 'free', NULL, '2026-10-06 07:50:21.481210'),
  (2, 'jdelacruz', 'farmer@poultryconnect.com', 'scrypt:32768:8:1$DBi3fZQVyoESCyM0$48b1c21a6fcb323b27f53c50c9e06d8bd6471751639a85de8a558c8957a0f3bda96be80a809ba1ccbf5b76731b86bce24df722fb8b84ae5e303acb68cc685f74', 'farmer', 'Juan', 'Dela Cruz', '09171234567', NULL, NULL, 1, 1, '2026-10-14 12:38:49.036708', '2026-09-29 07:50:21.481242', '2026-10-14 12:38:49.037632', 'monthly', '2026-11-06 10:14:54.138117', '2026-09-30 05:59:41.155600'),
  (3, 'mreyes', 'buyer@poultryconnect.com', 'scrypt:32768:8:1$IUXbvijcdlRuBdx7$9b898f6d89bb20593c9392da04a896985bd0bbc38316cd070450930843489e5bae80cd379dfc47cef55954f5f4651d969f2dc9982fa9be5bc725e937d9d3d62f', 'buyer', 'Maria', 'Reyes', '09189876543', NULL, NULL, 1, 0, '2026-10-14 12:35:58.599439', '2026-09-29 07:50:21.481253', '2026-10-14 12:35:58.603564', 'free', NULL, '2026-10-06 07:50:21.481253'),
  (4, 'jusko', 'jusko@gmail.com', 'scrypt:32768:8:1$RSBJnTwF3NyC2f5z$85c253751941559f4a72b0701eaeb94e7f33339caed7c35a121dae0dc287d43bd92061d0612b04623f62c67ea02a3fb0415206fb0c555004ba90130c2f3d25b4', 'farmer', 'Jusko', 'Po', NULL, NULL, NULL, 1, 0, '2026-10-14 11:53:57.905618', '2026-10-14 11:21:09.667383', '2026-10-14 11:53:57.908568', 'free', NULL, '2026-10-21 11:21:09.667398');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `conversations`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `conversations`;
CREATE TABLE `conversations` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `farmer_id` INT(11) NOT NULL,
  `participant_id` INT(11) NOT NULL,
  `participant_role` VARCHAR(32) NOT NULL,
  `deleted_by_farmer` TINYINT(1) DEFAULT 0,
  `deleted_by_participant` TINYINT(1) DEFAULT 0,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_convo_pair` (`farmer_id`, `participant_id`),
  KEY `ix_conversations_participant_id` (`participant_id`),
  KEY `ix_conversations_farmer_id` (`farmer_id`),
  CONSTRAINT `fk_conversations_participant_id` FOREIGN KEY (`participant_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_conversations_farmer_id` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `conversations`
LOCK TABLES `conversations` WRITE;
INSERT INTO `conversations` (`id`, `farmer_id`, `participant_id`, `participant_role`, `deleted_by_farmer`, `deleted_by_participant`, `created_at`) VALUES
  (1, 2, 3, 'buyer', 0, 0, '2026-10-07 10:06:13.833557');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `farmer_verifications`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `farmer_verifications`;
CREATE TABLE `farmer_verifications` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `farmer_id` INT(11) NOT NULL,
  `status` VARCHAR(8) NOT NULL DEFAULT 'pending',
  `farm_name` VARCHAR(150) DEFAULT NULL,
  `farm_location` VARCHAR(255) DEFAULT NULL,
  `initial_flock_size` INT(11) DEFAULT NULL,
  `id_type` VARCHAR(100) DEFAULT NULL,
  `id_number` VARCHAR(100) DEFAULT NULL,
  `id_document_url` VARCHAR(500) DEFAULT NULL,
  `permit_type` VARCHAR(100) DEFAULT NULL,
  `permit_document_url` VARCHAR(500) DEFAULT NULL,
  `farm_photo_url` VARCHAR(500) DEFAULT NULL,
  `rejection_reason` TEXT DEFAULT NULL,
  `reviewed_by_id` INT(11) DEFAULT NULL,
  `reviewed_at` DATETIME DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_farmer_verifications_farmer_id` (`farmer_id`),
  KEY `ix_farmer_verifications_status` (`status`),
  CONSTRAINT `fk_farmer_verifications_reviewed_by_id` FOREIGN KEY (`reviewed_by_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_farmer_verifications_farmer_id` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `farmer_verifications`
LOCK TABLES `farmer_verifications` WRITE;
INSERT INTO `farmer_verifications` (`id`, `farmer_id`, `status`, `rejection_reason`, `reviewed_by_id`, `reviewed_at`, `notes`, `created_at`, `updated_at`, `farm_name`, `farm_location`, `initial_flock_size`, `id_type`, `id_number`, `id_document_url`, `permit_type`, `permit_document_url`, `farm_photo_url`) VALUES
  (1, 1, 'approved', NULL, 4, '2026-08-21 15:35:01.881085', NULL, '2026-08-21 15:35:01.882925', '2026-08-21 15:35:01.882932', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (2, 2, 'approved', NULL, 1, '2026-09-30 05:08:02.395597', NULL, '2026-09-30 05:08:02.398555', '2026-09-30 05:08:02.398565', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (3, 4, 'pending', NULL, NULL, NULL, NULL, '2026-10-14 11:30:18.616553', '2026-10-14 11:30:18.613527', 'Batangas Highland Poultry Farm', 'Brgy. Mataasnakahoy, Lipa City, Batangas', 850, 'PhilSys National ID', '7429-8812-4091', 'uploads/verifications/sample_philsys_id.png', 'Barangay Clearance for Poultry / Business', 'uploads/verifications/sample_barangay_permit.png', 'uploads/verifications/sample_poultry_farm.png');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `farms`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `farms`;
CREATE TABLE `farms` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `farmer_id` INT(11) NOT NULL,
  `name` VARCHAR(120) NOT NULL,
  `location` VARCHAR(255) DEFAULT NULL,
  `description` TEXT DEFAULT NULL,
  `flock_size` INT(11) DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_farms_farmer_id` (`farmer_id`),
  CONSTRAINT `fk_farms_farmer_id` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `farms`
LOCK TABLES `farms` WRITE;
INSERT INTO `farms` (`id`, `farmer_id`, `name`, `location`, `description`, `flock_size`, `is_active`, `created_at`, `updated_at`) VALUES
  (1, 2, 'Sunshine Poultry Farm', 'San Jose, Batangas', 'Family-owned layer farm specializing in fresh eggs.', 4817, 1, '2026-09-29 07:50:21.509133', '2026-09-29 07:50:21.683897'),
  (2, 4, 'Batangas Highland Poultry Farm', 'Brgy. Mataasnakahoy, Lipa City, Batangas', NULL, 850, 1, '2026-10-14 11:30:18.624102', '2026-10-14 11:30:18.624109');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `notifications`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `title` VARCHAR(120) NOT NULL,
  `body` VARCHAR(255) NOT NULL,
  `notif_type` VARCHAR(32) NOT NULL DEFAULT 'message',
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `link_url` VARCHAR(255) DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_notifications_user_id` (`user_id`),
  KEY `ix_notifications_is_read` (`is_read`),
  CONSTRAINT `fk_notifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `notifications`
LOCK TABLES `notifications` WRITE;
INSERT INTO `notifications` (`id`, `user_id`, `title`, `body`, `notif_type`, `is_read`, `link_url`, `created_at`) VALUES
  (1, 3, 'New Conversation', 'Maria Reyes started a conversation with you.', 'message', 0, '/messaging/?open=1', '2026-10-07 10:06:13.865833'),
  (2, 2, 'New message from Maria Reyes', 'hello', 'message', 0, '/messaging/?open=1', '2026-10-07 10:09:26.980200'),
  (3, 2, 'New message from Maria Reyes', 'hello again', 'message', 0, '/messaging/?open=1', '2026-10-07 10:13:49.313094'),
  (4, 2, 'New message from Maria Reyes', 'hi', 'message', 0, '/messaging/?open=1', '2026-10-07 10:13:56.871501'),
  (5, 3, 'Message read by Juan Dela Cruz', 'Juan Dela Cruz has seen your latest message.', 'seen', 0, '/messaging/?open=1', '2026-10-07 10:14:47.905472'),
  (6, 3, 'New message from Juan Dela Cruz', 'hello why', 'message', 0, '/messaging/?open=1', '2026-10-07 10:15:06.423656'),
  (7, 3, 'New message from Juan Dela Cruz', 'hey', 'message', 0, '/messaging/?open=1', '2026-10-07 10:16:59.762209'),
  (8, 3, 'New message from Juan Dela Cruz', 'hi', 'message', 0, '/messaging/?open=1', '2026-10-07 10:23:08.041379'),
  (9, 3, 'New message from Juan Dela Cruz', 'Testing message sending from browser agent', 'message', 0, '/messaging/?open=1', '2026-10-07 10:28:34.505509'),
  (10, 3, 'New message from Juan Dela Cruz', 'Testing via JavaScript trigger', 'message', 0, '/messaging/?open=1', '2026-10-07 10:30:08.689239'),
  (11, 3, 'New message from Juan Dela Cruz', 'Testing via JavaScript trigger', 'message', 0, '/messaging/?open=1', '2026-10-07 10:32:02.363701'),
  (12, 3, 'New message from Juan Dela Cruz', 'hello', 'message', 0, '/messaging/?open=1', '2026-10-07 10:36:23.049416');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `orders`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` INT(11) NOT NULL,
  `total_amount` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
  `status` VARCHAR(9) NOT NULL DEFAULT 'pending',
  `delivery_address` VARCHAR(500) NOT NULL,
  `contact_phone` VARCHAR(30) NOT NULL,
  `payment_method` VARCHAR(50) NOT NULL DEFAULT 'COD',
  `payment_date` DATETIME DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  `rating` INT(11) DEFAULT NULL,
  `feedback_text` TEXT DEFAULT NULL,
  `feedback_category` VARCHAR(100) DEFAULT NULL,
  `feedback_issue` VARCHAR(100) DEFAULT NULL,
  `feedback_sentiment` VARCHAR(20) DEFAULT NULL,
  `feedback_keywords` VARCHAR(500) DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_orders_status` (`status`),
  KEY `ix_orders_buyer_id` (`buyer_id`),
  CONSTRAINT `fk_orders_buyer_id` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `orders`
LOCK TABLES `orders` WRITE;
INSERT INTO `orders` (`id`, `buyer_id`, `total_amount`, `status`, `delivery_address`, `contact_phone`, `notes`, `created_at`, `updated_at`, `payment_method`, `payment_date`, `rating`, `feedback_text`, `feedback_category`, `feedback_issue`, `feedback_sentiment`, `feedback_keywords`) VALUES
  (1, 3, 3400, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-12 15:00:00.000000', '2026-07-12 15:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (2, 3, 4750, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-08 13:00:00.000000', '2026-07-08 13:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (3, 3, 5940, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-09 09:00:00.000000', '2026-08-09 09:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (4, 3, 2050, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-08 09:00:00.000000', '2026-08-08 09:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (5, 3, 7140, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-18 17:00:00.000000', '2026-07-18 17:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (6, 3, 5940, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-18 08:00:00.000000', '2026-07-18 08:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (7, 3, 7175, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-05 16:00:00.000000', '2026-07-05 16:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (8, 3, 2210, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-04 10:00:00.000000', '2026-07-04 10:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (9, 3, 7955, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-01 12:00:00.000000', '2026-08-01 12:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (10, 3, 3400, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-23 18:00:00.000000', '2026-07-23 18:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (11, 3, 5130, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-13 09:00:00.000000', '2026-08-13 09:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (12, 3, 4940, 'completed', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-22 17:00:00.000000', '2026-09-30 06:14:14.678242', 'COD', NULL, 1, NULL, NULL, NULL, NULL, NULL),
  (13, 3, 825, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-31 13:00:00.000000', '2026-07-31 13:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (14, 3, 850, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-20 15:00:00.000000', '2026-07-20 15:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (15, 3, 3075, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-02 09:00:00.000000', '2026-07-02 09:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (16, 3, 6105, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-25 14:00:00.000000', '2026-07-25 14:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (17, 3, 2940, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-16 08:00:00.000000', '2026-09-16 08:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (18, 3, 4810, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-16 17:00:00.000000', '2026-07-16 17:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (19, 3, 6600, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-17 17:00:00.000000', '2026-09-17 17:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (20, 3, 4760, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-13 11:00:00.000000', '2026-09-13 11:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (21, 3, 3885, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-31 09:00:00.000000', '2026-07-31 09:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (22, 3, 4455, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-12 08:00:00.000000', '2026-07-12 08:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (23, 3, 1870, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-10 13:00:00.000000', '2026-07-10 13:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (24, 3, 8610, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-06 11:00:00.000000', '2026-09-06 11:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (25, 3, 1680, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-11 18:00:00.000000', '2026-07-11 18:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (26, 3, 4440, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-09 15:00:00.000000', '2026-09-09 15:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (27, 3, 8360, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-22 10:00:00.000000', '2026-07-22 10:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (28, 3, 4440, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-15 15:00:00.000000', '2026-08-15 15:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (29, 3, 5670, 'pending', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-29 12:00:00.000000', '2026-09-29 12:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (30, 3, 3740, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-01 16:00:00.000000', '2026-07-01 16:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (31, 3, 2850, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-07 14:00:00.000000', '2026-09-07 14:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (32, 3, 8085, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-10 17:00:00.000000', '2026-08-10 17:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (33, 3, 2475, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-18 15:00:00.000000', '2026-09-18 15:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (34, 3, 5365, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-05 13:00:00.000000', '2026-07-05 13:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (35, 3, 3610, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-05 15:00:00.000000', '2026-09-05 15:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (36, 3, 8330, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-16 08:00:00.000000', '2026-09-16 08:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (37, 3, 3230, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-17 16:00:00.000000', '2026-07-17 16:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (38, 3, 6150, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-13 16:00:00.000000', '2026-08-13 16:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (39, 3, 5610, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-07 18:00:00.000000', '2026-07-07 18:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (40, 3, 2310, 'completed', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-22 11:00:00.000000', '2026-09-30 06:17:23.961838', 'COD', NULL, 1, NULL, NULL, NULL, NULL, NULL),
  (41, 3, 2890, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-09 11:00:00.000000', '2026-09-09 11:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (42, 3, 4100, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-13 11:00:00.000000', '2026-08-13 11:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (43, 3, 7990, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-12 14:00:00.000000', '2026-08-12 14:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (44, 3, 5125, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-05 12:00:00.000000', '2026-09-05 12:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (45, 3, 850, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-11 15:00:00.000000', '2026-07-11 15:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (46, 3, 6290, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-06 08:00:00.000000', '2026-07-06 08:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (47, 3, 6435, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-25 12:00:00.000000', '2026-08-25 12:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (48, 3, 4715, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-07 17:00:00.000000', '2026-07-07 17:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (49, 3, 2720, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-17 18:00:00.000000', '2026-09-17 18:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (50, 3, 4750, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-21 16:00:00.000000', '2026-09-21 16:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (51, 3, 1900, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-07 13:00:00.000000', '2026-08-07 13:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (52, 3, 8610, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-15 18:00:00.000000', '2026-08-15 18:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (53, 3, 2100, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-05 13:00:00.000000', '2026-07-05 13:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (54, 3, 9660, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-27 13:00:00.000000', '2026-08-27 13:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (55, 3, 3885, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-28 08:00:00.000000', '2026-08-28 08:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (56, 3, 8360, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-31 17:00:00.000000', '2026-07-31 17:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (57, 3, 9225, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-06 18:00:00.000000', '2026-08-06 18:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (58, 3, 3150, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-25 11:00:00.000000', '2026-07-25 11:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (59, 3, 3990, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-24 09:00:00.000000', '2026-07-24 09:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (60, 3, 4560, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-03 15:00:00.000000', '2026-08-03 15:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (61, 3, 7410, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-13 08:00:00.000000', '2026-09-13 08:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (62, 3, 1320, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-17 08:00:00.000000', '2026-07-17 08:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (63, 3, 1870, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-14 11:00:00.000000', '2026-09-14 11:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (64, 3, 6475, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-17 09:00:00.000000', '2026-08-17 09:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (65, 3, 5130, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-30 17:00:00.000000', '2026-07-30 17:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (66, 3, 4440, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-09 10:00:00.000000', '2026-08-09 10:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (67, 3, 4920, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-08-31 16:00:00.000000', '2026-08-31 16:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (68, 3, 3570, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-23 08:00:00.000000', '2026-07-23 08:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (69, 3, 5445, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-07-03 15:00:00.000000', '2026-07-03 15:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (70, 3, 6355, 'delivered', '123 Buyer St, Manila', '09189876543', NULL, '2026-09-18 17:00:00.000000', '2026-09-18 17:00:00.000000', 'COD', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (71, 3, 5100, 'delivered', 'Batangas City Central Delivery Hub', '09189876543', NULL, '2026-10-02 10:30:00.000000', '2026-10-14 12:58:14.598886', 'COD', '2026-10-02 10:30:00.000000', NULL, NULL, NULL, NULL, NULL, NULL),
  (72, 3, 11400, 'delivered', 'Batangas City Central Delivery Hub', '09189876543', NULL, '2026-10-04 10:30:00.000000', '2026-10-14 12:58:14.609779', 'COD', '2026-10-04 10:30:00.000000', NULL, NULL, NULL, NULL, NULL, NULL),
  (73, 3, 10500, 'delivered', 'Batangas City Central Delivery Hub', '09189876543', NULL, '2026-10-06 10:30:00.000000', '2026-10-14 12:58:14.612338', 'COD', '2026-10-06 10:30:00.000000', NULL, NULL, NULL, NULL, NULL, NULL),
  (74, 3, 5750, 'delivered', 'Batangas City Central Delivery Hub', '09189876543', NULL, '2026-10-08 10:30:00.000000', '2026-10-14 12:58:14.613465', 'COD', '2026-10-08 10:30:00.000000', NULL, NULL, NULL, NULL, NULL, NULL),
  (75, 3, 5000, 'delivered', 'Batangas City Central Delivery Hub', '09189876543', NULL, '2026-10-10 10:30:00.000000', '2026-10-14 12:58:14.614566', 'COD', '2026-10-10 10:30:00.000000', NULL, NULL, NULL, NULL, NULL, NULL),
  (76, 3, 8550, 'delivered', 'Batangas City Central Delivery Hub', '09189876543', NULL, '2026-10-12 10:30:00.000000', '2026-10-14 12:58:14.615648', 'COD', '2026-10-12 10:30:00.000000', NULL, NULL, NULL, NULL, NULL, NULL),
  (77, 3, 7350, 'delivered', 'Batangas City Central Delivery Hub', '09189876543', NULL, '2026-10-13 10:30:00.000000', '2026-10-14 12:58:14.616703', 'COD', '2026-10-13 10:30:00.000000', NULL, NULL, NULL, NULL, NULL, NULL),
  (78, 3, 3400, 'delivered', 'Batangas City Central Delivery Hub', '09189876543', NULL, '2026-10-14 10:30:00.000000', '2026-10-14 12:58:14.617773', 'COD', '2026-10-14 10:30:00.000000', NULL, NULL, NULL, NULL, NULL, NULL);
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `expenses`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `expenses`;
CREATE TABLE `expenses` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `farm_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `expense_date` DATE NOT NULL,
  `category` VARCHAR(9) NOT NULL DEFAULT 'other',
  `frequency` VARCHAR(8) NOT NULL DEFAULT 'one_time',
  `end_date` DATE DEFAULT NULL,
  `amount` DECIMAL(10, 2) NOT NULL,
  `description` VARCHAR(255) DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_expenses_user_id` (`user_id`),
  KEY `ix_expenses_expense_date` (`expense_date`),
  KEY `ix_expenses_farm_id` (`farm_id`),
  KEY `ix_expenses_category` (`category`),
  CONSTRAINT `fk_expenses_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_expenses_farm_id` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `expenses`
LOCK TABLES `expenses` WRITE;
INSERT INTO `expenses` (`id`, `farm_id`, `user_id`, `expense_date`, `category`, `frequency`, `end_date`, `amount`, `description`, `created_at`, `updated_at`) VALUES
  (1, 1, 2, '2026-07-01', 'feed', 'one_time', NULL, 16337.50, 'Weekly feed supply', '2026-09-29 07:50:21.594096', '2026-09-29 07:50:21.594110'),
  (2, 1, 2, '2026-07-01', 'labor', 'one_time', NULL, 10877.59, 'Farm hand wages', '2026-09-29 07:50:21.594121', '2026-09-29 07:50:21.594128'),
  (3, 1, 2, '2026-07-01', 'utilities', 'one_time', NULL, 5876.59, 'Electricity and water bill', '2026-09-29 07:50:21.594137', '2026-09-29 07:50:21.594144'),
  (4, 1, 2, '2026-07-08', 'feed', 'one_time', NULL, 16253.56, 'Weekly feed supply', '2026-09-29 07:50:21.646968', '2026-09-29 07:50:21.646977'),
  (5, 1, 2, '2026-07-15', 'feed', 'one_time', NULL, 16552.10, 'Weekly feed supply', '2026-09-29 07:50:21.686418', '2026-09-29 07:50:21.686433'),
  (6, 1, 2, '2026-07-16', 'labor', 'one_time', NULL, 10458.24, 'Farm hand wages', '2026-09-29 07:50:21.686443', '2026-09-29 07:50:21.686450'),
  (7, 1, 2, '2026-07-22', 'feed', 'one_time', NULL, 15039.25, 'Weekly feed supply', '2026-09-29 07:50:21.686458', '2026-09-29 07:50:21.686467'),
  (8, 1, 2, '2026-07-29', 'feed', 'one_time', NULL, 18875.15, 'Weekly feed supply', '2026-09-29 07:50:21.686475', '2026-09-29 07:50:21.686482'),
  (9, 1, 2, '2026-07-31', 'labor', 'one_time', NULL, 11549.94, 'Farm hand wages', '2026-09-29 07:50:21.686490', '2026-09-29 07:50:21.686498'),
  (10, 1, 2, '2026-08-01', 'utilities', 'one_time', NULL, 5365.25, 'Electricity and water bill', '2026-09-29 07:50:21.686508', '2026-09-29 07:50:21.686516'),
  (11, 1, 2, '2026-08-05', 'feed', 'one_time', NULL, 15633.59, 'Weekly feed supply', '2026-09-29 07:50:21.686525', '2026-09-29 07:50:21.686532'),
  (12, 1, 2, '2026-08-12', 'feed', 'one_time', NULL, 17772.75, 'Weekly feed supply', '2026-09-29 07:50:21.686540', '2026-09-29 07:50:21.686548'),
  (13, 1, 2, '2026-08-15', 'labor', 'one_time', NULL, 11674.34, 'Farm hand wages', '2026-09-29 07:50:21.686556', '2026-09-29 07:50:21.686562'),
  (14, 1, 2, '2026-08-19', 'feed', 'one_time', NULL, 18883.06, 'Weekly feed supply', '2026-09-29 07:50:21.686571', '2026-09-29 07:50:21.686578'),
  (15, 1, 2, '2026-08-26', 'feed', 'one_time', NULL, 17408.35, 'Weekly feed supply', '2026-09-29 07:50:21.686586', '2026-09-29 07:50:21.686593'),
  (16, 1, 2, '2026-08-30', 'labor', 'one_time', NULL, 10701.57, 'Farm hand wages', '2026-09-29 07:50:21.686602', '2026-09-29 07:50:21.686609'),
  (17, 1, 2, '2026-09-01', 'utilities', 'one_time', NULL, 5099.02, 'Electricity and water bill', '2026-09-29 07:50:21.686618', '2026-09-29 07:50:21.686626'),
  (18, 1, 2, '2026-09-02', 'feed', 'one_time', NULL, 16168.61, 'Weekly feed supply', '2026-09-29 07:50:21.686635', '2026-09-29 07:50:21.686643'),
  (19, 1, 2, '2026-09-09', 'feed', 'one_time', NULL, 16570.67, 'Weekly feed supply', '2026-09-29 07:50:21.686708', '2026-09-29 07:50:21.686730'),
  (20, 1, 2, '2026-09-14', 'labor', 'one_time', NULL, 10535.67, 'Farm hand wages', '2026-09-29 07:50:21.686744', '2026-09-29 07:50:21.686752'),
  (21, 1, 2, '2026-09-16', 'feed', 'one_time', NULL, 16667.56, 'Weekly feed supply', '2026-09-29 07:50:21.686761', '2026-09-29 07:50:21.686769'),
  (22, 1, 2, '2026-09-23', 'feed', 'one_time', NULL, 18514.56, 'Weekly feed supply', '2026-09-29 07:50:21.686778', '2026-09-29 07:50:21.686786'),
  (23, 1, 2, '2026-10-02', 'feed', 'one_time', NULL, 18500, 'Bulk Purchase: 25 sacks Premium Layer Feed (B-Meg)', '2026-10-14 12:58:14.585918', '2026-10-14 12:58:14.585932'),
  (24, 1, 2, '2026-10-05', 'utilities', 'monthly', NULL, 4800, 'Meralco Electricity Bill & Water Pumping', '2026-10-14 12:58:14.585936', '2026-10-14 12:58:14.585940'),
  (25, 1, 2, '2026-10-08', 'labor', 'weekly', NULL, 6500, 'Caretaker and Egg Harvester Wages (Week 1-2)', '2026-10-14 12:58:14.585943', '2026-10-14 12:58:14.585946'),
  (26, 1, 2, '2026-10-10', 'medicine', 'one_time', NULL, 2750, 'Electrolytes, Antibiotics & Disinfectant Solution', '2026-10-14 12:58:14.585949', '2026-10-14 12:58:14.585952'),
  (27, 1, 2, '2026-10-12', 'other', 'one_time', NULL, 1200, 'Cardboard Egg Trays & Shrinkwrap Rolls', '2026-10-14 12:58:14.585955', '2026-10-14 12:58:14.585958'),
  (28, 2, 4, '2026-10-03', 'feed', 'one_time', NULL, 14000, 'Layer Pellets Batch 1', '2026-10-14 12:58:14.585961', '2026-10-14 12:58:14.585964'),
  (29, 2, 4, '2026-10-07', 'labor', 'weekly', NULL, 5000, 'Farm hand weekly wage', '2026-10-14 12:58:14.585967', '2026-10-14 12:58:14.585970');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `feed_records`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `feed_records`;
CREATE TABLE `feed_records` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `farm_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `record_date` DATE NOT NULL,
  `feed_type` VARCHAR(100) NOT NULL,
  `feed_consumed_kg` DECIMAL(8, 2) DEFAULT 0.00,
  `feed_cost` DECIMAL(10, 2) DEFAULT 0.00,
  `notes` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_feed_records_farm_id` (`farm_id`),
  KEY `ix_feed_records_record_date` (`record_date`),
  KEY `ix_feed_records_user_id` (`user_id`),
  CONSTRAINT `fk_feed_records_farm_id` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`),
  CONSTRAINT `fk_feed_records_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `feed_records`
LOCK TABLES `feed_records` WRITE;
INSERT INTO `feed_records` (`id`, `farm_id`, `user_id`, `record_date`, `feed_type`, `feed_consumed_kg`, `feed_cost`, `notes`, `created_at`, `updated_at`) VALUES
  (1, 1, 2, '2026-10-01', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593116', '2026-10-14 12:58:14.593123'),
  (2, 2, 4, '2026-10-01', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593127', '2026-10-14 12:58:14.593130'),
  (3, 1, 2, '2026-10-02', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593133', '2026-10-14 12:58:14.593136'),
  (4, 2, 4, '2026-10-02', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593139', '2026-10-14 12:58:14.593142'),
  (5, 1, 2, '2026-10-03', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593145', '2026-10-14 12:58:14.593148'),
  (6, 2, 4, '2026-10-03', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593151', '2026-10-14 12:58:14.593154'),
  (7, 1, 2, '2026-10-04', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593157', '2026-10-14 12:58:14.593160'),
  (8, 2, 4, '2026-10-04', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593163', '2026-10-14 12:58:14.593166'),
  (9, 1, 2, '2026-10-05', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593169', '2026-10-14 12:58:14.593172'),
  (10, 2, 4, '2026-10-05', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593175', '2026-10-14 12:58:14.593178'),
  (11, 1, 2, '2026-10-06', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593181', '2026-10-14 12:58:14.593184'),
  (12, 2, 4, '2026-10-06', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593187', '2026-10-14 12:58:14.593190'),
  (13, 1, 2, '2026-10-07', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593193', '2026-10-14 12:58:14.593195'),
  (14, 2, 4, '2026-10-07', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593198', '2026-10-14 12:58:14.593201'),
  (15, 1, 2, '2026-10-08', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593205', '2026-10-14 12:58:14.593207'),
  (16, 2, 4, '2026-10-08', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593211', '2026-10-14 12:58:14.593213'),
  (17, 1, 2, '2026-10-09', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593216', '2026-10-14 12:58:14.593219'),
  (18, 2, 4, '2026-10-09', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593222', '2026-10-14 12:58:14.593225'),
  (19, 1, 2, '2026-10-10', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593228', '2026-10-14 12:58:14.593231'),
  (20, 2, 4, '2026-10-10', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593234', '2026-10-14 12:58:14.593237'),
  (21, 1, 2, '2026-10-11', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593240', '2026-10-14 12:58:14.593243'),
  (22, 2, 4, '2026-10-11', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593246', '2026-10-14 12:58:14.593249'),
  (23, 1, 2, '2026-10-12', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593252', '2026-10-14 12:58:14.593255'),
  (24, 2, 4, '2026-10-12', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593258', '2026-10-14 12:58:14.593261'),
  (25, 1, 2, '2026-10-13', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593264', '2026-10-14 12:58:14.593267'),
  (26, 2, 4, '2026-10-13', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593270', '2026-10-14 12:58:14.593273'),
  (27, 1, 2, '2026-10-14', 'Layer Mash Boost Premium', 98.50, 2955, 'Regular feeding schedule', '2026-10-14 12:58:14.593276', '2026-10-14 12:58:14.593278'),
  (28, 2, 4, '2026-10-14', 'Commercial Layer Pellet', 75, 2250, 'Morning ration', '2026-10-14 12:58:14.593281', '2026-10-14 12:58:14.593284');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `flock_history`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `flock_history`;
CREATE TABLE `flock_history` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `farm_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `date` DATE NOT NULL,
  `change_type` VARCHAR(50) NOT NULL,
  `quantity` INT(11) NOT NULL,
  `notes` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_flock_history_farm_id` (`farm_id`),
  KEY `ix_flock_history_date` (`date`),
  KEY `ix_flock_history_user_id` (`user_id`),
  CONSTRAINT `fk_flock_history_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_flock_history_farm_id` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `flock_history`
LOCK TABLES `flock_history` WRITE;
INSERT INTO `flock_history` (`id`, `farm_id`, `user_id`, `date`, `change_type`, `quantity`, `notes`, `created_at`) VALUES
  (1, 1, 2, '2026-07-01', 'initial', 5000, 'Initial batch of layer hens.', '2026-09-29 07:50:21.536747'),
  (2, 1, 2, '2026-07-01', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.621393'),
  (3, 1, 2, '2026-07-01', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.632591'),
  (4, 1, 2, '2026-07-02', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.632604'),
  (5, 1, 2, '2026-07-03', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.637642'),
  (6, 1, 2, '2026-07-04', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.640683'),
  (7, 1, 2, '2026-07-04', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.640688'),
  (8, 1, 2, '2026-07-05', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.640692'),
  (9, 1, 2, '2026-07-05', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.647535'),
  (10, 1, 2, '2026-07-08', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694480'),
  (11, 1, 2, '2026-07-08', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694491'),
  (12, 1, 2, '2026-07-11', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694496'),
  (13, 1, 2, '2026-07-12', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694500'),
  (14, 1, 2, '2026-07-12', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694505'),
  (15, 1, 2, '2026-07-13', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694509'),
  (16, 1, 2, '2026-07-14', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694513'),
  (17, 1, 2, '2026-07-14', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694518'),
  (18, 1, 2, '2026-07-15', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694522'),
  (19, 1, 2, '2026-07-15', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694527'),
  (20, 1, 2, '2026-07-16', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694531'),
  (21, 1, 2, '2026-07-16', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694535'),
  (22, 1, 2, '2026-07-17', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694540'),
  (23, 1, 2, '2026-07-17', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694544'),
  (24, 1, 2, '2026-07-18', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694549'),
  (25, 1, 2, '2026-07-18', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694553'),
  (26, 1, 2, '2026-07-19', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694557'),
  (27, 1, 2, '2026-07-19', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694562'),
  (28, 1, 2, '2026-07-20', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694566'),
  (29, 1, 2, '2026-07-20', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694570'),
  (30, 1, 2, '2026-07-21', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694575'),
  (31, 1, 2, '2026-07-22', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694579'),
  (32, 1, 2, '2026-07-24', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694583'),
  (33, 1, 2, '2026-07-25', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694588'),
  (34, 1, 2, '2026-07-25', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694592'),
  (35, 1, 2, '2026-07-26', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694596'),
  (36, 1, 2, '2026-07-26', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694601'),
  (37, 1, 2, '2026-07-27', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694605'),
  (38, 1, 2, '2026-07-28', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694610'),
  (39, 1, 2, '2026-07-28', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694614'),
  (40, 1, 2, '2026-07-30', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694618'),
  (41, 1, 2, '2026-07-30', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694623'),
  (42, 1, 2, '2026-08-01', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694627'),
  (43, 1, 2, '2026-08-02', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694631'),
  (44, 1, 2, '2026-08-03', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694636'),
  (45, 1, 2, '2026-08-03', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694640'),
  (46, 1, 2, '2026-08-04', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694645'),
  (47, 1, 2, '2026-08-05', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694649'),
  (48, 1, 2, '2026-08-06', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694653'),
  (49, 1, 2, '2026-08-07', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694658'),
  (50, 1, 2, '2026-08-07', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694662'),
  (51, 1, 2, '2026-08-09', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694670'),
  (52, 1, 2, '2026-08-10', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694678'),
  (53, 1, 2, '2026-08-10', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694685'),
  (54, 1, 2, '2026-08-11', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694693'),
  (55, 1, 2, '2026-08-11', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694702'),
  (56, 1, 2, '2026-08-12', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694709'),
  (57, 1, 2, '2026-08-12', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694716'),
  (58, 1, 2, '2026-08-13', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694720'),
  (59, 1, 2, '2026-08-14', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694725'),
  (60, 1, 2, '2026-08-14', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694729'),
  (61, 1, 2, '2026-08-15', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694734'),
  (62, 1, 2, '2026-08-15', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694738'),
  (63, 1, 2, '2026-08-16', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694743'),
  (64, 1, 2, '2026-08-16', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694747'),
  (65, 1, 2, '2026-08-17', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694751'),
  (66, 1, 2, '2026-08-17', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694755'),
  (67, 1, 2, '2026-08-18', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694760'),
  (68, 1, 2, '2026-08-18', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694764'),
  (69, 1, 2, '2026-08-19', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694769'),
  (70, 1, 2, '2026-08-20', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694774'),
  (71, 1, 2, '2026-08-21', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694778'),
  (72, 1, 2, '2026-08-22', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694782'),
  (73, 1, 2, '2026-08-22', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694793'),
  (74, 1, 2, '2026-08-23', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694798'),
  (75, 1, 2, '2026-08-25', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694802'),
  (76, 1, 2, '2026-08-25', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694807'),
  (77, 1, 2, '2026-08-26', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694811'),
  (78, 1, 2, '2026-08-27', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694815'),
  (79, 1, 2, '2026-08-28', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694820'),
  (80, 1, 2, '2026-08-28', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694824'),
  (81, 1, 2, '2026-08-29', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694829'),
  (82, 1, 2, '2026-08-29', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694833'),
  (83, 1, 2, '2026-08-30', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694837'),
  (84, 1, 2, '2026-08-30', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694842'),
  (85, 1, 2, '2026-08-31', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694846'),
  (86, 1, 2, '2026-09-01', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694850'),
  (87, 1, 2, '2026-09-03', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694855'),
  (88, 1, 2, '2026-09-03', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694859'),
  (89, 1, 2, '2026-09-04', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694863'),
  (90, 1, 2, '2026-09-06', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694868'),
  (91, 1, 2, '2026-09-07', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694872'),
  (92, 1, 2, '2026-09-08', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694876'),
  (93, 1, 2, '2026-09-08', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694881'),
  (94, 1, 2, '2026-09-09', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694885'),
  (95, 1, 2, '2026-09-10', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694891'),
  (96, 1, 2, '2026-09-11', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694898'),
  (97, 1, 2, '2026-09-12', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694906'),
  (98, 1, 2, '2026-09-13', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694914'),
  (99, 1, 2, '2026-09-13', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694921'),
  (100, 1, 2, '2026-09-14', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694928'),
  (101, 1, 2, '2026-09-14', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694935'),
  (102, 1, 2, '2026-09-15', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694942'),
  (103, 1, 2, '2026-09-16', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694950'),
  (104, 1, 2, '2026-09-17', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694958'),
  (105, 1, 2, '2026-09-18', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694966'),
  (106, 1, 2, '2026-09-18', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.694974'),
  (107, 1, 2, '2026-09-19', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694982'),
  (108, 1, 2, '2026-09-20', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694987'),
  (109, 1, 2, '2026-09-21', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694992'),
  (110, 1, 2, '2026-09-22', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.694997'),
  (111, 1, 2, '2026-09-23', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.695001'),
  (112, 1, 2, '2026-09-23', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.695005'),
  (113, 1, 2, '2026-09-24', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.695010'),
  (114, 1, 2, '2026-09-25', 'mortality', -2, 'Daily mortality.', '2026-09-29 07:50:21.695014'),
  (115, 1, 2, '2026-09-25', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.695018'),
  (116, 1, 2, '2026-09-26', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.695023'),
  (117, 1, 2, '2026-09-27', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.695027'),
  (118, 1, 2, '2026-09-28', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.695031'),
  (119, 1, 2, '2026-09-28', 'mortality', -1, 'Daily mortality.', '2026-09-29 07:50:21.695036');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `messages`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `conversation_id` INT(11) NOT NULL,
  `sender_id` INT(11) NOT NULL,
  `receiver_id` INT(11) NOT NULL,
  `body` TEXT NOT NULL,
  `sent_at` DATETIME NOT NULL,
  `delivered_at` DATETIME DEFAULT NULL,
  `seen_at` DATETIME DEFAULT NULL,
  `is_seen` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `ix_messages_conversation_id` (`conversation_id`),
  KEY `ix_messages_is_seen` (`is_seen`),
  KEY `ix_messages_sender_id` (`sender_id`),
  KEY `ix_messages_sent_at` (`sent_at`),
  KEY `ix_messages_receiver_id` (`receiver_id`),
  CONSTRAINT `fk_messages_receiver_id` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_messages_sender_id` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_messages_conversation_id` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `messages`
LOCK TABLES `messages` WRITE;
INSERT INTO `messages` (`id`, `conversation_id`, `sender_id`, `receiver_id`, `body`, `sent_at`, `delivered_at`, `seen_at`, `is_seen`) VALUES
  (1, 1, 3, 2, 'hello', '2026-10-07 10:09:26.977061', '2026-10-07 10:09:26.966902', '2026-10-07 10:14:47.896611', 1),
  (2, 1, 3, 2, 'hello again', '2026-10-07 10:13:49.309479', '2026-10-07 10:13:49.303756', '2026-10-07 10:14:47.896611', 1),
  (3, 1, 3, 2, 'hi', '2026-10-07 10:13:56.868165', '2026-10-07 10:13:56.863656', '2026-10-07 10:14:47.896611', 1),
  (4, 1, 2, 3, 'hello why', '2026-10-07 10:15:06.421250', '2026-10-07 10:15:06.415494', NULL, 0),
  (5, 1, 2, 3, 'hey', '2026-10-07 10:16:59.759580', '2026-10-07 10:16:59.754105', NULL, 0),
  (6, 1, 2, 3, 'hi', '2026-10-07 10:23:08.038045', '2026-10-07 10:23:08.032546', NULL, 0),
  (7, 1, 2, 3, 'Testing message sending from browser agent', '2026-10-07 10:28:34.488873', '2026-10-07 10:28:34.419820', NULL, 0),
  (8, 1, 2, 3, 'Testing via JavaScript trigger', '2026-10-07 10:30:08.678672', '2026-10-07 10:30:08.662098', NULL, 0),
  (9, 1, 2, 3, 'Testing via JavaScript trigger', '2026-10-07 10:32:02.360922', '2026-10-07 10:32:02.356996', NULL, 0),
  (10, 1, 2, 3, 'hello', '2026-10-07 10:36:23.046624', '2026-10-07 10:36:23.042112', NULL, 0);
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `mortality_records`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `mortality_records`;
CREATE TABLE `mortality_records` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `farm_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `record_date` DATE NOT NULL,
  `quantity_died` INT(11) NOT NULL DEFAULT 0,
  `reason` VARCHAR(255) NOT NULL,
  `notes` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_mortality_records_record_date` (`record_date`),
  KEY `ix_mortality_records_user_id` (`user_id`),
  KEY `ix_mortality_records_farm_id` (`farm_id`),
  CONSTRAINT `fk_mortality_records_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_mortality_records_farm_id` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `mortality_records`
LOCK TABLES `mortality_records` WRITE;
INSERT INTO `mortality_records` (`id`, `farm_id`, `user_id`, `record_date`, `quantity_died`, `reason`, `notes`, `created_at`, `updated_at`) VALUES
  (1, 2, 3, '2026-08-18', 5, 'Heat stress', NULL, '2026-08-18 12:58:52.095133', '2026-08-18 12:58:52.095144'),
  (2, 5, 1, '2026-08-18', 1, '1', NULL, '2026-08-18 15:34:37.035946', '2026-08-18 15:34:37.035953'),
  (3, 4, 1, '2026-08-18', 1, '21', NULL, '2026-08-18 15:34:50.906191', '2026-08-18 15:34:50.906200'),
  (4, 1, 2, '2026-10-03', 2, 'Heat stress during midday peak', 'Hydration vitamins administered', '2026-10-14 12:58:14.596633', '2026-10-14 12:58:14.596639'),
  (5, 1, 2, '2026-10-08', 1, 'Natural age culling', 'Flock check normal', '2026-10-14 12:58:14.596642', '2026-10-14 12:58:14.596645'),
  (6, 1, 2, '2026-10-12', 2, 'Respiratory isolation check', 'Coop sanitized', '2026-10-14 12:58:14.596649', '2026-10-14 12:58:14.596651'),
  (7, 2, 4, '2026-10-05', 1, 'Injury from coop wire', 'Repaired mesh', '2026-10-14 12:58:14.596654', '2026-10-14 12:58:14.596657');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `production_records`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `production_records`;
CREATE TABLE `production_records` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `farm_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `record_date` DATE NOT NULL,
  `egg_count` INT(11) NOT NULL DEFAULT 0,
  `size` VARCHAR(11) DEFAULT NULL,
  `variety` VARCHAR(5) DEFAULT NULL,
  `feed_kg` DECIMAL(8, 2) DEFAULT 0.00,
  `feed_cost` DECIMAL(10, 2) DEFAULT 0.00,
  `egg_price` DECIMAL(10, 2) DEFAULT NULL,
  `mortality` INT(11) DEFAULT 0,
  `notes` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_farm_record_date_size_variety` (`farm_id`, `record_date`, `size`, `variety`),
  KEY `ix_production_records_record_date` (`record_date`),
  KEY `ix_production_records_user_id` (`user_id`),
  KEY `ix_production_records_farm_id` (`farm_id`),
  CONSTRAINT `fk_production_records_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_production_records_farm_id` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=223 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `production_records`
LOCK TABLES `production_records` WRITE;
INSERT INTO `production_records` (`id`, `farm_id`, `user_id`, `record_date`, `egg_count`, `size`, `variety`, `feed_kg`, `feed_cost`, `egg_price`, `mortality`, `notes`, `created_at`, `updated_at`) VALUES
  (1, 1, 2, '2026-07-01', 1863, 'large', 'brown', 297.67, 1102.08, 7, 2, NULL, '2026-09-29 07:50:21.625350', '2026-09-29 07:50:21.625370'),
  (2, 1, 2, '2026-07-01', 1697, 'medium', 'white', 253.63, 1055.98, 6.17, 1, NULL, '2026-09-29 07:50:21.634484', '2026-09-29 07:50:21.634491'),
  (3, 1, 2, '2026-07-02', 2137, 'large', 'brown', 296.86, 1036.35, 7, 1, NULL, '2026-09-29 07:50:21.634495', '2026-09-29 07:50:21.634499'),
  (4, 1, 2, '2026-07-02', 1806, 'medium', 'white', 274.61, 1040.82, 6.17, 0, NULL, '2026-09-29 07:50:21.634502', '2026-09-29 07:50:21.634506'),
  (5, 1, 2, '2026-07-03', 1658, 'medium', 'brown', 275.07, 1020.22, 6.33, 1, NULL, '2026-09-29 07:50:21.637993', '2026-09-29 07:50:21.637998'),
  (6, 1, 2, '2026-07-03', 2010, 'large', 'brown', 265.71, 1236.65, 7, 0, NULL, '2026-09-29 07:50:21.638002', '2026-09-29 07:50:21.638005'),
  (7, 1, 2, '2026-07-04', 1896, 'small', 'white', 293.55, 1089.02, 5.50, 2, NULL, '2026-09-29 07:50:21.641423', '2026-09-29 07:50:21.641431'),
  (8, 1, 2, '2026-07-04', 1712, 'medium', 'brown', 253.72, 1002.54, 6.33, 2, NULL, '2026-09-29 07:50:21.641438', '2026-09-29 07:50:21.641443'),
  (9, 1, 2, '2026-07-05', 1619, 'medium', 'brown', 250.58, 1163.01, 6.33, 1, NULL, '2026-09-29 07:50:21.641448', '2026-09-29 07:50:21.641453'),
  (10, 1, 2, '2026-07-05', 2119, 'small', 'brown', 297.73, 1142.54, 5.67, 2, NULL, '2026-09-29 07:50:21.648205', '2026-09-29 07:50:21.648214'),
  (11, 1, 2, '2026-07-06', 2073, 'small', 'brown', 291.83, 1162.97, 5.67, 0, NULL, '2026-09-29 07:50:21.648220', '2026-09-29 07:50:21.648226'),
  (12, 1, 2, '2026-07-06', 2137, 'small', 'white', 264.61, 1108.98, 5.50, 0, NULL, '2026-09-29 07:50:21.648232', '2026-09-29 07:50:21.648238'),
  (13, 1, 2, '2026-07-07', 1729, 'medium', 'brown', 276.61, 1236.95, 6.33, 0, NULL, '2026-09-29 07:50:21.648244', '2026-09-29 07:50:21.648249'),
  (14, 1, 2, '2026-07-07', 1806, 'small', 'white', 270.66, 1089.65, 5.50, 0, NULL, '2026-09-29 07:50:21.648255', '2026-09-29 07:50:21.648261'),
  (15, 1, 2, '2026-07-08', 2475, 'large', 'white', 275.39, 1067.64, 6.83, 1, NULL, '2026-09-29 07:50:21.707305', '2026-09-29 07:50:21.707315'),
  (16, 1, 2, '2026-07-08', 2035, 'medium', 'white', 298.89, 1059.13, 6.17, 2, NULL, '2026-09-29 07:50:21.707321', '2026-09-29 07:50:21.707325'),
  (17, 1, 2, '2026-07-09', 1641, 'small', 'white', 269.73, 1173.46, 5.50, 0, NULL, '2026-09-29 07:50:21.707330', '2026-09-29 07:50:21.707334'),
  (18, 1, 2, '2026-07-09', 2253, 'large', 'brown', 284.47, 1082.32, 7, 0, NULL, '2026-09-29 07:50:21.707339', '2026-09-29 07:50:21.707343'),
  (19, 1, 2, '2026-07-10', 1624, 'large', 'brown', 270.51, 1236.00, 7, 0, NULL, '2026-09-29 07:50:21.707347', '2026-09-29 07:50:21.707352'),
  (20, 1, 2, '2026-07-10', 1916, 'large', 'white', 258.02, 1098.45, 6.83, 0, NULL, '2026-09-29 07:50:21.707356', '2026-09-29 07:50:21.707361'),
  (21, 1, 2, '2026-07-11', 1809, 'large', 'white', 290.85, 1024.94, 6.83, 0, NULL, '2026-09-29 07:50:21.707365', '2026-09-29 07:50:21.707369'),
  (22, 1, 2, '2026-07-11', 1770, 'medium', 'white', 277.78, 1063.15, 6.17, 2, NULL, '2026-09-29 07:50:21.707373', '2026-09-29 07:50:21.707378'),
  (23, 1, 2, '2026-07-12', 1877, 'large', 'white', 261.58, 1148.05, 6.83, 2, NULL, '2026-09-29 07:50:21.707382', '2026-09-29 07:50:21.707386'),
  (24, 1, 2, '2026-07-12', 2155, 'large', 'brown', 277.08, 1197.02, 7, 2, NULL, '2026-09-29 07:50:21.707391', '2026-09-29 07:50:21.707395'),
  (25, 1, 2, '2026-07-13', 2362, 'large', 'white', 273.17, 1092.89, 6.83, 0, NULL, '2026-09-29 07:50:21.707399', '2026-09-29 07:50:21.707403'),
  (26, 1, 2, '2026-07-13', 1575, 'medium', 'brown', 297.63, 1088.59, 6.33, 1, NULL, '2026-09-29 07:50:21.707408', '2026-09-29 07:50:21.707412'),
  (27, 1, 2, '2026-07-14', 1911, 'large', 'brown', 262.39, 1113.16, 7, 1, NULL, '2026-09-29 07:50:21.707416', '2026-09-29 07:50:21.707421'),
  (28, 1, 2, '2026-07-14', 2201, 'small', 'white', 261.55, 1218.56, 5.50, 1, NULL, '2026-09-29 07:50:21.707425', '2026-09-29 07:50:21.707429'),
  (29, 1, 2, '2026-07-15', 2124, 'small', 'white', 287.67, 1210.50, 5.50, 1, NULL, '2026-09-29 07:50:21.707434', '2026-09-29 07:50:21.707438'),
  (30, 1, 2, '2026-07-15', 1932, 'large', 'white', 294.65, 1046.94, 6.83, 2, NULL, '2026-09-29 07:50:21.707442', '2026-09-29 07:50:21.707446'),
  (31, 1, 2, '2026-07-16', 1784, 'large', 'white', 251.70, 1069.44, 6.83, 1, NULL, '2026-09-29 07:50:21.707451', '2026-09-29 07:50:21.707455'),
  (32, 1, 2, '2026-07-16', 2306, 'small', 'white', 275.45, 1055.01, 5.50, 1, NULL, '2026-09-29 07:50:21.707459', '2026-09-29 07:50:21.707463'),
  (33, 1, 2, '2026-07-17', 1719, 'small', 'white', 273.53, 1046.11, 5.50, 1, NULL, '2026-09-29 07:50:21.707468', '2026-09-29 07:50:21.707472'),
  (34, 1, 2, '2026-07-17', 2010, 'medium', 'brown', 250.27, 1129.73, 6.33, 1, NULL, '2026-09-29 07:50:21.707478', '2026-09-29 07:50:21.707483'),
  (35, 1, 2, '2026-07-18', 1513, 'medium', 'brown', 293.44, 1140.27, 6.33, 2, NULL, '2026-09-29 07:50:21.707487', '2026-09-29 07:50:21.707491'),
  (36, 1, 2, '2026-07-18', 2007, 'large', 'brown', 286.29, 1106.07, 7, 2, NULL, '2026-09-29 07:50:21.707496', '2026-09-29 07:50:21.707500'),
  (37, 1, 2, '2026-07-19', 2289, 'medium', 'white', 261.01, 1172.02, 6.17, 1, NULL, '2026-09-29 07:50:21.707504', '2026-09-29 07:50:21.707508'),
  (38, 1, 2, '2026-07-19', 2276, 'large', 'white', 292.89, 1151.67, 6.83, 2, NULL, '2026-09-29 07:50:21.707512', '2026-09-29 07:50:21.707517'),
  (39, 1, 2, '2026-07-20', 1807, 'medium', 'white', 269.29, 1183.23, 6.17, 2, NULL, '2026-09-29 07:50:21.707521', '2026-09-29 07:50:21.707525'),
  (40, 1, 2, '2026-07-20', 1573, 'small', 'white', 291.64, 1096.53, 5.50, 2, NULL, '2026-09-29 07:50:21.707532', '2026-09-29 07:50:21.707539'),
  (41, 1, 2, '2026-07-21', 1618, 'medium', 'white', 267.98, 1115.08, 6.17, 0, NULL, '2026-09-29 07:50:21.707548', '2026-09-29 07:50:21.707555'),
  (42, 1, 2, '2026-07-21', 1637, 'small', 'white', 269.97, 1223.35, 5.50, 2, NULL, '2026-09-29 07:50:21.707563', '2026-09-29 07:50:21.707570'),
  (43, 1, 2, '2026-07-22', 1757, 'large', 'brown', 250.71, 1205.92, 7, 0, NULL, '2026-09-29 07:50:21.707578', '2026-09-29 07:50:21.707585'),
  (44, 1, 2, '2026-07-22', 2478, 'medium', 'brown', 295.98, 1170.37, 6.33, 1, NULL, '2026-09-29 07:50:21.707593', '2026-09-29 07:50:21.707602'),
  (45, 1, 2, '2026-07-23', 2003, 'medium', 'brown', 266.68, 1141.09, 6.33, 0, NULL, '2026-09-29 07:50:21.707611', '2026-09-29 07:50:21.707618'),
  (46, 1, 2, '2026-07-23', 1537, 'large', 'brown', 281.75, 1109.03, 7, 0, NULL, '2026-09-29 07:50:21.707625', '2026-09-29 07:50:21.707633'),
  (47, 1, 2, '2026-07-24', 1599, 'small', 'white', 282.44, 1234.17, 5.50, 0, NULL, '2026-09-29 07:50:21.707640', '2026-09-29 07:50:21.707648'),
  (48, 1, 2, '2026-07-24', 2299, 'medium', 'white', 291.89, 1044.05, 6.17, 1, NULL, '2026-09-29 07:50:21.707655', '2026-09-29 07:50:21.707663'),
  (49, 1, 2, '2026-07-25', 2054, 'small', 'brown', 261.96, 1085.23, 5.67, 1, NULL, '2026-09-29 07:50:21.707671', '2026-09-29 07:50:21.707678'),
  (50, 1, 2, '2026-07-25', 1926, 'medium', 'white', 293.62, 1167.39, 6.17, 2, NULL, '2026-09-29 07:50:21.707685', '2026-09-29 07:50:21.707692'),
  (51, 1, 2, '2026-07-26', 1896, 'medium', 'white', 283.54, 1193.85, 6.17, 2, NULL, '2026-09-29 07:50:21.707699', '2026-09-29 07:50:21.707706'),
  (52, 1, 2, '2026-07-26', 2488, 'small', 'brown', 262.07, 1096.17, 5.67, 1, NULL, '2026-09-29 07:50:21.707714', '2026-09-29 07:50:21.707721'),
  (53, 1, 2, '2026-07-27', 1667, 'large', 'brown', 271.63, 1212.06, 7, 1, NULL, '2026-09-29 07:50:21.707729', '2026-09-29 07:50:21.707736'),
  (54, 1, 2, '2026-07-27', 1975, 'medium', 'white', 251.85, 1166.48, 6.17, 0, NULL, '2026-09-29 07:50:21.707744', '2026-09-29 07:50:21.707751'),
  (55, 1, 2, '2026-07-28', 1569, 'large', 'brown', 296.52, 1110.20, 7, 2, NULL, '2026-09-29 07:50:21.707758', '2026-09-29 07:50:21.707765'),
  (56, 1, 2, '2026-07-28', 1736, 'small', 'brown', 298.21, 1053.74, 5.67, 1, NULL, '2026-09-29 07:50:21.707773', '2026-09-29 07:50:21.707780'),
  (57, 1, 2, '2026-07-29', 1964, 'small', 'brown', 253.57, 1182.54, 5.67, 0, NULL, '2026-09-29 07:50:21.707788', '2026-09-29 07:50:21.707794'),
  (58, 1, 2, '2026-07-29', 2073, 'large', 'white', 299.74, 1211.16, 6.83, 0, NULL, '2026-09-29 07:50:21.707801', '2026-09-29 07:50:21.707808'),
  (59, 1, 2, '2026-07-30', 2306, 'medium', 'white', 278.16, 1030.95, 6.17, 2, NULL, '2026-09-29 07:50:21.707815', '2026-09-29 07:50:21.707822'),
  (60, 1, 2, '2026-07-30', 2021, 'small', 'white', 250.77, 1167.71, 5.50, 1, NULL, '2026-09-29 07:50:21.707830', '2026-09-29 07:50:21.707837'),
  (61, 1, 2, '2026-07-31', 2370, 'small', 'brown', 272.29, 1205.05, 5.67, 0, NULL, '2026-09-29 07:50:21.707844', '2026-09-29 07:50:21.707851'),
  (62, 1, 2, '2026-07-31', 1955, 'medium', 'white', 280.64, 1095.71, 6.17, 0, NULL, '2026-09-29 07:50:21.707859', '2026-09-29 07:50:21.707866'),
  (63, 1, 2, '2026-08-01', 1723, 'large', 'brown', 250.33, 1003.74, 7, 0, NULL, '2026-09-29 07:50:21.707873', '2026-09-29 07:50:21.707880'),
  (64, 1, 2, '2026-08-01', 2067, 'medium', 'white', 271.47, 1182.97, 6.17, 2, NULL, '2026-09-29 07:50:21.707888', '2026-09-29 07:50:21.707895'),
  (65, 1, 2, '2026-08-02', 2080, 'small', 'white', 299.95, 1058.03, 5.50, 0, NULL, '2026-09-29 07:50:21.707902', '2026-09-29 07:50:21.707909'),
  (66, 1, 2, '2026-08-02', 2336, 'large', 'brown', 264.14, 1029.30, 7, 2, NULL, '2026-09-29 07:50:21.707917', '2026-09-29 07:50:21.707924'),
  (67, 1, 2, '2026-08-03', 2076, 'medium', 'white', 268.78, 1108.25, 6.17, 1, NULL, '2026-09-29 07:50:21.707931', '2026-09-29 07:50:21.707938'),
  (68, 1, 2, '2026-08-03', 1627, 'medium', 'brown', 280.70, 1145.63, 6.33, 1, NULL, '2026-09-29 07:50:21.707945', '2026-09-29 07:50:21.707952'),
  (69, 1, 2, '2026-08-04', 2085, 'large', 'white', 270.05, 1145.40, 6.83, 1, NULL, '2026-09-29 07:50:21.707959', '2026-09-29 07:50:21.707966'),
  (70, 1, 2, '2026-08-04', 1565, 'medium', 'white', 294.58, 1215.25, 6.17, 0, NULL, '2026-09-29 07:50:21.707975', '2026-09-29 07:50:21.707982'),
  (71, 1, 2, '2026-08-05', 1695, 'medium', 'white', 286.63, 1205.03, 6.17, 2, NULL, '2026-09-29 07:50:21.707990', '2026-09-29 07:50:21.707999'),
  (72, 1, 2, '2026-08-05', 2378, 'large', 'brown', 261.32, 1042.90, 7, 0, NULL, '2026-09-29 07:50:21.708007', '2026-09-29 07:50:21.708014'),
  (73, 1, 2, '2026-08-06', 2375, 'small', 'brown', 283.08, 1000.47, 5.67, 0, NULL, '2026-09-29 07:50:21.708022', '2026-09-29 07:50:21.708029'),
  (74, 1, 2, '2026-08-06', 2290, 'small', 'white', 269.94, 1165.78, 5.50, 2, NULL, '2026-09-29 07:50:21.708037', '2026-09-29 07:50:21.708044'),
  (75, 1, 2, '2026-08-07', 1874, 'small', 'brown', 259.49, 1087.54, 5.67, 2, NULL, '2026-09-29 07:50:21.708052', '2026-09-29 07:50:21.708060'),
  (76, 1, 2, '2026-08-07', 1863, 'large', 'white', 273.80, 1129.52, 6.83, 2, NULL, '2026-09-29 07:50:21.708069', '2026-09-29 07:50:21.708077'),
  (77, 1, 2, '2026-08-08', 1940, 'small', 'brown', 298.35, 1151.42, 5.67, 0, NULL, '2026-09-29 07:50:21.708084', '2026-09-29 07:50:21.708092'),
  (78, 1, 2, '2026-08-08', 2484, 'large', 'brown', 292.59, 1194.06, 7, 0, NULL, '2026-09-29 07:50:21.708100', '2026-09-29 07:50:21.708107'),
  (79, 1, 2, '2026-08-09', 2098, 'medium', 'brown', 253.57, 1040.46, 6.33, 1, NULL, '2026-09-29 07:50:21.708115', '2026-09-29 07:50:21.708123'),
  (80, 1, 2, '2026-08-09', 2411, 'small', 'brown', 285.76, 1086.33, 5.67, 0, NULL, '2026-09-29 07:50:21.708130', '2026-09-29 07:50:21.708138'),
  (81, 1, 2, '2026-08-10', 1997, 'large', 'white', 291.18, 1089.36, 6.83, 1, NULL, '2026-09-29 07:50:21.708146', '2026-09-29 07:50:21.708153'),
  (82, 1, 2, '2026-08-10', 2295, 'large', 'brown', 273.70, 1050.56, 7, 2, NULL, '2026-09-29 07:50:21.708160', '2026-09-29 07:50:21.708165'),
  (83, 1, 2, '2026-08-11', 1846, 'small', 'brown', 280.13, 1241.79, 5.67, 2, NULL, '2026-09-29 07:50:21.708169', '2026-09-29 07:50:21.708173'),
  (84, 1, 2, '2026-08-11', 1520, 'large', 'brown', 255.75, 1185.86, 7, 2, NULL, '2026-09-29 07:50:21.708178', '2026-09-29 07:50:21.708182'),
  (85, 1, 2, '2026-08-12', 1697, 'small', 'brown', 269.67, 1115.76, 5.67, 2, NULL, '2026-09-29 07:50:21.708187', '2026-09-29 07:50:21.708191'),
  (86, 1, 2, '2026-08-12', 1757, 'small', 'white', 271.05, 1135.25, 5.50, 2, NULL, '2026-09-29 07:50:21.708195', '2026-09-29 07:50:21.708200'),
  (87, 1, 2, '2026-08-13', 1958, 'small', 'white', 260.48, 1053.69, 5.50, 2, NULL, '2026-09-29 07:50:21.708204', '2026-09-29 07:50:21.708208'),
  (88, 1, 2, '2026-08-13', 1943, 'large', 'brown', 263.58, 1242.78, 7, 0, NULL, '2026-09-29 07:50:21.708212', '2026-09-29 07:50:21.708217'),
  (89, 1, 2, '2026-08-14', 1528, 'small', 'white', 289.22, 1021.09, 5.50, 2, NULL, '2026-09-29 07:50:21.708221', '2026-09-29 07:50:21.708225'),
  (90, 1, 2, '2026-08-14', 1769, 'medium', 'brown', 285.14, 1095.14, 6.33, 2, NULL, '2026-09-29 07:50:21.708230', '2026-09-29 07:50:21.708234'),
  (91, 1, 2, '2026-08-15', 2201, 'large', 'brown', 278.87, 1181.79, 7, 1, NULL, '2026-09-29 07:50:21.708239', '2026-09-29 07:50:21.708243'),
  (92, 1, 2, '2026-08-15', 1567, 'large', 'white', 280.90, 1182.86, 6.83, 2, NULL, '2026-09-29 07:50:21.708248', '2026-09-29 07:50:21.708252'),
  (93, 1, 2, '2026-08-16', 2228, 'medium', 'brown', 279.64, 1188.16, 6.33, 1, NULL, '2026-09-29 07:50:21.708256', '2026-09-29 07:50:21.708260'),
  (94, 1, 2, '2026-08-16', 1961, 'large', 'brown', 250.99, 1145.36, 7, 1, NULL, '2026-09-29 07:50:21.708265', '2026-09-29 07:50:21.708269'),
  (95, 1, 2, '2026-08-17', 1590, 'medium', 'brown', 262.99, 1100.99, 6.33, 2, NULL, '2026-09-29 07:50:21.708273', '2026-09-29 07:50:21.708278'),
  (96, 1, 2, '2026-08-17', 1840, 'large', 'brown', 259.49, 1201.86, 7, 2, NULL, '2026-09-29 07:50:21.708282', '2026-09-29 07:50:21.708286'),
  (97, 1, 2, '2026-08-18', 1946, 'large', 'brown', 267.81, 1233.97, 7, 2, NULL, '2026-09-29 07:50:21.708291', '2026-09-29 07:50:21.708295'),
  (98, 1, 2, '2026-08-18', 1878, 'small', 'brown', 298.99, 1034.39, 5.67, 1, NULL, '2026-09-29 07:50:21.708299', '2026-09-29 07:50:21.708304'),
  (99, 1, 2, '2026-08-19', 1618, 'large', 'brown', 277.22, 1177.99, 7, 1, NULL, '2026-09-29 07:50:21.708308', '2026-09-29 07:50:21.708312'),
  (100, 1, 2, '2026-08-19', 1900, 'medium', 'brown', 258.49, 1098.24, 6.33, 0, NULL, '2026-09-29 07:50:21.708317', '2026-09-29 07:50:21.708321'),
  (101, 1, 2, '2026-08-20', 2477, 'medium', 'brown', 269.78, 1091.41, 6.33, 1, NULL, '2026-09-29 07:50:21.708325', '2026-09-29 07:50:21.708329'),
  (102, 1, 2, '2026-08-20', 2111, 'small', 'white', 297.29, 1098.02, 5.50, 0, NULL, '2026-09-29 07:50:21.708334', '2026-09-29 07:50:21.708338'),
  (103, 1, 2, '2026-08-21', 1725, 'medium', 'white', 286.86, 1029.56, 6.17, 1, NULL, '2026-09-29 07:50:21.708342', '2026-09-29 07:50:21.708346'),
  (104, 1, 2, '2026-08-21', 2133, 'large', 'white', 262.67, 1142.30, 6.83, 0, NULL, '2026-09-29 07:50:21.708351', '2026-09-29 07:50:21.708355'),
  (105, 1, 2, '2026-08-22', 1520, 'small', 'white', 254.30, 1005.52, 5.50, 2, NULL, '2026-09-29 07:50:21.708359', '2026-09-29 07:50:21.708364'),
  (106, 1, 2, '2026-08-22', 2424, 'large', 'brown', 273.75, 1042.12, 7, 2, NULL, '2026-09-29 07:50:21.708368', '2026-09-29 07:50:21.708372'),
  (107, 1, 2, '2026-08-23', 2001, 'small', 'white', 279.06, 1126.32, 5.50, 2, NULL, '2026-09-29 07:50:21.708377', '2026-09-29 07:50:21.708381'),
  (108, 1, 2, '2026-08-23', 1521, 'large', 'white', 260.01, 1189.68, 6.83, 0, NULL, '2026-09-29 07:50:21.708385', '2026-09-29 07:50:21.708389'),
  (109, 1, 2, '2026-08-24', 2415, 'small', 'white', 293.35, 1192.38, 5.50, 0, NULL, '2026-09-29 07:50:21.708394', '2026-09-29 07:50:21.708398'),
  (110, 1, 2, '2026-08-24', 1996, 'large', 'brown', 261.21, 1140.43, 7, 0, NULL, '2026-09-29 07:50:21.708424', '2026-09-29 07:50:21.708430'),
  (111, 1, 2, '2026-08-25', 2138, 'medium', 'white', 256.65, 1044.63, 6.17, 2, NULL, '2026-09-29 07:50:21.708434', '2026-09-29 07:50:21.708439'),
  (112, 1, 2, '2026-08-25', 2062, 'small', 'brown', 286.98, 1224.70, 5.67, 2, NULL, '2026-09-29 07:50:21.708443', '2026-09-29 07:50:21.708447'),
  (113, 1, 2, '2026-08-26', 1902, 'small', 'white', 297.37, 1037.88, 5.50, 0, NULL, '2026-09-29 07:50:21.708452', '2026-09-29 07:50:21.708456'),
  (114, 1, 2, '2026-08-26', 2181, 'large', 'white', 286.04, 1038.05, 6.83, 2, NULL, '2026-09-29 07:50:21.708460', '2026-09-29 07:50:21.708465'),
  (115, 1, 2, '2026-08-27', 1772, 'large', 'brown', 269.25, 1048.99, 7, 1, NULL, '2026-09-29 07:50:21.708469', '2026-09-29 07:50:21.708473'),
  (116, 1, 2, '2026-08-27', 2474, 'large', 'white', 299.26, 1218.80, 6.83, 0, NULL, '2026-09-29 07:50:21.708478', '2026-09-29 07:50:21.708482'),
  (117, 1, 2, '2026-08-28', 2458, 'medium', 'white', 278.46, 1136.51, 6.17, 2, NULL, '2026-09-29 07:50:21.708486', '2026-09-29 07:50:21.708490'),
  (118, 1, 2, '2026-08-28', 2382, 'large', 'white', 274.12, 1149.84, 6.83, 1, NULL, '2026-09-29 07:50:21.708495', '2026-09-29 07:50:21.708500'),
  (119, 1, 2, '2026-08-29', 1550, 'small', 'brown', 260.55, 1127.42, 5.67, 2, NULL, '2026-09-29 07:50:21.708504', '2026-09-29 07:50:21.708508'),
  (120, 1, 2, '2026-08-29', 1842, 'medium', 'brown', 293.54, 1017.56, 6.33, 2, NULL, '2026-09-29 07:50:21.708513', '2026-09-29 07:50:21.708517'),
  (121, 1, 2, '2026-08-30', 1759, 'large', 'brown', 281.05, 1090.09, 7, 2, NULL, '2026-09-29 07:50:21.708521', '2026-09-29 07:50:21.708525'),
  (122, 1, 2, '2026-08-30', 1621, 'medium', 'brown', 285.23, 1056.57, 6.33, 1, NULL, '2026-09-29 07:50:21.708530', '2026-09-29 07:50:21.708534'),
  (123, 1, 2, '2026-08-31', 1500, 'large', 'brown', 267.88, 1104.17, 7, 1, NULL, '2026-09-29 07:50:21.708539', '2026-09-29 07:50:21.708543'),
  (124, 1, 2, '2026-08-31', 2152, 'medium', 'white', 283.25, 1003.55, 6.17, 0, NULL, '2026-09-29 07:50:21.708547', '2026-09-29 07:50:21.708551'),
  (125, 1, 2, '2026-09-01', 2211, 'large', 'brown', 285.69, 1128.02, 7, 0, NULL, '2026-09-29 07:50:21.708556', '2026-09-29 07:50:21.708560'),
  (126, 1, 2, '2026-09-01', 2107, 'medium', 'white', 295.72, 1224.83, 6.17, 1, NULL, '2026-09-29 07:50:21.708564', '2026-09-29 07:50:21.708568'),
  (127, 1, 2, '2026-09-02', 2109, 'small', 'white', 284.84, 1068.72, 5.50, 0, NULL, '2026-09-29 07:50:21.708573', '2026-09-29 07:50:21.708577'),
  (128, 1, 2, '2026-09-02', 1980, 'medium', 'brown', 253.86, 1224.93, 6.33, 0, NULL, '2026-09-29 07:50:21.708581', '2026-09-29 07:50:21.708586'),
  (129, 1, 2, '2026-09-03', 1521, 'large', 'brown', 262.92, 1167.20, 7, 2, NULL, '2026-09-29 07:50:21.708590', '2026-09-29 07:50:21.708594'),
  (130, 1, 2, '2026-09-03', 1568, 'small', 'white', 252.67, 1037.55, 5.50, 2, NULL, '2026-09-29 07:50:21.708599', '2026-09-29 07:50:21.708603'),
  (131, 1, 2, '2026-09-04', 2338, 'small', 'white', 280.97, 1238.19, 5.50, 0, NULL, '2026-09-29 07:50:21.708607', '2026-09-29 07:50:21.708611'),
  (132, 1, 2, '2026-09-04', 1885, 'medium', 'white', 262.45, 1015.44, 6.17, 2, NULL, '2026-09-29 07:50:21.708616', '2026-09-29 07:50:21.708620'),
  (133, 1, 2, '2026-09-05', 2050, 'medium', 'brown', 279.64, 1238.55, 6.33, 0, NULL, '2026-09-29 07:50:21.708624', '2026-09-29 07:50:21.708628'),
  (134, 1, 2, '2026-09-05', 2262, 'medium', 'white', 287.22, 1052.12, 6.17, 0, NULL, '2026-09-29 07:50:21.708633', '2026-09-29 07:50:21.708637'),
  (135, 1, 2, '2026-09-06', 1949, 'medium', 'white', 287.50, 1230.31, 6.17, 0, NULL, '2026-09-29 07:50:21.708641', '2026-09-29 07:50:21.708646'),
  (136, 1, 2, '2026-09-06', 1568, 'medium', 'brown', 278.74, 1059.74, 6.33, 2, NULL, '2026-09-29 07:50:21.708650', '2026-09-29 07:50:21.708654'),
  (137, 1, 2, '2026-09-07', 2009, 'large', 'brown', 262.53, 1170.15, 7, 1, NULL, '2026-09-29 07:50:21.708659', '2026-09-29 07:50:21.708663'),
  (138, 1, 2, '2026-09-07', 2283, 'medium', 'brown', 297.16, 1062.74, 6.33, 0, NULL, '2026-09-29 07:50:21.708668', '2026-09-29 07:50:21.708672'),
  (139, 1, 2, '2026-09-08', 1716, 'large', 'white', 250.57, 1247.64, 6.83, 2, NULL, '2026-09-29 07:50:21.708676', '2026-09-29 07:50:21.708681'),
  (140, 1, 2, '2026-09-08', 2251, 'medium', 'brown', 275.69, 1162.18, 6.33, 2, NULL, '2026-09-29 07:50:21.708685', '2026-09-29 07:50:21.708689'),
  (141, 1, 2, '2026-09-09', 2320, 'medium', 'brown', 284.94, 1166.91, 6.33, 2, NULL, '2026-09-29 07:50:21.708694', '2026-09-29 07:50:21.708698'),
  (142, 1, 2, '2026-09-09', 2377, 'large', 'brown', 268.73, 1022.13, 7, 0, NULL, '2026-09-29 07:50:21.708702', '2026-09-29 07:50:21.708706'),
  (143, 1, 2, '2026-09-10', 2424, 'small', 'brown', 289.72, 1025.03, 5.67, 2, NULL, '2026-09-29 07:50:21.708711', '2026-09-29 07:50:21.708715'),
  (144, 1, 2, '2026-09-10', 2165, 'large', 'brown', 274.06, 1169.42, 7, 0, NULL, '2026-09-29 07:50:21.708719', '2026-09-29 07:50:21.708724'),
  (145, 1, 2, '2026-09-11', 2289, 'medium', 'white', 276.78, 1104.01, 6.17, 0, NULL, '2026-09-29 07:50:21.708728', '2026-09-29 07:50:21.708732'),
  (146, 1, 2, '2026-09-11', 1506, 'small', 'brown', 263.86, 1173.33, 5.67, 1, NULL, '2026-09-29 07:50:21.708736', '2026-09-29 07:50:21.708741'),
  (147, 1, 2, '2026-09-12', 2423, 'small', 'white', 274.41, 1113.39, 5.50, 0, NULL, '2026-09-29 07:50:21.708745', '2026-09-29 07:50:21.708749'),
  (148, 1, 2, '2026-09-12', 2078, 'medium', 'white', 261.12, 1211.34, 6.17, 2, NULL, '2026-09-29 07:50:21.708754', '2026-09-29 07:50:21.708758'),
  (149, 1, 2, '2026-09-13', 2476, 'medium', 'brown', 271.77, 1235.08, 6.33, 1, NULL, '2026-09-29 07:50:21.708762', '2026-09-29 07:50:21.708766'),
  (150, 1, 2, '2026-09-13', 1569, 'small', 'brown', 285.35, 1008.45, 5.67, 2, NULL, '2026-09-29 07:50:21.708771', '2026-09-29 07:50:21.708775'),
  (151, 1, 2, '2026-09-14', 2064, 'small', 'white', 297.93, 1127.87, 5.50, 1, NULL, '2026-09-29 07:50:21.708780', '2026-09-29 07:50:21.708784'),
  (152, 1, 2, '2026-09-14', 1575, 'small', 'brown', 280.97, 1068.19, 5.67, 2, NULL, '2026-09-29 07:50:21.708788', '2026-09-29 07:50:21.708792'),
  (153, 1, 2, '2026-09-15', 1623, 'medium', 'brown', 257.66, 1239.54, 6.33, 0, NULL, '2026-09-29 07:50:21.708797', '2026-09-29 07:50:21.708801'),
  (154, 1, 2, '2026-09-15', 2438, 'large', 'white', 284.52, 1235.03, 6.83, 1, NULL, '2026-09-29 07:50:21.708805', '2026-09-29 07:50:21.708809'),
  (155, 1, 2, '2026-09-16', 1624, 'large', 'brown', 282.67, 1179.87, 7, 0, NULL, '2026-09-29 07:50:21.708814', '2026-09-29 07:50:21.708818'),
  (156, 1, 2, '2026-09-16', 2345, 'small', 'brown', 262.91, 1210.47, 5.67, 2, NULL, '2026-09-29 07:50:21.708823', '2026-09-29 07:50:21.708827'),
  (157, 1, 2, '2026-09-17', 1699, 'medium', 'white', 263.70, 1198.01, 6.17, 1, NULL, '2026-09-29 07:50:21.708831', '2026-09-29 07:50:21.708835'),
  (158, 1, 2, '2026-09-17', 2029, 'large', 'white', 297.13, 1156.09, 6.83, 0, NULL, '2026-09-29 07:50:21.708840', '2026-09-29 07:50:21.708844'),
  (159, 1, 2, '2026-09-18', 2401, 'medium', 'white', 285.10, 1079.15, 6.17, 1, NULL, '2026-09-29 07:50:21.708848', '2026-09-29 07:50:21.708852'),
  (160, 1, 2, '2026-09-18', 2096, 'large', 'brown', 253.18, 1007.44, 7, 1, NULL, '2026-09-29 07:50:21.708857', '2026-09-29 07:50:21.708861'),
  (161, 1, 2, '2026-09-19', 1520, 'medium', 'brown', 270.55, 1147.28, 6.33, 2, NULL, '2026-09-29 07:50:21.708866', '2026-09-29 07:50:21.708870'),
  (162, 1, 2, '2026-09-19', 1617, 'medium', 'white', 276.28, 1124.96, 6.17, 0, NULL, '2026-09-29 07:50:21.708875', '2026-09-29 07:50:21.708879'),
  (163, 1, 2, '2026-09-20', 1939, 'large', 'brown', 296.48, 1040.30, 7, 0, NULL, '2026-09-29 07:50:21.708883', '2026-09-29 07:50:21.708888'),
  (164, 1, 2, '2026-09-20', 1888, 'large', 'white', 256.90, 1099.15, 6.83, 2, NULL, '2026-09-29 07:50:21.708892', '2026-09-29 07:50:21.708896'),
  (165, 1, 2, '2026-09-21', 1566, 'small', 'white', 269.00, 1182.54, 5.50, 2, NULL, '2026-09-29 07:50:21.708901', '2026-09-29 07:50:21.708905'),
  (166, 1, 2, '2026-09-21', 1679, 'small', 'brown', 268.10, 1193.00, 5.67, 0, NULL, '2026-09-29 07:50:21.708909', '2026-09-29 07:50:21.708913'),
  (167, 1, 2, '2026-09-22', 1657, 'medium', 'brown', 296.71, 1226.64, 6.33, 0, NULL, '2026-09-29 07:50:21.708918', '2026-09-29 07:50:21.708922'),
  (168, 1, 2, '2026-09-22', 1955, 'large', 'white', 260.36, 1191.66, 6.83, 2, NULL, '2026-09-29 07:50:21.708926', '2026-09-29 07:50:21.708930'),
  (169, 1, 2, '2026-09-23', 1554, 'medium', 'brown', 267.92, 1071.44, 6.33, 1, NULL, '2026-09-29 07:50:21.708935', '2026-09-29 07:50:21.708939'),
  (170, 1, 2, '2026-09-23', 2321, 'large', 'brown', 298.59, 1193.06, 7, 2, NULL, '2026-09-29 07:50:21.708944', '2026-09-29 07:50:21.708948'),
  (171, 1, 2, '2026-09-24', 2223, 'large', 'brown', 260.90, 1249.18, 7, 0, NULL, '2026-09-29 07:50:21.708952', '2026-09-29 07:50:21.708956'),
  (172, 1, 2, '2026-09-24', 2003, 'small', 'brown', 257.85, 1105.08, 5.67, 1, NULL, '2026-09-29 07:50:21.708961', '2026-09-29 07:50:21.708965'),
  (173, 1, 2, '2026-09-25', 1669, 'medium', 'white', 287.22, 1222.16, 6.17, 2, NULL, '2026-09-29 07:50:21.708969', '2026-09-29 07:50:21.708974'),
  (174, 1, 2, '2026-09-25', 1873, 'small', 'brown', 296.26, 1080.56, 5.67, 1, NULL, '2026-09-29 07:50:21.708978', '2026-09-29 07:50:21.708982'),
  (175, 1, 2, '2026-09-26', 1967, 'medium', 'brown', 274.59, 1026.51, 6.33, 1, NULL, '2026-09-29 07:50:21.708987', '2026-09-29 07:50:21.708991'),
  (176, 1, 2, '2026-09-26', 2332, 'large', 'white', 295.15, 1197.38, 6.83, 0, NULL, '2026-09-29 07:50:21.708995', '2026-09-29 07:50:21.708999'),
  (177, 1, 2, '2026-09-27', 1618, 'medium', 'white', 255.26, 1051.13, 6.17, 0, NULL, '2026-09-29 07:50:21.709004', '2026-09-29 07:50:21.709008'),
  (178, 1, 2, '2026-09-27', 1839, 'large', 'brown', 272.00, 1135.80, 7, 1, NULL, '2026-09-29 07:50:21.709012', '2026-09-29 07:50:21.709017'),
  (179, 1, 2, '2026-09-28', 2429, 'medium', 'white', 299.57, 1099.47, 6.17, 1, NULL, '2026-09-29 07:50:21.709021', '2026-09-29 07:50:21.709025'),
  (180, 1, 2, '2026-09-28', 2186, 'small', 'brown', 274.63, 1014.28, 5.67, 1, NULL, '2026-09-29 07:50:21.709030', '2026-09-29 07:50:21.709034'),
  (181, 1, 2, '2026-10-01', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.601818', '2026-10-14 12:58:14.601824'),
  (182, 1, 2, '2026-10-01', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.601828', '2026-10-14 12:58:14.601831'),
  (183, 2, 4, '2026-10-01', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.601834', '2026-10-14 12:58:14.601837'),
  (184, 1, 2, '2026-10-02', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.601840', '2026-10-14 12:58:14.601843'),
  (185, 1, 2, '2026-10-02', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.601846', '2026-10-14 12:58:14.601849'),
  (186, 2, 4, '2026-10-02', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.601852', '2026-10-14 12:58:14.601855'),
  (187, 1, 2, '2026-10-03', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.601858', '2026-10-14 12:58:14.601861'),
  (188, 1, 2, '2026-10-03', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.601864', '2026-10-14 12:58:14.601867'),
  (189, 2, 4, '2026-10-03', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.601870', '2026-10-14 12:58:14.601873'),
  (190, 1, 2, '2026-10-04', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.601876', '2026-10-14 12:58:14.601879'),
  (191, 1, 2, '2026-10-04', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.601882', '2026-10-14 12:58:14.601885'),
  (192, 2, 4, '2026-10-04', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.601888', '2026-10-14 12:58:14.601891'),
  (193, 1, 2, '2026-10-05', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.601894', '2026-10-14 12:58:14.601897'),
  (194, 1, 2, '2026-10-05', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.601900', '2026-10-14 12:58:14.601903'),
  (195, 2, 4, '2026-10-05', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.601906', '2026-10-14 12:58:14.601909'),
  (196, 1, 2, '2026-10-06', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.601912', '2026-10-14 12:58:14.601915'),
  (197, 1, 2, '2026-10-06', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.601918', '2026-10-14 12:58:14.601921'),
  (198, 2, 4, '2026-10-06', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.601924', '2026-10-14 12:58:14.601927'),
  (199, 1, 2, '2026-10-07', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.601930', '2026-10-14 12:58:14.601933'),
  (200, 1, 2, '2026-10-07', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.601936', '2026-10-14 12:58:14.601939'),
  (201, 2, 4, '2026-10-07', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.601942', '2026-10-14 12:58:14.601945'),
  (202, 1, 2, '2026-10-08', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.601948', '2026-10-14 12:58:14.601951'),
  (203, 1, 2, '2026-10-08', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.601954', '2026-10-14 12:58:14.601957'),
  (204, 2, 4, '2026-10-08', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.601960', '2026-10-14 12:58:14.601963'),
  (205, 1, 2, '2026-10-09', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.601966', '2026-10-14 12:58:14.601969'),
  (206, 1, 2, '2026-10-09', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.601972', '2026-10-14 12:58:14.601975'),
  (207, 2, 4, '2026-10-09', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.601978', '2026-10-14 12:58:14.601981'),
  (208, 1, 2, '2026-10-10', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.601984', '2026-10-14 12:58:14.601987'),
  (209, 1, 2, '2026-10-10', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.601990', '2026-10-14 12:58:14.601993'),
  (210, 2, 4, '2026-10-10', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.601996', '2026-10-14 12:58:14.601999'),
  (211, 1, 2, '2026-10-11', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.602002', '2026-10-14 12:58:14.602004'),
  (212, 1, 2, '2026-10-11', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.602007', '2026-10-14 12:58:14.602010'),
  (213, 2, 4, '2026-10-11', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.602013', '2026-10-14 12:58:14.602016'),
  (214, 1, 2, '2026-10-12', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.602019', '2026-10-14 12:58:14.602022'),
  (215, 1, 2, '2026-10-12', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.602028', '2026-10-14 12:58:14.602031'),
  (216, 2, 4, '2026-10-12', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.602034', '2026-10-14 12:58:14.602037'),
  (217, 1, 2, '2026-10-13', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.602040', '2026-10-14 12:58:14.602043'),
  (218, 1, 2, '2026-10-13', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.602046', '2026-10-14 12:58:14.602049'),
  (219, 2, 4, '2026-10-13', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.602052', '2026-10-14 12:58:14.602055'),
  (220, 1, 2, '2026-10-14', 850, 'medium', 'brown', 95.50, 2865, 6.50, 1, 'Healthy flock, high laying consistency', '2026-10-14 12:58:14.602058', '2026-10-14 12:58:14.602061'),
  (221, 1, 2, '2026-10-14', 420, 'large', 'brown', 0, 0, 7.20, 0, 'Grade A Large sorted', '2026-10-14 12:58:14.602064', '2026-10-14 12:58:14.602066'),
  (222, 2, 4, '2026-10-14', 650, 'medium', 'white', 72, 2160, 6.20, 0, 'Standard output', '2026-10-14 12:58:14.602069', '2026-10-14 12:58:14.602072');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `products`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `farmer_id` INT(11) NOT NULL,
  `farm_id` INT(11) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `size` VARCHAR(11) NOT NULL DEFAULT 'medium',
  `variety` VARCHAR(5) NOT NULL DEFAULT 'brown',
  `unit` VARCHAR(8) NOT NULL DEFAULT 'piece',
  `price` DECIMAL(10, 2) NOT NULL,
  `stock` INT(11) NOT NULL DEFAULT 0,
  `location` VARCHAR(255) DEFAULT NULL,
  `is_available` TINYINT(1) NOT NULL DEFAULT 1,
  `image_url` VARCHAR(500) DEFAULT NULL,
  `moderation_status` VARCHAR(8) NOT NULL DEFAULT 'pending',
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_products_farmer_id` (`farmer_id`),
  KEY `ix_products_farm_id` (`farm_id`),
  KEY `ix_products_variety` (`variety`),
  KEY `ix_products_is_available` (`is_available`),
  KEY `ix_products_size` (`size`),
  CONSTRAINT `fk_products_farmer_id` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_products_farm_id` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `products`
LOCK TABLES `products` WRITE;
INSERT INTO `products` (`id`, `farmer_id`, `farm_id`, `name`, `description`, `size`, `variety`, `unit`, `price`, `stock`, `location`, `is_available`, `created_at`, `updated_at`, `image_url`, `moderation_status`) VALUES
  (1, 2, 1, 'Fresh Brown Eggs (Small)', 'Freshly harvested small brown eggs.', 'small', 'brown', 'tray', 170, 100, NULL, 1, '2026-09-29 07:50:21.565475', '2026-09-29 07:50:21.565485', NULL, 'pending'),
  (2, 2, 1, 'Fresh Brown Eggs (Medium)', 'Freshly harvested medium brown eggs.', 'medium', 'brown', 'tray', 190, 300, NULL, 1, '2026-09-29 07:50:21.565492', '2026-09-29 07:50:21.565496', NULL, 'pending'),
  (3, 2, 1, 'Fresh Brown Eggs (Large)', 'Freshly harvested large brown eggs.', 'large', 'brown', 'tray', 210, 200, NULL, 1, '2026-09-29 07:50:21.565501', '2026-09-29 07:50:21.565506', NULL, 'pending'),
  (4, 2, 1, 'Fresh White Eggs (Small)', 'Freshly harvested small white eggs.', 'small', 'white', 'tray', 165, 120, NULL, 1, '2026-09-29 07:50:21.565511', '2026-09-29 07:50:21.565515', NULL, 'pending'),
  (5, 2, 1, 'Fresh White Eggs (Medium)', 'Freshly harvested medium white eggs.', 'medium', 'white', 'tray', 185, 250, NULL, 1, '2026-09-29 07:50:21.565520', '2026-09-29 07:50:21.565525', NULL, 'pending'),
  (6, 2, 1, 'Fresh White Eggs (Large)', 'Freshly harvested large white eggs.', 'large', 'white', 'tray', 205, 180, NULL, 1, '2026-09-29 07:50:21.565531', '2026-09-29 07:50:21.565538', NULL, 'pending'),
  (7, 2, 1, 'Fresh Brown Eggs (Extra Large)', NULL, 'extra_large', 'brown', 'tray', 230, 80, 'Sunshine Farm', 1, '2026-10-14 12:56:47.913152', '2026-10-14 12:56:47.913169', NULL, 'pending'),
  (8, 2, 1, 'Fresh Brown Eggs (Jumbo)', NULL, 'jumbo', 'brown', 'tray', 250, 50, 'Sunshine Farm', 1, '2026-10-14 12:56:47.913174', '2026-10-14 12:56:47.913177', NULL, 'pending');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `sales_records`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `sales_records`;
CREATE TABLE `sales_records` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `farm_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `sale_date` DATE NOT NULL,
  `quantity_sold` INT(11) NOT NULL,
  `price_per_egg` DECIMAL(10, 2) NOT NULL,
  `total_revenue` DECIMAL(12, 2) NOT NULL,
  `buyer_name` VARCHAR(255) DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_sales_records_user_id` (`user_id`),
  KEY `ix_sales_records_farm_id` (`farm_id`),
  KEY `ix_sales_records_sale_date` (`sale_date`),
  CONSTRAINT `fk_sales_records_farm_id` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`),
  CONSTRAINT `fk_sales_records_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `sales_records`
LOCK TABLES `sales_records` WRITE;
INSERT INTO `sales_records` (`id`, `farm_id`, `user_id`, `sale_date`, `quantity_sold`, `price_per_egg`, `total_revenue`, `buyer_name`, `notes`, `created_at`, `updated_at`) VALUES
  (1, 1, 2, '2026-07-12', 600, 5.67, 3400, 'Maria Reyes', NULL, '2026-07-12 15:00:00.000000', '2026-09-29 07:50:21.734197'),
  (2, 1, 2, '2026-07-08', 750, 6.33, 4750, 'Maria Reyes', NULL, '2026-07-08 13:00:00.000000', '2026-09-29 07:50:21.740814'),
  (3, 1, 2, '2026-08-09', 1080, 5.50, 5940, 'Maria Reyes', NULL, '2026-08-09 09:00:00.000000', '2026-09-29 07:50:21.744477'),
  (4, 1, 2, '2026-08-08', 300, 6.83, 2050, 'Maria Reyes', NULL, '2026-08-08 09:00:00.000000', '2026-09-29 07:50:21.747973'),
  (5, 1, 2, '2026-07-18', 1260, 5.67, 7140, 'Maria Reyes', NULL, '2026-07-18 17:00:00.000000', '2026-09-29 07:50:21.750868'),
  (6, 1, 2, '2026-07-18', 1080, 5.50, 5940, 'Maria Reyes', NULL, '2026-07-18 08:00:00.000000', '2026-09-29 07:50:21.753251'),
  (7, 1, 2, '2026-07-05', 1050, 6.83, 7175, 'Maria Reyes', NULL, '2026-07-05 16:00:00.000000', '2026-09-29 07:50:21.755487'),
  (8, 1, 2, '2026-07-04', 390, 5.67, 2210, 'Maria Reyes', NULL, '2026-07-04 10:00:00.000000', '2026-09-29 07:50:21.757944'),
  (9, 1, 2, '2026-08-01', 1290, 6.17, 7955, 'Maria Reyes', NULL, '2026-08-01 12:00:00.000000', '2026-09-29 07:50:21.761083'),
  (10, 1, 2, '2026-07-23', 600, 5.67, 3400, 'Maria Reyes', NULL, '2026-07-23 18:00:00.000000', '2026-09-29 07:50:21.764390'),
  (11, 1, 2, '2026-08-13', 810, 6.33, 5130, 'Maria Reyes', NULL, '2026-08-13 09:00:00.000000', '2026-09-29 07:50:21.767920'),
  (12, 1, 2, '2026-09-22', 780, 6.33, 4940, 'Maria Reyes', NULL, '2026-09-22 17:00:00.000000', '2026-09-29 07:50:21.771238'),
  (13, 1, 2, '2026-07-31', 150, 5.50, 825, 'Maria Reyes', NULL, '2026-07-31 13:00:00.000000', '2026-09-29 07:50:21.774272'),
  (14, 1, 2, '2026-07-20', 150, 5.67, 850, 'Maria Reyes', NULL, '2026-07-20 15:00:00.000000', '2026-09-29 07:50:21.777730'),
  (15, 1, 2, '2026-07-02', 450, 6.83, 3075, 'Maria Reyes', NULL, '2026-07-02 09:00:00.000000', '2026-09-29 07:50:21.780852'),
  (16, 1, 2, '2026-07-25', 990, 6.17, 6105, 'Maria Reyes', NULL, '2026-07-25 14:00:00.000000', '2026-09-29 07:50:21.784180'),
  (17, 1, 2, '2026-09-16', 420, 7, 2940, 'Maria Reyes', NULL, '2026-09-16 08:00:00.000000', '2026-09-29 07:50:21.787408'),
  (18, 1, 2, '2026-07-16', 780, 6.17, 4810, 'Maria Reyes', NULL, '2026-07-16 17:00:00.000000', '2026-09-29 07:50:21.790667'),
  (19, 1, 2, '2026-09-17', 1200, 5.50, 6600, 'Maria Reyes', NULL, '2026-09-17 17:00:00.000000', '2026-09-29 07:50:21.794639'),
  (20, 1, 2, '2026-09-13', 840, 5.67, 4760, 'Maria Reyes', NULL, '2026-09-13 11:00:00.000000', '2026-09-29 07:50:21.797777'),
  (21, 1, 2, '2026-07-31', 630, 6.17, 3885, 'Maria Reyes', NULL, '2026-07-31 09:00:00.000000', '2026-09-29 07:50:21.800997'),
  (22, 1, 2, '2026-07-12', 810, 5.50, 4455, 'Maria Reyes', NULL, '2026-07-12 08:00:00.000000', '2026-09-29 07:50:21.804945'),
  (23, 1, 2, '2026-07-10', 330, 5.67, 1870, 'Maria Reyes', NULL, '2026-07-10 13:00:00.000000', '2026-09-29 07:50:21.808373'),
  (24, 1, 2, '2026-09-06', 1260, 6.83, 8610, 'Maria Reyes', NULL, '2026-09-06 11:00:00.000000', '2026-09-29 07:50:21.811076'),
  (25, 1, 2, '2026-07-11', 240, 7, 1680, 'Maria Reyes', NULL, '2026-07-11 18:00:00.000000', '2026-09-29 07:50:21.814329'),
  (26, 1, 2, '2026-09-09', 720, 6.17, 4440, 'Maria Reyes', NULL, '2026-09-09 15:00:00.000000', '2026-09-29 07:50:21.817570'),
  (27, 1, 2, '2026-07-22', 1320, 6.33, 8360, 'Maria Reyes', NULL, '2026-07-22 10:00:00.000000', '2026-09-29 07:50:21.820567'),
  (28, 1, 2, '2026-08-15', 720, 6.17, 4440, 'Maria Reyes', NULL, '2026-08-15 15:00:00.000000', '2026-09-29 07:50:21.823931'),
  (29, 1, 2, '2026-07-01', 660, 5.67, 3740, 'Maria Reyes', NULL, '2026-07-01 16:00:00.000000', '2026-09-29 07:50:21.827908'),
  (30, 1, 2, '2026-09-07', 450, 6.33, 2850, 'Maria Reyes', NULL, '2026-09-07 14:00:00.000000', '2026-09-29 07:50:21.830016'),
  (31, 1, 2, '2026-08-10', 1470, 5.50, 8085, 'Maria Reyes', NULL, '2026-08-10 17:00:00.000000', '2026-09-29 07:50:21.833061'),
  (32, 1, 2, '2026-09-18', 450, 5.50, 2475, 'Maria Reyes', NULL, '2026-09-18 15:00:00.000000', '2026-09-29 07:50:21.835470'),
  (33, 1, 2, '2026-07-05', 870, 6.17, 5365, 'Maria Reyes', NULL, '2026-07-05 13:00:00.000000', '2026-09-29 07:50:21.837598'),
  (34, 1, 2, '2026-09-05', 570, 6.33, 3610, 'Maria Reyes', NULL, '2026-09-05 15:00:00.000000', '2026-09-29 07:50:21.839717'),
  (35, 1, 2, '2026-09-16', 1470, 5.67, 8330, 'Maria Reyes', NULL, '2026-09-16 08:00:00.000000', '2026-09-29 07:50:21.842087'),
  (36, 1, 2, '2026-07-17', 510, 6.33, 3230, 'Maria Reyes', NULL, '2026-07-17 16:00:00.000000', '2026-09-29 07:50:21.845336'),
  (37, 1, 2, '2026-08-13', 900, 6.83, 6150, 'Maria Reyes', NULL, '2026-08-13 16:00:00.000000', '2026-09-29 07:50:21.848521'),
  (38, 1, 2, '2026-07-07', 990, 5.67, 5610, 'Maria Reyes', NULL, '2026-07-07 18:00:00.000000', '2026-09-29 07:50:21.851487'),
  (39, 1, 2, '2026-09-22', 330, 7, 2310, 'Maria Reyes', NULL, '2026-09-22 11:00:00.000000', '2026-09-29 07:50:21.853778'),
  (40, 1, 2, '2026-09-09', 510, 5.67, 2890, 'Maria Reyes', NULL, '2026-09-09 11:00:00.000000', '2026-09-29 07:50:21.856083'),
  (41, 1, 2, '2026-08-13', 600, 6.83, 4100, 'Maria Reyes', NULL, '2026-08-13 11:00:00.000000', '2026-09-29 07:50:21.858355'),
  (42, 1, 2, '2026-08-12', 1410, 5.67, 7990, 'Maria Reyes', NULL, '2026-08-12 14:00:00.000000', '2026-09-29 07:50:21.861643'),
  (43, 1, 2, '2026-09-05', 750, 6.83, 5125, 'Maria Reyes', NULL, '2026-09-05 12:00:00.000000', '2026-09-29 07:50:21.864873'),
  (44, 1, 2, '2026-07-11', 150, 5.67, 850, 'Maria Reyes', NULL, '2026-07-11 15:00:00.000000', '2026-09-29 07:50:21.867974'),
  (45, 1, 2, '2026-07-06', 1020, 6.17, 6290, 'Maria Reyes', NULL, '2026-07-06 08:00:00.000000', '2026-09-29 07:50:21.870344'),
  (46, 1, 2, '2026-08-25', 1170, 5.50, 6435, 'Maria Reyes', NULL, '2026-08-25 12:00:00.000000', '2026-09-29 07:50:21.872480'),
  (47, 1, 2, '2026-07-07', 690, 6.83, 4715, 'Maria Reyes', NULL, '2026-07-07 17:00:00.000000', '2026-09-29 07:50:21.874576'),
  (48, 1, 2, '2026-09-17', 480, 5.67, 2720, 'Maria Reyes', NULL, '2026-09-17 18:00:00.000000', '2026-09-29 07:50:21.877016'),
  (49, 1, 2, '2026-09-21', 750, 6.33, 4750, 'Maria Reyes', NULL, '2026-09-21 16:00:00.000000', '2026-09-29 07:50:21.879215'),
  (50, 1, 2, '2026-08-07', 300, 6.33, 1900, 'Maria Reyes', NULL, '2026-08-07 13:00:00.000000', '2026-09-29 07:50:21.881908'),
  (51, 1, 2, '2026-08-15', 1260, 6.83, 8610, 'Maria Reyes', NULL, '2026-08-15 18:00:00.000000', '2026-09-29 07:50:21.884599'),
  (52, 1, 2, '2026-07-05', 300, 7, 2100, 'Maria Reyes', NULL, '2026-07-05 13:00:00.000000', '2026-09-29 07:50:21.886769'),
  (53, 1, 2, '2026-08-27', 1380, 7, 9660, 'Maria Reyes', NULL, '2026-08-27 13:00:00.000000', '2026-09-29 07:50:21.888870'),
  (54, 1, 2, '2026-08-28', 630, 6.17, 3885, 'Maria Reyes', NULL, '2026-08-28 08:00:00.000000', '2026-09-29 07:50:21.890966'),
  (55, 1, 2, '2026-07-31', 1320, 6.33, 8360, 'Maria Reyes', NULL, '2026-07-31 17:00:00.000000', '2026-09-29 07:50:21.893473'),
  (56, 1, 2, '2026-08-06', 1350, 6.83, 9225, 'Maria Reyes', NULL, '2026-08-06 18:00:00.000000', '2026-09-29 07:50:21.895592'),
  (57, 1, 2, '2026-07-25', 450, 7, 3150, 'Maria Reyes', NULL, '2026-07-25 11:00:00.000000', '2026-09-29 07:50:21.898247'),
  (58, 1, 2, '2026-07-24', 570, 7, 3990, 'Maria Reyes', NULL, '2026-07-24 09:00:00.000000', '2026-09-29 07:50:21.900967'),
  (59, 1, 2, '2026-08-03', 720, 6.33, 4560, 'Maria Reyes', NULL, '2026-08-03 15:00:00.000000', '2026-09-29 07:50:21.903100'),
  (60, 1, 2, '2026-09-13', 1170, 6.33, 7410, 'Maria Reyes', NULL, '2026-09-13 08:00:00.000000', '2026-09-29 07:50:21.905203'),
  (61, 1, 2, '2026-07-17', 240, 5.50, 1320, 'Maria Reyes', NULL, '2026-07-17 08:00:00.000000', '2026-09-29 07:50:21.907569'),
  (62, 1, 2, '2026-09-14', 330, 5.67, 1870, 'Maria Reyes', NULL, '2026-09-14 11:00:00.000000', '2026-09-29 07:50:21.910525'),
  (63, 1, 2, '2026-08-17', 1050, 6.17, 6475, 'Maria Reyes', NULL, '2026-08-17 09:00:00.000000', '2026-09-29 07:50:21.912696'),
  (64, 1, 2, '2026-07-30', 810, 6.33, 5130, 'Maria Reyes', NULL, '2026-07-30 17:00:00.000000', '2026-09-29 07:50:21.915060'),
  (65, 1, 2, '2026-08-09', 720, 6.17, 4440, 'Maria Reyes', NULL, '2026-08-09 10:00:00.000000', '2026-09-29 07:50:21.918013'),
  (66, 1, 2, '2026-08-31', 720, 6.83, 4920, 'Maria Reyes', NULL, '2026-08-31 16:00:00.000000', '2026-09-29 07:50:21.920207'),
  (67, 1, 2, '2026-07-23', 630, 5.67, 3570, 'Maria Reyes', NULL, '2026-07-23 08:00:00.000000', '2026-09-29 07:50:21.922322'),
  (68, 1, 2, '2026-07-03', 990, 5.50, 5445, 'Maria Reyes', NULL, '2026-07-03 15:00:00.000000', '2026-09-29 07:50:21.924422'),
  (69, 1, 2, '2026-09-18', 930, 6.83, 6355, 'Maria Reyes', NULL, '2026-09-18 17:00:00.000000', '2026-09-29 07:50:21.926448'),
  (70, 1, 2, '2026-10-02', 3000, 6.80, 20400, 'Aling Nena Sari-sari Wholesale', '100 trays brown medium', '2026-10-14 12:58:14.606263', '2026-10-14 12:58:14.606271'),
  (71, 1, 2, '2026-10-05', 4500, 7.10, 31950, 'Batangas Public Market Stall #14', '150 trays large brown', '2026-10-14 12:58:14.606278', '2026-10-14 12:58:14.606283'),
  (72, 1, 2, '2026-10-07', 1800, 6.50, 11700, 'Golden Bakery & Pastries', '60 trays medium eggs', '2026-10-14 12:58:14.606289', '2026-10-14 12:58:14.606294'),
  (73, 1, 2, '2026-10-09', 2400, 7.80, 18720, 'Lipa City Gourmet Diner', '80 trays XL & Jumbo brown', '2026-10-14 12:58:14.606299', '2026-10-14 12:58:14.606304'),
  (74, 1, 2, '2026-10-11', 3600, 6.90, 24840, 'Community Egg Reseller Group', '120 trays mixed brown', '2026-10-14 12:58:14.606310', '2026-10-14 12:58:14.606315'),
  (75, 1, 2, '2026-10-13', 2100, 7, 14700, 'Mang Juan Canteen', '70 trays brown medium', '2026-10-14 12:58:14.606320', '2026-10-14 12:58:14.606323'),
  (76, 2, 4, '2026-10-04', 3000, 6.20, 18600, 'Tanauan Mini Mart', '100 trays white medium', '2026-10-14 12:58:14.606326', '2026-10-14 12:58:14.606329'),
  (77, 2, 4, '2026-10-10', 2400, 6.30, 15120, 'San Juan Grocers', '80 trays white', '2026-10-14 12:58:14.606332', '2026-10-14 12:58:14.606335');
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `buyer_feedback`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `buyer_feedback`;
CREATE TABLE `buyer_feedback` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` INT(11) NOT NULL,
  `order_id` INT(11) DEFAULT NULL,
  `product_id` INT(11) DEFAULT NULL,
  `farmer_id` INT(11) DEFAULT NULL,
  `category` VARCHAR(8) NOT NULL,
  `rating` INT(11) DEFAULT NULL,
  `feedback_text` TEXT NOT NULL,
  `ai_issue` VARCHAR(100) DEFAULT NULL,
  `ai_sentiment` VARCHAR(20) DEFAULT NULL,
  `ai_keywords` VARCHAR(500) DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_buyer_feedback_buyer_id` (`buyer_id`),
  KEY `ix_buyer_feedback_product_id` (`product_id`),
  KEY `ix_buyer_feedback_order_id` (`order_id`),
  KEY `ix_buyer_feedback_farmer_id` (`farmer_id`),
  CONSTRAINT `fk_buyer_feedback_farmer_id` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_buyer_feedback_order_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `fk_buyer_feedback_product_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_buyer_feedback_buyer_id` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `buyer_feedback`
LOCK TABLES `buyer_feedback` WRITE;
INSERT INTO `buyer_feedback` (`id`, `buyer_id`, `order_id`, `category`, `rating`, `feedback_text`, `ai_issue`, `ai_sentiment`, `ai_keywords`, `created_at`, `updated_at`, `product_id`, `farmer_id`) VALUES
  (1, 2, 10, 'product', 5, 'The eggs were perfectly fresh and delivery was fast!', 'Fresh eggs and fast delivery', 'Positive', '["eggs", "fresh", "delivery", "fast"]', '2026-08-21 16:23:49.075988', '2026-08-21 16:41:04.789460', NULL, 1),
  (2, 2, 41, 'delivery', 2, 'mabagal yun delivery', 'slow delivery', 'Negative', '["mabagal", "delivery", "slow delivery"]', '2026-08-21 16:23:49.080015', '2026-08-21 16:41:04.796157', NULL, 1),
  (3, 2, 55, 'delivery', 5, 'fast delivery', 'fast delivery', 'Positive', '["fast", "delivery"]', '2026-08-21 16:23:49.081084', '2026-08-21 16:41:04.797508', NULL, 1),
  (4, 2, 67, 'website', 4, 'mabilis naman', NULL, 'Positive', '["mabilis", "fast", "delivery"]', '2026-08-21 17:45:53.392759', '2026-08-21 17:45:53.392770', NULL, NULL),
  (5, 2, 67, 'product', 5, 'okay lang', NULL, 'Neutral', '["okay", "lang", "average", "acceptable"]', '2026-08-21 17:46:16.313289', '2026-08-21 17:46:16.313296', 6, 1),
  (6, 2, 67, 'delivery', 4, 'mabilis', NULL, 'Positive', '["mabilis", "fast", "delivery"]', '2026-08-21 17:46:16.313301', '2026-08-21 17:46:16.313304', NULL, 1),
  (7, 2, 4, 'website', 3, '', NULL, NULL, NULL, '2026-08-21 17:48:36.042077', '2026-08-21 17:48:36.042084', NULL, NULL),
  (8, 2, 4, 'product', 5, '', NULL, NULL, NULL, '2026-08-21 17:48:36.049721', '2026-08-21 17:48:36.049727', 3, 1),
  (9, 2, 4, 'delivery', 4, '', NULL, NULL, NULL, '2026-08-21 17:48:36.049732', '2026-08-21 17:48:36.049735', NULL, 1),
  (10, 2, 40, 'website', 4, '', NULL, NULL, NULL, '2026-08-21 17:48:53.645206', '2026-08-21 17:48:53.645216', NULL, NULL),
  (11, 2, 40, 'product', 5, '', NULL, NULL, NULL, '2026-08-21 17:48:53.648598', '2026-08-21 17:48:53.648608', 5, 1),
  (12, 2, 40, 'delivery', 4, '', NULL, NULL, NULL, '2026-08-21 17:48:53.648616', '2026-08-21 17:48:53.648621', NULL, 1),
  (13, 2, 68, 'website', 5, '', NULL, NULL, NULL, '2026-08-21 18:24:12.966509', '2026-08-21 18:24:12.966517', NULL, NULL),
  (14, 2, 68, 'product', 5, '', NULL, NULL, NULL, '2026-08-21 18:24:12.972049', '2026-08-21 18:24:12.972060', 5, 1),
  (15, 2, 68, 'delivery', 5, '', NULL, NULL, NULL, '2026-08-21 18:24:12.972067', '2026-08-21 18:24:12.972073', NULL, 1),
  (16, 2, NULL, 'product', 5, 'Napaka-fresh ng mga itlog at mabilis ang delivery!', 'Fast Delivery', 'Positive', '["napakafresh", "itlog", "mabilis", "delivery"]', '2026-09-21 16:21:27.342896', '2026-09-21 16:21:27.342902', NULL, NULL),
  (17, 2, NULL, 'product', 5, 'Napaka-fresh ng mga itlog at mabilis ang delivery!', 'Fast Delivery', 'Positive', '["napakafresh", "itlog", "mabilis", "delivery"]', '2026-09-21 16:21:46.311696', '2026-09-21 16:21:46.311702', NULL, NULL),
  (18, 2, NULL, 'product', 5, 'Napaka-fresh ng mga itlog at mabilis ang delivery!', 'Fast Delivery', 'Positive', '["napakafresh", "itlog", "mabilis", "delivery"]', '2026-09-21 16:22:33.991848', '2026-09-21 16:22:33.991854', NULL, NULL),
  (19, 2, NULL, 'product', 5, 'Napaka-fresh ng mga itlog at mabilis ang delivery!', 'Fast Delivery', 'Positive', '["napakafresh", "itlog", "mabilis", "delivery"]', '2026-09-21 16:22:57.874598', '2026-09-21 16:22:57.874604', NULL, NULL),
  (20, 3, 12, 'website', 5, '', NULL, NULL, NULL, '2026-09-30 06:14:14.682226', '2026-09-30 06:14:14.682233', NULL, NULL),
  (21, 3, 12, 'product', 5, '', NULL, NULL, NULL, '2026-09-30 06:14:14.687165', '2026-09-30 06:14:14.687172', 2, 2),
  (22, 3, 12, 'delivery', 5, '', NULL, NULL, NULL, '2026-09-30 06:14:14.687176', '2026-09-30 06:14:14.687179', NULL, 2),
  (23, 3, 40, 'website', 5, '', NULL, NULL, NULL, '2026-09-30 06:17:23.965829', '2026-09-30 06:17:23.965835', NULL, NULL),
  (24, 3, 40, 'product', 5, '', NULL, NULL, NULL, '2026-09-30 06:17:23.969609', '2026-09-30 06:17:23.969615', 3, 2),
  (25, 3, 40, 'delivery', 5, '', NULL, NULL, NULL, '2026-09-30 06:17:23.969619', '2026-09-30 06:17:23.969622', NULL, 2);
UNLOCK TABLES;

-- --------------------------------------------------------
-- Table structure for table `content_moderations`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `content_moderations`;
CREATE TABLE `content_moderations` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `product_id` INT(11) DEFAULT NULL,
  `uploader_id` INT(11) NOT NULL,
  `image_url` VARCHAR(500) NOT NULL,
  `status` VARCHAR(8) NOT NULL DEFAULT 'pending',
  `ai_result` TEXT DEFAULT NULL,
  `ai_flag_reason` TEXT DEFAULT NULL,
  `ai_safe` TINYINT(1) DEFAULT NULL,
  `admin_action` TEXT DEFAULT NULL,
  `reviewed_by_id` INT(11) DEFAULT NULL,
  `reviewed_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_content_moderations_product_id` (`product_id`),
  KEY `ix_content_moderations_status` (`status`),
  KEY `ix_content_moderations_uploader_id` (`uploader_id`),
  CONSTRAINT `fk_content_moderations_reviewed_by_id` FOREIGN KEY (`reviewed_by_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_content_moderations_uploader_id` FOREIGN KEY (`uploader_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_content_moderations_product_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `order_items`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `order_id` INT(11) NOT NULL,
  `product_id` INT(11) NOT NULL,
  `quantity` INT(11) NOT NULL DEFAULT 1,
  `unit_price` DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_order_items_order_id` (`order_id`),
  KEY `ix_order_items_product_id` (`product_id`),
  CONSTRAINT `fk_order_items_product_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_order_items_order_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `order_items`
LOCK TABLES `order_items` WRITE;
INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `quantity`, `unit_price`) VALUES
  (1, 1, 1, 20, 170),
  (2, 2, 2, 25, 190),
  (3, 3, 4, 36, 165),
  (4, 4, 6, 10, 205),
  (5, 5, 1, 42, 170),
  (6, 6, 4, 36, 165),
  (7, 7, 6, 35, 205),
  (8, 8, 1, 13, 170),
  (9, 9, 5, 43, 185),
  (10, 10, 1, 20, 170),
  (11, 11, 2, 27, 190),
  (12, 12, 2, 26, 190),
  (13, 13, 4, 5, 165),
  (14, 14, 1, 5, 170),
  (15, 15, 6, 15, 205),
  (16, 16, 5, 33, 185),
  (17, 17, 3, 14, 210),
  (18, 18, 5, 26, 185),
  (19, 19, 4, 40, 165),
  (20, 20, 1, 28, 170),
  (21, 21, 5, 21, 185),
  (22, 22, 4, 27, 165),
  (23, 23, 1, 11, 170),
  (24, 24, 6, 42, 205),
  (25, 25, 3, 8, 210),
  (26, 26, 5, 24, 185),
  (27, 27, 2, 44, 190),
  (28, 28, 5, 24, 185),
  (29, 29, 3, 27, 210),
  (30, 30, 1, 22, 170),
  (31, 31, 2, 15, 190),
  (32, 32, 4, 49, 165),
  (33, 33, 4, 15, 165),
  (34, 34, 5, 29, 185),
  (35, 35, 2, 19, 190),
  (36, 36, 1, 49, 170),
  (37, 37, 2, 17, 190),
  (38, 38, 6, 30, 205),
  (39, 39, 1, 33, 170),
  (40, 40, 3, 11, 210),
  (41, 41, 1, 17, 170),
  (42, 42, 6, 20, 205),
  (43, 43, 1, 47, 170),
  (44, 44, 6, 25, 205),
  (45, 45, 1, 5, 170),
  (46, 46, 5, 34, 185),
  (47, 47, 4, 39, 165),
  (48, 48, 6, 23, 205),
  (49, 49, 1, 16, 170),
  (50, 50, 2, 25, 190),
  (51, 51, 2, 10, 190),
  (52, 52, 6, 42, 205),
  (53, 53, 3, 10, 210),
  (54, 54, 3, 46, 210),
  (55, 55, 5, 21, 185),
  (56, 56, 2, 44, 190),
  (57, 57, 6, 45, 205),
  (58, 58, 3, 15, 210),
  (59, 59, 3, 19, 210),
  (60, 60, 2, 24, 190),
  (61, 61, 2, 39, 190),
  (62, 62, 4, 8, 165),
  (63, 63, 1, 11, 170),
  (64, 64, 5, 35, 185),
  (65, 65, 2, 27, 190),
  (66, 66, 5, 24, 185),
  (67, 67, 6, 24, 205),
  (68, 68, 1, 21, 170),
  (69, 69, 4, 33, 165),
  (70, 70, 6, 31, 205),
  (71, 71, 1, 30, 170),
  (72, 72, 2, 60, 190),
  (73, 73, 3, 50, 210),
  (74, 74, 7, 25, 230),
  (75, 75, 8, 20, 250),
  (76, 76, 2, 45, 190),
  (77, 77, 3, 35, 210),
  (78, 78, 1, 20, 170);
UNLOCK TABLES;

-- --------------------------------------------------------
-- Restore environment settings
-- --------------------------------------------------------
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT;
SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS;
SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION;
SET TIME_ZONE=@OLD_TIME_ZONE;
SET SQL_MODE=@OLD_SQL_MODE;
SET SQL_NOTES=@OLD_SQL_NOTES;
