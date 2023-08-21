// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {ERC20MintBurnInternal} from "./ERC20MintBurnInternal.sol";
import { LibMeta } from "../../../libraries/LibMeta.sol";


contract ERC20MintBurn is ERC20MintBurnInternal {
    function initializeERC20MintBurn(address[] memory minters_, address[] memory burners_) internal notERC20MintBurnInitialized {
        _initializeERC20MintBurn(minters_, burners_);
    }

    // Mint new tokens and assign them to an account
    function mint(address account, uint256 value) external isERC20MintBurnInitialized onlyERC20Minter {
        _mint(account, value);
    }

    // Burn tokens from the caller's account
    function burn(uint256 value) external isERC20MintBurnInitialized onlyERC20Burner {
        _burn(LibMeta.msgSender(), value);
    }

    // Add a minter role to an account
    function addMinter(address account) external onlyERC20MintBurnAdmin {
        _addMinter(account);
    }

    // Remove a minter role from an account
    function removeMinter(address account) external onlyERC20MintBurnAdmin {
        _removeMinter(account);
    }

    // Add a burner role to an account
    function addBurner(address account) external onlyERC20MintBurnAdmin {
        _addBurner(account);
    }

    // Remove a burner role from an account
    function removeBurner(address account) external onlyERC20MintBurnAdmin {
        _removeBurner(account);
    }

    // Add a mint-burn admin role to an account
    function addMintBurnAdmin(address account) external onlyERC20MintBurnAdmin {
        _addMintBurnAdmin(account);
    }

    // Remove a mint-burn admin role from an account
    function removeMintBurnAdmin(address account) external onlyERC20MintBurnAdmin {
        _removeMintBurnAdmin(account);
    }
}
