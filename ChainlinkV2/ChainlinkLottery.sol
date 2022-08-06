//This is for Educational Purposes Only
pragma solidity ^0.8.8;
//Chainlink Github
import "https://github.com/smartcontractkit/chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./ChainlinkLotteryGovernance.sol";
import {RandomnessInterface} from "./interfaces/randomness.sol";

//Lottery contract inherits from the ChainlinkClient contract
contract Lottery is ChainlinkClient {
    

        //Sets Chainlink Alarm clocks by connecting them to Kovan Testnet Oracles
        //Kovan Testnet Website: https://kovan-testnet.github.io/website/
        address Chainlink_Oracle_Alarm = 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
        bytes32 Chainlink_Alarm_JobId = "982105d690504c5d9ce374d040c08654";
        
        //Defines Entry Costs as .0025 ether (~8.75 USD as of 10/12/2021)
        //This value can be changed to whatever entry costs are required
        uint256 ticketPrice = .0025 ether;
        
        //Defines Gas/Transactional Fees to use Oracle Nodes(.1 LINK=0.00070023 Ether)
        uint256 Payment_to_Oracle= 0.00070023 ether;
        
        //Defines lottery states as open, closed,or calculating
        enum Lottery_state { Open, Closed, Calculating }
    
        //Displays the state of the lottery externally
        Lottery_state public Lottery_Status;
    
        //Counts how many players are in the Lottery
        address[] public players;
        //address payable[] public players;
    
        //Counts how many Lotteries have been played
        uint256 public LotteryCount;
        
        address payable owner;
        
        uint256 openingTime;
        
        uint256 closingTime;
    
        ChainlinkGovernance public governance;
    //Sets initial values for variables
    constructor() public
    {
        
        //Setting the owner
        owner = payable(msg.sender);
        
        //Required to connect with Chainlink Oracles
        //setPublicChainlinkToken();
    
        //First Lottery
        LotteryCount = 1;
    
        //Sets Lottery State as Closed
        Lottery_Status = Lottery_state.Closed;
        
        //governance = ChainlinkGovernance(msg.sender);
    }
    
    function isClosed() public {
        if (block.timestamp > closingTime){
            Lottery_Status = Lottery_state.Closed;
            require(block.timestamp < closingTime, "Buying period has already closed");
        }
    }
    
    //Function to check if lottery is open and also require payment before adding to Player list
    function enter() public payable {
        
        //Requires Players to pay entry costs
        assert(msg.value >= ticketPrice);
        
        //Checks that Lottery is open
        require(Lottery_Status == Lottery_state.Open, "Lottery is not open");
        
        isClosed();
        
        //Deposits ETH into Lottery wallet
        owner.transfer(msg.value);
        
        
        //adds new player to the existing Player list
        players.push(msg.sender);
        
        
        
        //
    }
    
    modifier isOwner(){
        require(msg.sender == owner, "You are not the owner ");
        _;
    }
    
    
    //Private Function to pick winner randomly using Chainlink VRFs
    function PickWinner() private {
        
        //Checks that Lottery is Calculating Winner
        require(Lottery_Status == Lottery_state.Calculating);
        
        RandomnessInterface(governance.randomness()).getRandom(LotteryCount,LotteryCount);
        
        
        //Uses Chainlink VRF function in ChainlinkLotteryGovernance.sol to generate randomness
        //VRFRandom(ChainlinkLotteryGovernance.randomness()).getRandom(lotteryId,lotteryId);
    }
    
    
    //Function to stop player enteries and initiate the PickWinner() function
    function fulfill_alarm(bytes32 _requestId)
    
        //Ensures that the request is valid and viewable externally 
        public  
        recordChainlinkFulfillment(_requestId)
            {
                //Checks that Lottery is Calculating Winner   
                require(Lottery_Status == Lottery_state.Open);
                
                //Changes Lottery Status to Calculating
                Lottery_Status=Lottery_state.Calculating;
                
                //Increases the Completed Lottery Count by 1 
                LotteryCount = LotteryCount + 1;
                
                //Initiates PickWinner() function
                PickWinner();
                
            }
     
     
    function CloseLottery() public isOwner {
        
        require(Lottery_Status == Lottery_state.Open);
        
        Lottery_Status = Lottery_state.Calculating;
        
        openingTime = 0;
        closingTime = 0;
        
        PickWinner();
        
    }
     
    //Function to start new lottery and         
    function StartLottery(uint256 duration) public isOwner {
        
        //ensures previous lottery is closed
        require(Lottery_Status == Lottery_state.Closed);
        
        //Starts new lottery
        Lottery_Status = Lottery_state.Open;
        
        openingTime = block.timestamp;
        
        closingTime = block.timestamp + duration;
        
        /*
        //Connects to Chainlink Alarm
        Chainlink.Request memory request = buildChainlinkRequest(Chainlink_Alarm_JobId, address(this), this.fulfill_alarm.selector);
        
        //
        request.addUint("times", block.timestamp + duration);
        
        //Sends the Chainlink Request to The Chainlink Alarm, and sends associated Gas/Transactional fees)
        sendChainlinkRequestTo(Chainlink_Oracle_Alarm,request,Payment_to_Oracle);
        */
    
    
    }

}