
pragma solidity >=0.7.0 <0.9.0;


contract VotingSystem {

   
    struct Vote {
        address voterAddress;
        bool choice;
    }

    struct Voter {
        string voterName;
        bool isVoted;
    }


    uint private countResultYes = 0;
    uint private countResultNo = 0;
    bool public finalResult= false;
    uint public totalVoter = 0;
    uint public totalVote = 0;


    address public ballotOfficialAddress;
    string public ballotOfficialName;
    string public proposal;

    mapping(uint => Vote) private votes;
    mapping(address => Voter) public voterRegister;

    // states of ballot
    enum State {
        Created,
        Voting,
        Ended
    }

    State public state;

    // MODIFIERS
    modifier onlyOfficial(){
        require(msg.sender == ballotOfficialAddress, "This address is not equal to the ballotOfficalAddress");
        _;
    }

    modifier inState(State _state){
        require(state == _state, "The state not matched");
        _;
    }

    // EVENTS
    event AddVoter(address indexed ballotOfficalAddress, address indexed voterAddress, string voterName);
    event DoVote();

    // FUNCTIONS
    constructor(string memory _ballotOfficialName, string memory _proposal){
        ballotOfficialAddress = msg.sender;
        ballotOfficialName = _ballotOfficialName;
        proposal = _proposal;
        state = State.Created;
    }


    // The creator of the ballot adds voter addresses one by one
    function addVoter(address _voterAddress, string memory _voterName) public inState(State.Created) onlyOfficial {
        voterRegister[_voterAddress] = Voter({
            voterName: _voterName,
            isVoted: false
        });
        totalVoter++;

        emit AddVoter(msg.sender, _voterAddress, _voterName);
    }


    // The voter chooses, true or false
    function doVote(bool _choice) public inState(State.Voting) returns(bool isVoted){
        // first check if the voter is in the voter registry && voter hasn' t voted yet
        if(bytes(voterRegister[msg.sender].voterName).length != 0 && !voterRegister[msg.sender].isVoted){
            voterRegister[msg.sender].isVoted = true;
            votes[totalVote] = Vote({
                voterAddress: msg.sender,
                choice: _choice
            });
            
            if(_choice){
                countResultYes++;
            }else {
                countResultNo++;
            }
            
            totalVote++;
            emit DoVote();

            return true;
        }
        return false;
    }


    function startVote() public inState(State.Created) onlyOfficial{
        require(state != State.Voting, "The voting has already started");
        state = State.Voting;
    }


    function endVote() public inState(State.Voting) onlyOfficial{
        state = State.Ended;
        finalResult = countResultYes > countResultNo;
    }


}

/*

With the voting system, yes-no votes can be made on the blockchain. Voters are added to the list by the Ethereum address deploying the smart contract. A voter can only vote once. There are 3 stages in a vote : Created, Voting, Ended. These stages are stored with an enum veriable. After a vote is over, it is not possible to vote again on the same address contract. The contract starts with an address deploying it in the constructor, and ends when the offical address ends voting with the endVote() function. There are 4 main functions on the smart contract :

1. addVoter(address _voterAddress, string memory _voterName)

2. doVote(bool _choice)

3. startVote()

4. endVote()

*/