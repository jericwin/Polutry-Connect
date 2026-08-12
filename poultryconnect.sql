-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 09, 2026 at 05:22 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `poultryconnect`
--

-- --------------------------------------------------------

--
-- Table structure for table `alembic_version`
--

CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `alembic_version`
--

INSERT INTO `alembic_version` (`version_num`) VALUES
('bebffabdfdfc');

-- --------------------------------------------------------

--
-- Table structure for table `conversations`
--

CREATE TABLE `conversations` (
  `id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `participant_id` int(10) UNSIGNED NOT NULL,
  `participant_role` varchar(32) NOT NULL,
  `deleted_by_farmer` tinyint(1) DEFAULT 0,
  `deleted_by_participant` tinyint(1) DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `conversations`
--

INSERT INTO `conversations` (`id`, `farmer_id`, `participant_id`, `participant_role`, `deleted_by_farmer`, `deleted_by_participant`, `created_at`) VALUES
(1, 2, 3, 'feed_supplier', 0, 0, '2026-07-15 16:04:04'),
(2, 2, 4, 'veterinarian', 0, 0, '2026-07-15 16:04:04'),
(3, 2, 7, 'buyer', 0, 0, '2026-07-15 08:26:05'),
(4, 6, 7, 'buyer', 0, 0, '2026-07-15 08:27:20'),
(5, 2, 5, 'buyer', 0, 0, '2026-07-15 08:36:43');

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `id` int(10) UNSIGNED NOT NULL,
  `farm_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `expense_date` date NOT NULL,
  `category` enum('feed','labor','utilities','medicine','other') NOT NULL DEFAULT 'other',
  `amount` decimal(10,2) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `frequency` enum('one_time','daily','weekly','monthly') NOT NULL DEFAULT 'one_time',
  `end_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`id`, `farm_id`, `user_id`, `expense_date`, `category`, `amount`, `description`, `created_at`, `updated_at`, `frequency`, `end_date`) VALUES
(26, 5, 11, '2026-07-10', 'feed', 80.00, 'Daily Feed Cost (Adjusted for Profit)', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'daily', NULL),
(27, 5, 11, '2026-07-10', 'medicine', 100.00, 'Maintenance & Operations - medicine', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(28, 5, 11, '2026-07-18', 'medicine', 100.00, 'Maintenance & Operations - medicine', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(29, 5, 11, '2026-07-24', 'medicine', 100.00, 'Maintenance & Operations - medicine', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(30, 5, 11, '2026-07-11', 'labor', 100.00, 'Maintenance & Operations - labor', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(31, 5, 11, '2026-07-12', 'medicine', 100.00, 'Maintenance & Operations - medicine', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(32, 5, 11, '2026-08-05', 'medicine', 100.00, 'Maintenance & Operations - medicine', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(33, 5, 11, '2026-07-20', 'other', 100.00, 'Maintenance & Operations - other', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(34, 5, 11, '2026-07-21', 'utilities', 100.00, 'Maintenance & Operations - utilities', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(35, 5, 11, '2026-07-15', 'medicine', 100.00, 'Maintenance & Operations - medicine', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(36, 5, 11, '2026-07-16', 'medicine', 100.00, 'Maintenance & Operations - medicine', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(37, 5, 11, '2026-08-03', 'medicine', 100.00, 'Maintenance & Operations - medicine', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(38, 5, 11, '2026-07-10', 'labor', 100.00, 'Maintenance & Operations - labor', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(39, 5, 11, '2026-08-09', 'labor', 100.00, 'Maintenance & Operations - labor', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(40, 5, 11, '2026-07-20', 'labor', 100.00, 'Maintenance & Operations - labor', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(41, 5, 11, '2026-08-04', 'feed', 100.00, 'Maintenance & Operations - feed', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL),
(42, 5, 11, '2026-08-01', 'other', 100.00, 'Maintenance & Operations - other', '2026-08-09 15:17:49', '2026-08-09 15:17:49', 'one_time', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `farms`
--

CREATE TABLE `farms` (
  `id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `flock_size` int(11) DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `farms`
--

INSERT INTO `farms` (`id`, `farmer_id`, `name`, `location`, `description`, `flock_size`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 2, 'Sunrise Layer Farm', 'Cavite', 'Layer farm producing fresh eggs.', 1200, 1, '2026-07-15 16:04:04', '2026-07-15 16:04:04'),
(2, 2, 'Green Feed Poultry', 'Laguna', 'Broiler and feed support farm.', 800, 1, '2026-07-15 16:04:04', '2026-07-15 16:04:04'),
(3, 6, 'Paete Farm', 'Paete', NULL, 500, 1, '2026-07-15 09:06:02', '2026-07-15 09:06:02'),
(4, 8, 'Juan Poultry Farm', 'San Jose, Batangas', 'A mid-sized layer poultry farm.', 5000, 1, '2026-08-05 14:07:45', '2026-08-05 14:07:45'),
(5, 11, 'Sunny Ridge Poultry', 'Batangas', NULL, 5000, 1, '2026-08-09 14:57:42', '2026-08-09 14:57:42');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(10) UNSIGNED NOT NULL,
  `conversation_id` int(10) UNSIGNED NOT NULL,
  `sender_id` int(10) UNSIGNED NOT NULL,
  `receiver_id` int(10) UNSIGNED NOT NULL,
  `body` text NOT NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp(),
  `delivered_at` datetime DEFAULT NULL,
  `seen_at` datetime DEFAULT NULL,
  `is_seen` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `conversation_id`, `sender_id`, `receiver_id`, `body`, `sent_at`, `delivered_at`, `seen_at`, `is_seen`) VALUES
(1, 1, 2, 3, 'Good morning, do you have available starter feed?', '2026-07-04 08:00:00', '2026-07-04 08:01:00', '2026-07-04 08:02:00', 1),
(2, 1, 3, 2, 'Yes, we have stock for delivery today.', '2026-07-04 08:05:00', '2026-07-04 08:06:00', NULL, 0),
(3, 2, 2, 4, 'Hi Doc, our flock seems less active today.', '2026-07-04 09:00:00', '2026-07-04 09:01:00', NULL, 0),
(4, 2, 4, 2, 'Please monitor the water intake and temperature.', '2026-07-04 09:10:00', '2026-07-04 09:11:00', NULL, 0),
(5, 5, 5, 2, 'Test message', '2026-07-15 08:36:43', NULL, NULL, 0),
(6, 1, 5, 2, 'Test message', '2026-07-15 08:37:48', NULL, NULL, 0),
(7, 4, 7, 6, 'Hello', '2026-07-15 08:40:11', '2026-07-15 08:40:11', '2026-07-15 08:40:11', 1),
(8, 4, 7, 6, 'Hi', '2026-07-15 08:40:18', '2026-07-15 08:40:18', '2026-07-15 08:40:19', 1);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(120) NOT NULL,
  `body` varchar(255) NOT NULL,
  `notif_type` varchar(32) NOT NULL DEFAULT 'message',
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `link_url` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `body`, `notif_type`, `is_read`, `link_url`, `created_at`) VALUES
(1, 3, 'New message', 'You received a new message from Juan Dela Cruz.', 'message', 0, '/messaging/?open=1', '2026-07-15 16:04:04'),
(2, 4, 'New message', 'You received a new message from Juan Dela Cruz.', 'message', 0, '/messaging/?open=2', '2026-07-15 16:04:04'),
(3, 7, 'New Conversation', 'Jeric Punay started a conversation with you.', 'message', 0, '/messaging/?open=3', '2026-07-15 08:26:05'),
(4, 7, 'New Conversation', 'Jenrie Araza started a conversation with you.', 'message', 0, '/messaging/?open=4', '2026-07-15 08:27:20'),
(5, 6, 'New message from Jeric Punay', 'Hello', 'message', 1, '/messaging/?open=4', '2026-07-15 08:40:11'),
(6, 7, 'Message read by Jenrie Araza', 'Jenrie Araza has seen your latest message.', 'seen', 0, '/messaging/?open=4', '2026-07-15 08:40:11'),
(7, 6, 'New message from Jeric Punay', 'Hi', 'message', 1, '/messaging/?open=4', '2026-07-15 08:40:18'),
(8, 7, 'Message read by Jenrie Araza', 'Jenrie Araza has seen your latest message.', 'seen', 0, '/messaging/?open=4', '2026-07-15 08:40:19'),
(9, 6, 'New Order Received!', 'You have a new order #4 from Jeric Punay.', 'order', 1, '/marketplace/manage/orders#farmerOrder-4', '2026-07-15 09:57:39');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(10) UNSIGNED NOT NULL,
  `buyer_id` int(10) UNSIGNED NOT NULL,
  `total_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `status` enum('pending','confirmed','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  `delivery_address` varchar(500) NOT NULL,
  `contact_phone` varchar(30) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `buyer_id`, `total_amount`, `status`, `delivery_address`, `contact_phone`, `notes`, `created_at`, `updated_at`) VALUES
(1, 5, 540.00, 'pending', '123 Main Street, Quezon City', '09170000005', 'Please deliver in the morning.', '2026-07-15 16:04:04', '2026-07-15 16:04:04'),
(2, 7, 7.00, 'pending', 'Near Plaza, Santa Maria, Laguna', '09270196752', NULL, '2026-07-15 09:47:32', '2026-07-15 09:47:32'),
(4, 7, 7.00, 'pending', 'Near Plaza, Santa Maria, Laguna', '09270196752', NULL, '2026-07-15 09:57:39', '2026-07-15 09:57:39'),
(5, 10, 190.00, 'pending', '123 Market St., Cityville', '09123456789', 'Mock Order 1 for farmer1', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(6, 10, 180.00, 'confirmed', '123 Market St., Cityville', '09123456789', 'Mock Order 2 for farmer1', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(7, 10, 825.00, 'shipped', '123 Market St., Cityville', '09123456789', 'Mock Order 3 for farmer1', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(8, 10, 465.00, 'pending', '123 Market St., Cityville', '09123456789', 'Mock Order 4 for farmer1', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(9, 10, 7.00, 'pending', '123 Market St., Cityville', '09123456789', 'Mock Order 1 for jenrie', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(10, 10, 7.00, 'confirmed', '123 Market St., Cityville', '09123456789', 'Mock Order 2 for jenrie', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(11, 10, 14.00, 'shipped', '123 Market St., Cityville', '09123456789', 'Mock Order 3 for jenrie', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(12, 10, 7.00, 'pending', '123 Market St., Cityville', '09123456789', 'Mock Order 4 for jenrie', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(13, 10, 220.00, 'pending', '123 Market St., Cityville', '09123456789', 'Mock Order 1 for juan_farmer', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(14, 10, 440.00, 'confirmed', '123 Market St., Cityville', '09123456789', 'Mock Order 2 for juan_farmer', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(15, 10, 540.00, 'delivered', '123 Market St., Cityville', '09123456789', 'Mock Order 3 for juan_farmer', '2026-08-05 15:19:19', '2026-08-05 16:01:02'),
(16, 10, 660.00, 'pending', '123 Market St., Cityville', '09123456789', 'Mock Order 4 for juan_farmer', '2026-08-05 15:19:19', '2026-08-05 15:19:19'),
(17, 13, 420.00, 'shipped', 'Makati City', '09987654321', 'Handle with care', '2026-08-09 14:57:42', '2026-08-09 14:57:42'),
(18, 13, 420.00, 'pending', 'Makati City', '09987654321', 'Handle with care', '2026-08-09 14:57:42', '2026-08-09 14:57:42'),
(19, 13, 420.00, 'delivered', 'Makati City', '09987654321', 'Handle with care', '2026-08-09 14:57:42', '2026-08-09 14:57:42'),
(20, 13, 420.00, 'cancelled', 'Makati City', '09987654321', 'Seed order 1', '2026-08-06 08:07:23', '2026-08-06 08:07:23'),
(21, 13, 2100.00, 'shipped', 'Makati City', '09987654321', 'Seed order 2', '2026-08-04 10:07:23', '2026-08-04 10:07:23'),
(22, 13, 840.00, 'cancelled', 'Makati City', '09987654321', 'Seed order 3', '2026-07-22 13:07:23', '2026-07-22 13:07:23'),
(23, 13, 2100.00, 'delivered', 'Makati City', '09987654321', 'Seed order 4', '2026-07-22 07:07:23', '2026-07-22 07:07:23'),
(24, 13, 420.00, 'pending', 'Makati City', '09987654321', 'Seed order 5', '2026-08-05 23:07:23', '2026-08-05 23:07:23'),
(25, 13, 1680.00, 'shipped', 'Makati City', '09987654321', 'Seed order 6', '2026-07-18 18:07:23', '2026-07-18 18:07:23'),
(26, 13, 1890.00, 'shipped', 'Makati City', '09987654321', 'Seed order 7', '2026-08-06 20:07:23', '2026-08-06 20:07:23'),
(27, 13, 2100.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 8', '2026-07-14 23:07:23', '2026-07-14 23:07:23'),
(28, 13, 1680.00, 'cancelled', 'Makati City', '09987654321', 'Seed order 9', '2026-07-17 14:07:23', '2026-07-17 14:07:23'),
(29, 13, 1890.00, 'delivered', 'Makati City', '09987654321', 'Seed order 10', '2026-07-20 02:07:23', '2026-07-20 02:07:23'),
(30, 13, 1470.00, 'pending', 'Makati City', '09987654321', 'Seed order 11', '2026-07-29 14:07:23', '2026-07-29 14:07:23'),
(31, 13, 420.00, 'shipped', 'Makati City', '09987654321', 'Seed order 12', '2026-08-07 23:07:23', '2026-08-07 23:07:23'),
(32, 13, 840.00, 'cancelled', 'Makati City', '09987654321', 'Seed order 13', '2026-07-14 04:07:23', '2026-07-14 04:07:23'),
(33, 13, 1680.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 14', '2026-07-20 04:07:23', '2026-07-20 04:07:23'),
(34, 13, 420.00, 'pending', 'Makati City', '09987654321', 'Seed order 15', '2026-08-09 10:07:23', '2026-08-09 10:07:23'),
(35, 13, 1260.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 16', '2026-07-31 16:07:23', '2026-07-31 16:07:23'),
(36, 13, 2100.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 17', '2026-07-22 14:07:23', '2026-07-22 14:07:23'),
(37, 13, 1890.00, 'pending', 'Makati City', '09987654321', 'Seed order 18', '2026-07-30 12:07:23', '2026-07-30 12:07:23'),
(38, 13, 2100.00, 'pending', 'Makati City', '09987654321', 'Seed order 19', '2026-07-12 03:07:23', '2026-07-12 03:07:23'),
(39, 13, 1890.00, 'pending', 'Makati City', '09987654321', 'Seed order 20', '2026-08-01 11:07:23', '2026-08-01 11:07:23'),
(40, 13, 1050.00, 'pending', 'Makati City', '09987654321', 'Seed order 21', '2026-07-15 15:07:23', '2026-07-15 15:07:23'),
(41, 13, 420.00, 'pending', 'Makati City', '09987654321', 'Seed order 22', '2026-07-29 22:07:23', '2026-07-29 22:07:23'),
(42, 13, 1050.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 23', '2026-07-18 02:07:23', '2026-07-18 02:07:23'),
(43, 13, 420.00, 'delivered', 'Makati City', '09987654321', 'Seed order 24', '2026-07-29 12:07:23', '2026-07-29 12:07:23'),
(44, 13, 1470.00, 'pending', 'Makati City', '09987654321', 'Seed order 25', '2026-07-17 15:07:23', '2026-07-17 15:07:23'),
(45, 13, 420.00, 'shipped', 'Makati City', '09987654321', 'Seed order 26', '2026-07-15 19:07:23', '2026-07-15 19:07:23'),
(46, 13, 630.00, 'shipped', 'Makati City', '09987654321', 'Seed order 27', '2026-07-15 21:07:23', '2026-07-15 21:07:23'),
(47, 13, 840.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 28', '2026-07-22 06:07:23', '2026-07-22 06:07:23'),
(48, 13, 1050.00, 'shipped', 'Makati City', '09987654321', 'Seed order 29', '2026-07-30 23:07:23', '2026-07-30 23:07:23'),
(49, 13, 420.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 30', '2026-07-12 03:07:23', '2026-07-12 03:07:23'),
(50, 13, 2100.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 31', '2026-07-13 00:07:23', '2026-07-13 00:07:23'),
(51, 13, 1890.00, 'pending', 'Makati City', '09987654321', 'Seed order 32', '2026-07-23 08:07:23', '2026-07-23 08:07:23'),
(52, 13, 1890.00, 'delivered', 'Makati City', '09987654321', 'Seed order 33', '2026-08-06 14:07:23', '2026-08-06 14:07:23'),
(53, 13, 630.00, 'pending', 'Makati City', '09987654321', 'Seed order 34', '2026-07-23 16:07:23', '2026-07-23 16:07:23'),
(54, 13, 420.00, 'delivered', 'Makati City', '09987654321', 'Seed order 35', '2026-07-26 16:07:23', '2026-07-26 16:07:23'),
(55, 13, 2100.00, 'shipped', 'Makati City', '09987654321', 'Seed order 36', '2026-08-07 05:07:23', '2026-08-07 05:07:23'),
(56, 13, 2100.00, 'cancelled', 'Makati City', '09987654321', 'Seed order 37', '2026-07-22 15:07:23', '2026-07-22 15:07:23'),
(57, 13, 630.00, 'pending', 'Makati City', '09987654321', 'Seed order 38', '2026-08-07 04:07:23', '2026-08-07 04:07:23'),
(58, 13, 2100.00, 'cancelled', 'Makati City', '09987654321', 'Seed order 39', '2026-07-13 04:07:23', '2026-07-13 04:07:23'),
(59, 13, 420.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 40', '2026-07-24 01:07:23', '2026-07-24 01:07:23'),
(60, 13, 1260.00, 'delivered', 'Makati City', '09987654321', 'Seed order 41', '2026-08-02 02:07:23', '2026-08-02 02:07:23'),
(61, 13, 630.00, 'cancelled', 'Makati City', '09987654321', 'Seed order 42', '2026-07-18 20:07:23', '2026-07-18 20:07:23'),
(62, 13, 2100.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 43', '2026-07-22 12:07:23', '2026-07-22 12:07:23'),
(63, 13, 210.00, 'shipped', 'Makati City', '09987654321', 'Seed order 44', '2026-07-18 22:07:23', '2026-07-18 22:07:23'),
(64, 13, 420.00, 'pending', 'Makati City', '09987654321', 'Seed order 45', '2026-07-30 17:07:23', '2026-07-30 17:07:23'),
(65, 13, 1260.00, 'pending', 'Makati City', '09987654321', 'Seed order 46', '2026-07-13 04:07:23', '2026-07-13 04:07:23'),
(66, 13, 1050.00, 'confirmed', 'Makati City', '09987654321', 'Seed order 47', '2026-08-04 00:07:23', '2026-08-04 00:07:23'),
(67, 13, 1050.00, 'delivered', 'Makati City', '09987654321', 'Seed order 48', '2026-08-03 10:07:23', '2026-08-03 10:07:23'),
(68, 13, 2100.00, 'delivered', 'Makati City', '09987654321', 'Seed order 49', '2026-07-30 00:07:23', '2026-07-30 00:07:23'),
(69, 13, 840.00, 'delivered', 'Makati City', '09987654321', 'Seed order 50', '2026-08-09 15:07:23', '2026-08-09 15:07:23');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int(10) UNSIGNED NOT NULL,
  `order_id` int(10) UNSIGNED NOT NULL,
  `product_id` int(10) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `unit_price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `quantity`, `unit_price`) VALUES
(1, 1, 1, 3, 180.00),
(2, 2, 3, 1, 7.00),
(3, 4, 3, 1, 7.00),
(4, 5, 2, 2, 95.00),
(5, 6, 1, 1, 180.00),
(6, 7, 1, 3, 180.00),
(7, 7, 2, 3, 95.00),
(8, 8, 1, 1, 180.00),
(9, 8, 2, 3, 95.00),
(10, 9, 3, 1, 7.00),
(11, 10, 3, 1, 7.00),
(12, 11, 3, 2, 7.00),
(13, 12, 3, 1, 7.00),
(14, 13, 4, 1, 220.00),
(15, 14, 4, 2, 220.00),
(16, 15, 5, 3, 180.00),
(17, 16, 4, 3, 220.00),
(18, 17, 6, 2, 210.00),
(19, 18, 6, 2, 210.00),
(20, 19, 6, 2, 210.00),
(21, 20, 6, 2, 210.00),
(22, 21, 6, 10, 210.00),
(23, 22, 6, 4, 210.00),
(24, 23, 6, 10, 210.00),
(25, 24, 6, 2, 210.00),
(26, 25, 6, 8, 210.00),
(27, 26, 6, 9, 210.00),
(28, 27, 6, 10, 210.00),
(29, 28, 6, 8, 210.00),
(30, 29, 6, 9, 210.00),
(31, 30, 6, 7, 210.00),
(32, 31, 6, 2, 210.00),
(33, 32, 6, 4, 210.00),
(34, 33, 6, 8, 210.00),
(35, 34, 6, 2, 210.00),
(36, 35, 6, 6, 210.00),
(37, 36, 6, 10, 210.00),
(38, 37, 6, 9, 210.00),
(39, 38, 6, 10, 210.00),
(40, 39, 6, 9, 210.00),
(41, 40, 6, 5, 210.00),
(42, 41, 6, 2, 210.00),
(43, 42, 6, 5, 210.00),
(44, 43, 6, 2, 210.00),
(45, 44, 6, 7, 210.00),
(46, 45, 6, 2, 210.00),
(47, 46, 6, 3, 210.00),
(48, 47, 6, 4, 210.00),
(49, 48, 6, 5, 210.00),
(50, 49, 6, 2, 210.00),
(51, 50, 6, 10, 210.00),
(52, 51, 6, 9, 210.00),
(53, 52, 6, 9, 210.00),
(54, 53, 6, 3, 210.00),
(55, 54, 6, 2, 210.00),
(56, 55, 6, 10, 210.00),
(57, 56, 6, 10, 210.00),
(58, 57, 6, 3, 210.00),
(59, 58, 6, 10, 210.00),
(60, 59, 6, 2, 210.00),
(61, 60, 6, 6, 210.00),
(62, 61, 6, 3, 210.00),
(63, 62, 6, 10, 210.00),
(64, 63, 6, 1, 210.00),
(65, 64, 6, 2, 210.00),
(66, 65, 6, 6, 210.00),
(67, 66, 6, 5, 210.00),
(68, 67, 6, 5, 210.00),
(69, 68, 6, 10, 210.00),
(70, 69, 6, 4, 210.00);

-- --------------------------------------------------------

--
-- Table structure for table `production_records`
--

CREATE TABLE `production_records` (
  `id` int(10) UNSIGNED NOT NULL,
  `farm_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `record_date` date NOT NULL,
  `egg_count` int(11) NOT NULL DEFAULT 0,
  `feed_kg` decimal(8,2) DEFAULT 0.00,
  `feed_cost` decimal(10,2) DEFAULT 0.00,
  `egg_price` decimal(10,2) DEFAULT NULL,
  `mortality` int(11) DEFAULT 0,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `size` varchar(20) DEFAULT NULL,
  `variety` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `production_records`
--

INSERT INTO `production_records` (`id`, `farm_id`, `user_id`, `record_date`, `egg_count`, `feed_kg`, `feed_cost`, `egg_price`, `mortality`, `notes`, `created_at`, `updated_at`, `size`, `variety`) VALUES
(1, 1, 2, '2026-07-01', 980, 220.50, 15435.00, 5.50, 3, 'Steady production after vaccination.', '2026-07-15 16:04:04', '2026-07-15 16:04:04', NULL, NULL),
(2, 1, 2, '2026-07-02', 1010, 225.00, 15750.00, 5.50, 2, 'Improved feed conversion.', '2026-07-15 16:04:04', '2026-07-15 16:04:04', NULL, NULL),
(3, 4, 8, '2026-08-05', 4705, 598.59, 11949.94, 6.50, 4, 'Normal day', '2026-08-05 14:07:45', '2026-08-05 14:07:45', NULL, NULL),
(4, 4, 8, '2026-08-04', 4338, 526.08, 11189.15, 6.50, 4, 'Normal day', '2026-08-05 14:07:45', '2026-08-05 14:07:45', NULL, NULL),
(5, 4, 8, '2026-08-03', 4379, 527.57, 10739.45, 6.50, 1, 'Normal day', '2026-08-05 14:07:45', '2026-08-05 14:07:45', NULL, NULL),
(6, 4, 8, '2026-08-02', 4477, 552.03, 11928.89, 6.50, 1, 'Normal day', '2026-08-05 14:07:45', '2026-08-05 14:07:45', NULL, NULL),
(7, 4, 8, '2026-08-01', 4605, 557.92, 11758.45, 6.50, 4, 'Normal day', '2026-08-05 14:07:45', '2026-08-05 14:07:45', NULL, NULL),
(8, 4, 8, '2026-07-31', 4009, 596.14, 10807.02, 6.50, 5, 'Normal day', '2026-08-05 14:07:45', '2026-08-05 14:07:45', NULL, NULL),
(9, 4, 8, '2026-07-30', 4269, 526.75, 10047.90, 6.50, 3, 'Normal day', '2026-08-05 14:07:45', '2026-08-05 14:07:45', NULL, NULL),
(10, 5, 11, '2026-06-20', 4692, 539.91, 15231.89, 7.24, 5, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'small', 'white'),
(11, 5, 11, '2026-06-21', 4012, 530.16, 15961.86, 7.96, 3, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'white'),
(12, 5, 11, '2026-06-22', 4178, 536.15, 15348.65, 7.23, 4, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'white'),
(13, 5, 11, '2026-06-23', 4782, 541.27, 15808.44, 7.84, 3, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'white'),
(14, 5, 11, '2026-06-24', 4101, 536.02, 15087.26, 8.02, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'white'),
(15, 5, 11, '2026-06-25', 4296, 520.46, 15255.88, 8.02, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'white'),
(16, 5, 11, '2026-06-26', 4378, 539.49, 15440.54, 7.58, 2, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'white'),
(17, 5, 11, '2026-06-27', 4711, 501.54, 15721.48, 6.79, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'brown'),
(18, 5, 11, '2026-06-28', 4387, 519.94, 15271.73, 7.76, 5, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'brown'),
(19, 5, 11, '2026-06-29', 4735, 535.63, 15615.61, 6.93, 4, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'small', 'brown'),
(20, 5, 11, '2026-06-30', 4569, 502.02, 15607.62, 8.33, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'white'),
(21, 5, 11, '2026-07-01', 4415, 539.37, 15288.69, 8.09, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'white'),
(22, 5, 11, '2026-07-02', 4618, 500.03, 15911.54, 7.15, 4, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'brown'),
(23, 5, 11, '2026-07-03', 4749, 527.00, 15791.71, 7.09, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'white'),
(24, 5, 11, '2026-07-04', 4438, 505.91, 15175.33, 7.64, 5, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'brown'),
(25, 5, 11, '2026-07-05', 4337, 534.85, 15051.85, 8.22, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'brown'),
(26, 5, 11, '2026-07-06', 4765, 526.14, 15244.02, 7.56, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'small', 'brown'),
(27, 5, 11, '2026-07-07', 4712, 507.61, 15314.68, 7.62, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'white'),
(28, 5, 11, '2026-07-08', 4456, 526.65, 15175.98, 7.55, 2, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'white'),
(29, 5, 11, '2026-07-09', 4381, 526.29, 15245.54, 7.13, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'white'),
(30, 5, 11, '2026-07-10', 4733, 527.69, 15358.97, 6.79, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'large', 'white'),
(31, 5, 11, '2026-07-11', 4705, 525.71, 15759.86, 6.80, 3, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'brown'),
(32, 5, 11, '2026-07-12', 4681, 514.60, 15488.46, 8.29, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'white'),
(33, 5, 11, '2026-07-13', 4563, 512.49, 15329.44, 7.51, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'small', 'brown'),
(34, 5, 11, '2026-07-14', 4583, 524.03, 15767.27, 6.71, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'brown'),
(35, 5, 11, '2026-07-15', 4313, 515.05, 15808.03, 7.38, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'white'),
(36, 5, 11, '2026-07-16', 4203, 513.43, 15628.83, 8.07, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'brown'),
(37, 5, 11, '2026-07-17', 4347, 546.69, 15695.89, 7.23, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'brown'),
(38, 5, 11, '2026-07-18', 4760, 521.06, 15503.03, 7.53, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'large', 'white'),
(39, 5, 11, '2026-07-19', 4142, 526.70, 15714.15, 8.29, 4, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'brown'),
(40, 5, 11, '2026-07-20', 4518, 503.40, 15184.21, 7.59, 5, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'white'),
(41, 5, 11, '2026-07-21', 4690, 516.80, 15700.21, 7.55, 2, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'brown'),
(42, 5, 11, '2026-07-22', 4386, 545.67, 15552.81, 6.55, 3, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'white'),
(43, 5, 11, '2026-07-23', 4044, 540.78, 15546.49, 7.49, 4, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'brown'),
(44, 5, 11, '2026-07-24', 4059, 549.88, 15472.47, 7.37, 3, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'white'),
(45, 5, 11, '2026-07-25', 4398, 507.50, 15551.25, 8.19, 5, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'white'),
(46, 5, 11, '2026-07-26', 4498, 543.65, 15811.58, 7.92, 3, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'large', 'brown'),
(47, 5, 11, '2026-07-27', 4072, 520.57, 15507.92, 7.13, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'brown'),
(48, 5, 11, '2026-07-28', 4559, 501.67, 15786.77, 8.47, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'brown'),
(49, 5, 11, '2026-07-29', 4494, 501.72, 15324.05, 8.04, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'white'),
(50, 5, 11, '2026-07-30', 4472, 515.51, 15226.47, 6.76, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'brown'),
(51, 5, 11, '2026-07-31', 4134, 504.37, 15571.49, 7.28, 1, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'extra_large', 'white'),
(52, 5, 11, '2026-08-01', 4505, 540.07, 15141.38, 7.90, 5, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'small', 'brown'),
(53, 5, 11, '2026-08-02', 4104, 530.72, 15782.93, 7.57, 4, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'medium', 'white'),
(54, 5, 11, '2026-08-03', 4390, 517.59, 15027.77, 6.58, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'small', 'brown'),
(55, 5, 11, '2026-08-04', 4345, 523.78, 15530.55, 7.69, 3, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'small', 'brown'),
(56, 5, 11, '2026-08-05', 4074, 540.29, 15634.60, 8.48, 4, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'jumbo', 'white'),
(57, 5, 11, '2026-08-06', 4785, 531.08, 15320.18, 7.03, 4, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'large', 'white'),
(58, 5, 11, '2026-08-07', 4132, 536.92, 15128.98, 7.48, 4, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'small', 'brown'),
(59, 5, 11, '2026-08-08', 4528, 540.75, 15919.32, 6.93, 0, 'Daily routine check.', '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'large', 'brown');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `farm_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `unit` enum('piece','tray','kilogram','head') NOT NULL DEFAULT 'piece',
  `price` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `location` varchar(255) DEFAULT NULL,
  `is_available` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `size` enum('small','medium','large') NOT NULL DEFAULT 'medium',
  `variety` enum('brown','white') NOT NULL DEFAULT 'brown'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `farmer_id`, `farm_id`, `name`, `description`, `unit`, `price`, `stock`, `location`, `is_available`, `created_at`, `updated_at`, `size`, `variety`) VALUES
(1, 2, 1, 'Fresh Eggs', 'Tray of fresh eggs from Sunrise Layer Farm.', 'tray', 180.00, 120, 'Cavite', 1, '2026-07-15 16:04:04', '2026-07-15 16:04:04', 'medium', 'brown'),
(2, 2, 2, 'Broiler Chickens', 'Healthy broiler chickens ready for delivery.', 'head', 95.00, 45, 'Laguna', 1, '2026-07-15 16:04:04', '2026-07-15 16:04:04', 'medium', 'brown'),
(3, 6, 3, 'Egg', NULL, 'tray', 7.00, 48, 'Paete', 1, '2026-07-15 09:41:23', '2026-07-15 09:57:39', 'small', 'brown'),
(4, 8, 4, 'Premium Large Brown Eggs', 'Fresh daily harvest', 'tray', 220.00, 100, NULL, 1, '2026-08-05 15:19:19', '2026-08-05 15:19:19', 'large', 'brown'),
(5, 8, 4, 'Medium White Eggs', 'Great for baking', 'tray', 180.00, 50, NULL, 1, '2026-08-05 15:19:19', '2026-08-05 15:19:19', 'medium', 'white'),
(6, 11, 5, 'Fresh Large Brown Eggs', 'Farm fresh brown eggs collected daily.', 'tray', 210.00, 100, 'Batangas', 1, '2026-08-09 14:57:42', '2026-08-09 14:57:42', 'large', 'brown');

-- --------------------------------------------------------

--
-- Table structure for table `sales_records`
--

CREATE TABLE `sales_records` (
  `id` int(11) NOT NULL,
  `farm_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `sale_date` date NOT NULL,
  `quantity_sold` int(11) NOT NULL,
  `price_per_egg` decimal(10,2) NOT NULL,
  `total_revenue` decimal(12,2) NOT NULL,
  `buyer_name` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sales_records`
--

INSERT INTO `sales_records` (`id`, `farm_id`, `user_id`, `sale_date`, `quantity_sold`, `price_per_egg`, `total_revenue`, `buyer_name`, `notes`, `created_at`, `updated_at`) VALUES
(1, 4, 8, '2026-08-05', 3, 180.00, 540.00, 'Demo Buyer', 'Auto-generated from Order #15', '2026-08-05 16:01:02', '2026-08-05 16:01:02'),
(2, 5, 11, '2026-07-22', 10, 210.00, 2100.00, 'Maria Clara', 'Fresh Large Brown Eggs (Order #23)', '2026-07-22 07:07:23', '2026-08-09 15:07:23'),
(3, 5, 11, '2026-07-20', 9, 210.00, 1890.00, 'Maria Clara', 'Fresh Large Brown Eggs (Order #29)', '2026-07-20 02:07:23', '2026-08-09 15:07:23'),
(4, 5, 11, '2026-07-29', 2, 210.00, 420.00, 'Maria Clara', 'Fresh Large Brown Eggs (Order #43)', '2026-07-29 12:07:23', '2026-08-09 15:07:23'),
(5, 5, 11, '2026-08-06', 9, 210.00, 1890.00, 'Maria Clara', 'Fresh Large Brown Eggs (Order #52)', '2026-08-06 14:07:23', '2026-08-09 15:07:23'),
(6, 5, 11, '2026-07-26', 2, 210.00, 420.00, 'Maria Clara', 'Fresh Large Brown Eggs (Order #54)', '2026-07-26 16:07:23', '2026-08-09 15:07:23'),
(7, 5, 11, '2026-08-02', 6, 210.00, 1260.00, 'Maria Clara', 'Fresh Large Brown Eggs (Order #60)', '2026-08-02 02:07:23', '2026-08-09 15:07:23'),
(8, 5, 11, '2026-08-03', 5, 210.00, 1050.00, 'Maria Clara', 'Fresh Large Brown Eggs (Order #67)', '2026-08-03 10:07:23', '2026-08-09 15:07:23'),
(9, 5, 11, '2026-07-30', 10, 210.00, 2100.00, 'Maria Clara', 'Fresh Large Brown Eggs (Order #68)', '2026-07-30 00:07:23', '2026-08-09 15:07:23'),
(10, 5, 11, '2026-08-09', 4, 210.00, 840.00, 'Maria Clara', 'Fresh Large Brown Eggs (Order #69)', '2026-08-09 15:07:23', '2026-08-09 15:07:23');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password_hash` varchar(256) NOT NULL,
  `role` enum('admin','farmer','buyer','feed_supplier','veterinarian') NOT NULL DEFAULT 'farmer',
  `first_name` varchar(64) DEFAULT NULL,
  `last_name` varchar(64) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `online_status` tinyint(1) NOT NULL DEFAULT 0,
  `last_seen` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `address` varchar(200) DEFAULT NULL,
  `landmark` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `role`, `first_name`, `last_name`, `phone`, `is_active`, `online_status`, `last_seen`, `created_at`, `updated_at`, `address`, `landmark`) VALUES
(1, 'admin', 'admin@poultryconnect.com', 'scrypt:32768:8:1$D9BhAxWKtWFZJWDl$63e9d41b219fd31e4b22a27c2813064adc92d03e25303ad8b9c28125bf18ee5ae035e922b22ec4afd9c9b318223adcebe73f6bdb067d271ea43a3849c6e215ee', 'admin', 'System', 'Admin', '09170000001', 1, 1, '2026-07-15 16:04:04', '2026-07-15 16:04:04', '2026-07-15 16:04:04', NULL, NULL),
(2, 'farmer1', 'farmer1@poultryconnect.com', 'scrypt:32768:8:1$D9BhAxWKtWFZJWDl$63e9d41b219fd31e4b22a27c2813064adc92d03e25303ad8b9c28125bf18ee5ae035e922b22ec4afd9c9b318223adcebe73f6bdb067d271ea43a3849c6e215ee', 'farmer', 'Juan', 'Dela Cruz', '09170000002', 1, 1, '2026-07-15 16:04:04', '2026-07-15 16:04:04', '2026-07-15 16:04:04', NULL, NULL),
(3, 'supplier1', 'supplier1@poultryconnect.com', 'scrypt:32768:8:1$D9BhAxWKtWFZJWDl$63e9d41b219fd31e4b22a27c2813064adc92d03e25303ad8b9c28125bf18ee5ae035e922b22ec4afd9c9b318223adcebe73f6bdb067d271ea43a3849c6e215ee', 'feed_supplier', 'Maria', 'Santos', '09170000003', 1, 1, '2026-07-15 16:04:04', '2026-07-15 16:04:04', '2026-07-15 16:04:04', NULL, NULL),
(4, 'vet1', 'vet1@poultryconnect.com', 'scrypt:32768:8:1$D9BhAxWKtWFZJWDl$63e9d41b219fd31e4b22a27c2813064adc92d03e25303ad8b9c28125bf18ee5ae035e922b22ec4afd9c9b318223adcebe73f6bdb067d271ea43a3849c6e215ee', 'veterinarian', 'Rosa', 'Cruz', '09170000004', 1, 1, '2026-07-15 16:04:04', '2026-07-15 16:04:04', '2026-07-15 16:04:04', NULL, NULL),
(5, 'buyer1', 'buyer1@poultryconnect.com', 'scrypt:32768:8:1$D9BhAxWKtWFZJWDl$63e9d41b219fd31e4b22a27c2813064adc92d03e25303ad8b9c28125bf18ee5ae035e922b22ec4afd9c9b318223adcebe73f6bdb067d271ea43a3849c6e215ee', 'buyer', 'Pedro', 'Reyes', '09170000005', 1, 0, '2026-07-15 16:04:04', '2026-07-15 16:04:04', '2026-07-15 16:04:04', NULL, NULL),
(6, 'jenrie', 'jenrie.araza12@gmail.com', 'scrypt:32768:8:1$6GnRje2dFwyME64s$e0bb6c8445bb14e0b6617aa062f7033fd80fe29412219b8be47c151d698195ecedb3b16ef8808927da764f71ded0a31228e73a4239835be35c106962a592cf6c', 'farmer', 'Jenrie', 'Araza', NULL, 1, 0, '2026-07-15 10:02:58', '2026-07-15 08:04:49', '2026-07-15 10:02:58', NULL, NULL),
(7, 'jeric', 'punay.jeric@gmail.com', 'scrypt:32768:8:1$Gk3kiVWefV5l9FdT$e1395bc712be122a14f345c79f8fe1a6149e5eb2c4029c3913ecf1917a159b2eab640bc2d70f74fc9105c82c7a3c50225d4a22cee05fec6c4c3d53db8ee6ee3d', 'buyer', 'Jeric', 'Punay', '09270196752', 1, 1, '2026-07-15 09:05:15', '2026-07-15 08:21:16', '2026-07-15 09:43:54', 'Santa Maria, Laguna', 'Near Plaza'),
(8, 'juan_farmer', 'juan@example.com', 'scrypt:32768:8:1$BaVcTavr7DKgUwTy$82c5307c9b0990a42b7562595e0b1c67e2130455c8854ec1546c2359339c27f5d3f48dcecda070bcf46077d056ff8fd6c2d81031033b57122f213b64d4c8b8bb', 'farmer', 'Juan', 'Dela Cruz', '09123456789', 1, 1, '2026-08-05 16:04:33', '2026-08-05 14:07:45', '2026-08-05 16:04:33', 'San Jose, Batangas', NULL),
(9, 'maria_buyer', 'maria@example.com', 'scrypt:32768:8:1$GuP9v4ZOHUWubK0T$1e90ccb7f67ef279891cb66478252981b20bce8c5fb9e0a8de51caa2882cacb11dbcdc828526a13be1c43ce5f51676295ce4cf7028b230ed5c273adf52884dad', 'buyer', 'Maria', 'Clara', '09987654321', 1, 0, NULL, '2026-08-05 14:07:45', '2026-08-05 14:07:45', 'Lipa City, Batangas', NULL),
(10, 'demo_buyer', 'demo_buyer@example.com', 'scrypt:32768:8:1$k4tRW87MXsaOL2pa$2f2a9f3f7985e200ce80678d3e53bb38c6655eeb34657e843772f0570c6cc9559eab5957d31634d620ef8f613eca136aaad1f6b900ef5118ca4293e455740029', 'buyer', 'Demo', 'Buyer', '09123456789', 1, 0, NULL, '2026-08-05 15:19:19', '2026-08-05 15:19:19', '123 Market St.', 'Near Plaza'),
(11, 'demo_farmer', 'farmer@demo.com', 'scrypt:32768:8:1$B9LwiUsRM5bH5Ufj$2fda8a18a0ea9afe17040d621522f1ef26c341cb6762687aab05ae17510de9d34b9c8f75ed86362947d519db3873198535dc7fa2483b73c69d6bdb1a295659d6', 'farmer', 'Juan', 'Dela Cruz', '09123456789', 1, 0, '2026-08-09 15:15:52', '2026-08-09 14:57:14', '2026-08-09 15:15:52', 'Brgy. San Jose, Batangas', NULL),
(13, 'demo_buyer_2026', 'buyer@demo.com', 'scrypt:32768:8:1$pJAOxwe3TCkgcoWT$5747e771b5fc6d5a3128da40f8da2fa7eba5ae6d3447b3d5157840f7fb7f252d3093ac098445f93e9e419d7793d311804ba26f16351cb513365e2c27c833454e', 'buyer', 'Maria', 'Clara', '09987654321', 1, 1, '2026-08-09 15:18:48', '2026-08-09 14:57:42', '2026-08-09 15:18:48', 'Makati City', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alembic_version`
--
ALTER TABLE `alembic_version`
  ADD PRIMARY KEY (`version_num`);

--
-- Indexes for table `conversations`
--
ALTER TABLE `conversations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_convo_pair` (`farmer_id`,`participant_id`),
  ADD KEY `idx_conversations_farmer` (`farmer_id`),
  ADD KEY `idx_conversations_participant` (`participant_id`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_expenses_farm` (`farm_id`),
  ADD KEY `idx_expenses_user` (`user_id`),
  ADD KEY `idx_expenses_date` (`expense_date`),
  ADD KEY `idx_expenses_category` (`category`);

--
-- Indexes for table `farms`
--
ALTER TABLE `farms`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_farms_farmer_id` (`farmer_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_messages_conversation` (`conversation_id`),
  ADD KEY `idx_messages_sender` (`sender_id`),
  ADD KEY `idx_messages_receiver` (`receiver_id`),
  ADD KEY `idx_messages_sent_at` (`sent_at`),
  ADD KEY `idx_messages_seen` (`is_seen`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_user` (`user_id`),
  ADD KEY `idx_notifications_read` (`is_read`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_orders_buyer` (`buyer_id`),
  ADD KEY `idx_orders_status` (`status`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_order_items_order` (`order_id`),
  ADD KEY `idx_order_items_product` (`product_id`);

--
-- Indexes for table `production_records`
--
ALTER TABLE `production_records`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_farm_record_date_size_variety` (`farm_id`,`record_date`,`size`,`variety`),
  ADD KEY `idx_production_farm` (`farm_id`),
  ADD KEY `idx_production_user` (`user_id`),
  ADD KEY `idx_production_date` (`record_date`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_products_farmer` (`farmer_id`),
  ADD KEY `idx_products_farm` (`farm_id`),
  ADD KEY `idx_products_available` (`is_available`);

--
-- Indexes for table `sales_records`
--
ALTER TABLE `sales_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `farm_id` (`farm_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_username` (`username`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_email` (`email`),
  ADD KEY `idx_users_username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `conversations`
--
ALTER TABLE `conversations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `farms`
--
ALTER TABLE `farms`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT for table `production_records`
--
ALTER TABLE `production_records`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `sales_records`
--
ALTER TABLE `sales_records`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `conversations`
--
ALTER TABLE `conversations`
  ADD CONSTRAINT `fk_conversations_farmer` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_conversations_participant` FOREIGN KEY (`participant_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `fk_expenses_farm` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_expenses_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `farms`
--
ALTER TABLE `farms`
  ADD CONSTRAINT `fk_farms_farmer` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `fk_messages_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_messages_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `production_records`
--
ALTER TABLE `production_records`
  ADD CONSTRAINT `fk_production_farm` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_production_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_farm` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_products_farmer` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `sales_records`
--
ALTER TABLE `sales_records`
  ADD CONSTRAINT `sales_records_ibfk_1` FOREIGN KEY (`farm_id`) REFERENCES `farms` (`id`),
  ADD CONSTRAINT `sales_records_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
