// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.17;

interface IVault {
    function claim() external;
    function calculateReward(address user, uint256 userLastDepositTimestamp) external view returns (uint256);
    function deposit(uint256 amount) external;
    function withdraw(uint256 shares) external;
    function balanceOf(address user) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function rewardToken() external view returns (address);
    function stakingToken() external view returns (address);
}
