pragma solidity ^0.6.0;

contract AccountsDemo {
    address public whoDeposited;
    uint public depositAmount;
    uint public accountBalance;

    function deposit() public payable {
        whoDeposited = msg.sender;
        depositAmount = msg.value;
        accountBalance = address(this).balance;
    }
}