// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibUtil} from "../../../libraries/LibUtil.sol";

struct ERC1155MetaStorage {
    string name;
    string symbol;
    string uriPrefix;

}

library LibERC1155Meta {
    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.erc1155meta.storage");

    function diamondStorage() internal pure returns (ERC1155MetaStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly ("memory-safe") {
            ds.slot := position
        }
    }
}
