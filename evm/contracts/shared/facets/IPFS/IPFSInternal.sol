// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.3;

// Import the LibUtil library for string comparison
import {LibUtil} from "../../libraries/LibUtil.sol";

// Structure to store IPFS data
struct IPFSData {
  string cid;
  string fileName;
  bytes _hash;
}

// Storage contract for IPFS data
struct IPFSStorage {
  mapping(uint256 => IPFSData) ipfsData;
  uint256 ipfsDataCount;
}

// Library to access IPFS storage
library LibIPFS {
  bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.ipfs.storage");

  /**
   * @dev Returns the storage instance of IPFSStorage
   * @return ds The IPFSStorage storage instance
   */
  function diamondStorage() internal pure returns (IPFSStorage storage ds) {
    bytes32 position = STORAGE_POSITION;
    assembly {
      ds.slot := position
    }
  }
}

contract IPFSInternal {
  // Custom error for existing IPFS CID
  error IPFSCIDExists(string _hash);

  /**
   * @dev Internal function to access the IPFSStorage storage instance
   * @return ipfsStore_ The IPFSStorage storage instance
   */
  function _ipfsStore () internal pure returns (IPFSStorage storage ipfsStore_) {
    ipfsStore_ = LibIPFS.diamondStorage();
  }

  /**
   * @dev Adds a new IPFS hash entry to the storage
   * @param _cid The CID of the IPFS hash
   * @param _fileName The name of the file
   * @param _hash The hash value
   */
  function _addHash(string memory _cid, string memory _fileName, bytes memory _hash) internal returns(uint256 _id) {
    // Check if the CID already exists
    if (_hasHash(_cid)) revert IPFSCIDExists(_cid);

    // Get the next available index in the IPFSData mapping
    uint256 index = _ipfsStore().ipfsDataCount;

    // Create a new IPFSData entry and assign the values
    IPFSData storage data = _ipfsStore().ipfsData[index];
    data.cid = _cid;
    data.fileName = _fileName;
    data._hash = _hash;

    // Increment the data count
    _ipfsStore().ipfsDataCount++;
    _id = index;
  }

  /**
   * @dev Checks if a CID already exists in the storage
   * @param _cid The CID to check
   * @return _hasCID True if the CID exists, false otherwise
   */
  function _hasHash(string memory _cid) internal view returns(bool _hasCID) {
    uint256 count = _ipfsStore().ipfsDataCount;

    for (uint256 i = 0; i < count; i++) {
      string memory ipfsCid = _ipfsStore().ipfsData[i].cid;
      if (LibUtil._stringCompare(_cid, ipfsCid)) {
        _hasCID = true;
        break;
      }
    }
  }

  /**
   * @dev Retrieves the CID associated with a given ID
   * @param _id The ID of the IPFSData
   * @return cid_ The CID of the IPFS hash
   */
  function _getHash(uint256 _id) internal view returns (string memory cid_) {
    // Check if the ID is valid
    require(_id < _ipfsStore().ipfsDataCount, "Invalid ID");

    // Retrieve and return the CID
    cid_ = _ipfsStore().ipfsData[_id].cid;
  }
}

contract IPFS is IPFSInternal {
  function getHash(uint256 _id) external view returns (string memory cid_) {
    cid_ = _getHash(_id);
  }
  function addHash(string memory _cid, string memory _fileName, bytes memory _hash) external {
    _addHash(_cid, _fileName, _hash);
  }
}