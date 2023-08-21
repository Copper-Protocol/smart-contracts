// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibUtil} from "../../../libraries/LibUtil.sol";

struct ERC1155BaseStorage {
    mapping(address => mapping(uint256 => uint256)) balances;
    mapping(address => mapping(address => bool)) operatorApproval;
    mapping(uint256 => string) tokenURIs;
    uint256[] tokenIds;
}

library LibERC1155Base {
    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.erc1155base.storage");

    function diamondStorage() internal pure returns (ERC1155BaseStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

