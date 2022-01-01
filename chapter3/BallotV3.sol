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

    enum Phase {Init, Regs, Vote, Done}
    // 내부적으로 0,1,2,3 으로 적용

    Phase public state = Phase.Init;

    modifier validPhase(Phase reqPhase) {
        require(state == reqPhase);
        _;
    }

    constructor (uint numProposals) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 2;

        for(uint prop = 0; prop < numProposals; prop++){
            proposals.push(Proposal(0));
        }

        state = Phase.Regs;
    }

    function changeState(Phase x) public {
        if(msg.sender != chairperson) revert();
        if(x < state) revert();
        state = x;
    }

    function register(address voter) public validPhase(Phase.Regs) {
        if(msg.sender != chairperson || voters[voter].voted == true) revert();
        voters[voter].weight = 1;
        voters[voter].voted = false;
    }

    function vote(uint toProposal) public validPhase(Phase.Vote) {
        Voter memory sender = voters[msg.sender]; // struct 는 기본적으로 storage type, 굳이 저장 안 해도 되는 거면 memory로 변환
        if(sender.voted == true || toProposal >= proposals.length) revert();
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
    }
}