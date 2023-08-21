// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import { LibMeta } from "../../../libraries/LibMeta.sol";
import { AccessControlInternal } from "../../../facets/AccessControl/AccessControl/AccessControlInternal.sol";
import { AccessControlModifiers } from "../../../facets/AccessControl/AccessControl/AccessControlModifiers.sol";
import { LibAccessControl, AccessControlStorage } from "../../../libraries/LibAccessControl.sol";
import { ERC20BaseStorage, LibERC20Base } from "../LibERC20.sol";
import {LibERC20MintBurn, ERC20MintBurnStorage} from "./LibERC20MintBurn.sol";
import {ERC20MintBurnModifiers} from "./ERC20MintBurnModifiers.sol";

contract ERC20MintBurnRolesInternal is AccessControlInternal, ERC20MintBurnModifiers {
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event BurnerAdded(address indexed account);
    event BurnerRemoved(address indexed account);

    // Add a minter role to an account
    function _addMinter(address account) internal {
        require(account != address(0), "Cannot add minter to the zero address");
        _grantRole("ROLE_ERC20_MINTER", account);
        emit MinterAdded(account);
    }

    // Remove a minter role from an account
    function _removeMinter(address account) internal {
        require(account != address(0), "Cannot remove minter from the zero address");
        _revokeRole("ROLE_ERC20_MINTER", account);
        emit MinterRemoved(account);
    }

    // Add a burner role to an account
    function _addBurner(address account) internal {
        require(account != address(0), "Cannot add burner to the zero address");
        _grantRole("ROLE_ERC20_BURNER", account);
        emit BurnerAdded(account);
    }

    // Remove a burner role from an account
    function _removeBurner(address account) internal {
        require(account != address(0), "Cannot remove burner from the zero address");
        _revokeRole("ROLE_ERC20_BURNER", account);
        emit BurnerRemoved(account);
    }
}

contract ERC20MintBurnInternal is ERC20MintBurnRolesInternal {
    event MintBurnAdminAdded(address indexed account);
    event MintBurnAdminRemoved(address indexed account);

    function _initializeERC20MintBurn(address[] memory minters, address[] memory burners) internal {
        ERC20MintBurnStorage storage mintBurnStore = LibERC20MintBurn.diamondStorage();

        LibAccessControl.setRoleAdmin("ROLE_ERC20_MINTER", "ROLE_ERC20_ADMIN");
        LibAccessControl.setRoleAdmin("ROLE_ERC20_BURNER", "ROLE_ERC20_ADMIN");
        LibAccessControl.setRoleAdmin("ROLE_ERC20_MINTER", "ROLE_ERC20_MINT_BURN_ADMIN");
        LibAccessControl.setRoleAdmin("ROLE_ERC20_BURNER", "ROLE_ERC20_MINT_BURN_ADMIN");
        LibAccessControl.setRoleAdmin("ROLE_ERC20_MINT_BURN_ADMIN", "ROLE_ERC20_ADMIN");

        // Set the caller of _initialize as the admin
        address admin = LibMeta.msgSender();
        LibAccessControl.grantRole("ROLE_ERC20_ADMIN", admin);
        LibAccessControl.grantRole("ROLE_ERC20_MINT_BURN_ADMIN", admin);

        // Add minters
        for (uint256 i = 0; i < minters.length; i++) {
            LibAccessControl.grantRole("ROLE_ERC20_MINTER", minters[i]);
        }

        // Add burners
        for (uint256 i = 0; i < burners.length; i++) {
            LibAccessControl.grantRole("ROLE_ERC20_BURNER", burners[i]);
        }

        mintBurnStore.ERC20_MINT_BURN_INIT = true;
    }

    // Mint new tokens and assign them to an account
    function _mint(address account, uint256 value) internal {
        ERC20BaseStorage storage erc20baseStore = LibERC20Base.diamondStorage();
        require(account != address(0), "mint to the zero address");
        erc20baseStore.totalSupply += value;
        erc20baseStore.balances[account] += value;
        // emit Transfer(address(0), account, value);
    }

    // Burn tokens from the caller's account
    function _burn(address account, uint256 value) internal {
        ERC20BaseStorage storage erc20baseStore = LibERC20Base.diamondStorage();

        require(erc20baseStore.balances[account] >= value, "burn amount exceeds balance");
        erc20baseStore.balances[account] -= value;
        erc20baseStore.totalSupply -= value;
        // emit Transfer(account, address(0), value);
    }

    // Add a mint-burn admin role to an account
    function _addMintBurnAdmin(address account) internal {
        require(account != address(0), "Cannot add mint-burn admin to the zero address");
        _grantRole("ROLE_ERC20_MINT_BURN_ADMIN", account);
        emit MintBurnAdminAdded(account);
    }

    // Remove a mint-burn admin role from an account
    function _removeMintBurnAdmin(address account) internal {
        require(account != address(0), "Cannot remove mint-burn admin from the zero address");
        _revokeRole("ROLE_ERC20_MINT_BURN_ADMIN", account);
        emit MintBurnAdminRemoved(account);
    }
}