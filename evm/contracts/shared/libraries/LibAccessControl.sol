// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import { LibMeta } from "./LibMeta.sol";

/**
 * @title Access Control Storage
 * @dev Storage struct for access control-related data
 */
struct AccessControlStorage {

    mapping(bytes32 => mapping(address => bool)) roles;
    mapping(address => bytes32[]) memberRoles;
    mapping(bytes32 => address[]) roleMembers;
    mapping(bytes32 => bytes32) roleAdmins;
    address owner;

}

/**
 * @title LibAccessControl
 * @dev Library for access control-related functions
 */
library LibAccessControl {

    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.access_control.storage");

    /**
     * @dev Returns the access control storage struct
     * @return ds Access control storage struct
     */
    function diamondStorage() internal pure returns (AccessControlStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Sets the admin role for a given role
     * @param roleId Role ID
     * @param adminRoleId Admin role ID
     */
    function setRoleAdmin(bytes32 roleId, bytes32 adminRoleId) internal {
        AccessControlStorage storage acs = diamondStorage();
        acs.roleAdmins[roleId] = adminRoleId;
    }

    /**
     * @dev Grants a role to an account
     * @param roleId Role ID
     * @param account Account address
     */
    function grantRole(bytes32 roleId, address account) internal {
        AccessControlStorage storage acs = diamondStorage();
        require(!hasRole(roleId, account), "AccessControl: account already has role");
        acs.roles[roleId][account] = true;
        acs.memberRoles[account].push(roleId);
        acs.roleMembers[roleId].push(account);
    }

    /**
     * @dev Revokes a role from an account
     * @param roleId Role ID
     * @param account Account address
     */
    function revokeRole(bytes32 roleId, address account) internal {
        AccessControlStorage storage acs = diamondStorage();
        require(hasRole(roleId, account), "AccessControl: account does not have role");
        delete acs.roles[roleId][account];
        _removeFromRoleMembers(acs.memberRoles[account], roleId);
        _removeFromRoleMembers(acs.roleMembers[roleId], account);
    }

    /**
     * @dev Adds a new role with a given admin role
     * @param roleId Role ID
     * @param adminRoleId Admin role ID
     */
    function addRole(bytes32 roleId, bytes32 adminRoleId) internal {
        AccessControlStorage storage acs = diamondStorage();
        require(adminRoleId != bytes32(0), "AccessControl: invalid admin role");
        require(acs.roleAdmins[roleId] == bytes32(0), "AccessControl: role already exists");
        acs.roleAdmins[roleId] = adminRoleId;
    }

    /**
     * @dev Removes a role
     * @param roleId Role ID
     */
    function removeRole(bytes32 roleId) internal {
        AccessControlStorage storage acs = diamondStorage();
        require(acs.roleAdmins[roleId] != bytes32(0), "AccessControl: role does not exist");
        delete acs.roleAdmins[roleId];
    }

    /**
     * @dev Internal function to remove an item from a storage array
     * @param members Storage array
     * @param roleId Role ID to remove
     */
    function _removeFromRoleMembers(bytes32[] storage members, bytes32 roleId) internal {
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == roleId) {
                if (i != members.length - 1) {
                    members[i] = members[members.length - 1];
                }
                members.pop();
                break;
            }
        }
    }

    /**
     * @dev Internal function to remove an item from a storage array
     * @param members Storage array
     * @param member Address to remove
     */
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

    /**
     * @dev Checks if an account has a role
     * @param roleId Role ID
     * @param account Account address
     * @return bool True if account has the role, false otherwise
     */
    function hasRole(bytes32 roleId, address account) internal view returns (bool) {
        AccessControlStorage storage acs = diamondStorage();
        return acs.roles[roleId][account];
    }

    /**
     * @dev Returns the admin role for a given role
     * @param roleId Role ID
     * @return bytes32 Admin role ID
     */
    function getRoleAdmin(bytes32 roleId) internal view returns (bytes32) {
        AccessControlStorage storage acs = diamondStorage();
        return acs.roleAdmins[roleId];
    }

    /**
     * @dev Returns the members of a role
     * @param roleId Role ID
     * @return address[] Storage array of role members
     */
    function getRoleMembers(bytes32 roleId) internal view returns (address[] storage) {
        AccessControlStorage storage acs = diamondStorage();
        return acs.roleMembers[roleId];
    }

    /**
     * @dev Returns the roles assigned to an account
     * @param account Account address
     * @return bytes32[] Storage array of role IDs
     */
    function getMemberRoles(address account) internal view returns (bytes32[] storage) {
        AccessControlStorage storage acs = diamondStorage();
        return acs.memberRoles[account];
    }
    function _checkRole(bytes32 roleId, address account) internal view {
        require(LibAccessControl.hasRole(roleId, account), "AccessControl: account does not have role");
    }
}
