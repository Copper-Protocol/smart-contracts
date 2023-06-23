// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;
pragma abicoder v2;

library EnumerableSet {
    struct Set {
        mapping(address => bool) _values;
        address[] _entries;
    }

    function add(Set storage set, address value) internal returns (bool) {
        if (contains(set, value)) {
            return false;
        }
        set._values[value] = true;
        set._entries.push(value);
        return true;
    }

    function remove(Set storage set, address value) internal returns (bool) {
        if (!contains(set, value)) {
            return false;
        }
        set._values[value] = false;
        for (uint256 i = 0; i < set._entries.length; i++) {
            if (set._entries[i] == value) {
                set._entries[i] = set._entries[set._entries.length - 1];
                set._entries.pop();
                break;
            }
        }
        return true;
    }

    function contains(Set storage set, address value) internal view returns (bool) {
        return set._values[value];
    }

    function length(Set storage set) internal view returns (uint256) {
        return set._entries.length;
    }

    function at(Set storage set, uint256 index) internal view returns (address) {
        require(index < set._entries.length, "EnumerableSet: index out of bounds");
        return set._entries[index];
    }
}
