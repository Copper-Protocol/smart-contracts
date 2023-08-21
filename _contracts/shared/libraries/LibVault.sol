// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {LibMeta} from "./LibMeta.sol";

struct VaultStorage {
    IERC20 token;
    uint256 totalSupply;
    mapping(address => mapping(address => uint256)) balances; // balanceOfToken[user][token]
    mapping(address => mapping(address => Deposit)) claims; // claims[user][token]
    mapping(address => bool) validStakeTokens;

    uint256 rewardRate;
    CopperLocker timelock;
}

struct Deposit {
  address user;
  address token;
  uint256 lastClaimTime;
}
library LibVault {
  bytes32 constant VAULT_STORAGE_POSITION = keccak256("fraktal-protocol.vault.storage");

  function diamondStorage() internal pure returns (VaultStorage storage ds) {
    bytes32 position = VAULT_STORAGE_POSITION;
    assembly {
        ds.slot := position
    }
  }
  function _token () internal view returns(token_) {
    token_ = diamondStorage().token;
  }
  function _rewards (address user, address token) internal view returns (uint reward_) {
    Deposit memory claim = diamondStorage().claim(user, token);
    uint256[] memory tokenRatio = new uint256[](2);
    tokenRatio = _getTokemPrice(token);
  }
  function _getTokenPrice (address feed) internal returns(uint256[] memory tokenRatio) {
    // getTokenPriceRatio from chainlink feed
  }
  function _isValidStakeToken (address _token_) internal view returns (bool isValid) {
    return diamondStorage().validStakeTokens[_token];
  }
  function _balanceOf (address _user_, address _token_) internal view returns(uint256 balance_) {
    if (_token_ == address(0)) _token_ = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    balance_ = diamondStorage().balances[_user_][_token_];
  }
  function _transferFrom (address _sender, address _recipient, address _token_, uint256 _amount) internal {
    if (_token_ == address(0)) _token_ = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    if (_token_ == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
      payable(_sender).transfer(_recipient, _token_);
    }
    else {
      IERC20(_token_).transferFrom(_sender, _recipient, _amount);
    }
  }
}
