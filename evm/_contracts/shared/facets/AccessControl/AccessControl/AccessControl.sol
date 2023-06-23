// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControlModifiers} from "./AccessControlModifiers.sol";
import {AccessControlInternal} from "./AccessControlInternal.sol";
import {LibMeta} from "../../../libraries/LibMeta.sol";

contract AccessControl is AccessControlModifiers, AccessControlInternal {
    function setRoleAdmin(bytes32 roleId, bytes32 adminRoleId) external onlyOwner {
        _setRoleAdmin(roleId, adminRoleId);
    }

    function grantRole(bytes32 roleId, address account) external onlyRole(getRoleAdmin(roleId)) {
        _grantRole(roleId, account);
    }

    function revokeRole(bytes32 roleId, address account) external onlyRole(getRoleAdmin(roleId)) {
        _revokeRole(roleId, account);
    }

    function hasRole(bytes32 roleId, address account) external view returns (bool) {
        return LibAccessControl.hasRole(roleId, account);
    }

    function getRoleAdmin(bytes32 roleId) external view returns (bytes32) {
        return LibAccessControl.getRoleAdmin(roleId);
    }

    function getRoleMembers(bytes32 roleId) external view returns (address[] storage) {
        return LibAccessControl.getRoleMembers(roleId);
    }

    function getMemberRoles(address account) external view returns (bytes32[] storage) {
        return LibAccessControl.getMemberRoles(account);
    }
}
