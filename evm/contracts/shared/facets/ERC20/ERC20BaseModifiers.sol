// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibMeta} from "../../libraries/LibMeta.sol";
import {LibAccessControl, AccessControlStorage} from "../../libraries/LibAccessControl.sol";
import {AccessControlModifiers} from "../../facets/AccessControl/AccessControl/AccessControlModifiers.sol";
import {ERC20BaseStorage, LibERC20Base} from "./LibERC20.sol";

contract ERC20BaseModifiers {
    // Modifier to restrict access to only the admin
    modifier onlyERC20Admin() {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        LibAccessControl._checkRole("ROLE_ADMIN", LibMeta.msgSender());
        _;
    }

    // Modifier to check if the ERC20 token is initialized
    modifier isInitialized() {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        require(erc20BaseStore.ERC20_INIT, "NOT INITIALIZED");
        _;
    }

    // Modifier to check if the ERC20 token is not yet initialized
    modifier notInitialized() {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        require(!erc20BaseStore.ERC20_INIT, "ALREADY INITIALIZED");
        _;
    }
}
