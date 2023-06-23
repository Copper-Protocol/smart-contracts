// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibMeta} from "./LibMeta.sol";

struct AccessControlStorage {
    mapping(bytes32 => mapping(address => bool)) roles;
    mapping(address => bytes32[]) memberRoles;
    mapping(bytes32 => address[]) roleMembers;
    mapping(bytes32 => bytes32) roleAdmins;
    address owner;
}

library LibAccessControl {
    bytes32 constant STORAGE_POSITION = keccak256("fraktal-protocol.access_control.storage");

    function diamondStorage() internal pure returns (AccessControlStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function _setRoleAdmin(bytes32 roleId, bytes32 adminRoleId) internal {
        AccessControlStorage storage acs = diamondStorage();
        acs.roleAdmins[roleId] = adminRoleId;
    }

    function _grantRole(bytes32 roleId, address account) internal {
        AccessControlStorage storage acs = diamondStorage();
        require(!hasRole(roleId, account), "AccessControl: account already has role");
        acs.roles[roleId][account] = true;
        acs.memberRoles[account].push(roleId);
        acs.roleMembers[roleId].push(account);
    }

    function _revokeRole(bytes32 roleId, address account) internal {
        AccessControlStorage storage acs = diamondStorage();
        require(hasRole(roleId, account), "AccessControl: account does not have role");
        delete acs.roles[roleId][account];
        // _removeFromRoleMembers(acs.memberRoles[account], roleId);
        _removeFromRoleMembers(acs.roleMembers[roleId], account);
    }

    function _removeFromRoleMembers(address[] storage members, address member) internal {
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == member) {
                if (i != members.length - 1) {
                    members[i] = members[members.length - 1];
                }
                members.pop();
                break;
            }
        }
    }

    function _checkRole(bytes32 roleId, address account) internal view {
        require(hasRole(roleId, account), "AccessControl: account does not have role");
    }

    function hasRole(bytes32 roleId, address account) internal view returns (bool) {
        AccessControlStorage storage acs = diamondStorage();
        return acs.roles[roleId][account];
    }

    function getRoleAdmin(bytes32 roleId) internal view returns (bytes32) {
        AccessControlStorage storage acs = diamondStorage();
        return acs.roleAdmins[roleId];
    }

    function getRoleMembers(bytes32 roleId) internal view returns (address[] storage) {
        AccessControlStorage storage acs = diamondStorage();
        return acs.roleMembers[roleId];
    }

    function getMemberRoles(address account) internal view returns (bytes32[] storage) {
        AccessControlStorage storage acs = diamondStorage();
        return acs.memberRoles[account];
    }
}
