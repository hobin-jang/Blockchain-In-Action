pragma solidity >=0.4.22 <0.9.0;

contract BlindAuction {

    struct Bid {
        // 입찰 정보
        bytes32 blindedBid; // 입찰자
        uint deposit; // 예치금
    }

    address payable beneficiary; // 컨트랙트 배포자 = 수혜자 (owner)
    address public highestBidder; // 최고 입찰자
    uint public highestBid = 0;

    mapping(address => Bid) public bids; // 입찰 정보
    mapping(address => uint) pendingReturns; // 환불 안 된 것들 경매 끝나고 환불

    enum Phase {Init, Bidding, Reveal, Done} // 경매 상태. 수혜자에 의해 설정
    Phase public currentPhase = Phase.Init;

    // 이벤트 정의
    event AuctionEnded(address winner, uint highestBid);
    event BiddingStarted();
    event RevealStarted();
    event AuctionInit();

    // 경매 단계 진행을 위한 modifier
    modifier validPhase(Phase reqPhase) {
        require(currentPhase == reqPhase, "phase error");
        _;
    }

    // 수혜자 확인을 위한 modifier
    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "only Beneficiary");
        _;
    }

    // 컨트랙트 배포자가 수혜자 (beneficiary), 배포와 동시에 입찰 시작
    constructor() public {
        beneficiary = msg.sender;
    }

    function advancePhsae() public onlyBeneficiary {
        // Done이면 Init으로 초기화
        if (currentPhase == Phase.Done){
            currentPhase = Phase.Init;
        }
        // 나머지는 단계 증가
        else{
            uint nextPhase = uint(currentPhase) + 1;
            currentPhase = Phase(nextPhase);
        }

        // event 실행
        if(currentPhase == Phase.Reveal) emit RevealStarted();
        if(currentPhase == Phase.Bidding) emit BiddingStarted();
        if(currentPhase == Phase.Init) emit AuctionInit();
    }

    // 입찰
    function bid(bytes32 blindBid) public payable validPhase(Phase.Bidding) {
        require(msg.sender != beneficiary, "beneficiary Bid");
        bids[msg.sender] = Bid({blindedBid: blindBid, deposit: msg.value});
    }

    // 공개
    function reveal(uint value, bytes32 secret) public validPhase(Phase.Reveal) {
        require(msg.sender != beneficiary, "beneficiary Reveal");
        uint refund = 0;
        Bid storage bidToCheck = bids[msg.sender];

        // 이전 입찰자에게 환불
        if(bidToCheck.blindedBid == keccak256(abi.encodePacked(value, secret))){
            refund += bidToCheck.deposit;
            if(bidToCheck.deposit >= value * 1000000000000000000){
                if(placeBid(msg.sender, value * 1000000000000000000)){
                    refund -= value * 1000000000000000000;
                }
            }
        }
        msg.sender.transfer(refund);
    }

    // 더 높은 금액 입찰
    // internal 은 컨트랙트 내부에서만 호출가능
    function placeBid(address bidder, uint value) internal returns (bool success) {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            // 이전 입찰자 환불 정보
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    // 잔금 인출
    function withdraw() public {
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
            msg.sender.transfer(amount);
        }
    }

    // 경매 끝
    function auctionEnd() public validPhase(Phase.Done) {
        if(address(this).balance >= highestBid){
            beneficiary.transfer(highestBid);
        }
        emit AuctionEnded(highestBidder, highestBid);
    }

    // 경매 종료
    function closeAuction() public onlyBeneficiary {
        selfdestruct(beneficiary);
    }

}