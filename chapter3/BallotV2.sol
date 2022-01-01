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

    constructor (uint numProposals) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 2;

        for(uint prop = 0; prop < numProposals; prop++){
            proposals.push(Proposal(0));
        }
    }

    function changeState(Phase x) public {
        if (msg.sender != chairperson) revert(); // 의장만 상태 변화 가능, revert : 되돌리는 것
        if (x < state) revert(); // state는 0,1,2,3 (Phase 순서) 로 진행, 그렇지 않으면 되돌림
        state = x;
    }

}