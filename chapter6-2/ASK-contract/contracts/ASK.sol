pragma solidity >=0.4.22 <0.9.0;

contract Airlines {
    address chairperson;

    // 요청 파라미터 위한 스트럭트
    struct reqStruct {
        uint reqID;
        uint fID;
        uint numSeats;
        uint passengerID;
        address toAirline;
    }

    // 응답 파라미터 위한 스트럭트
    struct respStruct {
        uint reqID;
        bool status;
        address fromAirline;
    }

    // 온체인 데이터
    mapping(address => uint) public escrow;
    mapping(address => uint) membership;
    mapping(address => reqStruct) reqs;
    mapping(address => respStruct) reps;
    mapping(address => uint) settledReqID;

    // 수정자
    modifier onlyChairPerson {
        require(msg.sender == chairperson);
        _;
    }

    modifier onlyMember {
        require(membership[msg.sender] == 1);
        _;
    }

    // 생성자
    constructor() public payable {
        chairperson = msg.sender;
        membership[msg.sender] = 1;
        escrow[msg.sender] = msg.value;
    }

    function register() public payable {
        address AirlineA = msg.sender;
        membership[AirlineA] = 1;
        escrow[AirlineA] = msg.value;
    }

    function unregister(address payable AirlineZ) onlyChairPerson public {
        membership[AirlineZ] = 0;
        AirlineZ.transfer(escrow[AirlineZ]); // AirlineZ에게 환불
        escrow[AirlineZ] = 0;
    }

    function ASKrequest (uint reqID, uint flightID, uint numSeats, uint custID, address toAirline) onlyMember public {
        require(membership[toAirline] == 1);

        reqs[msg.sender] = reqStruct(reqID, flightID, numSeats, custID, toAirline);
    }

    function ASKresponse(uint reqID, bool success, address fromAirline) onlyMember public {
        require(membership[fromAirline] == 1);

        reps[msg.sender] = respStruct(reqID, success, fromAirline);
    }

    function settlePayment(uint reqID, address payable toAirline, uint numSeats) onlyMember payable public {
        address fromAirline = msg.sender;
        escrow[toAirline] = escrow[toAirline] + numSeats * 1000000000000000000;
        escrow[fromAirline] = escrow[fromAirline] - numSeats * 1000000000000000000;
        settledReqID[fromAirline] = reqID;
    }

    function replenishEscrow() payable public {
        escrow[msg.sender] = escrow[msg.sender] + msg.value;
    }
}