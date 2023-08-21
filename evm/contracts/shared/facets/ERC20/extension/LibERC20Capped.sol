// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibMeta} from "../../../libraries/LibMeta.sol";

struct ERC20CappedStorage {
  uint256 cap;
}

library LibERC20Capped {
  bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.erc1155capped.storage");

  function diamondStorage() internal pure returns (ERC20CappedStorage storage ds) {
    bytes32 position = STORAGE_POSITION;
    assembly {
        ds.slot := position
    }
  }
}