-- database creation
create schema Bus;
use bus;

-- table creation

-- Bus table
CREATE TABLE Bus (
  BusID INT PRIMARY KEY,
  BusNumber VARCHAR(20),
  BusType VARCHAR(50),
  TotalSeats INT
);

-- route table
CREATE TABLE Route (
  RouteID INT PRIMARY KEY,
  Source VARCHAR(50),
  Destination VARCHAR(50),
  DepartureTime TIME,
  ArrivalTime TIME,
  Fare DECIMAL(10,2)
);

-- customer table
CREATE TABLE Customer (
  CustomerID INT PRIMARY KEY,
  Name VARCHAR(100),
  PhoneNumber VARCHAR(15),
  Email VARCHAR(100)
);

-- ticket booking table 
CREATE TABLE TicketBooking (
  BookingID INT PRIMARY KEY,
  CustomerID INT,
  BusID INT,
  RouteID INT,
  SeatsBooked INT,
  TotalFare DECIMAL(10,2),
  Status ENUM('Confirmed', 'Pending', 'Cancelled'),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  FOREIGN KEY (BusID) REFERENCES Bus(BusID),
  FOREIGN KEY (RouteID) REFERENCES Route(RouteID)
);

-- payment table
CREATE TABLE Payment (
  PaymentID INT PRIMARY KEY,
  BookingID INT,
  PaymentMethod VARCHAR(50),
  AmountPaid DECIMAL(10,2),
  PaymentStatus ENUM('Completed', 'Pending', 'Failed'),
  FOREIGN KEY (BookingID) REFERENCES TicketBooking(BookingID)
);

-- Insert records
-- Bus records
INSERT INTO Bus VALUES
(1, 'MH12AB1234', 'AC Sleeper', 40),
(2, 'KA10XY5678', 'Non-AC Seater', 50);

-- route records
INSERT INTO Route VALUES
(101, 'Mumbai', 'Pune', '08:00:00', '11:00:00', 500),
(102, 'Delhi', 'Jaipur', '09:00:00', '13:00:00', 700);

-- customer records
INSERT INTO Customer VALUES
(1, 'Rahul Sharma', '9876543210', 'rahul@gmail.com'),
(2, 'Pooja Nair', '9123456789', 'pooja@gmail.com');

-- ticket booking records
INSERT INTO TicketBooking VALUES
(5001, 1, 1, 101, 2, 1000, 'Confirmed'),
(5002, 2, 2, 102, 1, 700, 'Pending');

-- payment records
INSERT INTO Payment VALUES
(1001, 5001, 'Credit Card', 1000, 'Completed'),
(1002, 5002, 'UPI', 700, 'Pending');

-- selecting queries
SELECT * FROM Bus;
SELECT * FROM Route;
SELECT * FROM Customer;
SELECT * FROM TicketBooking;
SELECT * FROM Payment;

-- select revenue report
SELECT RouteID, SUM(TotalFare) AS TotalRevenue
FROM TicketBooking
WHERE Status = 'Confirmed'
GROUP BY RouteID;

-- book ticket procedure
DELIMITER //
CREATE PROCEDURE BookTicket(
  IN p_BookingID INT,
  IN p_CustomerID INT,
  IN p_BusID INT,
  IN p_RouteID INT,
  IN p_Seats INT
)
BEGIN
  DECLARE fare DECIMAL(10,2);
  DECLARE total DECIMAL(10,2);
  DECLARE available INT;

  SELECT Fare INTO fare FROM Route WHERE RouteID = p_RouteID;
  SET total = fare * p_Seats;

  SELECT TotalSeats - IFNULL(SUM(SeatsBooked), 0) INTO available
  FROM TicketBooking
  WHERE BusID = p_BusID AND RouteID = p_RouteID AND Status = 'Confirmed';

  IF available >= p_Seats THEN
    INSERT INTO TicketBooking (BookingID, CustomerID, BusID, RouteID, SeatsBooked, TotalFare, Status)
    VALUES (p_BookingID, p_CustomerID, p_BusID, p_RouteID, p_Seats, total, 'Confirmed');
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough seats available';
  END IF;
END;
//
DELIMITER ;