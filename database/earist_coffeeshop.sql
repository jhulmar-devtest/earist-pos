-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 29, 2026 at 09:22 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `earist_coffeeshop`
--

-- --------------------------------------------------------

--
-- Table structure for table `addons`
--

CREATE TABLE `addons` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `addons`
--

INSERT INTO `addons` (`id`, `name`, `price`, `status`, `created_at`) VALUES
(1, 'Espresso', 30.00, 'active', '2026-04-28 11:05:46'),
(2, 'Syrup', 20.00, 'active', '2026-04-28 11:06:10'),
(3, 'Nata', 15.00, 'active', '2026-04-28 11:06:28');

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` int UNSIGNED NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'bcrypt hash',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `full_name`, `username`, `password`, `created_at`, `updated_at`) VALUES
(1, 'Jhulmar Bregonia', 'bregonia@kapehan.com', '$2y$10$ojgcxq4VxZcaeiKDZsMcve6r6FYVEWttI43XzqY284WlUVqLl01xG', '2026-04-28 19:02:04', '2026-04-28 19:05:13');

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `id` int UNSIGNED NOT NULL,
  `actor_type` enum('admin','cashier','student','faculty') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor_id` int UNSIGNED NOT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'e.g. orders, products',
  `target_id` int UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cashiers`
--

CREATE TABLE `cashiers` (
  `id` int UNSIGNED NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified` tinyint(1) NOT NULL DEFAULT '0',
  `email_verified_at` datetime DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'bcrypt hash',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int UNSIGNED NOT NULL COMMENT 'admin.id who created this account',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cashiers`
--

INSERT INTO `cashiers` (`id`, `full_name`, `username`, `email`, `email_verified`, `email_verified_at`, `password`, `is_active`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'Jay Mark Amilagan', 'amilagan@kapehan.com', NULL, 0, NULL, '$2y$12$mhvu78xgH30ZTpmIv5JyX.3bi8ls6OuLNNmKYPH.dy0W0VmVdWXJy', 1, 1, '2026-04-28 19:04:33', '2026-04-28 19:04:33');

-- --------------------------------------------------------

--
-- Table structure for table `cashier_sessions`
--

CREATE TABLE `cashier_sessions` (
  `id` int UNSIGNED NOT NULL,
  `cashier_id` int UNSIGNED NOT NULL,
  `login_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `logout_at` datetime DEFAULT NULL COMMENT 'NULL = still logged in'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int UNSIGNED NOT NULL,
  `parent_id` int UNSIGNED DEFAULT NULL,
  `name` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` tinyint NOT NULL DEFAULT '0',
  `icon` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `parent_id`, `name`, `sort_order`, `icon`, `created_at`) VALUES
(1, NULL, 'Coffee', 1, NULL, '2026-04-28 19:11:46'),
(2, 1, 'Signature Coffee', 1, NULL, '2026-04-28 19:11:46'),
(3, 1, 'Hot Coffee', 2, NULL, '2026-04-28 19:21:02'),
(4, 1, 'Iced Coffee', 3, NULL, '2026-04-28 20:21:43'),
(5, NULL, 'Other Drinks', 1, NULL, '2026-04-28 22:05:03'),
(6, 5, 'Matcha Series', 1, NULL, '2026-04-28 22:05:03'),
(7, 5, 'Non-Coffee', 2, NULL, '2026-04-28 22:07:09'),
(8, 5, 'Milktea', 3, NULL, '2026-04-28 22:11:04'),
(9, 5, 'Cocktails', 4, NULL, '2026-04-28 22:14:23');

-- --------------------------------------------------------

--
-- Table structure for table `email_otps`
--

CREATE TABLE `email_otps` (
  `id` int UNSIGNED NOT NULL,
  `user_type` enum('student','faculty','cashier') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `otp` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `purpose` enum('verification','password_reset') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `attempts` tinyint NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `email_otps`
--

INSERT INTO `email_otps` (`id`, `user_type`, `user_id`, `email`, `otp`, `purpose`, `expires_at`, `used_at`, `attempts`, `created_at`) VALUES
(1, 'student', 1, 'zxc.jhulmar@gmail.com', '581928', 'verification', '2026-04-28 12:10:18', '2026-04-28 19:55:58', 0, '2026-04-28 19:55:18');

-- --------------------------------------------------------

--
-- Table structure for table `faculty`
--

CREATE TABLE `faculty` (
  `id` int UNSIGNED NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `faculty_id_no` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'bcrypt hash',
  `email_verified` tinyint(1) NOT NULL DEFAULT '0',
  `email_verified_at` datetime DEFAULT NULL,
  `id_declaration` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Faculty agreed to ID declaration',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int UNSIGNED NOT NULL,
  `order_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Human-readable e.g. ORD-20240101-0001',
  `order_type` enum('walk-in','pre-order') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','preparing','ready','claimed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `student_id` int UNSIGNED DEFAULT NULL COMMENT 'NULL for walk-in, can also reference faculty',
  `faculty_id` int UNSIGNED DEFAULT NULL,
  `cashier_id` int UNSIGNED DEFAULT NULL COMMENT 'NULL until cashier processes',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `locked_by` int UNSIGNED DEFAULT NULL COMMENT 'Cashier ID who locked this order for preparation',
  `locked_at` datetime DEFAULT NULL COMMENT 'When the order was locked',
  `lock_expire_at` datetime DEFAULT NULL COMMENT 'When the lock expires (auto-unlock)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_details`
--

CREATE TABLE `order_details` (
  `id` int UNSIGNED NOT NULL,
  `order_id` int UNSIGNED NOT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `quantity` tinyint NOT NULL,
  `price_at_time` decimal(8,2) NOT NULL COMMENT 'Snapshot price at time of order',
  `subtotal` decimal(10,2) NOT NULL COMMENT 'quantity * price_at_time',
  `customization_note` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'e.g. Large · Less Sugar · +Oat Milk, +Extra Shot'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_feedback`
--

CREATE TABLE `order_feedback` (
  `id` int UNSIGNED NOT NULL,
  `order_id` int UNSIGNED NOT NULL COMMENT 'One feedback per order',
  `student_id` int UNSIGNED NOT NULL,
  `faculty_id` int UNSIGNED DEFAULT NULL,
  `cashier_id` int UNSIGNED DEFAULT NULL COMMENT 'NULL for walk-in orders processed by unknown cashier',
  `rating` tinyint NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int UNSIGNED NOT NULL,
  `order_id` int UNSIGNED NOT NULL COMMENT 'One payment per order',
  `payment_method` enum('cash','online','GCash','PayMaya','Online Banking') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount_paid` decimal(10,2) NOT NULL,
  `change_given` decimal(10,2) NOT NULL DEFAULT '0.00',
  `payment_status` enum('pending','paid','refunded','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `reference_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'For online payments (GCash, PayMaya, etc.)',
  `paid_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_denominations`
--

CREATE TABLE `payment_denominations` (
  `id` int UNSIGNED NOT NULL,
  `payment_id` int UNSIGNED NOT NULL,
  `denomination` decimal(8,2) NOT NULL COMMENT 'e.g. 1000, 500, 0.50',
  `quantity` smallint UNSIGNED NOT NULL DEFAULT '0',
  `subtotal` decimal(10,2) GENERATED ALWAYS AS ((`denomination` * `quantity`)) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bill and coin breakdown for cash payments';

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int UNSIGNED NOT NULL,
  `category_id` int UNSIGNED NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `has_sizes` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1 = show Small/Medium/Large size picker',
  `has_sugar` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1 = show sugar level picker',
  `has_addons` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1 = show add-ons checkboxes',
  `price` decimal(8,2) NOT NULL,
  `image_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_available` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `category_id`, `name`, `description`, `has_sizes`, `has_sugar`, `has_addons`, `price`, `image_path`, `is_available`, `created_at`, `updated_at`) VALUES
(1, 2, 'Salt Coffee Kluea', '', 1, 1, 0, 145.00, '5b5668ceb80c88c0f5bfd8b48e055234.jpg', 1, '2026-04-28 19:11:46', '2026-04-28 19:11:46'),
(2, 2, 'Vanilla Cold Foam', '', 1, 1, 0, 145.00, '8407445eb927a656b65b89cb95b9706e.jpg', 1, '2026-04-28 19:11:46', '2026-04-28 19:11:46'),
(3, 2, 'Barista Choice', '', 1, 1, 0, 155.00, NULL, 1, '2026-04-28 19:11:46', '2026-04-28 19:11:46'),
(4, 2, 'Chocolate Hazelnut', '', 1, 1, 0, 145.00, '41c8abdc5525fa6aa505b3df6323d992.jpg', 1, '2026-04-28 19:11:46', '2026-04-28 19:11:46'),
(5, 2, 'Tiramisu Latte', '', 1, 1, 0, 145.00, 'f5f5588d1adb9db3e61af166a9137c69.webp', 1, '2026-04-28 19:11:46', '2026-04-28 19:11:46'),
(6, 2, 'Biscoff Latte', '', 1, 1, 0, 155.00, 'b12ca8f51705c25bc422d8c5db7250f0.jpg', 1, '2026-04-28 19:11:46', '2026-04-28 19:11:46'),
(7, 3, 'Americano', '', 1, 1, 0, 75.00, 'e872e618806fdd77b5dfcf94574304aa.webp', 1, '2026-04-28 19:21:02', '2026-04-28 19:21:02'),
(8, 3, 'Cappuccino', '', 1, 1, 0, 85.00, 'c78b9446ef02ee615ca2d7c6f06ada6f.jpg', 1, '2026-04-28 19:21:55', '2026-04-28 19:21:55'),
(9, 3, 'Vietnamese', '', 1, 1, 0, 95.00, '91a778e2a35a18eaf43db18b6e1955ee.webp', 1, '2026-04-28 19:22:52', '2026-04-28 19:22:52'),
(10, 3, 'Hot Mocha', '', 1, 1, 0, 105.00, '77e0db82181247ec1c2fbe194c50b52f.png', 1, '2026-04-28 20:01:11', '2026-04-28 20:01:11'),
(11, 3, 'White Mocha', '', 1, 1, 0, 110.00, 'f574da67b282aae975f29d9752da7baf.jpg', 1, '2026-04-28 20:05:34', '2026-04-28 20:05:45'),
(12, 3, 'Hot Salted Latte', '', 1, 1, 0, 110.00, '1a987a0657182d0bc17adc1f8a0f27e0.jpg', 1, '2026-04-28 20:06:40', '2026-04-28 20:06:40'),
(13, 3, 'Hot Caramel Macchiato', '', 1, 1, 0, 110.00, '5907369f84859e186588e84d540b2a3e.jpg', 1, '2026-04-28 20:07:24', '2026-04-28 20:07:24'),
(14, 3, 'Hot Hazelnut', '', 1, 1, 0, 105.00, 'b3b5152f12c144012ac9443fb0ddc7a2.webp', 1, '2026-04-28 20:09:51', '2026-04-28 20:09:51'),
(15, 3, 'Hot Vanilla', '', 1, 1, 0, 105.00, '2352288ba9446ae7b8b2300e041b4c96.jpg', 1, '2026-04-28 20:10:29', '2026-04-28 20:10:29'),
(16, 3, 'Matcha Coffee', '', 1, 1, 0, 120.00, '6124719ed39e98ce8c9423ab34960257.webp', 1, '2026-04-28 20:12:01', '2026-04-28 22:02:09'),
(17, 4, 'Flat White', '', 1, 1, 0, 95.00, '39ad7d6d55f6a3433cafeb27ae472182.jpg', 1, '2026-04-28 20:21:43', '2026-04-28 20:21:43'),
(18, 4, 'Iced Americano', '', 1, 1, 0, 85.00, 'afb1df4b4869433ac55afd910d7a861a.webp', 1, '2026-04-28 20:21:43', '2026-04-28 20:21:43'),
(19, 4, 'Iced Latte', '', 1, 1, 0, 105.00, '510b8e568ea333ea9ee29010cf4be9fb.jpg', 1, '2026-04-28 20:21:43', '2026-04-28 20:21:43'),
(20, 4, 'Spanish Latte', '', 1, 1, 0, 115.00, '706d8c0e0326d2bac68e1b8b0201a195.jpg', 1, '2026-04-28 20:21:43', '2026-04-28 20:21:43'),
(21, 4, 'Iced Mocha', '', 1, 1, 0, 135.00, '22ebfad9dae580d58ff8412dfb5824c6.jpg', 1, '2026-04-28 20:21:43', '2026-04-28 20:21:43'),
(22, 4, 'Vanilla Latte', '', 1, 1, 0, 125.00, '9c715a08505c00d7ef2409c8ff088249.jpg', 1, '2026-04-28 20:21:43', '2026-04-28 20:21:43'),
(23, 4, 'Iced White Mocha', '', 1, 1, 0, 135.00, '125b5bc50b05df32409e32af3814ca47.png', 1, '2026-04-28 20:21:43', '2026-04-28 20:21:43'),
(24, 4, 'Caramel Macchiato', '', 1, 1, 0, 135.00, '503311bfbbcf7428a7c234922aa4a4e9.jpg', 1, '2026-04-28 20:21:43', '2026-04-28 20:23:09'),
(25, 4, 'Hazelnut Latte', '', 1, 1, 0, 135.00, '9b2f4c5477373c3592f31f895496901f.jpg', 1, '2026-04-28 20:24:47', '2026-04-28 20:24:47'),
(26, 4, 'Salted Caramel Latte', '', 1, 1, 0, 135.00, '6c1cf7a7e6ab59bd7164dc9e73c52aec.jpg', 1, '2026-04-28 20:25:10', '2026-04-28 20:25:10'),
(27, 4, 'Vietnamese Ice', '', 1, 1, 0, 125.00, '0ab9c6e6acd937e93bd6c9e9d8d57bf7.jpg', 1, '2026-04-28 20:25:33', '2026-04-28 20:25:33'),
(28, 6, 'Matcha Latte White', '', 1, 1, 0, 125.00, '10e3617bf156dc2ab3d26f10db31443b.jpg', 1, '2026-04-28 22:05:03', '2026-04-28 22:05:03'),
(29, 6, 'Chocolate Matcha Sea Salt', '', 1, 1, 0, 145.00, '4af41071142a32e1179632ef2cb32622.jpg', 1, '2026-04-28 22:05:03', '2026-04-28 22:05:03'),
(30, 6, 'Matcha Espresso', '', 1, 1, 0, 145.00, '32eb31755222089f976b24c93eb4fbd2.jpg', 1, '2026-04-28 22:05:03', '2026-04-28 22:05:03'),
(31, 6, 'Strawberry Matcha', '', 1, 1, 0, 145.00, '9d12e567f8ca4a8f9c5bcf5ae8db9e41.jpg', 1, '2026-04-28 22:05:03', '2026-04-28 22:05:03'),
(32, 6, 'Matcha', '', 1, 1, 0, 145.00, '916f11b41fa6e6d72daeb7516544aa80.webp', 1, '2026-04-28 22:05:03', '2026-04-28 22:05:03'),
(33, 7, 'Dark Chocolate', '', 1, 1, 0, 105.00, '6ab6ec1dc71d89bd747e1ba4ad8b3fc5.jpg', 1, '2026-04-28 22:07:09', '2026-04-28 22:07:09'),
(34, 8, 'Cookies and Cream', '', 1, 1, 0, 79.00, 'da408520ce4194470dd746612e3a86d1.jpg', 1, '2026-04-28 22:11:04', '2026-04-28 22:11:04'),
(35, 8, 'Dark Chocolate', '', 1, 1, 0, 79.00, '2c9c1d8f49cedd401eb540e83bfec567.jpg', 1, '2026-04-28 22:11:04', '2026-04-28 22:11:04'),
(36, 8, 'Okinawa', '', 1, 1, 0, 79.00, '738599dbae4bdd3f37d20dfe6f7a3f00.webp', 1, '2026-04-28 22:11:04', '2026-04-28 22:11:04'),
(37, 8, 'Wintermelon', '', 1, 1, 0, 79.00, '897cef8a82fb5c148346b1f40d2b0322.jpg', 1, '2026-04-28 22:11:04', '2026-04-28 22:11:04'),
(38, 9, 'Blueberry', '', 1, 1, 0, 55.00, '13c8cc02dd90f85a391b4f2e02bfd786.jpg', 1, '2026-04-28 22:14:23', '2026-04-28 22:14:23'),
(39, 9, 'Strawberry', '', 1, 1, 0, 55.00, 'cfebedbde285a1874d77bafbe91422f6.jpg', 1, '2026-04-28 22:14:23', '2026-04-28 22:14:23'),
(40, 9, 'Green Apple', '', 1, 1, 0, 55.00, '8bc2e1413e39e46e6ebca52c4a166d54.jpg', 1, '2026-04-28 22:14:23', '2026-04-28 22:14:23'),
(41, 9, 'Lychee', '', 1, 1, 0, 55.00, '2698973bb550472079b9fcf46471b2d9.webp', 1, '2026-04-28 22:14:23', '2026-04-28 22:14:23');

-- --------------------------------------------------------

--
-- Table structure for table `product_addons`
--

CREATE TABLE `product_addons` (
  `product_id` int UNSIGNED NOT NULL,
  `addon_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_addons`
--

INSERT INTO `product_addons` (`product_id`, `addon_id`) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 1),
(9, 1),
(10, 1),
(11, 1),
(12, 1),
(13, 1),
(14, 1),
(15, 1),
(16, 1),
(17, 1),
(18, 1),
(19, 1),
(20, 1),
(21, 1),
(22, 1),
(23, 1),
(24, 1),
(25, 1),
(26, 1),
(27, 1),
(28, 1),
(29, 1),
(30, 1),
(31, 1),
(32, 1),
(33, 1),
(34, 1),
(35, 1),
(36, 1),
(37, 1),
(38, 1),
(39, 1),
(40, 1),
(41, 1),
(1, 2),
(2, 2),
(3, 2),
(4, 2),
(5, 2),
(6, 2),
(7, 2),
(8, 2),
(9, 2),
(10, 2),
(11, 2),
(12, 2),
(13, 2),
(14, 2),
(15, 2),
(16, 2),
(17, 2),
(18, 2),
(19, 2),
(20, 2),
(21, 2),
(22, 2),
(23, 2),
(24, 2),
(25, 2),
(26, 2),
(27, 2),
(28, 2),
(29, 2),
(30, 2),
(31, 2),
(32, 2),
(33, 2),
(34, 2),
(35, 2),
(36, 2),
(37, 2),
(38, 2),
(39, 2),
(40, 2),
(41, 2),
(1, 3),
(2, 3),
(3, 3),
(4, 3),
(5, 3),
(6, 3),
(7, 3),
(8, 3),
(9, 3),
(10, 3),
(11, 3),
(12, 3),
(13, 3),
(14, 3),
(15, 3),
(16, 3),
(17, 3),
(18, 3),
(19, 3),
(20, 3),
(21, 3),
(22, 3),
(23, 3),
(24, 3),
(25, 3),
(26, 3),
(27, 3),
(28, 3),
(29, 3),
(30, 3),
(31, 3),
(32, 3),
(33, 3),
(34, 3),
(35, 3),
(36, 3),
(37, 3),
(38, 3),
(39, 3),
(40, 3),
(41, 3);

-- --------------------------------------------------------

--
-- Table structure for table `product_ratings`
--

CREATE TABLE `product_ratings` (
  `id` int UNSIGNED NOT NULL,
  `feedback_id` int UNSIGNED NOT NULL COMMENT 'Links to order_feedback.id',
  `order_id` int UNSIGNED NOT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `student_id` int UNSIGNED DEFAULT NULL,
  `faculty_id` int UNSIGNED DEFAULT NULL,
  `rating` tinyint NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `product_rating_summary`
-- (See below for the actual view)
--
CREATE TABLE `product_rating_summary` (
`product_id` int unsigned
,`product_name` varchar(150)
,`image_path` varchar(255)
,`category_name` varchar(60)
,`total_ratings` bigint
,`avg_rating` decimal(6,2)
,`five_star` decimal(23,0)
,`four_star` decimal(23,0)
,`three_star` decimal(23,0)
,`two_star` decimal(23,0)
,`one_star` decimal(23,0)
,`total_sold` decimal(25,0)
);

-- --------------------------------------------------------

--
-- Table structure for table `refund_requests`
--

CREATE TABLE `refund_requests` (
  `id` int UNSIGNED NOT NULL,
  `order_id` int UNSIGNED NOT NULL,
  `student_id` int UNSIGNED NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `admin_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `reviewed_by` int UNSIGNED DEFAULT NULL COMMENT 'admin.id',
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `id` int UNSIGNED NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_id_no` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `course` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified` tinyint(1) NOT NULL DEFAULT '0',
  `email_verified_at` datetime DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'bcrypt hash',
  `id_declaration` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Student agreed to ID declaration',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `full_name`, `student_id_no`, `course`, `email`, `email_verified`, `email_verified_at`, `password`, `id_declaration`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Jhulmar Bregonia', '2316-02097C', 'BS Information Technology', 'zxc.jhulmar@gmail.com', 1, '2026-04-28 19:55:58', '$2y$12$egtJRayCJT3zHqCWw.8jSOlD1Vsw43oiB.3k9NYoJARkg8LlVlURq', 1, 1, '2026-04-28 19:55:18', '2026-04-28 19:55:58');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `addons`
--
ALTER TABLE `addons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_actor` (`actor_type`,`actor_id`),
  ADD KEY `idx_audit_created` (`created_at`);

--
-- Indexes for table `cashiers`
--
ALTER TABLE `cashiers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_cashier_admin` (`created_by`);

--
-- Indexes for table `cashier_sessions`
--
ALTER TABLE `cashier_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cs_cashier` (`cashier_id`),
  ADD KEY `idx_cs_login_at` (`login_at`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `fk_cat_parent` (`parent_id`);

--
-- Indexes for table `email_otps`
--
ALTER TABLE `email_otps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_otp_lookup` (`user_type`,`user_id`,`purpose`),
  ADD KEY `idx_otp_expires` (`expires_at`),
  ADD KEY `idx_otp_email` (`email`,`purpose`);

--
-- Indexes for table `faculty`
--
ALTER TABLE `faculty`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `faculty_id_no` (`faculty_id_no`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_number` (`order_number`),
  ADD KEY `fk_order_cashier` (`cashier_id`),
  ADD KEY `idx_orders_status` (`status`),
  ADD KEY `idx_orders_type` (`order_type`),
  ADD KEY `idx_orders_created_at` (`created_at`),
  ADD KEY `idx_orders_student` (`student_id`),
  ADD KEY `idx_orders_locked` (`locked_by`,`locked_at`),
  ADD KEY `idx_orders_lock_expire` (`lock_expire_at`),
  ADD KEY `fk_order_faculty` (`faculty_id`);

--
-- Indexes for table `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_od_order` (`order_id`),
  ADD KEY `idx_od_product` (`product_id`);

--
-- Indexes for table `order_feedback`
--
ALTER TABLE `order_feedback`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_id` (`order_id`),
  ADD KEY `idx_fb_student` (`student_id`),
  ADD KEY `idx_fb_cashier` (`cashier_id`),
  ADD KEY `idx_fb_rating` (`rating`),
  ADD KEY `idx_fb_created` (`created_at`),
  ADD KEY `fk_feedback_faculty` (`faculty_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_id` (`order_id`);

--
-- Indexes for table `payment_denominations`
--
ALTER TABLE `payment_denominations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_payment_id` (`payment_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_product_category` (`category_id`);

--
-- Indexes for table `product_addons`
--
ALTER TABLE `product_addons`
  ADD PRIMARY KEY (`product_id`,`addon_id`),
  ADD KEY `fk_pa_addon` (`addon_id`);

--
-- Indexes for table `product_ratings`
--
ALTER TABLE `product_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_product_order` (`product_id`,`order_id`),
  ADD KEY `fk_pr_feedback` (`feedback_id`),
  ADD KEY `fk_pr_order` (`order_id`),
  ADD KEY `idx_pr_product` (`product_id`),
  ADD KEY `idx_pr_student` (`student_id`),
  ADD KEY `idx_pr_rating` (`rating`),
  ADD KEY `fk_pr_faculty` (`faculty_id`);

--
-- Indexes for table `refund_requests`
--
ALTER TABLE `refund_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_refund_order` (`order_id`),
  ADD KEY `fk_refund_student` (`student_id`),
  ADD KEY `fk_refund_admin` (`reviewed_by`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_id_no` (`student_id_no`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `addons`
--
ALTER TABLE `addons`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cashiers`
--
ALTER TABLE `cashiers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `cashier_sessions`
--
ALTER TABLE `cashier_sessions`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `email_otps`
--
ALTER TABLE `email_otps`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `faculty`
--
ALTER TABLE `faculty`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_details`
--
ALTER TABLE `order_details`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_feedback`
--
ALTER TABLE `order_feedback`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payment_denominations`
--
ALTER TABLE `payment_denominations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `product_ratings`
--
ALTER TABLE `product_ratings`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `refund_requests`
--
ALTER TABLE `refund_requests`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

-- --------------------------------------------------------

--
-- Structure for view `product_rating_summary`
--
DROP TABLE IF EXISTS `product_rating_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `product_rating_summary`  AS SELECT `p`.`id` AS `product_id`, `p`.`name` AS `product_name`, `p`.`image_path` AS `image_path`, `c`.`name` AS `category_name`, count(`pr`.`id`) AS `total_ratings`, round(avg(`pr`.`rating`),2) AS `avg_rating`, sum((`pr`.`rating` = 5)) AS `five_star`, sum((`pr`.`rating` = 4)) AS `four_star`, sum((`pr`.`rating` = 3)) AS `three_star`, sum((`pr`.`rating` = 2)) AS `two_star`, sum((`pr`.`rating` = 1)) AS `one_star`, coalesce((select sum(`od`.`quantity`) from `order_details` `od` where (`od`.`product_id` = `p`.`id`)),0) AS `total_sold` FROM ((`products` `p` left join `categories` `c` on((`p`.`category_id` = `c`.`id`))) left join `product_ratings` `pr` on((`pr`.`product_id` = `p`.`id`))) GROUP BY `p`.`id`, `p`.`name`, `p`.`image_path`, `c`.`name` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cashiers`
--
ALTER TABLE `cashiers`
  ADD CONSTRAINT `fk_cashier_admin` FOREIGN KEY (`created_by`) REFERENCES `admins` (`id`);

--
-- Constraints for table `cashier_sessions`
--
ALTER TABLE `cashier_sessions`
  ADD CONSTRAINT `fk_cs_cashier` FOREIGN KEY (`cashier_id`) REFERENCES `cashiers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `fk_cat_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_order_cashier` FOREIGN KEY (`cashier_id`) REFERENCES `cashiers` (`id`),
  ADD CONSTRAINT `fk_order_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculty` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_order_locked_by` FOREIGN KEY (`locked_by`) REFERENCES `cashiers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_order_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`);

--
-- Constraints for table `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `fk_od_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_od_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `order_feedback`
--
ALTER TABLE `order_feedback`
  ADD CONSTRAINT `fk_fb_cashier` FOREIGN KEY (`cashier_id`) REFERENCES `cashiers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_fb_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_fb_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_feedback_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculty` (`id`);

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_payment_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Constraints for table `payment_denominations`
--
ALTER TABLE `payment_denominations`
  ADD CONSTRAINT `fk_denom_payment` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

--
-- Constraints for table `product_addons`
--
ALTER TABLE `product_addons`
  ADD CONSTRAINT `fk_pa_addon` FOREIGN KEY (`addon_id`) REFERENCES `addons` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pa_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_ratings`
--
ALTER TABLE `product_ratings`
  ADD CONSTRAINT `fk_pr_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculty` (`id`),
  ADD CONSTRAINT `fk_pr_feedback` FOREIGN KEY (`feedback_id`) REFERENCES `order_feedback` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pr_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pr_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pr_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `refund_requests`
--
ALTER TABLE `refund_requests`
  ADD CONSTRAINT `fk_refund_admin` FOREIGN KEY (`reviewed_by`) REFERENCES `admins` (`id`),
  ADD CONSTRAINT `fk_refund_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `fk_refund_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
