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
  status ENUM('pending', 'assigned', 'in_progress', 'completed', 'canceled') NOT NULL DEFAULT 'pending',
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

INSERT IGNORE INTO service_categories (id, name, description, active) VALUES
(1, 'Celular', 'Serviços de manutenção de celulares.', 1),
(2, 'Notebook', 'Serviços de manutenção de notebooks.', 1),
(3, 'Computador', 'Serviços de manutenção de computadores.', 1),
(4, 'Videogame', 'Serviços para videogames e consoles.', 1),
(5, 'Móveis', 'Montagem e consertos de móveis.', 1),
(6, 'TV', 'Instalação e manutenção de televisores.', 1),
(7, 'Elétrica', 'Serviços elétricos residenciais.', 1),
(8, 'Hidráulica', 'Serviços hidráulicos residenciais.', 1);
