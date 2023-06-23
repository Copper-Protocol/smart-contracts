// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibMeta} from "../../../libraries/LibMeta.sol";
import {LibAccessControl} from "../../../libraries/LibAccessControl.sol";

contract AccessControlInternal {
    using LibMeta for address;
    using LibAccessControl for bytes32;
    using LibAccessControl for address;

    function _setRoleAdmin(bytes32 roleId, bytes32 adminRoleId) internal {
        LibAccessControl._setRoleAdmin(roleId, adminRoleId);
    }

    function _grantRole(bytes32 roleId, address account) internal {
        LibAccessControl._grantRole(roleId, account);
    }

    function _revokeRole(bytes32 roleId, address account) internal {
        LibAccessControl._revokeRole(roleId, account);
    }

    function _checkRole(bytes32 roleId, address account) internal view {
        LibAccessControl._checkRole(roleId, account);
    }

    function _setupRole(bytes32 roleId, address account) internal {
        _grantRole(roleId, account);
    }

    function _setRoleAdminVerified(bytes32 roleId, bytes32 adminRoleId) internal {
        require(roleId != adminRoleId, "AccessControl: cannot set role admin to self");
        _setRoleAdmin(roleId, adminRoleId);
    }

    function _grantRoleVerified(bytes32 roleId, address account) internal {
        require(account != address(0), "AccessControl: cannot grant role to zero address");
        _grantRole(roleId, account);
    }

    function _revokeRoleVerified(bytes32 roleId, address account) internal {
        require(account != address(0), "AccessControl: cannot revoke role from zero address");
        _revokeRole(roleId, account);
    }

    function _checkRoleVerified(bytes32 roleId, address account) internal view {
        require(account != address(0), "AccessControl: account cannot be zero address");
        _checkRole(roleId, account);
    }
}
