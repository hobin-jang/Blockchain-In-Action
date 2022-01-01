pragma solidity >=0.4.2 <=0.6.0;

contract BallotV2{

    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }

    struct Proposal {
        uint voteCount;
    }

    address chairperson;
    mapping(address => Voter) voters;
    Proposal[] proposals;

    uint totalWeights;

    enum Phase {Init, Regs, Vote, Done}
    // 내부적으로 0,1,2,3 으로 적용

    Phase public state = Phase.Init;

    modifier validPhase(Phase reqPhase) {
        require(state == reqPhase); // require : false면 해당 트랜잭션 중단, 체인에 기록 X
        _;
    }

    modifier onlyChair() {
        require(msg.sender == chairperson);
        _;
    }

    // constructor : contract 실행 시 처음 실행되는 내용
    constructor (uint numProposals) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 2; // 의장은 가중치 2 중

        for(uint prop = 0; prop < numProposals; prop++){
            proposals.push(Proposal(0));
        }

        state = Phase.Regs;

        totalWeights = 2; // 의장 가중치 2
    }

    // onlyChair 수정자로 chairperson인지 확인
    function changeState(Phase x) onlyChair public {
        // if(msg.sender != chairperson) revert(); // revert 실행 시 해당 함수 중단, 트랜잭션 종료
        // if(x < state) revert();
        require (x > state); // if + revert 대신 require로 처리
        state = x;
    }

    function register(address voter) public validPhase(Phase.Regs) onlyChair {
        // if(msg.sender != chairperson || voters[voter].voted == true) revert();
        require (voters[voter].voted == false);
        voters[voter].weight = 1;
        // voters[voter].voted = false; // require로 확인했음.

        totalWeights += 1; // 의장 
    }

    function vote(uint toProposal) public validPhase(Phase.Vote) {
        Voter memory sender = voters[msg.sender]; // struct 는 기본적으로 storage type, 굳이 저장 안 해도 되는 거면 memory로 변환
        // if(sender.voted == true || toProposal >= proposals.length) revert();
        require (sender.voted == false);
        require (toProposal < proposals.length);
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
    }

    function reqWinner() public validPhase(Phase.Done) view returns (uint winningProposal) {
        uint winningVoteCount = 0;
        for(uint prop = 0; prop < proposals.length; prop++){
            if(proposals[prop].voteCount > winningVoteCount){
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
        }

        assert(winningVoteCount >= (totalWeights / 2)); // 과반수 획득 필요
    }
}