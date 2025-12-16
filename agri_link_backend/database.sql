-- Agri-Link Database Schema

CREATE DATABASE IF NOT EXISTS agri_link;
USE agri_link;

-- Users Table (untuk Client/Restoran dan Admin/Petani)
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

-- Products Table (produk dari Admin/Petani)
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

-- Orders Table
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

-- Order Items Table
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

-- Cart Table (untuk sementara sebelum checkout)
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

-- Product Reviews Table
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

-- Account Approvals Log
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

-- Weather Cache (untuk menyimpan data cuaca dari BMKG)
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

-- Insert sample data for testing
INSERT INTO users (name, email, password, phone, role, status, company_name, city, province) VALUES
('Admin Petani Bandung', 'petani@agrilink.com', '$2a$10$YourHashedPasswordHere', '081234567890', 'admin', 'approved', 'Tani Maju Bandung', 'Bandung', 'Jawa Barat'),
('Restoran Taman Kota', 'restoran@agrilink.com', '$2a$10$YourHashedPasswordHere', '082345678901', 'client', 'approved', 'Taman Kota Restaurant', 'Bandung', 'Jawa Barat');

INSERT INTO products (admin_id, category, name, description, price, stock, unit, is_available) VALUES
(1, 'Sayuran', 'Tomat Segar', 'Tomat berkualitas tinggi dari kebun organik', 15000, 100, 'kg', TRUE),
(1, 'Sayuran', 'Bayam Segar', 'Bayam hijau segar setiap hari', 8000, 50, 'ikat', TRUE),
(1, 'Buah', 'Pisang Ambon', 'Pisang Ambon berkualitas premium', 12000, 75, 'sisir', TRUE),
(1, 'Daging', 'Daging Ayam', 'Ayam potong segar dari peternakan lokal', 45000, 30, 'kg', TRUE),
(1, 'Rempah', 'Bawang Merah', 'Bawang merah pilihan halus', 25000, 60, 'kg', TRUE);
