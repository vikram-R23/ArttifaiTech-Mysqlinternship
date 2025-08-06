-- database craetion
create database restaurant;
use restaurant;

-- table creation(menu)
CREATE TABLE Menu (
  ItemID INT PRIMARY KEY,
  ItemName VARCHAR(100),
  Price DECIMAL(10,2),
  Category VARCHAR(50),
  StockQuantity INT
);
-- customers table
CREATE TABLE Customers (
  CustomerID INT PRIMARY KEY,
  Name VARCHAR(100),
  PhoneNumber VARCHAR(15),
  Email VARCHAR(100)
);
-- orders table
CREATE TABLE Orders (
  OrderID INT PRIMARY KEY,
  CustomerID INT,
  OrderDate DATE,
  TotalAmount DECIMAL(10,2),
  Status ENUM('Pending', 'Delivered', 'Cancelled') DEFAULT 'Pending',
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
-- order details table
CREATE TABLE OrderDetails (
  OrderID INT,
  ItemID INT,
  Quantity INT,
  Subtotal DECIMAL(10,2),
  PRIMARY KEY (OrderID, ItemID),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY (ItemID) REFERENCES Menu(ItemID)
);

-- insert records(Menu)
INSERT INTO Menu (ItemID, ItemName, Price, Category, StockQuantity) VALUES
(101, 'Margherita Pizza', 300, 'Pizza', 10),
(102, 'Cheeseburger', 250, 'Burger', 15),
(103, 'Pasta Alfredo', 400, 'Pasta', 8);

-- customers records
INSERT INTO Customers (CustomerID, Name, PhoneNumber, Email) VALUES
(1, 'Rahul Sharma', '9876543210', 'rahul@gmail.com'),
(2, 'Pooja Nair', '9123456789', 'pooja@gmail.com');

-- order records
INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount, Status) VALUES
(5001, 1, '2025-03-25', 550, 'Delivered'),
(5002, 2, '2025-03-26', 400, 'Pending');

-- order details record
INSERT INTO OrderDetails (OrderID, ItemID, Quantity, Subtotal) VALUES
(5001, 101, 1, 300),
(5001, 102, 1, 250),
(5002, 103, 1, 400);

-- stored procedure and trigger
DELIMITER //
CREATE PROCEDURE PlaceOrder(
  IN p_OrderID INT,
  IN p_CustomerID INT,
  IN p_ItemID INT,
  IN p_Quantity INT
)
BEGIN
  DECLARE item_price DECIMAL(10,2);
  DECLARE stock INT;

  SELECT Price, StockQuantity INTO item_price, stock
  FROM Menu WHERE ItemID = p_ItemID;

  IF stock >= p_Quantity THEN
    INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount, Status)
    VALUES (p_OrderID, p_CustomerID, CURDATE(), item_price * p_Quantity, 'Pending');

    INSERT INTO OrderDetails (OrderID, ItemID, Quantity, Subtotal)
    VALUES (p_OrderID, p_ItemID, p_Quantity, item_price * p_Quantity);

    UPDATE Menu SET StockQuantity = StockQuantity - p_Quantity
    WHERE ItemID = p_ItemID;
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
  END IF;
END;
//
DELIMITER ;

-- Select data

SELECT * FROM Menu;
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;

SELECT OrderID, SUM(Subtotal) AS TotalSale
FROM OrderDetails
GROUP BY OrderID;

SELECT ItemName, StockQuantity
FROM Menu
WHERE StockQuantity < 5;