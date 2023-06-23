// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {LibMeta} from "../../libraries/LibMeta.sol";
import {VaultInternal} from "./VaultInternal.sol";
import {VaultModifiers} from "./VaultModifiers.sol";

contract Vault is VaultInternal, VaultModifiers {
    constructor(address _token) {
        _setToken(_token);
    }

    function token() external view returns (IERC20) {
        return _vaultStorage().token;
    }

    function totalSupply() external view returns (uint256) {
        return _vaultInternal.totalSupply();
    }

    function balanceOf(address user) external view returns (uint256) {
        return _vaultInternal.balanceOf(user);
    }

    function balanceOfToken(address user, address token) external view returns (uint256) {
        return _vaultInternal.balanceOfToken(user, token);
    }

    function rewards(address user) external view returns (uint256) {
        return _vaultInternal.rewards(user);
    }

    function deposit(uint256 amount) external {
        _vaultInternal._deposit(msg.sender, amount);
    }

    function withdraw(uint256 shares) external {
        _vaultInternal._withdraw(msg.sender, shares);
    }

    function claim() external returns (uint256) {
        return _vaultInternal._claim(msg.sender);
    }
}
