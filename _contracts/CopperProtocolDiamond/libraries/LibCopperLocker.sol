// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import {ICopperLocker} from "../interfaces/ICopperLocker.sol";

struct CopperLockerStorage {
  mapping(uint256 => mapping(string => ICopperLocker)) lockers;
  uint256 totalLockers;
}

library LibCopperLocker {
  bytes32 constant STORAGE_POSITION = keccak256("fraktal-protocol.multisig.storage");
  function diamondStorage() internal pure returns (CopperLockerStorage storage ds) {
    bytes32 position = STORAGE_POSITION;
    assembly {
      ds.slot := position
    }
  }

}

