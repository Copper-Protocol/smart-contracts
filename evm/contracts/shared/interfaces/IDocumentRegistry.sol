// SPDX-License-Identifier: FRAKTAL-PROTOCOL
pragma solidity 0.8.18;


/******************************************************************************\
* Author: Kryptokajun <kryptokajun@proton.me> (https://twitter.com/kryptokajun1)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

interface IDocumentRegistry {
    function addDocument(
        string memory name,
        uint256 docType,
        uint256 datetimePublished,
        bytes32 contentHash,
        string memory url
    ) external returns (uint256 docId);

    function addDocument(
        string memory name,
        string memory docType,
        uint256 datetimePublished,
        bytes32 contentHash,
        string memory url
    ) external returns (uint256 docId);
    
    function updateDocument(
        uint256 docId,
        string memory name,
        uint256 docType,
        uint256 datetimePublished,
        bytes32 contentHash,
        string memory url
    ) external;

    function totalDocuments() external view returns (uint256 totalDocs);

    function addDocType(string memory _type) external;

    function getDocTypeByName(string memory _type) external view returns (uint256 docTypeId);

    function hasDocType(string memory _type) external view returns (bool);

    function documents(uint256 docId)
        external
        view
        returns (
            string memory name,
            uint256 docType,
            uint256 datetimePublished,
            bytes32 contentHash,
            string memory url
        );
}