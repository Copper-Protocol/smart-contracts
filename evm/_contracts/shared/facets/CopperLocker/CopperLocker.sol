// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import {LibMeta} from "../../libraries/LibMeta.sol";
import {LibCopperLocker, CopperLockerStorage} from "../../libraries/LibCopperLocker.sol";


contract CopperLockerInternal {
  event Withdrawal(uint amount, uint when);
  
  function _initialize(uint _unlockTime) payable internal {
    require(
      block.timestamp < _unlockTime,
      "Unlock time should be in the future"
    );

    unlockTime = _unlockTime;
    owner = payable(LibMeta.msgSender());
  }
  function _withdraw() public {
    // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
    // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

    require(block.timestamp >= unlockTime, "You can't withdraw yet");
    require(LibMeta.msgSender() == owner, "You aren't the owner");

    emit Withdrawal(address(this).balance, block.timestamp);

    owner.transfer(address(this).balance);
  }
}
contract CopperLocker {
  function initialize (uint _unlockTime) payable external {
    _initialize(_unlockTime);
  }
  function withdraw () external {
    _withdraw();
  }
}
