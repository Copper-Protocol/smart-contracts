// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import "../CopperToken/CopperToken.sol";
import "../shared/libraries/LibMeta.sol";

contract CopperAirdrop {
    address public owner;
    CopperToken public copperToken;

    uint256 public airdropAmount = 500 * 10 ** 18;
    mapping(address => bool) public hasClaimed;

    constructor(address _copperTokenAddress) {
        owner = LibMeta.msgSender();
        copperToken = CopperToken(_copperTokenAddress);
    }

    modifier onlyOwner() {
        require(LibMeta.msgSender() == owner, "Only the contract owner can perform this action");
        _;
    }

    function claimAirdrop() external {
        require(!hasClaimed[LibMeta.msgSender()], "You have already claimed the airdrop");
        
        hasClaimed[LibMeta.msgSender()] = true;
        copperToken.mint(LibMeta.msgSender(), airdropAmount);
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
