pragma solidity 0.8.8;

interface GovernanceInterface {
    function lottery() external view returns (address);
    function randomness() external view returns (address);
}