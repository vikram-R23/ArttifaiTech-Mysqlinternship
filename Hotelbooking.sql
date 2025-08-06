-- creating database
create database Hotel;
use hotel;
-- create table
CREATE TABLE Rooms (
  RoomID INT PRIMARY KEY,
  RoomType VARCHAR(50),
  PricePerNight DECIMAL(10,2),
  Availability ENUM('Available', 'Booked') DEFAULT 'Available'
);

CREATE TABLE Customers (
  CustomerID INT PRIMARY KEY,
  Name VARCHAR(100),
  Contact VARCHAR(15),
  Email VARCHAR(100)
);

CREATE TABLE Bookings (
  BookingID INT PRIMARY KEY,
  CustomerID INT,
  RoomID INT,
  CheckInDate DATE,
  CheckOutDate DATE,
  TotalAmount DECIMAL(10,2),
  PaymentStatus ENUM('Paid', 'Pending') DEFAULT 'Pending',
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
  FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);

CREATE TABLE Payments (
  PaymentID INT PRIMARY KEY,
  BookingID INT,
  AmountPaid DECIMAL(10,2),
  PaymentMethod VARCHAR(50),
  PaymentDate DATE,
  FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- insert records
INSERT INTO Rooms (RoomID, RoomType, PricePerNight, Availability) VALUES
(101, 'Deluxe', 5000, 'Available'),
(102, 'Standard', 3000, 'Booked'),
(103, 'Suite', 8000, 'Available'),
(104, 'Standard', 3000, 'Available');

INSERT INTO Customers (CustomerID, Name, Contact, Email) VALUES
(1, 'Raj Malhotra', '9876543210', 'raj@gmail.com'),
(2, 'Ananya Sharma', '7894561230', 'ananya@yahoo.com');

INSERT INTO Bookings (BookingID, CustomerID, RoomID, CheckInDate, CheckOutDate, TotalAmount, PaymentStatus) VALUES
(1001, 1, 102, '2025-04-01', '2025-04-05', 12000, 'Paid'),
(1002, 2, 103, '2025-04-10', '2025-04-15', 40000, 'Pending');

INSERT INTO Payments (PaymentID, BookingID, AmountPaid, PaymentMethod, PaymentDate) VALUES
(5001, 1001, 12000, 'Credit Card', '2025-03-30'),
(5002, 1002, 20000, 'UPI', '2025-04-08');

-- select queries
SELECT RoomID, RoomType, PricePerNight, Availability FROM Rooms;

SELECT * FROM Customers;

SELECT BookingID, CustomerID, RoomID, CheckInDate, CheckOutDate, TotalAmount, PaymentStatus
FROM Bookings;

SELECT PaymentID, BookingID, AmountPaid, PaymentMethod, PaymentDate FROM Payments;

SELECT SUM(AmountPaid) AS TotalRevenue FROM Payments;
