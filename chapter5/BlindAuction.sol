pragma solidity ^0.6.0;

contract BlindAuction {

    struct Bid {
        // 입찰 정보
        bytes32 blindedBid; // 입찰자
        uint deposit; // 예치금
    }

    enum Phase {Init, Bidding, Reveal, Done} // 경매 상태. 수혜자에 의해 설정
    Phase public state = Phase.Init;

    address payable beneficiary; // 컨트랙트 배포자 = 수혜자 (owner)
    mapping(address=>Bid) bids; // 주소당 입찰 1번 위한 매핑

    address public highestBidder; // 최고 입찰자
    uint public highestBid = 0;

    mapping(address=>uint) depositReturns; // 예치금 반환

    // 경매 단계 진행을 위한 modifier
    modifier validPhase(Phase reqPhase) {
        require(state == reqPhase);
        _;
    }

    // 수혜자 확인을 위한 modifier
    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary);
        _;
    } 

    // 컨트랙트 배포자가 수혜자 (beneficiary), 배포와 동시에 입찰 시작
    constructor() public {
        beneficiary = msg.sender;
        state = Phase.Bidding;
    }

    // 상태 변환 (수혜자만이 수행 가능)
    function changeState(Phase x) public onlyBeneficiary {
        if(x < state) revert();
        state = x;
    }

    // 입찰과 입찰자 정보 기록
    function bid(bytes32 blindBid) public payable validPhase(Phase.Bidding) {
        bids[msg.sender] = Bid({
            blindedBid : blindBid,
            deposit : msg.value
        });
    }

    // 최종 입찰가 공개, secret으로 해시값 브루트포스 방지 
    function reveal(uint value, bytes32 secret) public validPhase(Phase.Reveal) {
        uint refund = 0;
        Bid storage bidToCheck = bids[msg.sender];
        if(bidToCheck.blindedBid == keccak256(abi.encodePacked(value, secret))) {
            refund += bidToCheck.deposit;
            if(bidToCheck.deposit >= value){
                // 최고 입찰자 바뀌면 해당 입찰자에게 차액 refund 전송, 
                // value 값을 deposit보다 높게 잡을 수 있으므로 placeBid로 확인 및 refund += deposit 먼저
                if(placeBid(msg.sender, value)){
                    refund -= value;
                }
            }
        }

        // 차액 sender에게 지불
        msg.sender.transfer(refund);
    }

    // 최고입찰자 변경 및 유지 (internal)
    function placeBid(address bidder, uint value) internal returns (bool success) {
        // 최고 입찰자 유지
        if(value <= highestBid) {
            return false;
        }

        // 최고 입찰자 변경 => 이전 입찰자에게 환불
        if(highestBidder != address(0)) {
            depositReturns[highestBidder] += highestBid;
        }

        // 최고 입찰자 변경
        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    // 입찰 실패자 출금
    function withdraw() public {
        uint amount = depositReturns[msg.sender];
        require (amount > 0);
        depositReturns[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    // 경매 종료 및 수혜자에게 최고 입찰액 전송
    function auctionEnd() public validPhase(Phase.Done) {
        beneficiary.transfer(highestBid);
    }
}