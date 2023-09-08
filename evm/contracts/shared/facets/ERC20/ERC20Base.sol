// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibMeta} from "../../libraries/LibMeta.sol";
import {AccessControlInternal} from "../../facets/AccessControl/AccessControl/AccessControlInternal.sol";
import {AccessControlModifiers} from "../../facets/AccessControl/AccessControl/AccessControlModifiers.sol";
import {LibAccessControl, AccessControlStorage} from "../../libraries/LibAccessControl.sol";

import {ERC20BaseStorage, LibERC20Base} from "./LibERC20.sol";
import {ERC20BaseModifiers} from "./ERC20BaseModifiers.sol";
import {ERC20BaseInternal} from "./ERC20BaseInternal.sol";


// ERC20 token contract with internal functions
contract ERC20Base is ERC20BaseModifiers, ERC20BaseInternal {
    // Initialize the ERC20 token
    function initializeBase (
        uint256 totalSupply_,
        uint256 decimals_
    ) external notInitialized virtual {
        _initialize(
            totalSupply_,
            decimals_
        );
    }


    // Transfer tokens to a given address
    function transfer(address to, uint256 value) external virtual isInitialized returns (bool) {
        _beforeTransfer();
        _transfer(LibMeta.msgSender(), to, value);
        return true;
    }

    // Transfer tokens from one address to another
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external isInitialized returns (bool) {
        _transferFrom(from, to, value);
        return true;
    }

    // Approve spender to spend a certain amount of tokens
    function approve(address spender, uint256 value) external isInitialized returns (bool) {
        _approve(LibMeta.msgSender(), spender, value);
        return true;
    }

    // Get the decimals of the token
    function decimals() external isInitialized view returns (uint8) {
        return _decimals();
    }

    // Get the total supply of the token
    function totalSupply() external isInitialized view returns (uint256) {
        return _totalSupply();
    }

    // Get the balance of an account
    function balanceOf(address account) external isInitialized view returns (uint256) {
        return _balanceOf(account);
    }

    // Get the allowance for spender on owner's tokens
    function allowance(address owner, address spender) external isInitialized view returns (uint256) {
        return _allowance(owner, spender);
    }
}