// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibMeta} from "../../../libraries/LibMeta.sol";
import {LibAccessControl, Owner} from "../../../libraries/LibAccessControl.sol";

contract OwnerModifiers {
    modifier onlyOwner() {
        require(LibMeta.msgSender() == LibAccessControl._getOwner(), "DiamondOwner: caller is not the owner");
        _;
    }
}

