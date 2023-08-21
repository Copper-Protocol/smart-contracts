// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibMeta} from "../../../libraries/LibMeta.sol";
import {ERC20MetaStorage, LibERC20Meta} from "./LibERC20Meta.sol";


contract ERC20MetaInternal {
  function _initERC20Meta (
    string memory name_,
    string memory symbol_
   ) internal {
    ERC20MetaStorage storage ds = LibERC20Meta.diamondStorage();
    ds.name = name_;
    ds.symbol = symbol_;
  }
  function _name () internal view returns (string memory name_) {
    ERC20MetaStorage storage ds = LibERC20Meta.diamondStorage();
    name_ = ds.name;
  }
  function _symbol () internal view returns (string memory symbol_) {
    ERC20MetaStorage storage ds = LibERC20Meta.diamondStorage();
    symbol_ = ds.symbol;
  }

}