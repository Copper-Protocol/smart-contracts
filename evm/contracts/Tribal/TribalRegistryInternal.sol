// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {IPFSInternal, IPFSStorage} from "../shared/facets/IPFS/IPFSInternal.sol";
import {LibMeta} from "../shared/libraries/LibMeta.sol";

struct TribalDocs {
  string name;

}
struct TribalData {
  string name;
  address chief;
  uint256[] tribalDocs;
  uint256 registrationTimestamp;

}
struct TribalRegistryStorage {
  mapping(uint256 => TribalData) tribes;
  uint256 totalTribes;
}

library LibTribalRegistry {
  bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.tribal-registry.storage");

  function diamondStorage() internal pure returns (TribalRegistryStorage storage ds) {
    bytes32 position = STORAGE_POSITION;
    assembly ("memory-safe") {
      ds.slot := position
    }
  }

}

contract TribalRegistryInternal is IPFSInternal {
  function _tribalRegStore () internal pure returns (TribalRegistryStorage storage store) {
    store = LibTribalRegistry.diamondStorage();
  }

  function _addTribe (string memory _name, address _chief) internal {
    uint256 totalTribes = _tribalRegStore().totalTribes;
    TribalData storage tribe = _tribalRegStore().tribes[totalTribes];

    tribe.name = _name;
    tribe.chief = _chief;
    tribe.registrationTimestamp = block.timestamp;
    _tribalRegStore().totalTribes++;
  }
  function _addTribalDocs (uint256 tribeId, string memory _cid, string memory _fileName, bytes memory _hash) internal {
    TribalData storage tribe = _tribalRegStore().tribes[tribeId];
    require(LibMeta.msgSender() == tribe.chief, 'Unauthorized');
    uint256 totalDocs = tribe.tribalDocs.length;
    uint256 docId = _addHash(_cid, _fileName, _hash);
    
    tribe.tribalDocs[totalDocs] = docId;
  }
  function _getTribe (uint256 _id) internal view returns (TribalData memory tribe) {
    tribe = _tribalRegStore().tribes[_id];
  }
}