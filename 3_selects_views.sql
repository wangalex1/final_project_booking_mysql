USE booking;

SELECT * FROM users WHERE email = 'alfonso.fisher@example.com';

-- show users who have confirmed reservations
SELECT 
	clients.display_name AS 'client name',
	reservations.start_at AS 'from',
	reservations.end_at AS 'to',
	owners.display_name AS 'owner name',
	(SELECT name FROM reservation_statuses WHERE reservations.status_id = id) AS 'status'
FROM users AS clients
	JOIN reservations 
		ON clients.id = reservations.client_id AND reservations.status_id = (SELECT id FROM reservation_statuses WHERE name = 'confirmed')
	JOIN estates
		ON estates.id = reservations.estate_id
	JOIN users AS owners
		ON owners.id = estates.owner_id;
		
-- show all reservations of all users grouped by user

SELECT
	clients.display_name AS 'name', CONCAT('$',reservations.price) AS 'price'
FROM reservations
	LEFT JOIN users AS clients
		ON reservations.client_id = clients.id
GROUP BY clients.id;

-- представления

CREATE OR REPLACE VIEW users_from_mexico AS
	SELECT * FROM users WHERE country = 'Mexico' ORDER BY created_at;

SELECT * FROM users_from_mexico;

CREATE OR REPLACE VIEW satisfied_clients AS
	SELECT users.display_name, users.email, feedbacks.score
	FROM feedbacks
		JOIN users
			ON feedbacks.client_id = users.id
		WHERE feedbacks.score > 6;
	
SELECT * FROM satisfied_clients;

