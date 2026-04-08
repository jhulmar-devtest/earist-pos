-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 08, 2026 at 06:33 AM
-- Server version: 8.4.3
-- PHP Version: 8.3.30

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
(1, 'jorge', 'jorge', '$2y$10$mAXfDYmeKAjP8IPDNFJZKOPk5eeHUaettfOSeX6YIkeY6hFcP.7cS', '2026-04-07 10:51:34', '2026-04-07 10:51:34');

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `id` int UNSIGNED NOT NULL,
  `actor_type` enum('admin','cashier','student') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor_id` int UNSIGNED NOT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'e.g. orders, products',
  `target_id` int UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_log`
--

INSERT INTO `audit_log` (`id`, `actor_type`, `actor_id`, `action`, `target`, `target_id`, `ip_address`, `created_at`) VALUES
(1, 'admin', 1, 'login', NULL, NULL, '::1', '2026-04-07 10:51:54'),
(2, 'admin', 1, 'logout', NULL, NULL, '::1', '2026-04-07 10:52:48'),
(3, 'admin', 1, 'login', NULL, NULL, '::1', '2026-04-07 10:53:19'),
(4, 'admin', 1, 'create_cashier', NULL, NULL, '::1', '2026-04-07 10:53:45'),
(5, 'admin', 1, 'logout', NULL, NULL, '::1', '2026-04-07 10:54:15'),
(6, 'cashier', 1, 'login', NULL, NULL, '::1', '2026-04-07 10:54:29'),
(7, 'cashier', 1, 'logout', NULL, NULL, '::1', '2026-04-07 10:55:05'),
(8, 'admin', 1, 'login', NULL, NULL, '::1', '2026-04-07 10:55:13'),
(9, 'admin', 1, 'logout', NULL, NULL, '::1', '2026-04-07 10:56:48'),
(10, 'cashier', 1, 'login', NULL, NULL, '::1', '2026-04-07 10:56:59'),
(11, 'cashier', 1, 'logout', NULL, NULL, '::1', '2026-04-07 11:00:30'),
(12, 'admin', 1, 'login', NULL, NULL, '::1', '2026-04-07 11:06:23'),
(13, 'admin', 1, 'add_category', 'categories', 1, '::1', '2026-04-07 11:23:52'),
(14, 'admin', 1, 'add_category', 'categories', 2, '::1', '2026-04-07 11:24:39'),
(15, 'cashier', 1, 'login', NULL, NULL, '::1', '2026-04-07 11:25:36'),
(16, 'admin', 1, 'add_category', 'categories', 3, '::1', '2026-04-07 12:13:17'),
(17, 'admin', 1, 'add_category', 'categories', 4, '::1', '2026-04-07 12:35:15'),
(18, 'admin', 1, 'add_product', 'products', 1, '::1', '2026-04-07 12:35:15'),
(19, 'admin', 1, 'add_category', 'categories', 6, '::1', '2026-04-07 12:36:42'),
(20, 'admin', 1, 'add_product', 'products', 2, '::1', '2026-04-07 12:36:42'),
(21, 'admin', 1, 'add_product', 'products', 3, '::1', '2026-04-07 12:37:51'),
(22, 'admin', 1, 'delete_category', 'categories', 1, '::1', '2026-04-07 13:01:21'),
(23, 'admin', 1, 'delete_category', 'categories', 6, '::1', '2026-04-07 13:01:26'),
(24, 'admin', 1, 'delete_category', 'categories', 3, '::1', '2026-04-07 13:01:28'),
(25, 'admin', 1, 'add_category', 'categories', 8, '::1', '2026-04-07 13:13:40'),
(26, 'admin', 1, 'add_product', 'products', 4, '::1', '2026-04-07 13:13:40'),
(27, 'admin', 1, 'delete_category', 'categories', 7, '::1', '2026-04-07 13:25:24'),
(28, 'admin', 1, 'add_category', 'categories', 10, '::1', '2026-04-07 13:26:26'),
(29, 'admin', 1, 'add_product', 'products', 5, '::1', '2026-04-07 13:26:26'),
(30, 'admin', 1, 'add_category', 'categories', 11, '::1', '2026-04-07 13:28:39'),
(31, 'admin', 1, 'add_category', 'categories', 12, '::1', '2026-04-07 13:33:47'),
(32, 'admin', 1, 'add_product', 'products', 6, '::1', '2026-04-07 13:33:47'),
(33, 'admin', 1, 'add_category', 'categories', 14, '::1', '2026-04-07 13:35:05'),
(34, 'admin', 1, 'add_product', 'products', 7, '::1', '2026-04-07 13:35:05'),
(35, 'admin', 1, 'add_category', 'categories', 20, '::1', '2026-04-07 13:54:47'),
(36, 'admin', 1, 'add_product', 'products', 8, '::1', '2026-04-07 13:54:47'),
(37, 'admin', 1, 'add_category', 'categories', 21, '::1', '2026-04-07 14:07:51'),
(38, 'admin', 1, 'add_product', 'products', 9, '::1', '2026-04-07 14:07:51'),
(39, 'admin', 1, 'delete_category', 'categories', 21, '::1', '2026-04-07 14:08:02'),
(40, 'admin', 1, 'add_category', 'categories', 23, '::1', '2026-04-07 14:15:54'),
(41, 'admin', 1, 'add_product', 'products', 10, '::1', '2026-04-07 14:15:54'),
(42, 'admin', 1, 'delete_category', 'categories', 22, '::1', '2026-04-07 14:40:04'),
(43, 'admin', 1, 'add_category', 'categories', 25, '::1', '2026-04-07 14:40:51'),
(44, 'admin', 1, 'add_product', 'products', 11, '::1', '2026-04-07 14:40:51'),
(45, 'admin', 1, 'delete_category', 'categories', 9, '::1', '2026-04-07 15:19:06'),
(46, 'admin', 1, 'delete_category', 'categories', 13, '::1', '2026-04-07 15:19:08'),
(47, 'admin', 1, 'delete_category', 'categories', 15, '::1', '2026-04-07 15:19:10'),
(48, 'admin', 1, 'delete_category', 'categories', 24, '::1', '2026-04-07 15:19:12'),
(49, 'admin', 1, 'add_category', 'categories', 27, '::1', '2026-04-07 15:37:03'),
(50, 'admin', 1, 'add_product', 'products', 12, '::1', '2026-04-07 15:37:03'),
(51, 'admin', 1, 'delete_category', 'categories', 26, '::1', '2026-04-07 15:38:36'),
(52, 'admin', 1, 'add_category', 'categories', 29, '::1', '2026-04-07 15:39:42'),
(53, 'admin', 1, 'add_product', 'products', 13, '::1', '2026-04-07 15:39:42'),
(54, 'admin', 1, 'add_product', 'products', 14, '::1', '2026-04-07 15:40:47'),
(55, 'admin', 1, 'add_category', 'categories', 30, '::1', '2026-04-07 15:41:59'),
(56, 'admin', 1, 'add_product', 'products', 15, '::1', '2026-04-07 15:41:59'),
(57, 'admin', 1, 'add_category', 'categories', 32, '::1', '2026-04-07 15:43:36'),
(58, 'admin', 1, 'add_product', 'products', 16, '::1', '2026-04-07 15:43:36'),
(59, 'admin', 1, 'login', NULL, NULL, '::1', '2026-04-07 16:18:51'),
(60, 'cashier', 1, 'login', NULL, NULL, '::1', '2026-04-07 16:19:23');

-- --------------------------------------------------------

--
-- Table structure for table `cashiers`
--

CREATE TABLE `cashiers` (
  `id` int UNSIGNED NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'bcrypt hash',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int UNSIGNED NOT NULL COMMENT 'admin.id who created this account',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cashiers`
--

INSERT INTO `cashiers` (`id`, `full_name`, `username`, `password`, `is_active`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'Jorge Banagan', 'jorge', '$2y$12$dyBUzMjDv8K1frmqNNN07eGKSRSJoZlgiIR2UkH3E40.8ebFmv0sC', 1, 1, '2026-04-07 10:53:45', '2026-04-07 10:53:45');

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

--
-- Dumping data for table `cashier_sessions`
--

INSERT INTO `cashier_sessions` (`id`, `cashier_id`, `login_at`, `logout_at`) VALUES
(1, 1, '2026-04-07 10:54:29', '2026-04-07 10:55:05'),
(2, 1, '2026-04-07 10:56:59', '2026-04-07 11:00:30'),
(3, 1, '2026-04-07 11:25:36', NULL),
(4, 1, '2026-04-07 16:19:23', NULL);

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
(28, NULL, 'Menu', 1, NULL, '2026-04-07 15:39:42'),
(29, 28, 'Coffee', 1, NULL, '2026-04-07 15:39:42'),
(30, 28, 'Snacks', 2, NULL, '2026-04-07 15:41:59'),
(31, NULL, 'Liwanag Special', 1, NULL, '2026-04-07 15:43:36'),
(32, 31, 'Non-Coffee', 1, NULL, '2026-04-07 15:43:36');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int UNSIGNED NOT NULL,
  `order_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Human-readable e.g. ORD-20240101-0001',
  `order_type` enum('walk-in','pre-order') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','preparing','ready','claimed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `student_id` int UNSIGNED DEFAULT NULL COMMENT 'NULL for walk-in',
  `cashier_id` int UNSIGNED DEFAULT NULL COMMENT 'NULL until cashier processes',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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
(13, 29, 'Coffee Latte', '', 1, 1, 1, 23.00, '6f73ed0481f446e21f77eb537e81a002.jpg', 1, '2026-04-07 15:39:42', '2026-04-07 15:39:42'),
(14, 29, 'Macchiato', '', 1, 1, 1, 23.00, 'cb06150f104b0695d3fac92986d2af4c.webp', 1, '2026-04-07 15:40:47', '2026-04-07 15:40:47'),
(15, 30, 'Fries', '', 1, 0, 0, 15.00, NULL, 1, '2026-04-07 15:41:59', '2026-04-07 15:41:59'),
(16, 32, 'Sago at Gulaman', '', 1, 0, 1, 20.00, '12663f655db2af5d7cd5667dd169cfce.jpg', 1, '2026-04-07 15:43:36', '2026-04-07 15:43:36');

-- --------------------------------------------------------

--
-- Table structure for table `product_ratings`
--

CREATE TABLE `product_ratings` (
  `id` int UNSIGNED NOT NULL,
  `feedback_id` int UNSIGNED NOT NULL COMMENT 'Links to order_feedback.id',
  `order_id` int UNSIGNED NOT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `student_id` int UNSIGNED NOT NULL,
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
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'bcrypt hash',
  `id_declaration` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Student agreed to ID declaration',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

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
  ADD KEY `fk_cat_parent` (`parent_id`);

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
  ADD KEY `idx_orders_student` (`student_id`);

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
  ADD KEY `idx_fb_created` (`created_at`);

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
-- Indexes for table `product_ratings`
--
ALTER TABLE `product_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_product_order` (`product_id`,`order_id`),
  ADD KEY `fk_pr_feedback` (`feedback_id`),
  ADD KEY `fk_pr_order` (`order_id`),
  ADD KEY `idx_pr_product` (`product_id`),
  ADD KEY `idx_pr_student` (`student_id`),
  ADD KEY `idx_pr_rating` (`rating`);

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
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `cashiers`
--
ALTER TABLE `cashiers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `cashier_sessions`
--
ALTER TABLE `cashier_sessions`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

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
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

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
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

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
  ADD CONSTRAINT `fk_fb_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

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
-- Constraints for table `product_ratings`
--
ALTER TABLE `product_ratings`
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
