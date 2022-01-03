pragma solidity >=0.4.22 <0.9.0;

contract Ballot{

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

    modifier onlyChair() {
        require(msg.sender == chairperson);
        _;
    }

    modifier validVoter() {
        require(voters[msg.sender].weight > 0, "Not a Registered Voter");
        _;
    }

    // constructor : contract 실행 시 처음 실행되는 내용
    constructor (uint numProposals) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 2; // 의장은 가중치 2 중

        for(uint prop = 0; prop < numProposals; prop++){
            proposals.push(Proposal(0));
        }

        totalWeights = 2; // 의장 가중치 2
    }

    function register(address voter) public onlyChair {
        // if(msg.sender != chairperson || voters[voter].voted == true) revert();
        require (voters[voter].voted == false);
        voters[voter].weight = 1;
        // voters[voter].voted = false; // require로 확인했음.

        totalWeights += 1; // 의장 
    }

    function vote(uint toProposal) public validVoter {
        Voter memory sender = voters[msg.sender]; // struct 는 기본적으로 storage type, 굳이 저장 안 해도 되는 거면 memory로 변환
        // if(sender.voted == true || toProposal >= proposals.length) revert();
        require (sender.voted == false);
        require (toProposal < proposals.length);
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
    }

    function reqWinner() public view returns (uint winningProposal) {
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