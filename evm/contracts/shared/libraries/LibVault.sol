// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.17;

import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";

struct VaultStorage {
    IERC20 rewardToken;
    IERC20 stakingToken;

    uint256 totalSupply; // total supply of staked token in this contract (needs to equal to or greater than stakingToken.balanceOf(address(this))), accum supply of tokens deposited
    uint256 multiplier; // when user unstakes or claims, we will use a mathematical equation to calculate rewardToken to claim multiplied by the multiplier

    mapping(address => uint256) balanceOf;
    mapping(address => uint256) lastDepositTimestamp;
}

library LibVault {
    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.vault.storage");

    /**
     * @notice Retrieves the storage struct of the Vault contract
     * @return ds The VaultStorage struct
     */
    function diamondStorage() internal pure returns (VaultStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @notice Retrieves the balance of the specified user
     * @param _user The address of the user
     * @return balance_ The balance of the user
     */
    function _balanceOf(address _user) internal view returns (uint256 balance_) {
        VaultStorage storage vaultStore = diamondStorage();
        balance_ = vaultStore.balanceOf[_user];
    }

    /**
     * @notice Retrieves the total supply of staked tokens
     * @return totalSupply The total supply of staked tokens
     */
    function _totalSupply() internal view returns (uint256 totalSupply) {
        VaultStorage storage vaultStore = diamondStorage();
        totalSupply = vaultStore.totalSupply;
    }

    /**
     * @notice Retrieves the reward token contract
     * @return token The reward token contract
     */
    function _rewardToken() internal view returns (IERC20 token) {
        VaultStorage storage vaultStore = diamondStorage();
        token = vaultStore.rewardToken;
    }

    /**
     * @notice Retrieves the staking token contract
     * @return token The staking token contract
     */
    function _stakingToken() internal view returns (IERC20 token) {
        VaultStorage storage vaultStore = diamondStorage();
        token = vaultStore.stakingToken;
    }

    /**
     * @notice Mints new staking tokens to the specified user
     * @param _to The address of the user to receive the staking tokens
     * @param _shares The amount of staking tokens to mint
     */
    function _mint(address _to, uint256 _shares) internal {
        VaultStorage storage vaultStore = diamondStorage();
        vaultStore.totalSupply += _shares;
        vaultStore.balanceOf[_to] += _shares;
    }

    /**
     * @notice Burns staking tokens from the specified user
     * @param _from The address of the user to burn staking tokens from
     * @param _shares The amount of staking tokens to burn
     */
    function _burn(address _from, uint256 _shares) internal {
        VaultStorage storage vaultStore = diamondStorage();
        vaultStore.totalSupply -= _shares;
        vaultStore.balanceOf[_from] -= _shares;
    }

    /**
     * @notice Deposits the specified amount of staking tokens into the contract
     * @param _amount The amount of staking tokens to deposit
     */
    function _deposit(uint256 _amount) internal {
        VaultStorage storage vaultStore = diamondStorage();
        uint256 shares;
        if (vaultStore.totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * vaultStore.totalSupply) / _stakingToken().balanceOf(address(this));
        }

        _mint(LibMeta.msgSender(), shares);
        _stakingToken().transferFrom(LibMeta.msgSender(), address(this), _amount);

        vaultStore.lastDepositTimestamp[LibMeta.msgSender()] = block.timestamp; // Update last deposit timestamp for the user

        // Mint reward tokens
        _claim(LibMeta.msgSender());
    }

    /**
     * @notice Withdraws the specified amount of staking tokens from the contract
     * @param _shares The amount of staking tokens to withdraw
     */
    function _withdraw(uint256 _shares) internal {
        VaultStorage storage vaultStore = diamondStorage();
        uint256 amount = (_shares * _stakingToken().balanceOf(address(this))) / vaultStore.totalSupply;
        _burn(LibMeta.msgSender(), _shares);
        _stakingToken().transfer(LibMeta.msgSender(), amount);

        vaultStore.lastDepositTimestamp[LibMeta.msgSender()] = block.timestamp; // Update last deposit timestamp for the user

        // Mint reward tokens
        _claim(LibMeta.msgSender());
    }

    /**
     * @notice Claims and mints reward tokens for the specified user
     * @param _user The address of the user to claim rewards for
     */
    function _claim(address _user) internal {
        VaultStorage storage vaultStore = diamondStorage();
        uint256 rewardAmount = (_stakingToken().balanceOf(address(this)) * (block.timestamp - vaultStore.lastDepositTimestamp[_user])) * vaultStore.multiplier;
        vaultStore.rewardToken.transfer(_user, rewardAmount);
    }
}
