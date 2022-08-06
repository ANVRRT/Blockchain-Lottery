pragma solidity ^0.8.8;

contract ChainlinkGovernance {
    
    uint256 public onceFlag;
    
    address public lottery;
    
    address public randomness;
    
    constructor() public {
        onceFlag = 1;
    }
    function init(address _lottery, address _randomness) public {
        require(_randomness != address(0), "No governance address");
        
        require(_lottery != address(0), "No lottery address");
        
        require(onceFlag > 0, "This has already been run");
        
        onceFlag = onceFlag - 1;
        randomness = _randomness;
        lottery = _lottery;
    }
}