-- database creation
CREATE DATABASE BloodDonationDB;
USE BloodDonationDB;

-- table creation
CREATE TABLE Donors (
  DonorID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(100),
  Age INT,
  BloodGroup VARCHAR(5),
  Contact VARCHAR(15),
  LastDonationDate DATE
);

CREATE TABLE Recipients (
  RecipientID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(100),
  Age INT,
  BloodGroup VARCHAR(5),
  Contact VARCHAR(15),
  BloodRequired INT
);

CREATE TABLE BloodInventory (
  BloodGroup VARCHAR(5) PRIMARY KEY,
  UnitsAvailable INT DEFAULT 0
);

INSERT INTO BloodInventory (BloodGroup, UnitsAvailable)
VALUES ('O+', 0), ('A+', 0), ('B+', 0), ('AB+', 0),
       ('O-', 0), ('A-', 0), ('B-', 0), ('AB-', 0);

CREATE TABLE Donations (
  DonationID INT AUTO_INCREMENT PRIMARY KEY,
  DonorID INT,
  BloodGroup VARCHAR(5),
  DonationDate DATE,
  FOREIGN KEY (DonorID) REFERENCES Donors(DonorID)
);

CREATE TABLE Requests (
  RequestID INT AUTO_INCREMENT PRIMARY KEY,
  RecipientID INT,
  BloodGroup VARCHAR(5),
  UnitsRequested INT,
  RequestDate DATE,
  Status ENUM('Approved', 'Rejected', 'Pending') DEFAULT 'Pending',
  FOREIGN KEY (RecipientID) REFERENCES Recipients(RecipientID)
);

-- create trigger

DELIMITER //
CREATE TRIGGER UpdateInventoryAfterDonation
AFTER INSERT ON Donations
FOR EACH ROW
BEGIN
  UPDATE BloodInventory
  SET UnitsAvailable = UnitsAvailable + 1
  WHERE BloodGroup = NEW.BloodGroup;
END;
//
DELIMITER ;

-- insert values in the tables
INSERT INTO Donors (Name, Age, BloodGroup, Contact, LastDonationDate)
VALUES ('Rahul Sharma', 28, 'O+', '9876543210', '2025-03-01');

INSERT INTO Recipients (Name, Age, BloodGroup, Contact, BloodRequired)
VALUES ('Aditi Verma', 35, 'O+', '9898989898', 2);

INSERT INTO Donations (DonorID, BloodGroup, DonationDate)
VALUES (1, 'O+', '2025-03-20');

-- check inventory and requests
SELECT UnitsAvailable FROM BloodInventory WHERE BloodGroup = 'O+';

INSERT INTO Requests (RecipientID, BloodGroup, UnitsRequested, RequestDate, Status)
VALUES (1, 'O+', 2, CURDATE(), 'Approved');

-- generate reports
SELECT * FROM BloodInventory;

SELECT Donors.Name, Donations.BloodGroup, Donations.DonationDate
FROM Donations
JOIN Donors ON Donations.DonorID = Donors.DonorID;

SELECT Recipients.Name, Requests.BloodGroup, Requests.UnitsRequested, Requests.Status
FROM Requests
JOIN Recipients ON Requests.RecipientID = Recipients.RecipientID;