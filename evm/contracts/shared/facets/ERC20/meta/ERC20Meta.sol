// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {ERC20MetaInternal} from "./ERC20MetaInternal.sol";

contract ERC20Meta is ERC20MetaInternal {
  function initERC20Meta (
    string memory name_,
    string memory symbol_
   ) internal {
    _initERC20Meta(name_, symbol_);
  }
  function name () external view returns (string memory name_) {
    name_ = _name();
  }
  function symbol () external view returns (string memory symbol_) {
    symbol_ = _symbol();
  }
}