-- Esquema inicial para a plataforma ShopMKT

CREATE DATABASE IF NOT EXISTS shopmkt CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shopmkt;

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  cpf VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(40) NOT NULL,
  password VARCHAR(255) NOT NULL,
  address VARCHAR(255),
  role ENUM('client', 'professional', 'admin') NOT NULL DEFAULT 'client',
  status ENUM('pending', 'active', 'blocked') NOT NULL DEFAULT 'pending',
  document_id VARCHAR(100),
  document_photo VARCHAR(255),
  profile_photo VARCHAR(255),
  resume TEXT,
  certifications TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS service_categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS service_requests (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  professional_id INT UNSIGNED,
  problem VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  photos JSON,
  address VARCHAR(255) NOT NULL,
  scheduled_at DATETIME,
  status ENUM('awaiting_payment_confirmation', 'pending', 'assigned', 'in_progress', 'completed', 'canceled') NOT NULL DEFAULT 'pending',
  payment_method VARCHAR(50) DEFAULT 'cash',
  price DECIMAL(10,2),
  completion_photos JSON,
  completion_notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (category_id) REFERENCES service_categories(id),
  FOREIGN KEY (professional_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS reviews (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  request_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  professional_id INT UNSIGNED NOT NULL,
  rating_quality TINYINT UNSIGNED NOT NULL,
  rating_punctuality TINYINT UNSIGNED NOT NULL,
  rating_politeness TINYINT UNSIGNED NOT NULL,
  rating_organization TINYINT UNSIGNED NOT NULL,
  rating_speed TINYINT UNSIGNED NOT NULL,
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (request_id) REFERENCES service_requests(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (professional_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS chats (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  request_id INT UNSIGNED NOT NULL,
  sender_id INT UNSIGNED NOT NULL,
  message TEXT,
  attachments JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (request_id) REFERENCES service_requests(id),
  FOREIGN KEY (sender_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS pro_catalog_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  professional_id INT UNSIGNED NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  item_name VARCHAR(150) NOT NULL,
  item_type ENUM('service', 'part') NOT NULL DEFAULT 'service',
  price DECIMAL(10,2) NOT NULL,
  description VARCHAR(255),
  active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (professional_id) REFERENCES users(id),
  FOREIGN KEY (category_id) REFERENCES service_categories(id)
);

CREATE TABLE IF NOT EXISTS pro_services (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  professional_id INT UNSIGNED NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  estimated_time VARCHAR(50) DEFAULT '1 hora',
  status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (professional_id) REFERENCES users(id),
  FOREIGN KEY (category_id) REFERENCES service_categories(id)
);

CREATE TABLE IF NOT EXISTS pro_products (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  professional_id INT UNSIGNED NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  stock INT NOT NULL DEFAULT 0,
  brand VARCHAR(100),
  compatible_model VARCHAR(150),
  status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (professional_id) REFERENCES users(id),
  FOREIGN KEY (category_id) REFERENCES service_categories(id)
);

INSERT IGNORE INTO service_categories (id, name, description, active) VALUES
(1, 'Técnico de celular', 'Serviços e reparos de smartphones e celulares.', 1),
(2, 'Técnico de computador/notebook', 'Manutenção, formatação e upgrade de computadores e notebooks.', 1),
(3, 'Técnico de videogame', 'Manutenção, limpeza e consertos de consoles e controles.', 1),
(4, 'Técnico de televisão', 'Instalação, reparos e suporte em Smart TVs e televisores.', 1),
(5, 'Montador de móveis', 'Montagem, desmontagem e ajuste de móveis em geral.', 1),
(6, 'Eletricista', 'Instalação elétrica residencial, reparos e quadros de força.', 1),
(7, 'Encanador / serviços hidráulicos', 'Reparos hidráulicos, desentupimentos e vazamentos.', 1),
(8, 'Outras categorias', 'Outros serviços técnicos e manutenção residencial.', 1);

