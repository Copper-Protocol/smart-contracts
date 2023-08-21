// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {ERC173BaseStorage, LibERC173Base} from "./LibERC173Base.sol";
import {LibMeta} from "../../libraries/LibMeta.sol";

contract ERC173BaseInternal {
  event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

  function _setOwner (address _newOwner) internal {
    ERC173BaseStorage storage erc172Store = LibERC173Base.diamondStorage();
    require(_newOwner != erc172Store.owner, 'SAME OWNER');
    require(LibMeta.msgSender() == erc172Store.owner, 'UNAUTHORIZED');
    erc172Store.owner = _newOwner;
  }
  function _transferOwnership(address newOwner) internal {
     ERC173BaseStorage storage erc172Store = LibERC173Base.diamondStorage();
  
    require(newOwner != address(0), "ERC173: new owner is the zero address");
    emit OwnershipTransferred(erc172Store.owner, newOwner);
    _setOwner(newOwner);
  }
  // IRREVERSABLE - DISABLES OWNER FUNCTIONALITY COMPLETELY and INDEFINITELY
  function _renounceOwnership() internal {
    ERC173BaseStorage storage erc172Store = LibERC173Base.diamondStorage();
    emit OwnershipTransferred(erc172Store.owner, address(0));
    _setOwner(address(0));
  }

}