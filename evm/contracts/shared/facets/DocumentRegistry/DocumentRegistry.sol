// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import { LibDocumentRegistry, DocumentStorage, Document } from "../../../shared/libraries/LibDocumentRegistry.sol";
import { DocumentRegistryInternal } from "./DocumentRegistryInternal.sol";
import { LibAccessControl } from "../../../shared/libraries/LibAccessControl.sol";
import { AccessControlModifiers } from "../AccessControl/AccessControl/AccessControlModifiers.sol";

contract DocumentRegistry is DocumentRegistryInternal, AccessControlModifiers {

    function addDocument(
        string memory name,
        uint256 docType,
        uint256 datetimePublished,
        bytes memory contentHash,
        string memory url
    ) external returns (uint256 docId) {
        docId = _addDocument(name, docType, datetimePublished, contentHash, url);
    }

    // function addDocument(
    //     string memory name,
    //     string memory docType,
    //     uint256 datetimePublished,
    //     bytes memory contentHash,
    //     string memory url
    // ) external returns (uint256 docId) {
    //     uint256 docTypeId = _getDocTypeByName(docType);
    //     if (!_hasDocType(name)) {
    //         docTypeId = _addDocType(docType);
    //     }
    //     docId = _addDocument(name, docTypeId, datetimePublished, contentHash, url);
    // }

    function updateDocument(
        uint256 docId,
        string memory name,
        uint256 docType,
        uint256 datetimePublished,
        bytes memory contentHash,
        string memory url
    ) external {
        _updateDocument(docId, name, docType, datetimePublished, contentHash, url);
    }

    function totalDocuments() external view returns (uint256 totalDocs) {
        totalDocs = _totalDocuments();
    }

    function addDocType(string memory _type) external {
        _addDocType(_type);
    }

    function getDocTypeByName(string memory _type) external view returns (uint256 docTypeId) {
        docTypeId = _getDocTypeByName(_type);
    }

    function hasDocType(string memory _type) external view returns (bool hasType) {
        hasType = _hasDocType(_type);
    }
    function getDocTypeById(uint256 _id) external view returns (string memory name) {
        name = _getDocTypeById(_id);
    }
    function documents(uint256 docId)
        external
        view
        returns (
            string memory name,
            uint256 docType,
            uint256 datetimePublished,
            bytes memory contentHash,
            string memory url
        )
    {
        return _getDocument(docId);
    }
}