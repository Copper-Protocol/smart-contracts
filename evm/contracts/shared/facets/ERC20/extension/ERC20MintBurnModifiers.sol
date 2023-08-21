// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import { LibMeta } from "../../../libraries/LibMeta.sol";
import { AccessControlInternal } from "../../../facets/AccessControl/AccessControl/AccessControlInternal.sol";
import { AccessControlModifiers } from "../../../facets/AccessControl/AccessControl/AccessControlModifiers.sol";
import { LibAccessControl, AccessControlStorage } from "../../../libraries/LibAccessControl.sol";
import { ERC20BaseStorage, LibERC20Base } from "../LibERC20.sol";
import {LibERC20MintBurn, ERC20MintBurnStorage} from "./LibERC20MintBurn.sol";

contract ERC20MintBurnModifiers {

    // Modifier to check if the ERC20 token is initialized
    modifier isERC20MintBurnInitialized() {
        ERC20MintBurnStorage storage erc20MintBurnStore = LibERC20MintBurn.diamondStorage();
        require(erc20MintBurnStore.ERC20_MINT_BURN_INIT, "NOT INITIALIZED");
        _;
    }

    // Modifier to check if the ERC20 token is not yet initialized
    modifier notERC20MintBurnInitialized() {
        ERC20MintBurnStorage storage erc20MintBurnStore = LibERC20MintBurn.diamondStorage();

        require(!erc20MintBurnStore.ERC20_MINT_BURN_INIT, "ALREADY INITIALIZED");
        _;
    }

    // Modifier to restrict access to only minters
    modifier onlyERC20Minter() {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        LibAccessControl._checkRole("ROLE_ERC20_MINTER", LibMeta.msgSender());
        _;
    }

    // Modifier to restrict access to only burners
    modifier onlyERC20Burner() {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        LibAccessControl._checkRole("ROLE_ERC20_BURNER", LibMeta.msgSender());
        _;
    }

    // Modifier to restrict access to only mint/burn admins
    modifier onlyERC20MintBurnAdmin() {
        LibAccessControl._checkRole("ROLE_ERC20_MINT_BURN_ADMIN", LibMeta.msgSender());
        _;
    }
}
