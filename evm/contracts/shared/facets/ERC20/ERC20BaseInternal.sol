// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibMeta} from "../../libraries/LibMeta.sol";
import {AccessControlInternal} from "../../facets/AccessControl/AccessControl/AccessControlInternal.sol";
import {AccessControlModifiers} from "../../facets/AccessControl/AccessControl/AccessControlModifiers.sol";
import {LibAccessControl, AccessControlStorage} from "../../libraries/LibAccessControl.sol";

import {ERC20BaseStorage, LibERC20Base} from "./LibERC20.sol";
import {ERC20BaseModifiers} from "./ERC20BaseModifiers.sol";

// Internal contract with ERC20 token functionality and access control
contract ERC20BaseInternal is AccessControlInternal, ERC20BaseModifiers {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Initialize the ERC20 token
    function _initialize(
        // string memory name_,
        // string memory symbol_,
        uint256 totalSupply_,
        uint256 decimal_
        // uint256 cap_
    ) internal {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();

        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        // erc20BaseStore.name = name_;
        // erc20BaseStore.symbol = symbol_;
        erc20BaseStore.totalSupply = totalSupply_;
        erc20BaseStore.decimals = decimal_;
        // erc20BaseStore.cap = cap_;


        erc20BaseStore.balances[LibMeta.msgSender()] = totalSupply_;
        emit Transfer(address(0), LibMeta.msgSender(), totalSupply_);
        erc20BaseStore.ERC20_INIT = true;
    }
    function _beforeTransfer () internal virtual {
        
    }
    // Get the name of the token
    // function _name() internal view returns (string memory) {
    //     ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
    //     return erc20BaseStore.name;
    // }

    // Get the symbol of the token
    // function _symbol() internal view returns (string memory) {
    //     ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
    //     return erc20BaseStore.symbol;
    // }

    // Get the decimals of the token
    function _decimals() internal view returns (uint8) {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        return uint8(erc20BaseStore.decimals);
    }

    // Get the total supply of the token
    function _totalSupply() internal view returns (uint256) {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        return erc20BaseStore.totalSupply;
    }

    // Get the balance of an account
    function _balanceOf(address account) internal view returns (uint256) {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        return erc20BaseStore.balances[account];
    }

    // Get the allowance for spender on owner's tokens
    function _allowance(address owner, address spender) internal view returns (uint256) {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        return erc20BaseStore.allowances[owner][spender];
    }

    // Transfer tokens from one address to another
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(value > 0, "transfer value must be greater than zero");
        require(erc20BaseStore.balances[from] >= value, "transfer amount exceeds balance");

        erc20BaseStore.balances[from] -= value;
        erc20BaseStore.balances[to] += value;
        emit Transfer(from, to, value);
    }

    // Transfer tokens from one address to another
    function _transferFrom(
        address from,
        address to,
        uint256 value
    ) internal {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        require(erc20BaseStore.allowances[from][LibMeta.msgSender()] >= value, "transfer amount exceeds allowance");
        erc20BaseStore.allowances[from][LibMeta.msgSender()] -= value;
        _transfer(from, to, value);
    }

    // Approve spender to spend owner's tokens
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        erc20BaseStore.allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


}
