pragma solidity ^0.8.0;
import "./Ownable.sol";

contract Library is Ownable {
    event NewBook(string name, uint8 copies);
    event BookBorrowed(address borrower, uint bookId);
    
    struct Book {
        string name;
        uint8 copies;
        address[] borrowers;
    }
    
    struct BorrowedBook {
        bool currentlyBorrowed;
    }
    
    Book[] private books;
    
    uint borrowFee = 1000000000000000 wei;

    mapping (address => uint) personBorrowCount;
    mapping (address => BorrowedBook[]) personBorrowedBooks;

    
    function addBook(Book calldata book) external onlyOwner {
        bytes memory tempEmptyStringTest = bytes(book.name);
        require(tempEmptyStringTest.length > 0, "Book name can not be empty.");
        
        address[] memory emptyBorrowers;
        books.push(Book(book.name, book.copies, emptyBorrowers));
        
        emit NewBook(book.name, book.copies);
    }
    
    function addCopies(uint bookId, uint8 copies) external onlyOwner {
        books[bookId].copies += copies;
    }
    
    function getBooks() external view returns (Book[] memory) {
        return books;
    }
    
    function borrowBook(uint bookId) external payable {
        require(books[bookId].copies > 0, "Out of copies.");
        require(!personBorrowedBooks[msg.sender][bookId].currentlyBorrowed, "Book already borrowed");
        require(msg.value == borrowFee);
        
        personBorrowCount[msg.sender]++;
        personBorrowedBooks[msg.sender][bookId] = BorrowedBook(true);

        books[bookId].borrowers.push(msg.sender);
        books[bookId].copies--;
        
        emit BookBorrowed(msg.sender, bookId);
    }
    
    receive() external payable {}
    
    function returnBook(uint bookId) external {
        require(personBorrowedBooks[msg.sender][bookId].currentlyBorrowed, "You haven't borrowed that book.");
        
        personBorrowCount[msg.sender]--;
        personBorrowedBooks[msg.sender][bookId].currentlyBorrowed = false;

        books[bookId].copies++;
    }
}
