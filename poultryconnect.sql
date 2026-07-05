-- PoultryConnect MySQL/MariaDB database dump for XAMPP phpMyAdmin
-- Import this file directly into phpMyAdmin.
-- It creates the full schema and sample data for immediate use.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS poultryconnect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE poultryconnect;

DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS conversations;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS production_records;
DROP TABLE IF EXISTS farms;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL,
  email VARCHAR(120) NOT NULL,
  password_hash VARCHAR(256) NOT NULL,
  role ENUM('admin','farmer','buyer','feed_supplier','veterinarian') NOT NULL DEFAULT 'farmer',
  first_name VARCHAR(64) DEFAULT NULL,
  last_name VARCHAR(64) DEFAULT NULL,
  phone VARCHAR(20) DEFAULT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  online_status TINYINT(1) NOT NULL DEFAULT 0,
  last_seen DATETIME DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_username (username),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_role (role),
  KEY idx_users_email (email),
  KEY idx_users_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE farms (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  farmer_id INT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  location VARCHAR(255) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  flock_size INT DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_farms_farmer_id (farmer_id),
  CONSTRAINT fk_farms_farmer FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE production_records (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  farm_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  record_date DATE NOT NULL,
  egg_count INT NOT NULL DEFAULT 0,
  feed_kg DECIMAL(8,2) DEFAULT 0.00,
  feed_cost DECIMAL(10,2) DEFAULT 0.00,
  egg_price DECIMAL(10,2) DEFAULT NULL,
  mortality INT DEFAULT 0,
  notes TEXT DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_farm_record_date (farm_id, record_date),
  KEY idx_production_farm (farm_id),
  KEY idx_production_user (user_id),
  KEY idx_production_date (record_date),
  CONSTRAINT fk_production_farm FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_production_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE expenses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  farm_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  expense_date DATE NOT NULL,
  category ENUM('feed','labor','utilities','medicine','other') NOT NULL DEFAULT 'other',
  amount DECIMAL(10,2) NOT NULL,
  description VARCHAR(255) DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_expenses_farm (farm_id),
  KEY idx_expenses_user (user_id),
  KEY idx_expenses_date (expense_date),
  KEY idx_expenses_category (category),
  CONSTRAINT fk_expenses_farm FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_expenses_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE products (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  farmer_id INT UNSIGNED NOT NULL,
  farm_id INT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT DEFAULT NULL,
  category ENUM('eggs','live_birds','dressed','other') NOT NULL DEFAULT 'eggs',
  unit ENUM('piece','tray','kilogram','head') NOT NULL DEFAULT 'piece',
  price DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  location VARCHAR(255) DEFAULT NULL,
  is_available TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_products_farmer (farmer_id),
  KEY idx_products_farm (farm_id),
  KEY idx_products_category (category),
  KEY idx_products_available (is_available),
  CONSTRAINT fk_products_farmer FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_products_farm FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE orders (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  buyer_id INT UNSIGNED NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  status ENUM('pending','confirmed','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  delivery_address VARCHAR(500) NOT NULL,
  contact_phone VARCHAR(30) NOT NULL,
  notes TEXT DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_orders_buyer (buyer_id),
  KEY idx_orders_status (status),
  CONSTRAINT fk_orders_buyer FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_items (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_order_items_order (order_id),
  KEY idx_order_items_product (product_id),
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE conversations (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  farmer_id INT UNSIGNED NOT NULL,
  participant_id INT UNSIGNED NOT NULL,
  participant_role VARCHAR(32) NOT NULL,
  deleted_by_farmer TINYINT(1) DEFAULT 0,
  deleted_by_participant TINYINT(1) DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_convo_pair (farmer_id, participant_id),
  KEY idx_conversations_farmer (farmer_id),
  KEY idx_conversations_participant (participant_id),
  CONSTRAINT fk_conversations_farmer FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_conversations_participant FOREIGN KEY (participant_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE messages (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id INT UNSIGNED NOT NULL,
  sender_id INT UNSIGNED NOT NULL,
  receiver_id INT UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  delivered_at DATETIME DEFAULT NULL,
  seen_at DATETIME DEFAULT NULL,
  is_seen TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_messages_conversation (conversation_id),
  KEY idx_messages_sender (sender_id),
  KEY idx_messages_receiver (receiver_id),
  KEY idx_messages_sent_at (sent_at),
  KEY idx_messages_seen (is_seen),
  CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notifications (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  title VARCHAR(120) NOT NULL,
  body VARCHAR(255) NOT NULL,
  notif_type VARCHAR(32) NOT NULL DEFAULT 'message',
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  link_url VARCHAR(255) DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_notifications_user (user_id),
  KEY idx_notifications_read (is_read),
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample data
INSERT INTO users (id, username, email, password_hash, role, first_name, last_name, phone, is_active, online_status, last_seen) VALUES
(1, 'admin', 'admin@poultryconnect.com', 'scrypt:32768:8:1$D9BhAxWKtWFZJWDl$63e9d41b219fd31e4b22a27c2813064adc92d03e25303ad8b9c28125bf18ee5ae035e922b22ec4afd9c9b318223adcebe73f6bdb067d271ea43a3849c6e215ee', 'admin', 'System', 'Admin', '09170000001', 1, 1, NOW()),
(2, 'farmer1', 'farmer1@poultryconnect.com', 'scrypt:32768:8:1$D9BhAxWKtWFZJWDl$63e9d41b219fd31e4b22a27c2813064adc92d03e25303ad8b9c28125bf18ee5ae035e922b22ec4afd9c9b318223adcebe73f6bdb067d271ea43a3849c6e215ee', 'farmer', 'Juan', 'Dela Cruz', '09170000002', 1, 1, NOW()),
(3, 'supplier1', 'supplier1@poultryconnect.com', 'scrypt:32768:8:1$D9BhAxWKtWFZJWDl$63e9d41b219fd31e4b22a27c2813064adc92d03e25303ad8b9c28125bf18ee5ae035e922b22ec4afd9c9b318223adcebe73f6bdb067d271ea43a3849c6e215ee', 'feed_supplier', 'Maria', 'Santos', '09170000003', 1, 1, NOW()),
(4, 'vet1', 'vet1@poultryconnect.com', 'scrypt:32768:8:1$D9BhAxWKtWFZJWDl$63e9d41b219fd31e4b22a27c2813064adc92d03e25303ad8b9c28125bf18ee5ae035e922b22ec4afd9c9b318223adcebe73f6bdb067d271ea43a3849c6e215ee', 'veterinarian', 'Rosa', 'Cruz', '09170000004', 1, 1, NOW()),
(5, 'buyer1', 'buyer1@poultryconnect.com', 'scrypt:32768:8:1$D9BhAxWKtWFZJWDl$63e9d41b219fd31e4b22a27c2813064adc92d03e25303ad8b9c28125bf18ee5ae035e922b22ec4afd9c9b318223adcebe73f6bdb067d271ea43a3849c6e215ee', 'buyer', 'Pedro', 'Reyes', '09170000005', 1, 0, NOW());

INSERT INTO farms (id, farmer_id, name, location, description, flock_size, is_active) VALUES
(1, 2, 'Sunrise Layer Farm', 'Cavite', 'Layer farm producing fresh eggs.', 1200, 1),
(2, 2, 'Green Feed Poultry', 'Laguna', 'Broiler and feed support farm.', 800, 1);

INSERT INTO production_records (id, farm_id, user_id, record_date, egg_count, feed_kg, feed_cost, egg_price, mortality, notes) VALUES
(1, 1, 2, '2026-07-01', 980, 220.50, 15435.00, 5.50, 3, 'Steady production after vaccination.'),
(2, 1, 2, '2026-07-02', 1010, 225.00, 15750.00, 5.50, 2, 'Improved feed conversion.');

INSERT INTO expenses (id, farm_id, user_id, expense_date, category, amount, description) VALUES
(1, 1, 2, '2026-07-02', 'feed', 15750.00, 'Poultry starter feed purchase'),
(2, 1, 2, '2026-07-03', 'medicine', 3200.00, 'Vaccination medicine');

INSERT INTO products (id, farmer_id, farm_id, name, description, category, unit, price, stock, location, is_available) VALUES
(1, 2, 1, 'Fresh Eggs', 'Tray of fresh eggs from Sunrise Layer Farm.', 'eggs', 'tray', 180.00, 120, 'Cavite', 1),
(2, 2, 2, 'Broiler Chickens', 'Healthy broiler chickens ready for delivery.', 'live_birds', 'head', 95.00, 45, 'Laguna', 1);

INSERT INTO orders (id, buyer_id, total_amount, status, delivery_address, contact_phone, notes) VALUES
(1, 5, 540.00, 'pending', '123 Main Street, Quezon City', '09170000005', 'Please deliver in the morning.');

INSERT INTO order_items (id, order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 3, 180.00);

INSERT INTO conversations (id, farmer_id, participant_id, participant_role, deleted_by_farmer, deleted_by_participant) VALUES
(1, 2, 3, 'feed_supplier', 0, 0),
(2, 2, 4, 'veterinarian', 0, 0);

INSERT INTO messages (id, conversation_id, sender_id, receiver_id, body, sent_at, delivered_at, seen_at, is_seen) VALUES
(1, 1, 2, 3, 'Good morning, do you have available starter feed?', '2026-07-04 08:00:00', '2026-07-04 08:01:00', '2026-07-04 08:02:00', 1),
(2, 1, 3, 2, 'Yes, we have stock for delivery today.', '2026-07-04 08:05:00', '2026-07-04 08:06:00', NULL, 0),
(3, 2, 2, 4, 'Hi Doc, our flock seems less active today.', '2026-07-04 09:00:00', '2026-07-04 09:01:00', NULL, 0),
(4, 2, 4, 2, 'Please monitor the water intake and temperature.', '2026-07-04 09:10:00', '2026-07-04 09:11:00', NULL, 0);

INSERT INTO notifications (id, user_id, title, body, notif_type, is_read, link_url) VALUES
(1, 3, 'New message', 'You received a new message from Juan Dela Cruz.', 'message', 0, '/messaging/?open=1'),
(2, 4, 'New message', 'You received a new message from Juan Dela Cruz.', 'message', 0, '/messaging/?open=2');
