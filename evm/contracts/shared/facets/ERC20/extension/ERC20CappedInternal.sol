// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibMeta} from "../../../libraries/LibMeta.sol";
import {LibERC20Base, ERC20BaseStorage} from "../LibERC20.sol";
import {ERC20BaseInternal} from "../ERC20BaseInternal.sol";
import {
  LibERC20Capped,
  ERC20CappedStorage
} from "./LibERC20Capped.sol";

contract ERC20CappedInternal is ERC20BaseInternal {
  function _initERC20Capped (uint cap_) internal {
    ERC20CappedStorage storage erc20capped = LibERC20Capped.diamondStorage();
    erc20capped.cap = cap_;
  }
  function _beforeTransfer () internal virtual override(ERC20BaseInternal) {
    ERC20BaseStorage storage erc20base = LibERC20Base.diamondStorage();
    ERC20CappedStorage storage erc20capped = LibERC20Capped.diamondStorage();
    require(uint256(erc20base.totalSupply) + msg.value <= uint256(erc20capped.cap), 'EXCEEDED CAPPED SUPPLY LIMITED');
  }
  function _cap () internal view returns (uint256 cap_) {
    ERC20CappedStorage storage store = LibERC20Capped.diamondStorage();
    cap_ = uint256(store.cap);
  }

}