// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.17;

import {LibERC20Capped, ERC20CappedStorage} from "./LibERC20Capped.sol";
import {LibERC20Base, ERC20BaseStorage} from "../LibERC20.sol";
import {ERC20CappedInternal} from "./ERC20CappedInternal.sol";
import {LibMeta} from "../../../libraries/LibMeta.sol";

contract ERC20Capped is ERC20CappedInternal {
  function initERC20Capped (uint cap_) external {
    _initERC20Capped (cap_);
  }
  function cap () external view returns (uint256 cap_) {
    cap_ = _cap();
  }
      // Transfer tokens to a given address
  function transfer(address to, uint256 value) external virtual returns (bool) {
      ERC20CappedInternal._beforeTransfer();
      _transfer(LibMeta.msgSender(), to, value);
      return true;
    }

}