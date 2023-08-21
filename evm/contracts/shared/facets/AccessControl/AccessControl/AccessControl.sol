// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {AccessControlModifiers} from "./AccessControlModifiers.sol";
import {AccessControlInternal} from "./AccessControlInternal.sol";
import {LibMeta} from "../../../libraries/LibMeta.sol";
import {LibAccessControl} from "../../../libraries/LibAccessControl.sol";

contract AccessControl is AccessControlModifiers, AccessControlInternal {
    function setRoleAdmin(bytes32 roleId, bytes32 adminRoleId) external onlyRole(LibAccessControl.getRoleAdmin(roleId)) {
        _setRoleAdmin(roleId, adminRoleId);
    }

    function grantRole(bytes32 roleId, address account) external onlyRole(LibAccessControl.getRoleAdmin(roleId)) {
        _grantRole(roleId, account);
    }

    function revokeRole(bytes32 roleId, address account) external onlyRole(LibAccessControl.getRoleAdmin(roleId)) {
        _revokeRole(roleId, account);
    }

    function hasRole(bytes32 roleId, address account) external view returns (bool) {
        return LibAccessControl.hasRole(roleId, account);
    }

    function getRoleAdmin(bytes32 roleId) external view returns (bytes32) {
        return LibAccessControl.getRoleAdmin(roleId);
    }

    function getRoleMembers(bytes32 roleId) external view returns (address[] memory members) {
        members = LibAccessControl.getRoleMembers(roleId);
    }

    function getMemberRoles(address account) external view returns (bytes32[] memory members) {
        members = LibAccessControl.getMemberRoles(account);
    }
}
