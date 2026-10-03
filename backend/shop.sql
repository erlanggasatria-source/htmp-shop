-- =========================================================
-- MVP E-COMMERCE DATABASE SCHEMA
-- Engine: MySQL 8+ | Charset: utf8mb4
-- =========================================================

CREATE DATABASE IF NOT EXISTS mvp_ecommerce
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
USE mvp_ecommerce;

-- ---------------------------------------------------------
-- 1. USERS
-- ---------------------------------------------------------
CREATE TABLE users (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(120) NOT NULL,
  email         VARCHAR(160) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone         VARCHAR(30)  NULL,
  role          ENUM('customer','admin') NOT NULL DEFAULT 'customer',
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 2. CATEGORIES (self-referencing untuk sub-kategori)
-- ---------------------------------------------------------
CREATE TABLE categories (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  parent_id  INT UNSIGNED NULL,
  name       VARCHAR(100) NOT NULL,
  slug       VARCHAR(120) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL,
  INDEX idx_slug (slug)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 3. PRODUCTS
-- ---------------------------------------------------------
CREATE TABLE products (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id INT UNSIGNED NOT NULL,
  name        VARCHAR(200) NOT NULL,
  slug        VARCHAR(220) NOT NULL UNIQUE,
  description TEXT         NULL,
  base_price  DECIMAL(12,2) NOT NULL,   -- harga dasar (tanpa varian)
  is_active   TINYINT(1) NOT NULL DEFAULT 1,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_slug (slug),
  INDEX idx_active (is_active)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 4. PRODUCT IMAGES (1 produk = banyak gambar)
-- ---------------------------------------------------------
CREATE TABLE product_images (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id  BIGINT UNSIGNED NOT NULL,
  url         VARCHAR(500) NOT NULL,
  sort_order  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  is_primary  TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  INDEX idx_product (product_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 5. PRODUCT VARIANTS (warna, ukuran, dll)
-- ---------------------------------------------------------
CREATE TABLE product_variants (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id  BIGINT UNSIGNED NOT NULL,
  name        VARCHAR(100) NOT NULL,   -- misal: "Merah / XL"
  sku         VARCHAR(80)  NOT NULL UNIQUE,
  price_delta DECIMAL(10,2) NOT NULL DEFAULT 0.00, -- selisih dari base_price
  stock       INT NOT NULL DEFAULT 0,
  is_active   TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  INDEX idx_sku (sku)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 6. USER ADDRESSES
-- ---------------------------------------------------------
CREATE TABLE addresses (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT UNSIGNED NOT NULL,
  label       VARCHAR(60) NOT NULL,    -- "Rumah", "Kantor"
  receiver    VARCHAR(120) NOT NULL,
  phone       VARCHAR(30)  NOT NULL,
  address     TEXT NOT NULL,
  city        VARCHAR(100) NOT NULL,
  postal_code VARCHAR(10) NOT NULL,
  is_default  TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 7. CARTS & CART ITEMS
-- ---------------------------------------------------------
CREATE TABLE carts (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT UNSIGNED NOT NULL UNIQUE,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE cart_items (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cart_id    BIGINT UNSIGNED NOT NULL,
  variant_id BIGINT UNSIGNED NOT NULL,
  qty        INT UNSIGNED NOT NULL DEFAULT 1,
  UNIQUE KEY uq_cart_variant (cart_id, variant_id),
  FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
  FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 8. ORDERS & ORDER ITEMS
-- ---------------------------------------------------------
CREATE TABLE orders (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         BIGINT UNSIGNED NOT NULL,
  order_number    VARCHAR(30) NOT NULL UNIQUE,  -- misal: INV/20260928/0001
  status          ENUM('pending','paid','packed','shipped','delivered','cancelled')
                  NOT NULL DEFAULT 'pending',
  subtotal        DECIMAL(12,2) NOT NULL,
  shipping_fee    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total           DECIMAL(12,2) NOT NULL,
  shipping_name   VARCHAR(120) NOT NULL,
  shipping_phone  VARCHAR(30)  NOT NULL,
  shipping_address TEXT NOT NULL,
  shipping_city   VARCHAR(100) NOT NULL,
  shipping_postal VARCHAR(10) NOT NULL,
  notes           TEXT NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  INDEX idx_user (user_id),
  INDEX idx_status (status)
) ENGINE=InnoDB;

CREATE TABLE order_items (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id    BIGINT UNSIGNED NOT NULL,
  variant_id  BIGINT UNSIGNED NOT NULL,
  product_name VARCHAR(200) NOT NULL,  -- snapshot nama saat order
  variant_name VARCHAR(100) NOT NULL,  -- snapshot varian saat order
  price       DECIMAL(12,2) NOT NULL, -- harga saat order (snapshot)
  qty         INT UNSIGNED NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (variant_id) REFERENCES product_variants(id)
) ENGINE=InnoDB;