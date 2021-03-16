-- Требования к курсовому проекту:
-- 1. Составить общее текстовое описание БД и решаемых ею задач;
-- 2. минимальное количество таблиц - 10;
-- 3. скрипты создания структуры БД (с первичными ключами, индексами, внешними ключами);
-- 4. создать ERDiagram для БД;
-- 5. скрипты наполнения БД данными;
-- 6. скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы);
-- 7. представления (минимум 2);
-- 8. хранимые процедуры / триггеры;
-- Примеры: описать модель хранения данных популярного веб-сайта: кинопоиск, booking.com, wikipedia, интернет-магазин, geekbrains, госуслуги...

DROP DATABASE IF EXISTS booking;
CREATE DATABASE booking;

USE booking;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT	PRIMARY KEY,
	email VARCHAR(150) NOT NULL UNIQUE,
	display_name VARCHAR(150) NOT NULL,
	picture_id INT UNSIGNED,
  birthday DATE,
	country VARCHAR(50) NOT NULL,
  title ENUM('Mr.', 'Mrs.', 'Mrx.') NOT NULL DEFAULT 'Mrx.',
	first_name VARCHAR(75) NOT NULL,
	last_name VARCHAR(75) NOT NULL,
	phone_number VARCHAR(25) NOT NULL UNIQUE,
	is_owner BOOLEAN NOT NULL,
	is_traveller BOOLEAN NOT NULL,
	genius_level INT UNSIGNED NOT NULL DEFAULT 0,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'All users';


DROP TABLE IF EXISTS reservations;
CREATE TABLE reservations (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT	PRIMARY KEY,
	status_id INT UNSIGNED NOT NULL DEFAULT 0,
	estate_id INT UNSIGNED NOT NULL,
	client_id INT UNSIGNED NOT NULL COMMENT 'The client who made the reservation',
	start_at DATE NOT NULL,
	end_at DATE NOT NULL,
	price INT UNSIGNED NOT NULL,
	currency_code INT UNSIGNED NOT NULL DEFAULT 840,
	is_paid BOOLEAN NOT NULL DEFAULT FALSE,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'All reservations';


DROP TABLE IF EXISTS reservation_statuses;
CREATE TABLE reservation_statuses (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name ENUM('pending_owner_confirmation', 'confirmed', 'active', 'cancelled', 'fulfilled') NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP	
) COMMENT 'Statuses of Estate reservation';


DROP TABLE IF EXISTS estates;
CREATE TABLE estates (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT	PRIMARY KEY,
	owner_id INT UNSIGNED NOT NULL,
	city VARCHAR(50) NOT NULL,
	address VARCHAR(150) NOT NULL,
	country VARCHAR(50) NOT NULL,
	comment VARCHAR(500),
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'All real estates';


DROP TABLE IF EXISTS feedbacks;
CREATE TABLE feedbacks (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT	PRIMARY KEY,
	client_id INT UNSIGNED NOT NULL,
	estate_id INT UNSIGNED NOT NULL,
	comment VARCHAR(500) NOT NULL,
	cleanliness SMALLINT NOT NULL, -- 1 to 5
	hospitality SMALLINT NOT NULL, -- 1 to 5
	availability SMALLINT NOT NULL, -- 1 to 5
	location SMALLINT NOT NULL, -- 1 to 5
	score FLOAT GENERATED ALWAYS AS ((cleanliness + hospitality + availability + location) / 4),
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'All feedbacks of users about estates';


DROP TABLE IF EXISTS medias;
CREATE TABLE medias (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	size INT UNSIGNED NOT NULL,
	url VARCHAR(250) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP	
) COMMENT 'Media files';


DROP TABLE IF EXISTS feedbacks_medias;
CREATE TABLE feedbacks_medias (
	feedback_id INT UNSIGNED NOT NULL,
	media_id INT UNSIGNED NOT NULL	
) COMMENT 'Media files in Feedbacks';


DROP TABLE IF EXISTS feedbacks_estates;
CREATE TABLE feedbacks_estates (
	estate_id INT UNSIGNED NOT NULL,
	media_id INT UNSIGNED NOT NULL	
) COMMENT 'Media files in Real estate descriptions';


DROP TABLE IF EXISTS cards;
CREATE TABLE cards(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	card_type VARCHAR(50) NOT NULL,
	card_number VARCHAR(50) NOT NULL,
	owner_name VARCHAR(50) NOT NULL,
	expires_at DATE NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP	
) COMMENT 'Cards of users';


DROP TABLE IF EXISTS users_cards;
CREATE TABLE users_cards (
	user_id INT UNSIGNED NOT NULL,
	card_id INT UNSIGNED NOT NULL	
) COMMENT 'Cards of the users';


-- ======================= FOREIGN KEYS ==========================

ALTER TABLE users 
	ADD CONSTRAINT users_picture_id_fk
		FOREIGN KEY (picture_id) REFERENCES medias(id)
			ON DELETE SET NULL;

ALTER TABLE reservations
	ADD CONSTRAINT reservations_status_id_fk
		FOREIGN KEY (status_id) REFERENCES reservation_statuses(id)
			ON DELETE RESTRICT,
	ADD CONSTRAINT reservations_estate_id_fk
		FOREIGN KEY (estate_id) REFERENCES estates(id)
			ON DELETE RESTRICT,
	ADD CONSTRAINT reservations_client_id_fk
		FOREIGN KEY (client_id) REFERENCES users(id)
			ON DELETE RESTRICT;
			
ALTER TABLE estates
	ADD CONSTRAINT estates_owner_id_fk
		FOREIGN KEY (owner_id) REFERENCES users(id)
			ON DELETE RESTRICT;

ALTER TABLE feedbacks
	ADD CONSTRAINT feedbacks_client_id_fk
		FOREIGN KEY (client_id) REFERENCES users(id)
			ON DELETE RESTRICT,
	ADD CONSTRAINT feedbacks_estate_id_fk
		FOREIGN KEY (estate_id) REFERENCES estates(id)
			ON DELETE RESTRICT;

ALTER TABLE feedbacks_medias
	ADD CONSTRAINT feedbacks_medias_feedback_id_fk
		FOREIGN KEY (feedback_id) REFERENCES feedbacks(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT feedbacks_medias_media_id_fk
		FOREIGN KEY (media_id) REFERENCES medias(id)
			ON DELETE CASCADE;

ALTER TABLE feedbacks_estates
	ADD CONSTRAINT feedbacks_estates_estate_id_fk
		FOREIGN KEY (estate_id) REFERENCES estates(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT feedbacks_estates_media_id_fk
		FOREIGN KEY (media_id) REFERENCES medias(id)
			ON DELETE CASCADE;

		
ALTER TABLE users_cards
	ADD CONSTRAINT users_cards_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT users_cards_card_id_fk
		FOREIGN KEY (card_id) REFERENCES cards(id)
			ON DELETE CASCADE;
			
		
-- ======================= INDEXES ==========================

CREATE INDEX users_email_idx ON users(email);
CREATE INDEX estates_country_city ON estates(country, city);