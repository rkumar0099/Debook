// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IPay.sol";
import "./interfaces/IBook.sol";
import "./libraries/SafeMath.sol";

contract Pay is IPay {
    /*
    use safemath for arithmetic operations on uint
    */
    using SafeMath for uint;
    /*
    Pool record to keep all the information regarding book's pool
    */
    struct Pool {
        address owner;
        uint numParticipants;
        uint pricePerContribution;
        uint totalContribution;
        uint bookPrice;
        uint phase;
        bool created;
    }
    /*
    Mapping to keep track of all the pools on the platform
    */
    mapping(bytes32 => Pool) public pools;
    /*
    Checks whether an address was a contributor for a book id and a pool phase
    */
    mapping(bytes32 => mapping(uint => mapping(address => bool))) contributors;
    /*
    Contributors who will be able to redeem for the previous phase of the pool in which they contributed
    */
    mapping(bytes32 => mapping(uint => mapping(address => bool))) public redeemed;
    /*
    Indicate the author withdrawals' status for every phase of the pool
    */
    mapping(bytes32 => mapping(uint => mapping(address => bool))) public authorWithdrawals;
    address public owner;

    constructor(address _owner) {
        /*
        This contract is deployed by the Router contract. Some functional calls are only
        authorized through the router contract
        */
        owner = _owner;
    }
    
    function createPool(bytes32 _id, uint _price, address _author) external {
        require(msg.sender == owner, 'Interact with router');
        require(!pools[_id].created, 'The pool is already created');
        Pool storage pool = pools[_id];
        // owner of this pool is the author
        pool.owner = _author;
        // price of the book which is set by author
        pool.bookPrice = _price;
        // every book price is divided into quarters
        pool.pricePerContribution = pool.bookPrice.div(4);
        // states pool for this book id has been created
        pool.created = true;
        // increment phase every time a book price is met by total contribution
        pool.phase = 1;
    }

    function deletePool(bytes32 _id, address _author) external {
        require(msg.sender == owner, 'Interact with owner');
        require(pools[_id].created, 'Pool does not exists');
        require(pools[_id].owner == _author, 'You are not author of this book');
        delete pools[_id];
    }

    function getRequiredAmt(bytes32 _id) internal view returns (uint amt) {
        require(pools[_id].created, 'Pool does not exists');
        Pool storage pool = pools[_id];
        uint _remAmt = pool.bookPrice.sub(pool.totalContribution);
        if (_remAmt < pool.pricePerContribution) {
            amt = _remAmt;
        } else {
            amt = pool.pricePerContribution;
        }
    }

    function addContribution(bytes32 _id, address _contributor, uint _amt) external {
        require(msg.sender == owner, 'Interact with router');
        require(pools[_id].created, 'Pool is not created');
        Pool storage pool = pools[_id];
        uint _phase = pool.phase;
        require(contributors[_id][_phase][_contributor] == false, 'You are already a contributor');
        uint _reqAmt = getRequiredAmt(_id);
        require(_amt >= _reqAmt, 'Insufficient contribution');
        contributors[_id][_phase][_contributor] = true;
        // user may send more contribution if he likes, sc only counts quarter
        pool.totalContribution += pool.pricePerContribution;
        if (pool.totalContribution == pool.bookPrice) {
            pool.totalContribution = 0;
            // increment the phase, all contributors of previous phase will be able to redeem
            // the book and author will be able to withdraw 95% of that phase earnings
            pool.phase += 1;
        }
        // increment buyers of that book
        pool.numParticipants += 1;
    }

    /*
    Return the amt to router, and let router handle transfers
    */
    function withdrawContribution(bytes32 _id, address _contributor) external returns (uint amt) {
        require(msg.sender == owner, 'Interact with router');
        require(pools[_id].created, 'Pool does not exists');
        // contributors can only withdraw if the phase is not yet completed
        uint _currentPhase = pools[_id].phase;
        require(contributors[_id][_currentPhase][_contributor], 'You are not a contributor');
        Pool storage pool = pools[_id];
        pool.totalContribution -= pool.pricePerContribution;
        pool.numParticipants -= 1;
        contributors[_id][_currentPhase][_contributor] = false;
        amt = pool.pricePerContribution;
    }

    // allow contributors to redeem the book
    function redeemBook(bytes32 _id, uint _phase, address _contributor) external returns (bool status) {
        require(msg.sender == owner, 'Interact with router');
        require(pools[_id].created, 'Pool is not created');
        uint _currentPhase = pools[_id].phase;
        require(_phase < _currentPhase, 'Redeem phase must be less than the current phase');
        require(contributors[_id][_phase][_contributor] == true, 'You have not contributed to that phase');
        require(redeemed[_id][_phase][_contributor] == false, 'You have already redeemed');
        // user can successfully withdraw the book
        redeemed[_id][_phase][_contributor] = true;
        status = true;
    }

    function currentPhase(bytes32 _id) external view returns (uint) {
        require(pools[_id].created, 'The pool does not exists');
        return pools[_id].phase;
    }

    function getAuthorWithdrawn(bytes32 _id, uint _phase, address _author) external view returns (bool) {
        return authorWithdrawals[_id][_phase][_author];
    }

    function setAuthorWithdrawn(bytes32 _id, uint _phase, address _author) external {
        require(msg.sender == owner, 'Interact with router');
        authorWithdrawals[_id][_phase][_author] = true;
    }

    function getAuthorFee(bytes32 _id) external view returns (uint) {
        require(pools[_id].created, 'The pool does not exists');
        uint _price = pools[_id].bookPrice;
        // 95% of the earnings of the phase goes to an author while 5% goes to the platform as commission
        return (_price.mul(95)).div(100);
    }
}