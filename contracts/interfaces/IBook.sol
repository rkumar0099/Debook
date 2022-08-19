// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IBook {
    function addBook(bytes32, address) external;
    function exists(bytes32) external returns (bool status);
    function deleteBook(bytes32) external;
    function getAuthorBooks(address) external view returns (bytes32[10] memory);
    function getAuthor(bytes32 _id) external view returns (address bookAuthor);
    function numAuthorBooks(address) external returns (uint num);
}