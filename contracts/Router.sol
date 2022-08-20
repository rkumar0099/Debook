// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


import "hardhat/console.sol";
import "./interfaces/IPay.sol";
import "./interfaces/IBook.sol";
import "./interfaces/IRouter.sol";
import "./Book.sol";
import "./Pay.sol";

// router contract route the calls to pools and create a new pool for each newly added book
contract Router is IRouter {
    address public book;
    address public pay;
    address public token;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        book = deployBookContract(getId("10000"));
        pay = deployPayContract(getId("20000"));
        console.log('Book address', book);
        console.log('Pay address', pay);
    }

    function deployBookContract(bytes32 _salt) public payable returns (address) {
        return address(new Book{salt: _salt}(address(this)));
    }

    function deployPayContract(bytes32 _salt) public payable returns (address) {
        return address(new Pay{salt: _salt}(address(this)));
    }

    function getId(string memory _hash) internal pure returns (bytes32 id) {
        bytes memory tempEmptyStringTest = bytes(_hash);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            id := mload(add(_hash, 32))
        }
    }
    // content hash 
    // price in eth or wei
    function addBook(string memory _hash, uint _price, bool _createPool) external {
        bytes32 _id = getId(_hash);
        address _author = msg.sender;
        bool status = IBook(book).exists(_id);
        require(status == false, 'The book is already uploaded');
        uint num = IBook(book).numAuthorBooks(_author);
        require(num < 10, 'You have already uploaded 10 books!!');
        IBook(book).addBook(_id, _author);
        // allow author to specify whether he allow users to pay in contribution
        //if (_createPool) {
        // assume we always create pool for a book upload
        // make router the owner as we have already confirmed this func is called by original author
        IPay(pay).createPool(_id, _price, _author);
        
        //}
    }

    function exists(string memory _hash) external returns (bool status) {
        bytes32 _id = getId(_hash);
        return IBook(book).exists(_id);
    }

    function deleteBook(string memory _hash) external {
        bytes32 _id = getId(_hash);
        bool status = IBook(book).exists(_id);
        require(status == true, 'The book is not uploaded to the platform');
        address _author = IBook(book).getAuthor(_id);
        require(_author == msg.sender, 'Only author can delete its uploaded book');
        IBook(book).deleteBook(_id);
        IPay(pay).deletePool(_id, _author);
    }

    function createPool(string memory _hash, uint _price) external {
        // for future use case
        // allow author to create pools with different prices for the same book
    }

    function deletePool(string memory _hash) external {
        bytes32 _id = getId(_hash);
        address _author = IBook(book).getAuthor(_id);
        require(msg.sender == _author, 'You are not authorized to call this function');
        IPay(pay).deletePool(_id, _author);
    }

    function addContribution(string memory _hash) external payable {
        bytes32 _id = getId(_hash);
        bool status = IBook(book).exists(_id);
        require(status == true, 'The book is not uploaded to the system');
        IPay(pay).addContribution(_id, msg.sender, msg.value);
    }

    function withdrawContribution(string memory _hash) external {
        bytes32 _id = getId(_hash);
        bool status = IBook(book).exists(_id);
        require(status == true, 'The book is not uploaded to the system');
        uint _amt = IPay(pay).withdrawContribution(_id, msg.sender);
        payable(msg.sender).transfer(_amt);
    }

    function withdrawAuthorEarnings(string memory _hash, uint _phase) external {
        bytes32 _id = getId(_hash);
        bool status = IBook(book).exists(_id);
        require(status == true, 'The book is not uploaded to the system');
        address _author = IBook(book).getAuthor(_id);
        require(msg.sender == _author, 'You are not author of this book');
        uint _currentPhase = IPay(pay).currentPhase(_id);
        require(_currentPhase > 1, 'No completed phase yet');
        require(_phase < _currentPhase, 'Withdrawal phase must be less than current phase');
        status = IPay(pay).getAuthorWithdrawn(_id, _phase, _author);
        require(status == false, 'You have already withdrawn');
        uint _amt = IPay(pay).getAuthorFee(_id);
        payable(_author).transfer(_amt);
        IPay(pay).setAuthorWithdrawn(_id, _phase, _author);
    }

    function redeemBook(string memory _hash, uint _phase) external returns (bool status) {
        bytes32 _id = getId(_hash);
        bool _status = IBook(book).exists(_id);
        require(_status == true, 'The book is not uploaded to the platform');
        status = IPay(pay).redeemBook(_id, _phase, msg.sender);
    }

    function fund() external payable {}

}