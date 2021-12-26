pragma solidity ^0.6.0;

contract Airlines {
    address chairperson;
    struct details {
        uint escrow;
        uint status;
        uint hashofDetails;
    }

    mapping (address => details) public balanceDetails;
    mapping (address => uint) membership;

    modifier onlyChairperson{
        require(msg.sender == chairperson);
        _;
    }

    modifier onlyMemeber{
        require(membership[msg.sender] == 1);
        _;
    }

    constructor() public payable {
        chairperson = msg.sender;
        membership[msg.sender] = 1;
        balanceDetails[msg.sender].escrow = msg.value;
    }

    function register() public payable {
        address AirlineA = msg.sender;
        membership[AirlineA] = 1;
        balanceDetails[AirlineA].escrow = msg.value;
    }

    function unregister (address payable AirlineZ) onlyChairperson public {
        membership[AirlineZ] = 0;
        AirlineZ.transfer(balanceDetails[AirlineZ].escrow);
        balanceDetails[AirlineZ].escrow = 0;
    }

    function request(address toAirline, uint hashofDetails) onlyMemeber public {
        if(membership[toAirline] != 1){
            revert();
        }

        balanceDetails[msg.sender].status = 0;
        balanceDetails[msg.sender].hashofDetails = hashofDetails;
    }

    function response(address fromAirline, uint hashofDetails, uint done) onlyMemeber public {
        if(membership[fromAirline] != 1){
            revert();
        }

        balanceDetails[msg.sender].status = done;
        balanceDetails[fromAirline].hashofDetails = hashofDetails;
    }

    function settlePayment(address payable toAirline) onlyMemeber payable public {
        address fromAirline = msg.sender;
        uint amt = msg.value;

        balanceDetails[toAirline].escrow = balanceDetails[toAirline].escrow + amt;
        balanceDetails[fromAirline].escrow = balanceDetails[fromAirline].escrow - amt;

        toAirline.transfer(amt);
    }
}