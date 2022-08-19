// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IPay {
    function createPool(bytes32 _id, uint _price, address _author) external;
    function deletePool(bytes32 _id, address _author) external;
    function addContribution(bytes32 _id, address _contributor, uint _amt) external;
    function withdrawContribution(bytes32 _id, address _contributor) external returns (uint amt);
    function redeemBook(bytes32 _id, uint _phase, address _contributor) external returns (bool status);
    function currentPhase(bytes32 _id) external view returns (uint);
    function getAuthorWithdrawn(bytes32 _id, uint _phase, address _author) external view returns (bool);
    function setAuthorWithdrawn(bytes32 _id, uint _phase, address _author) external;
    function getAuthorFee(bytes32 _id) external view returns (uint);
}