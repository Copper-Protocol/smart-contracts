// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

struct ERC173BaseStorage {
  address owner;
}
library LibERC173Base {
  bytes32 constant STORAGE_POSITION = keccak256("fraktal-protocol.ERC173Base.storage");

  function diamondStorage() internal pure returns (ERC173BaseStorage storage ds) {
    bytes32 position = STORAGE_POSITION;
    assembly {
        ds.slot := position
    }
  } 
}
