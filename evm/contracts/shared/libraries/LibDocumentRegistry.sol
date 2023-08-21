// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

struct Document {
    string name; // Name of the document
    uint256 docType; // Type of the document
    uint256 datetimePublished; // Timestamp of when the document was published
    bytes contentHash; // Hash of the document content
    string url; // URL of the document
}

struct DocumentStorage {
    mapping(uint256 => Document) documents; // Mapping of document IDs to documents
    uint256 totalDocuments; // Total count of documents
    mapping(uint256 => string) docTypes;
    uint256 totalDocTypes;
}

library LibDocumentRegistry {
    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.document-registry.storage");

    function diamondStorage() internal pure returns (DocumentStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
