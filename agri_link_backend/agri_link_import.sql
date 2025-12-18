-- Agri-Link clean import script
-- Run this to (re)create schema + seed sample data

CREATE DATABASE IF NOT EXISTS agri_link;
USE agri_link;

-- Drop tables in FK-safe order
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS product_reviews;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS weather_cache;
DROP TABLE IF EXISTS account_approvals;
DROP TABLE IF EXISTS users;

-- Users
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  address TEXT,
  city VARCHAR(50),
  province VARCHAR(50),
  postal_code VARCHAR(10),
  role ENUM('client', 'admin') NOT NULL DEFAULT 'client',
  status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
  avatar_url VARCHAR(255),
  company_name VARCHAR(100),
  business_license VARCHAR(50),
  description TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_role (role),
  INDEX idx_status (status)
);

-- Account approvals
CREATE TABLE account_approvals (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  approved_by INT,
  status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
  reason VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_status (status)
);

-- Products
CREATE TABLE products (
  id INT PRIMARY KEY AUTO_INCREMENT,
  admin_id INT NOT NULL,
  category VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  price DECIMAL(12, 2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  unit VARCHAR(50) NOT NULL,
  image_url VARCHAR(255),
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_admin_id (admin_id),
  INDEX idx_category (category),
  INDEX idx_is_available (is_available)
);

-- Orders
CREATE TABLE orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_number VARCHAR(50) UNIQUE NOT NULL,
  client_id INT NOT NULL,
  admin_id INT,
  subtotal DECIMAL(12, 2) NOT NULL DEFAULT 0,
  discount_percentage DECIMAL(5, 2) DEFAULT 0,
  discount_amount DECIMAL(12, 2) DEFAULT 0,
  service_fee DECIMAL(12, 2) DEFAULT 0,
  tax_percentage DECIMAL(5, 2) DEFAULT 0,
  tax_amount DECIMAL(12, 2) DEFAULT 0,
  grand_total DECIMAL(12, 2) NOT NULL,
  status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
  payment_status ENUM('unpaid', 'paid', 'cancelled') NOT NULL DEFAULT 'unpaid',
  notes TEXT,
  delivery_address TEXT,
  delivery_date DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_client_id (client_id),
  INDEX idx_admin_id (admin_id),
  INDEX idx_status (status),
  INDEX idx_order_number (order_number)
);

-- Order items
CREATE TABLE order_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  price DECIMAL(12, 2) NOT NULL,
  subtotal DECIMAL(12, 2) NOT NULL,
  notes VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
  INDEX idx_order_id (order_id),
  INDEX idx_product_id (product_id)
);

-- Cart items
CREATE TABLE cart_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  client_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY unique_client_product (client_id, product_id),
  INDEX idx_client_id (client_id)
);

-- Product reviews
CREATE TABLE product_reviews (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT NOT NULL,
  client_id INT NOT NULL,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_product_id (product_id),
  INDEX idx_client_id (client_id)
);

-- Weather cache
CREATE TABLE weather_cache (
  id INT PRIMARY KEY AUTO_INCREMENT,
  province VARCHAR(50) NOT NULL,
  city VARCHAR(50),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  temperature INT,
  humidity INT,
  weather_description VARCHAR(100),
  wind_speed INT,
  weather_code INT,
  forecast_date DATE,
  cached_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_location_date (latitude, longitude, forecast_date),
  INDEX idx_province (province),
  INDEX idx_cached_at (cached_at)
);

-- Seed data (taken from agri_link.sql dump)
INSERT INTO users (id, name, email, password, phone, address, city, province, postal_code, role, status, avatar_url, company_name, business_license, description, latitude, longitude, created_at, updated_at) VALUES
  (1, 'Admin Petani Bandung', 'petani@agrilink.com', '$2a$10$YourHashedPasswordHere', '081234567890', NULL, 'Bandung', 'Jawa Barat', NULL, 'admin', 'approved', NULL, 'Tani Maju Bandung', NULL, NULL, NULL, NULL, '2025-12-16 18:11:19', '2025-12-16 18:11:19'),
  (2, 'Restoran Taman Kota', 'restoran@agrilink.com', '$2a$10$YourHashedPasswordHere', '082345678901', NULL, 'Bandung', 'Jawa Barat', NULL, 'client', 'approved', NULL, 'Taman Kota Restaurant', NULL, NULL, NULL, NULL, '2025-12-16 18:11:19', '2025-12-16 18:11:19'),
  (3, 'Nand', 'petani@example.com', '$2a$10$gmslaCVCcliUCkXwG35pJ.dzhMQHxArho4ZTUjLxQ0n0RTiSUBkiq', '0817627672677', 'bandung', 'bandung', 'jawa barat', NULL, 'admin', 'pending', NULL, 'sawah', NULL, NULL, NULL, NULL, '2025-12-16 20:03:20', '2025-12-16 20:03:20'),
  (4, 'Nanda', 'nanda@gmail.com', '$2a$10$/lJrDCnSTHvwuKyeMggLzO/ydv1x.69/Qm6w4fs8sRD2kYUn1Fvn.', '082727627627', 'bandung', 'Bandung', 'Jawa Barat', NULL, 'client', 'approved', NULL, 'Sawah', NULL, NULL, NULL, NULL, '2025-12-16 20:12:44', '2025-12-16 20:14:58'),
  (5, 'Yunan', 'Yunan@gmail.com', '$2a$10$StTCxlgybgHzf0fGQrBxA.MpJ1ihUT9GqalQFKt6lgSme9V8dgzXC', '0812767263737', 'bandung', 'Bandung', 'Jawa Barat', NULL, 'client', 'approved', NULL, 'Yunanz', NULL, NULL, NULL, NULL, '2025-12-17 03:14:04', '2025-12-17 03:14:04');

INSERT INTO products (id, admin_id, category, name, description, price, stock, unit, image_url, is_available, created_at, updated_at) VALUES
  (1, 1, 'Sayuran', 'Tomat Segar', 'Tomat berkualitas tinggi dari kebun organik', 15000.00, 100, 'kg', NULL, 1, '2025-12-16 18:11:21', '2025-12-16 18:11:21'),
  (2, 1, 'Sayuran', 'Bayam Segar', 'Bayam hijau segar setiap hari', 8000.00, 50, 'ikat', NULL, 1, '2025-12-16 18:11:21', '2025-12-16 18:11:21'),
  (3, 1, 'Buah', 'Pisang Ambon', 'Pisang Ambon berkualitas premium', 12000.00, 75, 'sisir', NULL, 1, '2025-12-16 18:11:21', '2025-12-16 18:11:21'),
  (4, 1, 'Daging', 'Daging Ayam', 'Ayam potong segar dari peternakan lokal', 45000.00, 30, 'kg', NULL, 1, '2025-12-16 18:11:21', '2025-12-16 18:11:21'),
  (5, 1, 'Rempah', 'Bawang Merah', 'Bawang merah pilihan halus', 25000.00, 60, 'kg', NULL, 1, '2025-12-16 18:11:21', '2025-12-16 18:11:21');

INSERT INTO cart_items (id, client_id, product_id, quantity, added_at) VALUES
  (2, 5, 2, 1, '2025-12-17 03:14:28');

-- Set auto increment counters
ALTER TABLE users AUTO_INCREMENT = 6;
ALTER TABLE products AUTO_INCREMENT = 6;
ALTER TABLE cart_items AUTO_INCREMENT = 3;

