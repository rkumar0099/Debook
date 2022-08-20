// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol"; 
import "./interfaces/IBook.sol";

contract Book is IBook {
    /* array to store the ids of all the books uploaded on the platform
    */
    bytes32[] public books;
    /*
    Every book id stores an author of that book
    */    
    mapping (bytes32 => address) author;
    /*
    Check the books that are present.
    */
    mapping (bytes32 => bool) present;
    /*
    MAX number of book an author can upload
    */
    uint MAX_BOOKS;
    /*
    Number of books uploaded by an author
    */
    mapping (address => uint) numBooks;
    /*
    Owner of this smart contract
    */
    address public owner;

    constructor(address _owner) {
        // Each author can upload at most 10 books.
        console.log('The owner of the Book smart contract is ', _owner);
        MAX_BOOKS = 10;
        owner = _owner;
    }

    /*
    A function to add book id and update the state of smart contract (sc)
    */
    function addBook(bytes32 _id, address _author) external {
        require(msg.sender == owner, 'Interact with router');
        require(present[_id] == false, 'The book is already added');
        require(numBooks[_author] < MAX_BOOKS, 'You have already uploaded ten books');
        books.push(_id);
        numBooks[_author] += 1;
        author[_id] = _author;
        present[_id] = true;
        console.log('The book status = ', present[_id]);
    }

    /*
    A function to get the ids of all books uploaded by the given author. Max ids are 10
    */
    function getAuthorBooks(address _author) external view returns (bytes32[10] memory ids) {
        require(_author != address(0), 'FORBIDDEN ADDRESS');
        uint index = 0;
        for(uint i = 0; i < books.length; i++) {
            bytes32 _id = books[i];
            if (author[_id] == _author) {
                // push this id to ids
                ids[index] = _id;
                index += 1;
                if (index == 10) {
                    break;
                }
            }
        }
    }

    /*
    A function to delete a book
    */
    function deleteBook(bytes32 _id) external {
        require(msg.sender == owner, 'Interact with router');
        require(present[_id] == true, 'Book is not present in the platform');
        for (uint i = 0; i < books.length; i++) {
            if (books[i] == _id) {
                delete books[i];
            }
        }
        present[_id] = false;
        address _author = author[_id];
        author[_id] = address(0);
        numBooks[_author] -= 1;
    }

    /*
    returns whether book is uploaded to the platform or not
    */
    function exists(bytes32 _id) external view returns (bool) {
        return present[_id];
    }
    /*
    get num of books uploaded by author
    */
    function numAuthorBooks(address _author) external view returns (uint num) {
        return numBooks[_author];
    }

    function getAuthor(bytes32 _id) external view returns (address bookAuthor) {
        require(present[_id], 'The book is not uploaded to the platform');
        return author[_id];
    }
}