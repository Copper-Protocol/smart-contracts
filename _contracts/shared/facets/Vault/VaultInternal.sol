// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {LibMeta} from "../../libraries/LibMeta.sol";
import {VaultEvents} from "./VaultEvents.sol";

contract VaultInternal {
    using SafeMath for uint256;


    function _vaultStorage() internal pure returns (VaultStorage storage ds) {
        ds = LibVault.diamondStorage();
    }

    function totalSupply() internal view returns (uint256) {
        return _vaultStorage().totalSupply;
    }

    function balanceOf(address _token_) internal view returns (uint256) {
        return _vaultStorage().balanceOf[LibMeta.msgSender()][_token_];
    }

    function _balanceOf(address _user_, address _token_) internal view returns (uint256) {
        return _vaultStorage().balanceOfToken[_user_][_token_];
    }

    function _rewards(address _user_) internal view returns (uint256) {
        return _vaultStorage().rewards[_user_];
    }

    function rewardRate() internal view returns (uint256) {
        return _vaultStorage().rewardRate;
    }

    function _setToken(address _token_) internal {
        _vaultStorage().token = IERC20(_token_);
    }

    function _deposit(address _user_, uint256 _amount_) internal {
        VaultStorage storage vault = _vaultStorage();
        uint256 shares = vault.totalSupply == 0 ? _amount_ : _amount_.mul(vault.totalSupply).div(vault.token.balanceOf(address(this)));
        vault.balanceOf[_user_] = vault.balanceOf[_user_].add(shares);
        vault.balanceOfToken[_user_][address(vault.token)] = vault.balanceOfToken[_user_][address(vault.token)].add(_amount_);
        vault.totalSupply = vault.totalSupply.add(shares);
        emit Deposit(_user_, _amount_);
    }

    function _withdraw(address _user_, uint256 shares) internal {
        VaultStorage storage vault = _vaultStorage();
        uint256 amount = shares.mul(vault.token.balanceOf(address(this))).div(vault.totalSupply);
        vault.balanceOf[_user_] = vault.balanceOf[_user_].sub(shares);
        vault.balanceOfToken[_user_][address(vault.token)] = vault.balanceOfToken[_user_][address(vault.token)].sub(amount);
        vault.totalSupply = vault.totalSupply.sub(shares);
        emit Withdraw(_user_, amount);
    }

    function _claim(address _user_) internal returns (uint256) {
        VaultStorage storage vault = _vaultStorage();
        uint256 reward = calculateReward(_user_);
        vault.rewards[_user_] = 0;
        emit Claim(_user_, reward);
        return reward;
    }

    function _calculateReward(address _user_) internal view returns (uint256) {
        VaultStorage storage vault = _vaultStorage();
        uint256 balance = vault.balanceOfToken[_user_][address(vault.token)];
        uint256 reward = balance.mul(vault.rewardRate).mul(block.timestamp).div(3 years);
        return reward;
    }
}
