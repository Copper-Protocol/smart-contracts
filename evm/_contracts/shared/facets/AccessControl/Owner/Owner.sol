// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibMeta} from "../../../libraries/LibMeta.sol";
import {LibAccessControl, Owner} from "../../../libraries/LibAccessControl.sol";
import {OwnerEvents} from "../ACEvents.sol";
import {OwnerInternal} from "./OwnerInternal.sol";

contract Owner is OwnerInternal {
    function owner() external view returns (address owner_) {
        owner_ = _owner();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }
}
