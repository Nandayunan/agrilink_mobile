-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 18 Des 2025 pada 19.58
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12



SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `agri_link`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `account_approvals`
--

CREATE TABLE `account_approvals` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `cart_items`
--

CREATE TABLE `cart_items` (
  `id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `added_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `cart_items`
--

INSERT INTO `cart_items` (`id`, `client_id`, `product_id`, `quantity`, `added_at`) VALUES
(2, 5, 2, 1, '2025-12-17 03:14:28');

-- --------------------------------------------------------

--
-- Struktur dari tabel `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `order_number` varchar(50) NOT NULL,
  `client_id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount_percentage` decimal(5,2) DEFAULT 0.00,
  `discount_amount` decimal(12,2) DEFAULT 0.00,
  `service_fee` decimal(12,2) DEFAULT 0.00,
  `tax_percentage` decimal(5,2) DEFAULT 0.00,
  `tax_amount` decimal(12,2) DEFAULT 0.00,
  `grand_total` decimal(12,2) NOT NULL,
  `status` enum('pending','confirmed','processing','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  `payment_status` enum('unpaid','paid','cancelled') NOT NULL DEFAULT 'unpaid',
  `notes` text DEFAULT NULL,
  `delivery_address` text DEFAULT NULL,
  `delivery_date` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `category` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(12,2) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `unit` varchar(50) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `products`
--

INSERT INTO `products` (`id`, `admin_id`, `category`, `name`, `description`, `price`, `stock`, `unit`, `image_url`, `is_available`, `created_at`, `updated_at`) VALUES
(1, 1, 'Sayuran', 'Tomat Segar', 'Tomat berkualitas tinggi dari kebun organik', 15000.00, 100, 'kg', NULL, 1, '2025-12-16 18:11:21', '2025-12-16 18:11:21'),
(2, 1, 'Sayuran', 'Bayam Segar', 'Bayam hijau segar setiap hari', 8000.00, 50, 'ikat', NULL, 1, '2025-12-16 18:11:21', '2025-12-16 18:11:21'),
(3, 1, 'Buah', 'Pisang Ambon', 'Pisang Ambon berkualitas premium', 12000.00, 75, 'sisir', NULL, 1, '2025-12-16 18:11:21', '2025-12-16 18:11:21'),
(4, 1, 'Daging', 'Daging Ayam', 'Ayam potong segar dari peternakan lokal', 45000.00, 30, 'kg', NULL, 1, '2025-12-16 18:11:21', '2025-12-16 18:11:21'),
(5, 1, 'Rempah', 'Bawang Merah', 'Bawang merah pilihan halus', 25000.00, 60, 'kg', NULL, 1, '2025-12-16 18:11:21', '2025-12-16 18:11:21');

-- --------------------------------------------------------

--
-- Struktur dari tabel `product_reviews`
--

CREATE TABLE `product_reviews` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `province` varchar(50) DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `role` enum('client','admin') NOT NULL DEFAULT 'client',
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `avatar_url` varchar(255) DEFAULT NULL,
  `company_name` varchar(100) DEFAULT NULL,
  `business_license` varchar(50) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `phone`, `address`, `city`, `province`, `postal_code`, `role`, `status`, `avatar_url`, `company_name`, `business_license`, `description`, `latitude`, `longitude`, `created_at`, `updated_at`) VALUES
(1, 'Admin Petani Bandung', 'petani@agrilink.com', '$2a$10$YourHashedPasswordHere', '081234567890', NULL, 'Bandung', 'Jawa Barat', NULL, 'admin', 'approved', NULL, 'Tani Maju Bandung', NULL, NULL, NULL, NULL, '2025-12-16 18:11:19', '2025-12-16 18:11:19'),
(2, 'Restoran Taman Kota', 'restoran@agrilink.com', '$2a$10$YourHashedPasswordHere', '082345678901', NULL, 'Bandung', 'Jawa Barat', NULL, 'client', 'approved', NULL, 'Taman Kota Restaurant', NULL, NULL, NULL, NULL, '2025-12-16 18:11:19', '2025-12-16 18:11:19'),
(3, 'Nand', 'petani@example.com', '$2a$10$gmslaCVCcliUCkXwG35pJ.dzhMQHxArho4ZTUjLxQ0n0RTiSUBkiq', '0817627672677', 'bandung', 'bandung', 'jawa barat', NULL, 'admin', 'pending', NULL, 'sawah', NULL, NULL, NULL, NULL, '2025-12-16 20:03:20', '2025-12-16 20:03:20'),
(4, 'Nanda', 'nanda@gmail.com', '$2a$10$/lJrDCnSTHvwuKyeMggLzO/ydv1x.69/Qm6w4fs8sRD2kYUn1Fvn.', '082727627627', 'bandung', 'Bandung', 'Jawa Barat', NULL, 'client', 'approved', NULL, 'Sawah', NULL, NULL, NULL, NULL, '2025-12-16 20:12:44', '2025-12-16 20:14:58'),
(5, 'Yunan', 'Yunan@gmail.com', '$2a$10$StTCxlgybgHzf0fGQrBxA.MpJ1ihUT9GqalQFKt6lgSme9V8dgzXC', '0812767263737', 'bandung', 'Bandung', 'Jawa Barat', NULL, 'client', 'approved', NULL, 'Yunanz', NULL, NULL, NULL, NULL, '2025-12-17 03:14:04', '2025-12-17 03:14:04');

-- --------------------------------------------------------

--
-- Struktur dari tabel `restaurant_farmers`
--

CREATE TABLE `restaurant_farmers` (
  `id` int(11) NOT NULL,
  `restaurant_id` int(11) NOT NULL,
  `farmer_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `recipient_id` int(11) NOT NULL,
  `sender_type` enum('restaurant','farmer','supplier') NOT NULL,
  `recipient_type` enum('restaurant','farmer','supplier') NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `message_type` enum('inquiry','offer','update','order_related') NOT NULL DEFAULT 'inquiry',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `weather_cache`
--

CREATE TABLE `weather_cache` (
  `id` int(11) NOT NULL,
  `province` varchar(50) NOT NULL,
  `city` varchar(50) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `temperature` int(11) DEFAULT NULL,
  `humidity` int(11) DEFAULT NULL,
  `weather_description` varchar(100) DEFAULT NULL,
  `wind_speed` int(11) DEFAULT NULL,
  `weather_code` int(11) DEFAULT NULL,
  `forecast_date` date DEFAULT NULL,
  `cached_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `account_approvals`
--
ALTER TABLE `account_approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indeks untuk tabel `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_client_product` (`client_id`,`product_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `idx_client_id` (`client_id`);

--
-- Indeks untuk tabel `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_number` (`order_number`),
  ADD KEY `idx_client_id` (`client_id`),
  ADD KEY `idx_admin_id` (`admin_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_order_number` (`order_number`);

--
-- Indeks untuk tabel `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_order_id` (`order_id`),
  ADD KEY `idx_product_id` (`product_id`);

--
-- Indeks untuk tabel `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_admin_id` (`admin_id`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_is_available` (`is_available`);

--
-- Indeks untuk tabel `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_product_id` (`product_id`),
  ADD KEY `idx_client_id` (`client_id`);

--
-- Indeks untuk tabel `restaurant_farmers`
--
ALTER TABLE `restaurant_farmers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_restaurant_id` (`restaurant_id`),
  ADD KEY `idx_farmer_id` (`farmer_id`),
  ADD UNIQUE KEY `unique_restaurant_farmer` (`restaurant_id`,`farmer_id`);

--
-- Indeks untuk tabel `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sender_id` (`sender_id`),
  ADD KEY `idx_recipient_id` (`recipient_id`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_status` (`status`);

--
-- Indeks untuk tabel `weather_cache`
--
ALTER TABLE `weather_cache`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_location_date` (`latitude`,`longitude`,`forecast_date`),
  ADD KEY `idx_province` (`province`),
  ADD KEY `idx_cached_at` (`cached_at`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `account_approvals`
--
ALTER TABLE `account_approvals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `product_reviews`
--
ALTER TABLE `product_reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `restaurant_farmers`
--
ALTER TABLE `restaurant_farmers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `weather_cache`
--
ALTER TABLE `weather_cache`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `account_approvals`
--
ALTER TABLE `account_approvals`
  ADD CONSTRAINT `account_approvals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `account_approvals_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Ketidakleluasaan untuk tabel `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD CONSTRAINT `product_reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_reviews_ibfk_2` FOREIGN KEY (`client_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `restaurant_farmers`
--
ALTER TABLE `restaurant_farmers`
  ADD CONSTRAINT `restaurant_farmers_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `restaurant_farmers_ibfk_2` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
