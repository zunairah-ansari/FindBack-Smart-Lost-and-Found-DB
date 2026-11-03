-- FindBack: Smart Lost-and-Found Database
-- MySQL 8.0

CREATE DATABASE IF NOT EXIST FindBack;
USE FindBack;




-- Create Users table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Categories table
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create Locations table
CREATE TABLE Locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create ItemReports table
CREATE TABLE ItemReports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    location_id INT NOT NULL,
    report_type ENUM('Lost', 'Found') NOT NULL,
    item_description VARCHAR(255) NOT NULL,
    report_date DATE NOT NULL,
    status ENUM('Open', 'Matched', 'Returned', 'Closed') DEFAULT 'Open',
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    FOREIGN KEY (location_id) REFERENCES Locations(location_id)
);

-- Create Claims table
CREATE TABLE Claims (
    claim_id INT AUTO_INCREMENT PRIMARY KEY,
    report_id INT NOT NULL,
    user_id INT NOT NULL,
    claim_date DATE NOT NULL,
    claim_status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    FOREIGN KEY (report_id) REFERENCES ItemReports(report_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Create Returns table
CREATE TABLE Returns (
    return_id INT AUTO_INCREMENT PRIMARY KEY,
    report_id INT NOT NULL,
    claim_id INT NOT NULL,
    return_date DATE NOT NULL,
    return_notes VARCHAR(255),
    FOREIGN KEY (report_id) REFERENCES ItemReports(report_id),
    FOREIGN KEY (claim_id) REFERENCES Claims(claim_id)
);



-- Insert sample users
INSERT INTO Users (user_id, full_name, email, created_at)
VALUES
(1, 'Ayesha Ansari', 'ayesha@gmail.com', NOW()),
(2, 'Rahul Sharma', 'rahul@gmail.com', NOW()),
(3, 'Priya Patel', 'priya@gmail.com', NOW()),
(4, 'Arjun Mehta', 'arjun@gmail.com', NOW()),
(5, 'Sara Khan', 'sara@gmail.com', NOW()),
(6, 'Vikram Singh', 'vikram@gmail.com', NOW());

-- Insert categories
INSERT INTO Categories (category_id, category_name)
VALUES
(1, 'Wallet'),
(2, 'Mobile Phone'),
(3, 'Keys'),
(4, 'ID Card'),
(5, 'Bag'),
(6, 'Water Bottle');

-- Insert locations
INSERT INTO Locations (location_id, location_name)
VALUES
(1, 'Library'),
(2, 'Canteen'),
(3, 'Classroom'),
(4, 'College Gate'),
(5, 'Parking Area'),
(6, 'Computer Lab');


-- Insert sample item reports
INSERT INTO ItemReports
(report_id, user_id, category_id, location_id, report_type,
 item_description, report_date, status)
VALUES
(1, 2, 1, 1, 'Lost', 'Black leather wallet', '2026-10-28', 'Open'),
(2, 3, 1, 1, 'Found', 'Black wallet found near library desk', '2026-10-29', 'Returned'),
(3, 4, 2, 3, 'Lost', 'Blue Samsung mobile phone', '2026-10-27', 'Open'),
(4, 5, 3, 2, 'Found', 'Small bunch of keys found in canteen', '2026-10-29', 'Open'),
(5, 6, 4, 4, 'Lost', 'College identity card', '2026-10-26', 'Open'),
(6, 1, 5, 5, 'Found', 'Black backpack found in parking area', '2026-10-30', 'Returned');


-- Insert sample claims
INSERT INTO Claims
(claim_id, report_id, user_id, claim_date, claim_status)
VALUES
(1, 2, 2, '2026-10-31', 'Pending'),
(2, 6, 3, '2026-10-31', 'Pending'),
(3, 2, 4, '2026-10-30', 'Approved'),
(4, 6, 5, '2026-10-29', 'Rejected'),
(5, 4, 6, '2026-10-30', 'Pending'),
(6, 5, 1, '2026-10-31', 'Pending');

-- Insert sample returns
INSERT INTO Returns
(return_id, report_id, claim_id, return_date, return_notes)
VALUES
(1, 2, 3, '2026-10-31', 'Wallet returned to owner'),
(2, 6, 5, '2026-10-31', 'Backpack returned to owner'),
(3, 4, 2, '2026-10-30', 'Keys returned to owner'),
(4, 2, 3, '2026-10-29', 'Wallet handed over to owner'),
(5, 6, 5, '2026-10-28', 'Backpack collected by owner'),
(6, 4, 2, '2026-10-27', 'Keys collected by owner');


-- 1. Display all item reports with user, category, and location
SELECT
    ItemReports.report_id,
    Users.full_name,
    Categories.category_name,
    Locations.location_name,
    ItemReports.report_type,
    ItemReports.item_description,
    ItemReports.report_date,
    ItemReports.status
FROM ItemReports
JOIN Users ON ItemReports.user_id = Users.user_id
JOIN Categories ON ItemReports.category_id = Categories.category_id
JOIN Locations ON ItemReports.location_id = Locations.location_id;

-- 2. Display all lost items
SELECT *
FROM ItemReports
WHERE report_type = 'Lost';

-- 3. Display all found items
SELECT *
FROM ItemReports
WHERE report_type = 'Found';

-- 4. Find open reports
SELECT *
FROM ItemReports
WHERE status = 'Open';

-- 5. Count reports by category
SELECT
    Categories.category_name,
    COUNT(ItemReports.report_id) AS total_reports
FROM Categories
LEFT JOIN ItemReports
    ON Categories.category_id = ItemReports.category_id
GROUP BY Categories.category_id, Categories.category_name;

-- 6. Display claims with claimant names
SELECT
    Claims.claim_id,
    Users.full_name,
    Claims.report_id,
    Claims.claim_date,
    Claims.claim_status
FROM Claims
JOIN Users ON Claims.user_id = Users.user_id;

-- 7. Display return records
SELECT
    Returns.return_id,
    Returns.report_id,
    Returns.return_date,
    Returns.return_notes
FROM Returns;

-- 8. Find possible lost-and-found matches by category and location
SELECT
    Lost.report_id AS lost_report_id,
    Found.report_id AS found_report_id,
    Categories.category_name,
    Locations.location_name,
    Lost.item_description AS lost_item,
    Found.item_description AS found_item
FROM ItemReports AS Lost
JOIN ItemReports AS Found
    ON Lost.category_id = Found.category_id
    AND Lost.location_id = Found.location_id
JOIN Categories
    ON Lost.category_id = Categories.category_id
JOIN Locations
    ON Lost.location_id = Locations.location_id
WHERE Lost.report_type = 'Lost'
  AND Found.report_type = 'Found';


