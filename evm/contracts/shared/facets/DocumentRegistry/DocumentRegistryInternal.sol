// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibDocumentRegistry, DocumentStorage, Document} from "../../libraries/LibDocumentRegistry.sol";

import {LibUtil} from "../../libraries/LibUtil.sol";

contract DocumentRegistryInternal {
    event DocumentAdded(
        uint256 docId,
        string name,
        uint256 docType,
        uint256 datetimePublished,
        bytes contentHash,
        string url
    );
    event DocumentRemoved(uint256 docId);
    event DocumentUpdated(
        uint256 docId,
        string name,
        uint256 docType,
        uint256 datetimePublished,
        bytes contentHash,
        string url
    );
    event DocumentTypeAdded(uint256 indexed totalDocTypes, string indexed _type);
    function _addDocument(
        string memory name,
        uint256 docType,
        uint256 datetimePublished,
        bytes memory contentHash,
        string memory url
    ) internal returns (uint256 docId) {
        DocumentStorage storage docStore = LibDocumentRegistry.diamondStorage();

        docId = docStore.totalDocuments;
        docStore.documents[docId] = Document({
            name: name,
            docType: docType,
            datetimePublished: datetimePublished,
            contentHash: contentHash,
            url: url
        });

        docStore.totalDocuments++;

        emit DocumentAdded(
            docId,
            name,
            docType,
            datetimePublished,
            contentHash,
            url
        );
    }

    function _updateDocument(
        uint256 docId,
        string memory name,
        uint256 docType,
        uint256 datetimePublished,
        bytes memory contentHash,
        string memory url
    ) internal {
        DocumentStorage storage docStore = LibDocumentRegistry.diamondStorage();
        require(docId < docStore.totalDocuments, "Invalid document ID");

        Document storage document = docStore.documents[docId];

        document.name = name;
        document.docType = docType;
        document.datetimePublished = datetimePublished;
        document.contentHash = contentHash;
        document.url = url;

        emit DocumentUpdated(
            docId,
            name,
            docType,
            datetimePublished,
            contentHash,
            url
        );
    }

    function _getAllDocTypes() internal view returns (string[] memory docTypes) {
        DocumentStorage storage docStore = LibDocumentRegistry.diamondStorage();
        docTypes = new string[](docStore.totalDocTypes);

        for (uint256 i = 1; i <= docStore.totalDocTypes; i++) {
            docTypes[i - 1] = docStore.docTypes[i];
        }
    }

    function _totalDocuments() internal view returns (uint256 totalDocs) {
        DocumentStorage storage docStore = LibDocumentRegistry.diamondStorage();
        totalDocs = docStore.totalDocuments;
    }

    function _getDocument(uint256 docId)
        internal
        view
        returns (
            string memory name,
            uint256 docType,
            uint256 datetimePublished,
            bytes memory contentHash,
            string memory url
        )
    {
        DocumentStorage storage docStore = LibDocumentRegistry.diamondStorage();
        require(docId < docStore.totalDocuments, "Invalid document ID");

        Document storage document = docStore.documents[docId];

        name = document.name;
        docType = document.docType;
        datetimePublished = document.datetimePublished;
        contentHash = document.contentHash;
        url = document.url;
    }

    function _addDocType(string memory _type) internal returns(uint256 _id) {
        require(!_hasDocType(_type), "DOC TYPE EXISTS");
        DocumentStorage storage docStore = LibDocumentRegistry.diamondStorage();
        docStore.totalDocTypes++;
        docStore.docTypes[docStore.totalDocTypes] = _type;
        _id = docStore.totalDocTypes;
        emit DocumentTypeAdded(docStore.totalDocTypes, _type);
    }

    function _getDocTypeByName(string memory name) internal view returns (uint256 id) {
        DocumentStorage storage docStore = LibDocumentRegistry.diamondStorage();
        uint256 totalTypes = docStore.totalDocTypes;

        for (uint256 i = 1; i <= totalTypes; i++) {
            if (LibUtil._stringCompare(docStore.docTypes[i], name)) {
                id = i;
                break;
            }
        }
    }

    function _getDocTypeById(uint256 _id) internal view returns (string memory name) {
        DocumentStorage storage docStore = LibDocumentRegistry.diamondStorage();
        name = docStore.docTypes[_id];
    }

    function _hasDocType(string memory name_) internal view returns (bool hasType_) {
        uint256 docId = _getDocTypeByName(name_);

        hasType_ = LibUtil._stringCompare(name_, _getDocTypeById(docId));
    }
}
