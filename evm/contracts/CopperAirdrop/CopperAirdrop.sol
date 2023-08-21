// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import "../CopperToken/CopperToken.sol";

contract CopperAirdrop {
    address public owner;
    CopperToken public copperToken;

    uint256 public airdropAmount = 500;
    mapping(address => bool) public hasClaimed;

    constructor(address _copperTokenAddress) {
        owner = msg.sender;
        copperToken = CopperToken(_copperTokenAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    function claimAirdrop() external {
        require(!hasClaimed[msg.sender], "You have already claimed the airdrop");
        
        hasClaimed[msg.sender] = true;
        copperToken.mint(msg.sender, airdropAmount);
    }

    // Function to airdrop tokens to a list of recipients
    function airdropTokens(address[] calldata recipients) external onlyOwner {
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            require(!hasClaimed[recipient], "Address has already claimed the airdrop");

            hasClaimed[recipient] = true;
            copperToken.mint(recipient, airdropAmount);
        }
    }
}
