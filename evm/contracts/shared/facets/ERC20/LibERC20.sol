// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.17;

import {IERC20} from "../../interfaces/IERC20.sol";
import {LibMeta} from "../../libraries/LibMeta.sol";


// Struct to store ERC20 token data
struct ERC20BaseStorage {
    uint256 decimals;
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    mapping(address => bool) minters;
    mapping(address => bool) burners;
    bool ERC20_INIT;
}

// Library to access ERC20BaseStorage
library LibERC20Base {
    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.erc20-base.storage");

    function diamondStorage() internal pure returns (ERC20BaseStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

