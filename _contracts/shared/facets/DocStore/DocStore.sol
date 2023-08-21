// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {LibDocument, Document} from "../../libraries/LibDocument.sol";

contract DocStore {

  mapping(uint256 => Document) private documents;
  uint256 private nextDocumentId;

  event DocumentCreated(uint256 indexed documentId);
  event DocumentUpdated(uint256 indexed documentId);

  // Function to create a new document
  function createDocument(
    string memory _name,
    string memory _url,
    string memory _hash,
    bool _verified
  ) public {
    Document storage document = documents[nextDocumentId];
    document.createDocument(_name, _url, _hash, _verified);
    emit DocumentCreated(nextDocumentId);
    nextDocumentId++;
  }

  // Function to update a document's information
  function updateDocument(
    uint256 documentId,
    string memory _name,
    string memory _url,
    string memory _hash,
    bool _verified
  ) public {
    require(documentId < nextDocumentId, "Invalid documentId");
    Document storage document = documents[documentId];
    document.updateDocument(_name, _url, _hash, _verified);
    emit DocumentUpdated(documentId);
  }

  // Function to retrieve a document's information
  function getDocument(uint256 documentId)
    public
    view
    returns (
      string memory name,
      string memory url,
      string memory hash,
      bool verified
    )
  {
    require(documentId < nextDocumentId, "Invalid documentId");
    Document storage document = documents[documentId];
    return (
      document.name,
      document.url,
      document.hash,
      document.verified
    );
  }
}
