-- Create Database
CREATE DATABASE IF NOT EXISTS library_management;
USE library_management;

-- Create Publisher table
CREATE TABLE Publisher (
    PublisherID INT PRIMARY KEY AUTO_INCREMENT,
    PublisherName VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    Phone VARCHAR(20),
    Email VARCHAR(100)
);

-- Create Author table
CREATE TABLE Author (
    AuthorID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    Biography TEXT
);

-- Create Book table with ISBN
CREATE TABLE Book (
    ISBN VARCHAR(13) PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    PublisherID INT,
    PublicationYear INT,
    Edition VARCHAR(20),
    Available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID)
);

-- Create Book_Author table (for many-to-many relationship between Book and Author)
CREATE TABLE Book_Author (
    ISBN VARCHAR(13),
    AuthorID INT,
    PRIMARY KEY (ISBN, AuthorID),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN),
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
);

-- Create LibraryStaff table
CREATE TABLE LibraryStaff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Position VARCHAR(50),
    HireDate DATE
);

-- Create Member table
CREATE TABLE Member (
    MemberID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(255),
    JoinDate DATE,
    MembershipStatus VARCHAR(20) DEFAULT 'Active'
);

-- Create Borrow_List table
CREATE TABLE Borrow_List (
    BorrowID INT PRIMARY KEY AUTO_INCREMENT,
    ISBN VARCHAR(13),
    MemberID INT,
    StaffID INT,
    BorrowDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (StaffID) REFERENCES LibraryStaff(StaffID)
);

-- Create Fine_Late_Return table
CREATE TABLE Fine_Late_Return (
    FineID INT PRIMARY KEY AUTO_INCREMENT,
    BorrowID INT,
    FineAmount DECIMAL(10,2) NOT NULL,
    FineDate DATE NOT NULL,
    PaidStatus BOOLEAN DEFAULT FALSE,
    PaymentDate DATE,
    FOREIGN KEY (BorrowID) REFERENCES Borrow_List(BorrowID)
);

-- Add indexes for better performance
CREATE INDEX idx_book_title ON Book(Title);
CREATE INDEX idx_member_name ON Member(LastName, FirstName);
CREATE INDEX idx_borrow_dates ON Borrow_List(BorrowDate, DueDate, ReturnDate);

-- Query 1: Find members named James with fines greater than 100 ringgit
SELECT 
    m.MemberID,
    m.FirstName,
    m.LastName,
    f.FineAmount,
    f.FineDate,
    f.PaidStatus
FROM 
    Member m
    JOIN Borrow_List bl ON m.MemberID = bl.MemberID
    JOIN Fine_Late_Return f ON bl.BorrowID = f.BorrowID
WHERE 
    (m.FirstName LIKE '%James%' OR m.LastName LIKE '%James%')
    AND f.FineAmount > 100
ORDER BY 
    f.FineAmount DESC;

-- Query 2: Sort all fines in ascending order with member and book details
SELECT 
    m.FirstName,
    m.LastName,
    b.Title,
    bl.BorrowDate,
    bl.DueDate,
    bl.ReturnDate,
    f.FineAmount,
    f.PaidStatus
FROM 
    Fine_Late_Return f
    JOIN Borrow_List bl ON f.BorrowID = bl.BorrowID
    JOIN Member m ON bl.MemberID = m.MemberID
    JOIN Book b ON bl.ISBN = b.ISBN
ORDER BY 
    f.FineAmount ASC;

-- Query 3: Find active members who borrowed 10 or more books in a month
SELECT 
    m.MemberID,
    m.FirstName,
    m.LastName,
    m.Email,
    DATE_FORMAT(bl.BorrowDate, '%Y-%m') as BorrowMonth,
    COUNT(*) as BooksPerMonth
FROM 
    Member m
    JOIN Borrow_List bl ON m.MemberID = bl.MemberID
WHERE 
    m.MembershipStatus = 'Active'
GROUP BY 
    m.MemberID, 
    DATE_FORMAT(bl.BorrowDate, '%Y-%m')
HAVING 
    COUNT(*) >= 10
ORDER BY 
    BorrowMonth DESC, 
    BooksPerMonth DESC; 