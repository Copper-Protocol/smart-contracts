// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibMeta} from "../shared/libraries/LibMeta.sol";
import {AccessControlInternal} from "../shared/facets/AccessControl/AccessControl/AccessControlInternal.sol";
import {AccessControlModifiers} from "../shared/facets/AccessControl/AccessControl/AccessControlModifiers.sol";
import {LibAccessControl, AccessControlStorage} from "../shared/libraries/LibAccessControl.sol";

import {IERC165} from "../shared/interfaces/IERC165.sol";
import {IERC173} from "../shared/interfaces/IERC173.sol";

import {ERC20Base} from "../shared/facets/ERC20/ERC20Base.sol";
import {ERC20BaseStorage, LibERC20Base} from "../shared/libraries/LibERC20.sol";

// ERC20 token contract with additional external functions
contract CopperERC20 is ERC20Base {
    // Transfer tokens from one address to another
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        return _transferFrom(from, to, value);
    }

    // Approve spender to spend a certain amount of tokens
    function approve(address spender, uint256 value) external override returns (bool) {
        _approve(LibMeta.msgSender(), spender, value);
        return true;
    }

    // Mint new tokens and assign them to an account
    function mint(address account, uint256 value) external override onlyMinter {
        _mint(account, value);
    }

    // Burn tokens from the caller's account
    function burn(uint256 value) external override onlyBurner {
        _burn(value);
    }

    // Add a minter role to an account
    function addMinter(address account) external override onlyAdmin {
        _addMinter(account);
    }

    // Remove a minter role from an account
    function removeMinter(address account) external override onlyAdmin {
        _removeMinter(account);
    }

    // Add a burner role to an account
    function addBurner(address account) external override onlyAdmin {
        _addBurner(account);
    }

    // Remove a burner role from an account
    function removeBurner(address account) external override onlyAdmin {
        _removeBurner(account);
    }

    // Transfer tokens to a given address
    function transfer(address to, uint256 value) external override returns (bool) {
        return _transfer(LibMeta.msgSender(), to, value);
    }

    // Get the name of the token
    function name() external view returns (string memory) {
        return _name();
    }

    // Get the symbol of the token
    function symbol() external view returns (string memory) {
        return _symbol();
    }

    // Get the decimals of the token
    function decimals() external view returns (uint8) {
        return _decimals();
    }

    // Get the total supply of the token
    function totalSupply() external view returns (uint256) {
        return _totalSupply();
    }

    // Get the balance of an account
    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf(account);
    }

    // Get the allowance for spender on owner's tokens
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowance(owner, spender);
    }

}
