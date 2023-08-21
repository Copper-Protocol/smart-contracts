// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibMeta} from "../../../libraries/LibMeta.sol";
import {LibAccessControl, Owner} from "../../../libraries/LibAccessControl.sol";
import {OwnerEvents} from "../ACEvents.sol";
import {OwnerModifiers} from "./OwnerModifiers.sol";

contract OwnerInternal is OwnerModifiers, OwnerEvents {
    function _owner() internal view returns (address owner_) {
        owner_ = LibAccessControl._getOwner();
    }

    function _setOwner(address _owner_) internal {
        LibAccessControl._setOwner(_owner_);
    }

    function _removeOwner(address _owner_) internal {
        LibAccessControl._removeOwner(_owner_);
    }

    function _transferOwnership(address newOwner_) internal {
        require(newOwner_ != address(0), "DiamondOwner: new owner is the zero address");
        emit OwnershipTransferred(_owner(), newOwner_);
        LibAccessControl._setOwner(newOwner_);
    }
}
