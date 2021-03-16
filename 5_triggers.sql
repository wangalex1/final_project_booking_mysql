USE booking;

DROP TABLE IF EXISTS security_logs;
CREATE TABLE security_logs (
  name VARCHAR(255) COMMENT 'Название раздела',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=Archive;

DELIMITER //
DROP TRIGGER IF EXISTS log_signup_attempt//
CREATE TRIGGER log_signup_attempt BEFORE INSERT ON users
FOR EACH ROW
BEGIN
  INSERT INTO security_logs (name) VALUES (CONCAT('signup attemp for email', NEW.email));
END//

DELIMITER ;

INSERT INTO `users` (`id`, `email`, `display_name`, `picture_id`, `birthday`, `country`, `title`, `first_name`, `last_name`, `phone_number`, `is_owner`, `is_traveller`, `genius_level`, `created_at`, `updated_at`) VALUES (NULL, 'jkunze=2@example.org', 'Chyna Deckow', 18, '1989-06-11', 'Syrian Arab Republic', 'Mrx.', 'Blanche', 'Deckow', '(758)933-4976x5252', 1, 1, 0, '2002-05-07 10:46:49', '1975-07-04 15:49:06');

SELECT * FROM security_logs;