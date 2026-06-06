-- Create the database and use it
DROP DATABASE IF EXISTS elite_sports_club;
CREATE DATABASE elite_sports_club;
USE elite_sports_club;

-- SECTION 1: CREATE TABLES

-- Create membership_plans table to store available subscription plans
CREATE TABLE membership_plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    duration_days INT NOT NULL CHECK (duration_days > 0 AND duration_days <= 365),
    fee DECIMAL(10, 2) NOT NULL CHECK (fee > 0)
);

-- Create sports table to store the available sports and their capacity
CREATE TABLE sports (
    sport_id INT PRIMARY KEY,
    sport_name VARCHAR(50) NOT NULL UNIQUE,
    max_members INT NOT NULL CHECK (max_members >= 1 AND max_members <= 500),
    CHECK (sport_name REGEXP '^[A-Za-z ]+$')
);

-- Create coaches table to store coach details and the sport they train
CREATE TABLE coaches (
    coach_id INT PRIMARY KEY,
    coach_name VARCHAR(100) NOT NULL,
    sport_id INT NOT NULL,
    experience_years INT NOT NULL CHECK (experience_years >= 0 AND experience_years <= 50),
    salary DECIMAL(10, 2) NOT NULL CHECK (salary >= 10000.00 AND salary <= 500000.00),
    phone VARCHAR(15) NOT NULL UNIQUE,
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id),
    CHECK (coach_name REGEXP '^[A-Za-z ]+$'),
    CHECK (phone REGEXP '^[6-9][0-9]{9}$')
);

-- Create facilities table to store sports facilities and their availability
CREATE TABLE facilities (
    facility_id INT PRIMARY KEY,
    facility_name VARCHAR(100) NOT NULL,
    sport_id INT NOT NULL,
    capacity INT NOT NULL CHECK (capacity >= 1),
    availability_status ENUM('Available', 'Under Maintenance') NOT NULL DEFAULT 'Available',
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
);

-- Create members table to store member details and link to their plan
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    age INT NOT NULL CHECK (age >= 5 AND age <= 80),
    gender ENUM('Male', 'Female') NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    join_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    plan_id INT NOT NULL,
    FOREIGN KEY (plan_id) REFERENCES membership_plans(plan_id),
    CHECK (full_name REGEXP '^[A-Za-z ]+$'),
    CHECK (phone REGEXP '^[6-9][0-9]{9}$'),
    CHECK (expiry_date >= join_date)
);

-- Create enrollments table to link members and the sports they play
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    member_id INT,
    sport_id INT,
    enrollment_date DATE,
    UNIQUE (member_id, sport_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
);

-- Create bookings table for facility reservations by members
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    member_id INT,
    facility_id INT,
    booking_date DATE,
    time_slot ENUM('Morning', 'Afternoon', 'Evening'),
    status ENUM('Confirmed', 'Cancelled'),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
);

-- Create booking_log table to keep a history of bookings (populated via trigger)
CREATE TABLE booking_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    member_id INT,
    facility_id INT,
    logged_at TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- SECTION 2: INSERT DATA

-- Insert 3 membership plans
INSERT INTO membership_plans (plan_id, plan_name, duration_days, fee) VALUES
(1, 'Monthly', 30, 1000.00),
(2, 'Quarterly', 90, 2500.00),
(3, 'Annual', 365, 9000.00);

-- Insert 8 sports
INSERT INTO sports (sport_id, sport_name, max_members) VALUES
(1, 'Cricket', 100),
(2, 'Football', 80),
(3, 'Basketball', 60),
(4, 'Tennis', 50),
(5, 'Badminton', 50),
(6, 'Swimming', 150),
(7, 'Volleyball', 60),
(8, 'Athletics', 120);

-- Insert 8 coaches with realistic data
INSERT INTO coaches (coach_id, coach_name, sport_id, experience_years, salary, phone) VALUES
(1, 'Rahul Sharma', 1, 8, 45000.00, '9876543210'),
(2, 'Priya Reddy', 4, 6, 40000.00, '9123456780'),
(3, 'Arjun Kumar', 2, 10, 55000.00, '9988776655'),
(4, 'Pullela Gopichand', 5, 15, 60000.00, '9876543213'),
(5, 'Virdhawal Khade', 6, 12, 50000.00, '9876543214'),
(6, 'Sunil Chhetri', 2, 18, 65000.00, '9876543215'),
(7, 'Manish Verma', 3, 7, 42000.00, '9876543216'),
(8, 'Deepa Nair', 7, 5, 38000.00, '9876543217');

-- Insert 8 facilities
INSERT INTO facilities (facility_id, facility_name, sport_id, capacity, availability_status) VALUES
(1, 'Main Cricket Ground', 1, 22, 'Available'),
(2, 'Football Turf', 2, 22, 'Available'),
(3, 'Indoor Badminton Court', 5, 4, 'Available'),
(4, 'Tennis Court A', 4, 4, 'Available'),
(5, 'Olympic Swimming Pool', 6, 50, 'Available'),
(6, 'Basketball Arena', 3, 20, 'Available'),
(7, 'Volleyball Court', 7, 12, 'Under Maintenance'),
(8, 'Athletics Track', 8, 100, 'Available');

-- Insert 10 members with valid data
INSERT INTO members (member_id, full_name, age, gender, phone, email, join_date, expiry_date, plan_id) VALUES
(1, 'Arjun Patel', 25, 'Male', '9123456701', 'arjun@example.com', '2024-01-15', '2024-02-14', 1),
(2, 'Priya Sharma', 22, 'Female', '9123456702', 'priya@example.com', '2024-05-10', '2024-08-08', 2),
(3, 'Rohan Desai', 28, 'Male', '9123456703', 'rohan@example.com', DATE_SUB(CURDATE(), INTERVAL 100 DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 100 DAY), INTERVAL 365 DAY), 3),
(4, 'Sneha Iyer', 24, 'Female', '9123456704', 'sneha@example.com', DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 15 DAY), INTERVAL 30 DAY), 1),
(5, 'Vikram Singh', 30, 'Male', '9123456705', 'vikram@example.com', '2024-09-01', '2024-11-30', 2),
(6, 'Ananya Gupta', 27, 'Female', '9123456706', 'ananya@example.com', DATE_SUB(CURDATE(), INTERVAL 200 DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 200 DAY), INTERVAL 365 DAY), 3),
(7, 'Karan Verma', 21, 'Male', '9123456707', 'karan@example.com', DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 10 DAY), INTERVAL 30 DAY), 1),
(8, 'Meera Reddy', 26, 'Female', '9123456708', 'meera@example.com', DATE_SUB(CURDATE(), INTERVAL 45 DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 45 DAY), INTERVAL 90 DAY), 2),
(9, 'Rahul Nair', 29, 'Male', '9123456709', 'rahuln@example.com', '2024-11-10', '2025-11-10', 3),
(10, 'Neha Kapoor', 23, 'Female', '9123456710', 'neha@example.com', DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 5 DAY), INTERVAL 30 DAY), 1);

-- Insert 12 enrollments
INSERT INTO enrollments (enrollment_id, member_id, sport_id, enrollment_date) VALUES
(1, 1, 1, '2024-01-15'),
(2, 2, 5, '2024-05-10'),
(3, 3, 2, DATE_SUB(CURDATE(), INTERVAL 100 DAY)),
(4, 3, 6, DATE_SUB(CURDATE(), INTERVAL 95 DAY)),
(5, 4, 5, DATE_SUB(CURDATE(), INTERVAL 15 DAY)),
(6, 5, 2, '2024-09-01'),
(7, 6, 1, DATE_SUB(CURDATE(), INTERVAL 200 DAY)),
(8, 6, 6, DATE_SUB(CURDATE(), INTERVAL 195 DAY)),
(9, 7, 6, DATE_SUB(CURDATE(), INTERVAL 10 DAY)),
(10, 8, 5, DATE_SUB(CURDATE(), INTERVAL 45 DAY)),
(11, 9, 1, '2024-11-10'),
(12, 10, 2, DATE_SUB(CURDATE(), INTERVAL 5 DAY));

-- Insert 10 bookings
INSERT INTO bookings (booking_id, member_id, facility_id, booking_date, time_slot, status) VALUES
(1, 1, 1, '2024-01-20', 'Morning', 'Confirmed'),
(2, 2, 3, '2024-05-15', 'Evening', 'Confirmed'),
(3, 3, 2, CURDATE(), 'Afternoon', 'Confirmed'),
(4, 4, 3, CURDATE(), 'Morning', 'Confirmed'),
(5, 5, 2, '2024-09-15', 'Evening', 'Cancelled'),
(6, 6, 1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Morning', 'Confirmed'),
(7, 6, 5, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Afternoon', 'Confirmed'),
(8, 7, 5, CURDATE(), 'Evening', 'Confirmed'),
(9, 8, 3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Morning', 'Cancelled'),
(10, 10, 2, CURDATE(), 'Afternoon', 'Confirmed');

-- SECTION 3: QUERIES

-- 1. List all members with their membership plan name and fee using JOIN
SELECT m.full_name, p.plan_name, p.fee
FROM members m
JOIN membership_plans p ON m.plan_id = p.plan_id;

-- 2. List all members enrolled in Football along with their coach's name using JOIN across members, enrollments, sports, and coaches
SELECT m.full_name, c.coach_name
FROM members m
JOIN enrollments e ON m.member_id = e.member_id
JOIN sports s ON e.sport_id = s.sport_id
JOIN coaches c ON s.sport_id = c.sport_id
WHERE s.sport_name = 'Football';

-- 3. Count how many members are enrolled in each sport using GROUP BY and ORDER BY count descending
SELECT s.sport_name, COUNT(e.member_id) AS enrolled_members
FROM sports s
LEFT JOIN enrollments e ON s.sport_id = e.sport_id
GROUP BY s.sport_name
ORDER BY enrolled_members DESC;

-- 4. Find all bookings made by a specific member showing facility name, date, time slot, and status
SELECT f.facility_name, b.booking_date, b.time_slot, b.status
FROM bookings b
JOIN facilities f ON b.facility_id = f.facility_id
JOIN members m ON b.member_id = m.member_id
WHERE m.full_name = 'Ananya Gupta';

-- 5. Find which facilities are currently Under Maintenance
SELECT facility_name, sport_id
FROM facilities
WHERE availability_status = 'Under Maintenance';

-- 6. List coaches along with the sport they train and how many members are enrolled in that sport using GROUP BY
SELECT c.coach_name, s.sport_name, COUNT(e.member_id) AS enrolled_members
FROM coaches c
JOIN sports s ON c.sport_id = s.sport_id
LEFT JOIN enrollments e ON s.sport_id = e.sport_id
GROUP BY c.coach_id, c.coach_name, s.sport_name;

-- 7. Find members who have enrolled in more than one sport using GROUP BY and HAVING
SELECT m.full_name, COUNT(e.sport_id) AS sports_enrolled
FROM members m
JOIN enrollments e ON m.member_id = e.member_id
GROUP BY m.member_id, m.full_name
HAVING COUNT(e.sport_id) > 1;

-- 8. Find all members whose membership has already expired (compare expiry_date with CURDATE())
SELECT full_name, expiry_date
FROM members
WHERE expiry_date < CURDATE();

-- 9. A subquery to find the sport with the highest number of enrollments
SELECT sport_name
FROM sports
WHERE sport_id = (
    SELECT sport_id
    FROM enrollments
    GROUP BY sport_id
    ORDER BY COUNT(member_id) DESC
    LIMIT 1
);

-- 10. List all morning slot bookings that are Confirmed with member name and facility name
SELECT m.full_name, f.facility_name, b.booking_date
FROM bookings b
JOIN members m ON b.member_id = m.member_id
JOIN facilities f ON b.facility_id = f.facility_id
WHERE b.time_slot = 'Morning' AND b.status = 'Confirmed';

-- SECTION 4: VIEW

-- Create a view called active_members_view that shows member details only for members whose expiry_date is greater than or equal to today
CREATE VIEW active_members_view AS
SELECT m.member_id, m.full_name, m.phone, p.plan_name, m.expiry_date
FROM members m
JOIN membership_plans p ON m.plan_id = p.plan_id
WHERE m.expiry_date >= CURDATE();

-- Show a SELECT on this view after creating it
SELECT * FROM active_members_view;

-- SECTION 5: STORED PROCEDURE

DELIMITER //

-- Create a stored procedure called enroll_member that accepts member_id and sport_id as input parameters
CREATE PROCEDURE enroll_member(IN p_member_id INT, IN p_sport_id INT)
BEGIN
    DECLARE is_enrolled INT;
    
    -- Check if the member is already enrolled in that sport
    SELECT COUNT(*) INTO is_enrolled
    FROM enrollments
    WHERE member_id = p_member_id AND sport_id = p_sport_id;
    
    IF is_enrolled > 0 THEN
        SELECT 'Member already enrolled.' AS Message;
    ELSE
        -- Insert a new row into the enrollments table with today's date
        INSERT INTO enrollments (enrollment_id, member_id, sport_id, enrollment_date)
        SELECT COALESCE(MAX(enrollment_id), 0) + 1, p_member_id, p_sport_id, CURDATE()
        FROM enrollments;
        
        SELECT 'Enrollment successful.' AS Message;
    END IF;
END //

DELIMITER ;

-- Show a sample CALL statement (Member 1 is NOT currently enrolled in sport 2)
CALL enroll_member(1, 2);

-- Calling again to demonstrate the 'Member already enrolled' message
CALL enroll_member(1, 2);

-- SECTION 6: TRIGGER

DELIMITER //

-- Create an AFTER INSERT trigger on the bookings table called log_booking
CREATE TRIGGER log_booking
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    -- Automatically insert a row into the booking_log table capturing the booking details
    INSERT INTO booking_log (booking_id, member_id, facility_id, logged_at)
    VALUES (NEW.booking_id, NEW.member_id, NEW.facility_id, CURRENT_TIMESTAMP);
END //

DELIMITER ;

-- Show a sample INSERT into bookings to demonstrate the trigger firing
INSERT INTO bookings (booking_id, member_id, facility_id, booking_date, time_slot, status) 
VALUES (11, 7, 1, CURDATE(), 'Morning', 'Confirmed');

-- SELECT from booking_log to verify the trigger worked
SELECT * FROM booking_log;

-- ========================================================================
-- SECTION 7: ADVANCED QUERIES (ANALYTICAL & AGGREGATE)
-- ========================================================================

-- Rank members by booking frequency using window functions
SELECT 
    m.member_id, 
    m.full_name, 
    COUNT(b.booking_id) AS booking_count,
    RANK() OVER(ORDER BY COUNT(b.booking_id) DESC) AS rank_by_bookings,
    DENSE_RANK() OVER(ORDER BY COUNT(b.booking_id) DESC) AS dense_rank_by_bookings,
    ROW_NUMBER() OVER(ORDER BY COUNT(b.booking_id) DESC) AS row_num_by_bookings
FROM members m
LEFT JOIN bookings b ON m.member_id = b.member_id
GROUP BY m.member_id, m.full_name;

-- Rank coaches by experience within each sport
SELECT 
    c.coach_id,
    c.coach_name,
    s.sport_name,
    c.experience_years,
    RANK() OVER(PARTITION BY c.sport_id ORDER BY c.experience_years DESC) AS experience_rank
FROM coaches c
JOIN sports s ON c.sport_id = s.sport_id;

-- ========================================================================
-- SECTION 8: NEW STORED PROCEDURES
-- ========================================================================

DELIMITER //

-- Stored Procedure: Cancel Booking
-- Checks if booking exists and is Confirmed, updates status to Cancelled and logs message
CREATE PROCEDURE cancel_booking(IN p_booking_id INT)
BEGIN
    DECLARE v_status VARCHAR(20);
    
    -- Check if booking exists and get its status
    SELECT status INTO v_status
    FROM bookings
    WHERE booking_id = p_booking_id;
    
    IF v_status IS NULL THEN
        SELECT 'Booking not found.' AS Message;
    ELSEIF v_status = 'Confirmed' THEN
        UPDATE bookings
        SET status = 'Cancelled'
        WHERE booking_id = p_booking_id;
        SELECT CONCAT('Booking ', p_booking_id, ' cancelled successfully.') AS Message;
    ELSE
        SELECT CONCAT('Booking is already ', v_status, '.') AS Message;
    END IF;
END //

-- Stored Procedure: Renew Membership
-- Extends the expiry_date of a member based on the selected plan's duration
CREATE PROCEDURE renew_membership(IN p_member_id INT, IN p_plan_id INT)
BEGIN
    DECLARE v_duration INT;
    DECLARE v_current_expiry DATE;
    DECLARE v_new_expiry DATE;
    
    -- Get plan duration
    SELECT duration_days INTO v_duration
    FROM membership_plans
    WHERE plan_id = p_plan_id;
    
    IF v_duration IS NULL THEN
        SELECT 'Invalid plan selected.' AS Message;
    ELSE
        -- Get current expiry
        SELECT expiry_date INTO v_current_expiry
        FROM members
        WHERE member_id = p_member_id;
        
        IF v_current_expiry IS NULL THEN
            SELECT 'Member not found.' AS Message;
        ELSE
            -- If already expired, start from today. Otherwise, extend from expiry date.
            IF v_current_expiry < CURDATE() THEN
                SET v_new_expiry = DATE_ADD(CURDATE(), INTERVAL v_duration DAY);
            ELSE
                SET v_new_expiry = DATE_ADD(v_current_expiry, INTERVAL v_duration DAY);
            END IF;
            
            UPDATE members
            SET plan_id = p_plan_id, expiry_date = v_new_expiry
            WHERE member_id = p_member_id;
            
            SELECT CONCAT('Membership renewed successfully. New expiry date: ', v_new_expiry) AS Message;
        END IF;
    END IF;
END //

DELIMITER ;

-- Sample CALL for cancel_booking
CALL cancel_booking(1);

-- Sample CALL for renew_membership
CALL renew_membership(1, 2);

-- ========================================================================
-- SECTION 9: ADDITIONAL TRIGGERS
-- ========================================================================

-- Create booking_status_log table for the update trigger
CREATE TABLE booking_status_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    old_status ENUM('Confirmed', 'Cancelled'),
    new_status ENUM('Confirmed', 'Cancelled'),
    changed_at TIMESTAMP
);

DELIMITER //

-- Trigger: BEFORE INSERT on enrollments
-- Checks if the sport has reached max_members and raises an error if so
CREATE TRIGGER check_max_members
BEFORE INSERT ON enrollments
FOR EACH ROW
BEGIN
    DECLARE v_current_enrollments INT;
    DECLARE v_max_members INT;
    
    -- Get current count and max allowed
    SELECT COUNT(*) INTO v_current_enrollments
    FROM enrollments
    WHERE sport_id = NEW.sport_id;
    
    SELECT max_members INTO v_max_members
    FROM sports
    WHERE sport_id = NEW.sport_id;
    
    IF v_current_enrollments >= v_max_members THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot enroll: Sport has reached maximum capacity.';
    END IF;
END //

-- Trigger: AFTER UPDATE on bookings
-- Logs any status change to the booking_status_log table
CREATE TRIGGER log_booking_status_change
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO booking_status_log (booking_id, old_status, new_status, changed_at)
        VALUES (NEW.booking_id, OLD.status, NEW.status, CURRENT_TIMESTAMP);
    END IF;
END //

DELIMITER ;

-- ========================================================================
-- SECTION 10: NEW VIEW (Coach Workload)
-- ========================================================================

-- Create coach_workload_view showing coach details and their assigned members count
CREATE VIEW coach_workload_view AS
SELECT 
    c.coach_name,
    s.sport_name,
    c.salary,
    COUNT(e.member_id) AS members_to_train
FROM coaches c
JOIN sports s ON c.sport_id = s.sport_id
LEFT JOIN enrollments e ON s.sport_id = e.sport_id
GROUP BY c.coach_id, c.coach_name, s.sport_name, c.salary;

-- Query the newly created view
SELECT * FROM coach_workload_view;

-- ========================================================================
-- SECTION 11: INDEXES
-- ========================================================================

-- Index on member_id in enrollments: Speeds up finding all sports a specific member plays
CREATE INDEX idx_enrollments_member_id ON enrollments(member_id);

-- Index on sport_id in enrollments: Optimizes aggregating members by sport (e.g., checking capacities)
CREATE INDEX idx_enrollments_sport_id ON enrollments(sport_id);

-- Index on member_id in bookings: Speeds up lookups of booking histories for a given member
CREATE INDEX idx_bookings_member_id ON bookings(member_id);

-- Index on facility_id in bookings: Optimizes checking bookings for a particular facility (e.g., conflicts)
CREATE INDEX idx_bookings_facility_id ON bookings(facility_id);

-- Index on sport_id in coaches: Improves JOIN performance between coaches and sports
CREATE INDEX idx_coaches_sport_id ON coaches(sport_id);

-- Index on sport_id in facilities: Improves JOIN performance between facilities and sports
CREATE INDEX idx_facilities_sport_id ON facilities(sport_id);

-- ========================================================================
-- SECTION 12: TRANSACTIONS
-- ========================================================================

-- Demonstrate a transaction block with a stored procedure that uses an EXIT HANDLER
DELIMITER //

CREATE PROCEDURE register_enroll_and_book(
    IN p_member_id INT, 
    IN p_name VARCHAR(100), 
    IN p_phone VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_sport_id INT, 
    IN p_facility_id INT
)
BEGIN
    -- Declare exit handler for SQLEXCEPTION
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        -- If any error occurs, rollback the entire transaction
        ROLLBACK;
        SELECT 'Transaction failed and rolled back due to an error.' AS Transaction_Status;
    END;

    -- Start Transaction
    START TRANSACTION;

    -- Step 1: Insert new member with valid data
    INSERT INTO members (member_id, full_name, age, gender, phone, email, join_date, expiry_date, plan_id) 
    VALUES (p_member_id, p_name, 25, 'Male', p_phone, p_email, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 1);

    -- Step 2: Enroll in sport
    INSERT INTO enrollments (enrollment_id, member_id, sport_id, enrollment_date) 
    SELECT COALESCE(MAX(enrollment_id), 0) + 1, p_member_id, p_sport_id, CURDATE() FROM enrollments;

    -- Step 3: Make a booking
    INSERT INTO bookings (booking_id, member_id, facility_id, booking_date, time_slot, status) 
    SELECT COALESCE(MAX(booking_id), 0) + 1, p_member_id, p_facility_id, CURDATE(), 'Morning', 'Confirmed' FROM bookings;

    -- If all steps succeed, commit the transaction
    COMMIT;
    SELECT 'Transaction committed successfully.' AS Transaction_Status;
END //

DELIMITER ;

-- Call the transaction procedure (Valid case)
CALL register_enroll_and_book(11, 'Suresh Raina', '9876501234', 'suresh@example.com', 1, 1);

-- Call with a duplicate member_id to force a failure and demonstrate ROLLBACK
CALL register_enroll_and_book(11, 'Duplicate Suresh', '9876501235', 'dupe@example.com', 2, 2);
