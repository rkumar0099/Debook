// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IRouter {
    function addBook(string memory _hash, uint _price, bool _createPool) external;
    function deleteBook(string memory _hash) external;
    function createPool(string memory _hash, uint _price) external;
    function deletePool(string memory _hash) external;
    function addContribution(string memory _hash) external payable;
    function withdrawContribution(string memory _hash) external;
    function withdrawAuthorEarnings(string memory _hash, uint _phase) external;
    function redeemBook(string memory _hash, uint _phase) external returns (bool status);
    function fund() external payable;
}