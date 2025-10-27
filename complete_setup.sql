-- Complete Movie Ticketing System Setup
-- Run this file once to set up the entire database

DROP DATABASE IF EXISTS movie_ticketing;
CREATE DATABASE movie_ticketing;
USE movie_ticketing;

-- ============================================
-- CREATE TABLES
-- ============================================

-- Create Theatre
CREATE TABLE Theatre (
    theatre_id INT PRIMARY KEY AUTO_INCREMENT,
    theatre_name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);

-- Create Screen
CREATE TABLE Screen (
    screen_id INT PRIMARY KEY AUTO_INCREMENT,
    theatre_id INT NOT NULL,
    screen_num INT,
    total_seats INT,
    FOREIGN KEY (theatre_id) REFERENCES Theatre(theatre_id)
);

-- Create Movie
CREATE TABLE Movie (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    language VARCHAR(20),
    ReleaseDate DATE,
    duration INT
);

-- Create Show
CREATE TABLE ShowTable (
    show_id INT PRIMARY KEY AUTO_INCREMENT,
    screen_id INT NOT NULL,
    movie_id INT NOT NULL,
    showdate DATE NOT NULL,
    show_time DATETIME NOT NULL,
    FOREIGN KEY (screen_id) REFERENCES Screen(screen_id),
    FOREIGN KEY (movie_id) REFERENCES Movie(movie_id)
);

-- Create Seat (with price)
CREATE TABLE Seat (
    seat_id INT PRIMARY KEY AUTO_INCREMENT,
    screen_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_type VARCHAR(20),
    price DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (screen_id) REFERENCES Screen(screen_id)
);

-- Create User (with password)
CREATE TABLE User (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    password VARCHAR(255) NOT NULL DEFAULT 'password123'
);

-- Create Booking
CREATE TABLE Booking (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    show_id INT NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (show_id) REFERENCES ShowTable(show_id)
);

-- Create Ticket table
CREATE TABLE Ticket (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    seat_id INT NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (seat_id) REFERENCES Seat(seat_id)
);

-- Create Payment
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(20),
    status VARCHAR(20),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);

-- ============================================
-- INSERT SAMPLE DATA
-- ============================================

-- Insert Theatres
INSERT INTO Theatre (theatre_id, theatre_name, location) VALUES
(1, 'PVR Cinemas', 'Bangalore'),
(2, 'INOX', 'Mumbai'),
(3, 'Cinepolis', 'Delhi'),
(4, 'PVR Director''s Cut', 'Chennai'),
(5, 'Cinepolis VIP', 'Hyderabad'),
(6, 'INOX Megaplex', 'Pune');

-- Insert Screens
INSERT INTO Screen (screen_id, theatre_id, screen_num, total_seats) VALUES
(1, 1, 1, 100),
(2, 1, 2, 120),
(3, 2, 1, 80),
(4, 3, 1, 150),
(5, 1, 3, 150),
(6, 2, 2, 100),
(7, 3, 2, 130),
(8, 4, 1, 200),
(9, 5, 1, 80);

-- Insert Movies
INSERT INTO Movie (movie_id, title, genre, language, ReleaseDate, duration) VALUES
(1, 'Inception', 'Sci-Fi', 'English', '2025-10-01', 148),
(2, '3 Idiots', 'Comedy-Drama', 'Hindi', '2025-09-15', 170),
(3, 'Bahubali', 'Action', 'Telugu', '2025-08-20', 160),
(4, 'Interstellar', 'Sci-Fi', 'English', '2025-10-10', 169),
(5, 'Avengers Endgame', 'Action', 'English', '2025-10-15', 181),
(6, 'Dangal', 'Drama', 'Hindi', '2025-09-20', 161),
(7, 'RRR', 'Action', 'Telugu', '2025-10-05', 187),
(8, 'The Dark Knight', 'Action', 'English', '2025-09-10', 152),
(9, 'KGF Chapter 2', 'Action', 'Kannada', '2025-10-12', 168),
(10, 'Dilwale Dulhania Le Jayenge', 'Romance', 'Hindi', '2025-08-25', 189);

-- Insert Shows (Future dates: Nov 1-7, 2025)
INSERT INTO ShowTable (show_id, screen_id, movie_id, showdate, show_time) VALUES
(1, 1, 1, '2025-11-01', '2025-11-01 18:30:00'),
(2, 1, 2, '2025-11-01', '2025-11-01 21:00:00'),
(3, 2, 3, '2025-11-02', '2025-11-02 19:00:00'),
(4, 3, 4, '2025-11-03', '2025-11-03 20:30:00'),
(5, 5, 5, '2025-11-04', '2025-11-04 15:00:00'),
(6, 5, 5, '2025-11-04', '2025-11-04 19:30:00'),
(7, 6, 6, '2025-11-05', '2025-11-05 17:00:00'),
(8, 7, 7, '2025-11-05', '2025-11-05 20:00:00'),
(9, 8, 8, '2025-11-06', '2025-11-06 18:00:00'),
(10, 9, 9, '2025-11-06', '2025-11-06 21:30:00'),
(11, 1, 10, '2025-11-07', '2025-11-07 16:00:00'),
(12, 2, 1, '2025-11-07', '2025-11-07 19:00:00');

-- Insert Seats for all screens
-- Screen 1 (PVR Cinemas - Screen 1) - 100 seats
INSERT INTO Seat (screen_id, seat_number, seat_type, price) VALUES
-- Regular seats
(1, 'A1', 'Regular', 200.00), (1, 'A2', 'Regular', 200.00), (1, 'A3', 'Regular', 200.00), (1, 'A4', 'Regular', 200.00), (1, 'A5', 'Regular', 200.00),
(1, 'A6', 'Regular', 200.00), (1, 'A7', 'Regular', 200.00), (1, 'A8', 'Regular', 200.00), (1, 'A9', 'Regular', 200.00), (1, 'A10', 'Regular', 200.00),
(1, 'B1', 'Regular', 200.00), (1, 'B2', 'Regular', 200.00), (1, 'B3', 'Regular', 200.00), (1, 'B4', 'Regular', 200.00), (1, 'B5', 'Regular', 200.00),
(1, 'B6', 'Regular', 200.00), (1, 'B7', 'Regular', 200.00), (1, 'B8', 'Regular', 200.00), (1, 'B9', 'Regular', 200.00), (1, 'B10', 'Regular', 200.00),
-- Premium seats
(1, 'C1', 'Premium', 300.00), (1, 'C2', 'Premium', 300.00), (1, 'C3', 'Premium', 300.00), (1, 'C4', 'Premium', 300.00), (1, 'C5', 'Premium', 300.00),
(1, 'D1', 'Premium', 300.00), (1, 'D2', 'Premium', 300.00), (1, 'D3', 'Premium', 300.00), (1, 'D4', 'Premium', 300.00), (1, 'D5', 'Premium', 300.00),
(1, 'E1', 'Premium', 300.00), (1, 'E2', 'Premium', 300.00), (1, 'E3', 'Premium', 300.00), (1, 'E4', 'Premium', 300.00), (1, 'E5', 'Premium', 300.00),
-- VIP seats
(1, 'F1', 'VIP', 500.00), (1, 'F2', 'VIP', 500.00), (1, 'F3', 'VIP', 500.00), (1, 'F4', 'VIP', 500.00), (1, 'F5', 'VIP', 500.00),
(1, 'G1', 'VIP', 500.00), (1, 'G2', 'VIP', 500.00), (1, 'G3', 'VIP', 500.00), (1, 'G4', 'VIP', 500.00), (1, 'G5', 'VIP', 500.00);

-- Screen 2 (PVR Cinemas - Screen 2) - 120 seats
INSERT INTO Seat (screen_id, seat_number, seat_type, price) VALUES
-- Regular seats
(2, 'A1', 'Regular', 180.00), (2, 'A2', 'Regular', 180.00), (2, 'A3', 'Regular', 180.00), (2, 'A4', 'Regular', 180.00), (2, 'A5', 'Regular', 180.00),
(2, 'A6', 'Regular', 180.00), (2, 'A7', 'Regular', 180.00), (2, 'A8', 'Regular', 180.00), (2, 'A9', 'Regular', 180.00), (2, 'A10', 'Regular', 180.00),
(2, 'B1', 'Regular', 180.00), (2, 'B2', 'Regular', 180.00), (2, 'B3', 'Regular', 180.00), (2, 'B4', 'Regular', 180.00), (2, 'B5', 'Regular', 180.00),
(2, 'B6', 'Regular', 180.00), (2, 'B7', 'Regular', 180.00), (2, 'B8', 'Regular', 180.00), (2, 'B9', 'Regular', 180.00), (2, 'B10', 'Regular', 180.00),
-- Premium seats
(2, 'C1', 'Premium', 280.00), (2, 'C2', 'Premium', 280.00), (2, 'C3', 'Premium', 280.00), (2, 'C4', 'Premium', 280.00), (2, 'C5', 'Premium', 280.00),
(2, 'D1', 'Premium', 280.00), (2, 'D2', 'Premium', 280.00), (2, 'D3', 'Premium', 280.00), (2, 'D4', 'Premium', 280.00), (2, 'D5', 'Premium', 280.00),
-- VIP seats
(2, 'E1', 'VIP', 450.00), (2, 'E2', 'VIP', 450.00), (2, 'E3', 'VIP', 450.00), (2, 'E4', 'VIP', 450.00), (2, 'E5', 'VIP', 450.00),
(2, 'F1', 'VIP', 450.00), (2, 'F2', 'VIP', 450.00), (2, 'F3', 'VIP', 450.00), (2, 'F4', 'VIP', 450.00), (2, 'F5', 'VIP', 450.00);

-- Screen 3 (INOX - Screen 1) - 80 seats
INSERT INTO Seat (screen_id, seat_number, seat_type, price) VALUES
-- Regular seats
(3, 'A1', 'Regular', 220.00), (3, 'A2', 'Regular', 220.00), (3, 'A3', 'Regular', 220.00), (3, 'A4', 'Regular', 220.00), (3, 'A5', 'Regular', 220.00),
(3, 'B1', 'Regular', 220.00), (3, 'B2', 'Regular', 220.00), (3, 'B3', 'Regular', 220.00), (3, 'B4', 'Regular', 220.00), (3, 'B5', 'Regular', 220.00),
(3, 'C1', 'Regular', 220.00), (3, 'C2', 'Regular', 220.00), (3, 'C3', 'Regular', 220.00), (3, 'C4', 'Regular', 220.00), (3, 'C5', 'Regular', 220.00),
-- Premium seats
(3, 'D1', 'Premium', 320.00), (3, 'D2', 'Premium', 320.00), (3, 'D3', 'Premium', 320.00), (3, 'D4', 'Premium', 320.00), (3, 'D5', 'Premium', 320.00),
(3, 'E1', 'Premium', 320.00), (3, 'E2', 'Premium', 320.00), (3, 'E3', 'Premium', 320.00), (3, 'E4', 'Premium', 320.00), (3, 'E5', 'Premium', 320.00),
-- VIP seats
(3, 'F1', 'VIP', 520.00), (3, 'F2', 'VIP', 520.00), (3, 'F3', 'VIP', 520.00), (3, 'F4', 'VIP', 520.00), (3, 'F5', 'VIP', 520.00);

-- Screen 4 (Cinepolis - Screen 1) - 150 seats
INSERT INTO Seat (screen_id, seat_number, seat_type, price) VALUES
-- Regular seats
(4, 'A1', 'Regular', 250.00), (4, 'A2', 'Regular', 250.00), (4, 'A3', 'Regular', 250.00), (4, 'A4', 'Regular', 250.00), (4, 'A5', 'Regular', 250.00),
(4, 'A6', 'Regular', 250.00), (4, 'A7', 'Regular', 250.00), (4, 'A8', 'Regular', 250.00), (4, 'A9', 'Regular', 250.00), (4, 'A10', 'Regular', 250.00),
(4, 'B1', 'Regular', 250.00), (4, 'B2', 'Regular', 250.00), (4, 'B3', 'Regular', 250.00), (4, 'B4', 'Regular', 250.00), (4, 'B5', 'Regular', 250.00),
(4, 'B6', 'Regular', 250.00), (4, 'B7', 'Regular', 250.00), (4, 'B8', 'Regular', 250.00), (4, 'B9', 'Regular', 250.00), (4, 'B10', 'Regular', 250.00),
-- Premium seats
(4, 'C1', 'Premium', 350.00), (4, 'C2', 'Premium', 350.00), (4, 'C3', 'Premium', 350.00), (4, 'C4', 'Premium', 350.00), (4, 'C5', 'Premium', 350.00),
(4, 'D1', 'Premium', 350.00), (4, 'D2', 'Premium', 350.00), (4, 'D3', 'Premium', 350.00), (4, 'D4', 'Premium', 350.00), (4, 'D5', 'Premium', 350.00),
(4, 'E1', 'Premium', 350.00), (4, 'E2', 'Premium', 350.00), (4, 'E3', 'Premium', 350.00), (4, 'E4', 'Premium', 350.00), (4, 'E5', 'Premium', 350.00),
-- VIP seats
(4, 'F1', 'VIP', 550.00), (4, 'F2', 'VIP', 550.00), (4, 'F3', 'VIP', 550.00), (4, 'F4', 'VIP', 550.00), (4, 'F5', 'VIP', 550.00),
(4, 'G1', 'VIP', 550.00), (4, 'G2', 'VIP', 550.00), (4, 'G3', 'VIP', 550.00), (4, 'G4', 'VIP', 550.00), (4, 'G5', 'VIP', 550.00);

-- Screen 5 seats
INSERT INTO Seat (screen_id, seat_number, seat_type, price) VALUES
(5, 'A1', 'Regular', 200.00), (5, 'A2', 'Regular', 200.00), (5, 'A3', 'Regular', 200.00), (5, 'A4', 'Regular', 200.00), (5, 'A5', 'Regular', 200.00),
(5, 'B1', 'Premium', 300.00), (5, 'B2', 'Premium', 300.00), (5, 'B3', 'Premium', 300.00), (5, 'B4', 'Premium', 300.00), (5, 'B5', 'Premium', 300.00),
(5, 'C1', 'VIP', 500.00), (5, 'C2', 'VIP', 500.00), (5, 'C3', 'VIP', 500.00);

-- Screen 6 seats
INSERT INTO Seat (screen_id, seat_number, seat_type, price) VALUES
(6, 'A1', 'Regular', 180.00), (6, 'A2', 'Regular', 180.00), (6, 'A3', 'Regular', 180.00), (6, 'A4', 'Regular', 180.00), (6, 'A5', 'Regular', 180.00),
(6, 'B1', 'Premium', 280.00), (6, 'B2', 'Premium', 280.00), (6, 'B3', 'Premium', 280.00), (6, 'B4', 'Premium', 280.00),
(6, 'C1', 'VIP', 450.00), (6, 'C2', 'VIP', 450.00), (6, 'C3', 'VIP', 450.00);

-- Screen 7 seats
INSERT INTO Seat (screen_id, seat_number, seat_type, price) VALUES
(7, 'A1', 'Regular', 220.00), (7, 'A2', 'Regular', 220.00), (7, 'A3', 'Regular', 220.00), (7, 'A4', 'Regular', 220.00), (7, 'A5', 'Regular', 220.00),
(7, 'B1', 'Premium', 320.00), (7, 'B2', 'Premium', 320.00), (7, 'B3', 'Premium', 320.00), (7, 'B4', 'Premium', 320.00),
(7, 'C1', 'VIP', 520.00), (7, 'C2', 'VIP', 520.00), (7, 'C3', 'VIP', 520.00);

-- Screen 8 seats
INSERT INTO Seat (screen_id, seat_number, seat_type, price) VALUES
(8, 'A1', 'Regular', 250.00), (8, 'A2', 'Regular', 250.00), (8, 'A3', 'Regular', 250.00), (8, 'A4', 'Regular', 250.00), (8, 'A5', 'Regular', 250.00),
(8, 'B1', 'Premium', 350.00), (8, 'B2', 'Premium', 350.00), (8, 'B3', 'Premium', 350.00), (8, 'B4', 'Premium', 350.00),
(8, 'C1', 'VIP', 550.00), (8, 'C2', 'VIP', 550.00), (8, 'C3', 'VIP', 550.00);

-- Screen 9 seats
INSERT INTO Seat (screen_id, seat_number, seat_type, price) VALUES
(9, 'A1', 'Regular', 200.00), (9, 'A2', 'Regular', 200.00), (9, 'A3', 'Regular', 200.00), (9, 'A4', 'Regular', 200.00),
(9, 'B1', 'Premium', 300.00), (9, 'B2', 'Premium', 300.00), (9, 'B3', 'Premium', 300.00),
(9, 'C1', 'VIP', 500.00), (9, 'C2', 'VIP', 500.00);

-- Insert Users (with passwords)
INSERT INTO User (user_id, user_name, email, phone, password) VALUES
(1, 'Rahul Mehta', 'rahul@example.com', '9876543210', 'password123'),
(2, 'Ananya Sharma', 'ananya@example.com', '9876501234', 'password123'),
(3, 'John Doe', 'john@example.com', '9998887776', 'password123'),
(4, 'Priya Singh', 'priya@example.com', '9876123456', 'password123'),
(5, 'Amit Kumar', 'amit@example.com', '9876234567', 'pass123'),
(6, 'Sneha Patel', 'sneha@example.com', '9876345678', 'pass123'),
(7, 'Vikram Singh', 'vikram@example.com', '9876456789', 'pass123'),
(8, 'Meera Reddy', 'meera@example.com', '9876567890', 'pass123'),
(9, 'Rajesh Gupta', 'rajesh@example.com', '9876678901', 'pass123'),
(10, 'Kavita Sharma', 'kavita@example.com', '9876789012', 'pass123');

-- Insert Sample Bookings
INSERT INTO Booking (booking_id, user_id, show_id, booking_date) VALUES
(1, 1, 1, '2025-10-20 10:00:00'),
(2, 2, 2, '2025-10-20 11:30:00'),
(3, 3, 3, '2025-10-21 09:15:00'),
(4, 4, 4, '2025-10-21 14:00:00'),
(5, 5, 5, '2025-10-25 10:30:00'),
(6, 6, 6, '2025-10-25 11:00:00'),
(7, 7, 7, '2025-10-25 12:15:00'),
(8, 8, 8, '2025-10-25 14:00:00');

-- Insert Sample Tickets
INSERT INTO Ticket (ticket_id, booking_id, seat_id) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 21),
(4, 3, 41),
(5, 4, 61),
(6, 5, 91),
(7, 5, 92),
(8, 6, 51),
(9, 7, 71),
(10, 7, 72),
(11, 8, 101),
(12, 8, 102),
(13, 8, 103);

-- Insert Sample Payments
INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method, status) VALUES
(1, 1, 400.00, '2025-10-20 10:01:00', 'Credit Card', 'Success'),
(2, 2, 300.00, '2025-10-20 11:32:00', 'UPI', 'Success'),
(3, 3, 520.00, '2025-10-21 09:17:00', 'Debit Card', 'Pending'),
(4, 4, 550.00, '2025-10-21 14:03:00', 'Cash', 'Success'),
(5, 5, 400.00, '2025-10-25 10:31:00', 'UPI', 'Success'),
(6, 6, 200.00, '2025-10-25 11:02:00', 'Credit Card', 'Success'),
(7, 7, 440.00, '2025-10-25 12:17:00', 'Debit Card', 'Success'),
(8, 8, 750.00, '2025-10-25 14:03:00', 'Net Banking', 'Success');

-- ============================================
-- DISPLAY SUMMARY
-- ============================================

SELECT '✅ Database setup completed successfully!' as Status;
SELECT '===========================================' as '';
SELECT 'SUMMARY' as '';
SELECT '===========================================' as '';
SELECT COUNT(*) as Total_Theatres FROM Theatre;
SELECT COUNT(*) as Total_Screens FROM Screen;
SELECT COUNT(*) as Total_Movies FROM Movie;
SELECT COUNT(*) as Total_Shows FROM ShowTable;
SELECT COUNT(*) as Total_Seats FROM Seat;
SELECT COUNT(*) as Total_Users FROM User;
SELECT COUNT(*) as Total_Bookings FROM Booking;
SELECT '===========================================' as '';
SELECT 'Default user passwords: password123 or pass123' as Info;
SELECT '===========================================' as '';
