pragma solidity ^0.8.8;

import "./vrf/VRFConsumerBase.sol";
import {GovernanceInterface} from "./interfaces/governance.sol";
import {LotteryInterface} from "./interfaces/lottery.sol";

contract VRF is VRFConsumerBase{
    
        bytes32 internal keyHash;
        
        uint256 internal fee;
        
        mapping (uint => uint) public randomNumber;
        
        mapping (bytes32 => uint) public requestIds;
        
        GovernanceInterface public governance;
        
        uint256 public most_recent_random;
    
    constructor(address _governance)
    
        VRFConsumerBase(
            
            0xf720CF1B963e0e7bE9F58fd471EFa67e7bF00cfb, // VRF Coordinator
            
            0x20fE562d797A42Dcb3399062AE9546cd06f63280  // LINK Token
            
        ) public
    {
        
        keyHash = 0xced103054e349b8dfb51352f0f8fa9b5d20dde3d06f9f43cb2b85bc64b238205;
        
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        
        governance = GovernanceInterface(_governance);
        
    }
    
    function getRandom(
    
        uint256 userProvidedSeed, 
        
        uint256 lotteryId
        )
        public 
        {
        
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        
        bytes32 _requestId = requestRandomness(keyHash, fee, userProvidedSeed);
        
        requestIds[_requestId] = lotteryId;
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) external override {
    
        require(msg.sender == vrfCoordinator, "Fulillment only permitted by Coordinator");
        
        most_recent_random = randomness;
        
        uint lotteryId = requestIds[requestId];
        
        randomNumber[lotteryId] = randomness;
        
        LotteryInterface(governance.lottery()).fulfill_random(randomness);
        
    }
    
}