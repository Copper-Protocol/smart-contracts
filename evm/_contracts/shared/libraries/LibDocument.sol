// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

struct Document {
  string name;
  string url;
  string hash;
  bool verified;
}

library LibDocument {

    // Function to create a new document
  function createDocument(
    string memory _name,
    string memory _url,
    string memory _hash,
    bool _verified
  ) internal pure returns (Document memory) {
    return Document({
        name: _name,
        url: _url,
        hash: _hash,
        verified: _verified
    });
  }

  // Function to update a document's information
  function updateDocument(
    Document storage document,
    string memory _name,
    string memory _url,
    string memory _hash,
    bool _verified
  ) internal {
    document.name = _name;
    document.url = _url;
    document.hash = _hash;
    document.verified = _verified;
  }
}

