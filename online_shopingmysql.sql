-- table creation
CREATE TABLE Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100),
    Price DECIMAL(10,2),
    Stock_Quantity INT
);

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Contact VARCHAR(15)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Subtotal DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
-- Insert Sample Data
INSERT INTO Product (ProductName, Price, Stock_Quantity)
VALUES ('Laptop', 50000, 10), ('Smartphone', 25000, 5), ('Headphones', 2000, 15);

INSERT INTO Customer (Name, Email, Contact)
VALUES ('John Doe', 'john@example.com', '9876543210'), ('Jane Smith', 'jane@example.com', '9123456789');

-- Stored Procedure for Placing an Order
DELIMITER //

CREATE PROCEDURE PlaceOrder (
    IN cust_id INT,
    IN prod_id1 INT, IN qty1 INT,
    IN prod_id2 INT, IN qty2 INT
)
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE stock1 INT;
    DECLARE stock2 INT;

    SELECT Stock_Quantity INTO stock1 FROM Product WHERE ProductID = prod_id1;
    SELECT Stock_Quantity INTO stock2 FROM Product WHERE ProductID = prod_id2;

    IF stock1 < qty1 OR stock2 < qty2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock!';
    ELSE
        SELECT (Price * qty1) + (Price * qty2) INTO total
        FROM Product WHERE ProductID IN (prod_id1, prod_id2);

        INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
        VALUES (cust_id, CURDATE(), total);

        SET @order_id = LAST_INSERT_ID();

        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Subtotal)
        SELECT @order_id, prod_id1, qty1, Price * qty1 FROM Product WHERE ProductID = prod_id1;

        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Subtotal)
        SELECT @order_id, prod_id2, qty2, Price * qty2 FROM Product WHERE ProductID = prod_id2;

        UPDATE Product SET Stock_Quantity = Stock_Quantity - qty1 WHERE ProductID = prod_id1;
        UPDATE Product SET Stock_Quantity = Stock_Quantity - qty2 WHERE ProductID = prod_id2;
    END IF;
END //

-- Trigger to Prevent Negative Stock

DELIMITER //

CREATE TRIGGER PreventNegativeStock
BEFORE UPDATE ON Product
FOR EACH ROW
BEGIN
    IF NEW.Stock_Quantity < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Stock cannot be negative!';
    END IF;
END //

DELIMITER ;

-- Sales summary
SELECT 
    P.ProductName,
    SUM(OD.Quantity) AS TotalSold,
    SUM(OD.Subtotal) AS TotalRevenue
FROM 
    OrderDetails OD
JOIN 
    Product P ON OD.ProductID = P.ProductID
GROUP BY 
    P.ProductName;

-- Current Stock Status
SELECT ProductName, Stock_Quantity
FROM Product
ORDER BY Stock_Quantity ASC;