-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 15, 2026 at 12:05 PM
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
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`id`, `farm_id`, `user_id`, `expense_date`, `category`, `amount`, `description`, `created_at`, `updated_at`) VALUES
(1, 1, 2, '2026-07-02', 'feed', 15750.00, 'Poultry starter feed purchase', '2026-07-15 16:04:04', '2026-07-15 16:04:04'),
(2, 1, 2, '2026-07-03', 'medicine', 3200.00, 'Vaccination medicine', '2026-07-15 16:04:04', '2026-07-15 16:04:04');

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
(3, 6, 'Paete Farm', 'Paete', NULL, 500, 1, '2026-07-15 09:06:02', '2026-07-15 09:06:02');

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
(4, 7, 7.00, 'pending', 'Near Plaza, Santa Maria, Laguna', '09270196752', NULL, '2026-07-15 09:57:39', '2026-07-15 09:57:39');

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
(3, 4, 3, 1, 7.00);

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
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `production_records`
--

INSERT INTO `production_records` (`id`, `farm_id`, `user_id`, `record_date`, `egg_count`, `feed_kg`, `feed_cost`, `egg_price`, `mortality`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 2, '2026-07-01', 980, 220.50, 15435.00, 5.50, 3, 'Steady production after vaccination.', '2026-07-15 16:04:04', '2026-07-15 16:04:04'),
(2, 1, 2, '2026-07-02', 1010, 225.00, 15750.00, 5.50, 2, 'Improved feed conversion.', '2026-07-15 16:04:04', '2026-07-15 16:04:04');

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
(3, 6, 3, 'Egg', NULL, 'tray', 7.00, 48, 'Paete', 1, '2026-07-15 09:41:23', '2026-07-15 09:57:39', 'small', 'brown');

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
(7, 'jeric', 'punay.jeric@gmail.com', 'scrypt:32768:8:1$Gk3kiVWefV5l9FdT$e1395bc712be122a14f345c79f8fe1a6149e5eb2c4029c3913ecf1917a159b2eab640bc2d70f74fc9105c82c7a3c50225d4a22cee05fec6c4c3d53db8ee6ee3d', 'buyer', 'Jeric', 'Punay', '09270196752', 1, 1, '2026-07-15 09:05:15', '2026-07-15 08:21:16', '2026-07-15 09:43:54', 'Santa Maria, Laguna', 'Near Plaza');

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
  ADD UNIQUE KEY `uq_farm_record_date` (`farm_id`,`record_date`),
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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `farms`
--
ALTER TABLE `farms`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `production_records`
--
ALTER TABLE `production_records`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
