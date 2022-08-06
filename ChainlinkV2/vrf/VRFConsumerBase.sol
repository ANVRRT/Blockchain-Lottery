pragma solidity ^0.8.8;

import "./SafeMath.sol";

import "./interfaces/LinkTokenInterface.sol";

import "./VRFRequestIDBase.sol";


abstract contract VRFConsumerBase is VRFRequestIDBase {

  using SafeMath for uint256;

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
  
    external virtual;

  function requestRandomness(bytes32 _keyHash, uint256 _fee, uint256 _seed)
  
    public returns (bytes32 requestId)
  {
      
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, _seed));

    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, _seed, address(this), nonces[_keyHash]);

    nonces[_keyHash] = nonces[_keyHash].add(1); 
    
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal LINK;
  address internal vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) public nonces;
  
  constructor(address _vrfCoordinator, address _link) {
      
    vrfCoordinator = _vrfCoordinator;
    
    LINK = LinkTokenInterface(_link);
    
  }
}