pragma solidity >=0.4.2 <=0.6.0;

contract BallotV1{

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
    Phase public state1 = Phase.Init;
    Phase public state2 = Phase.Regs;
    Phase public state3 = Phase.Vote;
    Phase public state4 = Phase.Done;
}