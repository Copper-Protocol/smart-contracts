// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibMeta} from "../../../libraries/LibMeta.sol";
import {LibAccessControl} from "../../../libraries/LibAccessControl.sol";

contract AccessControlModifiers {
    modifier onlyRole(bytes32 roleId) {
        require(LibAccessControl.hasRole(roleId, LibMeta.msgSender()), "AccessControl: sender does not have role");
        _;
    }
}

