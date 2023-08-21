// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

struct ERC20MetaStorage {
  string name;
  string symbol;
}
library LibERC20Meta {
  bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.erc1155meta.storage");

  function diamondStorage() internal pure returns (ERC20MetaStorage storage ds) {
    bytes32 position = STORAGE_POSITION;
    assembly {
        ds.slot := position
    }
  }

}