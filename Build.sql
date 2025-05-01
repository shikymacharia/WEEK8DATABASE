
-- Create the database if it doesn't exist
CREATE DATABASE  library_management_system;

-- Select the database to use
USE library_management_system;

-- -------------------------------------------------------------
-- Table Creation
-- -------------------------------------------------------------

-- Table: Books
-- Stores information about individual books
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    ISBN VARCHAR(20) UNIQUE NOT NULL,
    PublicationYear INT,
    Author VARCHAR(255) NOT NULL,
    Genre VARCHAR(100),
    TotalCopies INT NOT NULL,
    AvailableCopies INT NOT NULL,
    CHECK (TotalCopies >= 0),
    CHECK (AvailableCopies >= 0 AND AvailableCopies <= TotalCopies)
);

-- Table: Members
-- Stores information about library members
CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(255),
    MembershipDate DATE NOT NULL
);

-- Table: Loans
-- Stores information about book loans
CREATE TABLE Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    LoanDate DATE NOT NULL,
    ReturnDate DATE,
    Status ENUM('loaned', 'returned', 'overdue') NOT NULL DEFAULT 'loaned',
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    CHECK (LoanDate <= ReturnDate OR ReturnDate IS NULL)
);

-- Table: Reservations
-- Stores information about book reservations
CREATE TABLE Reservations (
    ReservationID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    ReservationDate DATE NOT NULL,
    Status ENUM('pending', 'active', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

-- Table: Authors
-- Stores the authors.
CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    AuthorName VARCHAR(255) NOT NULL,
    Biography TEXT
);

-- Table: BookAuthors (Many-to-Many relationship between Books and Authors)
CREATE TABLE BookAuthors (
    BookID INT,
    AuthorID INT,
    PRIMARY KEY (BookID, AuthorID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

-- -------------------------------------------------------------
-- Insert Sample Data
-- -------------------------------------------------------------

-- Insert sample data into the Books table
INSERT INTO Books (Title, ISBN, PublicationYear, Author, Genre, TotalCopies, AvailableCopies) VALUES
('The Great Gatsby', '978-0743273565', 1925, 'F. Scott Fitzgerald', 'Fiction', 5, 5),
('To Kill a Mockingbird', '978-0061120084', 1960, 'Harper Lee', 'Fiction', 3, 3),
('1984', '978-0451524935', 1949, 'George Orwell', 'Science Fiction', 4, 4),
('Pride and Prejudice', '978-0141439518', 1813, 'Jane Austen', 'Romance', 2, 2),
('The Hitchhiker\'s Guide to the Galaxy', '978-0345391803', 1979, 'Douglas Adams', 'Science Fiction', 6, 6);

-- Insert sample data into the Members table
INSERT INTO Members (FirstName, LastName, Email, Phone, Address, MembershipDate) VALUES
('John', 'Doe', 'john.doe@example.com', '123-456-7890', '123 Main St', '2023-01-15'),
('Jane', 'Smith', 'jane.smith@example.com', '987-654-3210', '456 Oak Ave', '2022-12-01'),
('Emily', 'Brown', 'emily.brown@example.com', '555-123-4567', '789 Pine Ln', '2023-02-20'),
('Michael', 'Wilson', 'michael.wilson@example.com', '111-222-3333', '321 Cedar Rd', '2023-03-10'),
('Jessica', 'Garcia', 'jessica.garcia@example.com', '444-555-6666', '654 Birch Ct', '2022-11-05');

-- Insert sample data into the Loans table
INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate, Status) VALUES
(1, 1, '2023-10-26', '2023-11-10', 'returned'),
(2, 2, '2023-10-28', NULL, 'loaned'),
(3, 3, '2023-11-01', NULL, 'loaned'),
(1, 4, '2023-11-05', NULL, 'loaned'),
(4, 5, '2023-11-03', '2023-11-09', 'returned');

-- Insert sample data into the Reservations table
INSERT INTO Reservations (BookID, MemberID, ReservationDate, Status) VALUES
(1, 3, '2023-11-02', 'pending'),
(2, 1, '2023-11-05', 'pending'),
(5, 4, '2023-11-07', 'pending'),
(3, 2, '2023-11-09', 'pending'),
(4, 3, '2023-11-10', 'pending');

-- Insert sample data into the Authors table
INSERT INTO Authors (AuthorName, Biography) VALUES
('F. Scott Fitzgerald', 'An American novelist and short-story writer...'),
('Harper Lee', 'An American novelist widely known for To Kill a Mockingbird...'),
('George Orwell', 'An English novelist, essayist, journalist, and critic...'),
('Jane Austen', 'An English novelist known primarily for her six major novels...'),
('Douglas Adams', 'An English author, screenwriter, essayist, humorist... ');

-- Insert data into the BookAuthors table
INSERT INTO BookAuthors (BookID, AuthorID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- -------------------------------------------------------------
-- Basic Queries
-- -------------------------------------------------------------
-- Get all books
SELECT * FROM Books;

-- Get all members
SELECT * FROM Members;

-- Get all loans
SELECT * FROM Loans;

-- Get all reservations
SELECT * FROM Reservations;

-- Get books with available copies greater than 0
SELECT * FROM Books WHERE AvailableCopies > 0;

-- Get members who joined before 2023
SELECT * FROM Members WHERE MembershipDate < '2023-01-01';

-- Get loans that are currently loaned out
SELECT * FROM Loans WHERE Status = 'loaned';

-- Get reservations that are pending
SELECT * FROM Reservations WHERE Status = 'pending';

-- -------------------------------------------------------------
-- Join Queries
-- -------------------------------------------------------------

-- Get books and their authors
SELECT b.Title, a.AuthorName
FROM Books b
JOIN BookAuthors ba ON b.BookID = ba.BookID
JOIN Authors a ON ba.AuthorID = a.AuthorID;

-- Get the details of books currently loaned out, including member name
SELECT b.Title, m.FirstName, m.LastName, l.LoanDate
FROM Books b
JOIN Loans l ON b.BookID = l.BookID
JOIN Members m ON l.MemberID = m.MemberID
WHERE l.Status = 'loaned';

-- Get the number of loans for each book
SELECT b.Title, COUNT(l.LoanID) AS NumberOfLoans
FROM Books b
LEFT JOIN Loans l ON b.BookID = l.BookID
GROUP BY b.Title
ORDER BY NumberOfLoans DESC;

-- Get the members who have made reservations, along with the book titles
SELECT m.FirstName, m.LastName, b.Title AS ReservedBook
FROM Members m
JOIN Reservations r ON m.MemberID = r.MemberID
JOIN Books b ON r.BookID = b.BookID;

-- -------------------------------------------------------------
-- Aggregate Queries
-- -------------------------------------------------------------

-- Get the total number of books in the library
SELECT SUM(TotalCopies) AS TotalNumberOfBooks FROM Books;

-- Get the number of available books
SELECT SUM(AvailableCopies) AS TotalAvailableBooks FROM Books;

-- Get the number of members
SELECT COUNT(*) AS TotalMembers FROM Members;

-- Get the average loan duration (in days)
SELECT AVG(DATEDIFF(ReturnDate, LoanDate)) AS AverageLoanDuration
FROM Loans
WHERE Status = 'returned';

-- -------------------------------------------------------------
-- Update Queries
-- -------------------------------------------------------------

-- Update the number of available copies for a book (after a loan)
UPDATE Books
SET AvailableCopies = AvailableCopies - 1
WHERE BookID = 1;

-- Update the status of a loan when a book is returned
UPDATE Loans
SET Status = 'returned', ReturnDate = CURDATE()
WHERE LoanID = 2;

-- Update a member's address
UPDATE Members
SET Address = '789 New Oak Ave'
WHERE MemberID = 3;

-- Update book title
UPDATE Books
SET Title = 'The Great Gatsby Revised'
WHERE BookID = 1;

-- -------------------------------------------------------------
-- Delete Queries
-- -------------------------------------------------------------

-- Delete a reservation
DELETE FROM Reservations WHERE ReservationID = 2;

-- Delete a member
--  DELETE FROM Members WHERE MemberID = 5; -- This will fail if the member has loans or reservations

-- Delete a book
-- DELETE FROM Books WHERE BookID = 5;  -- This will fail if the book is involved in any loans or reservations

-- -------------------------------------------------------------
-- Stored Procedures
-- -------------------------------------------------------------

-- Procedure to get all books by genre
DELIMITER //
CREATE PROCEDURE GetBooksByGenre(IN genre_name VARCHAR(100))
BEGIN
    SELECT * FROM Books WHERE Genre = genre_name;
END //
DELIMITER ;

-- Call the procedure
CALL GetBooksByGenre('Fiction');

-- Procedure to get all books and their authors
DELIMITER //
CREATE PROCEDURE GetBooksAndAuthors()
BEGIN
    SELECT b.Title, a.AuthorName
    FROM Books b
    JOIN BookAuthors ba ON b.BookID = ba.BookID
    JOIN Authors a ON ba.AuthorID = a.AuthorID;
END //
DELIMITER ;

CALL GetBooksAndAuthors();

-- -------------------------------------------------------------
-- Views
-- -------------------------------------------------------------
-- View to show book titles and available copies
CREATE VIEW BookAvailabilityView AS
SELECT Title, AvailableCopies
FROM Books;

-- Select from the view
SELECT * FROM BookAvailabilityView;

-- View to display member names and the books they have borrowed
CREATE VIEW MemberLoansView AS
SELECT m.FirstName, m.LastName, b.Title AS BookTitle
FROM Members m
JOIN Loans l ON m.MemberID = l.MemberID
JOIN Books b ON l.BookID = b.BookID
WHERE l.Status = 'loaned';

SELECT * FROM MemberLoansView;
