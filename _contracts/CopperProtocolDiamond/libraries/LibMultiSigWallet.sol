// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.8;

struct Transaction {
    address to;
    uint value;
    bytes data;
    bool executed;
    uint numConfirmations;
    // mapping from tx index => owner => bool

}

struct MultiSigWalletStorage {
    address[] owners;
    mapping(address => bool) isOwner;
    uint numConfirmationsRequired;
    mapping(uint => mapping(address => bool)) isConfirmed;

    Transaction[] transactions;

}

library LibMultiSigWallet {
  bytes32 constant STORAGE_POSITION = keccak256("fraktal-protocol.multisig.storage");
  function diamondStorage() internal pure returns (MultiSigWalletStorage storage ds) {
    bytes32 position = STORAGE_POSITION;
    assembly {
      ds.slot := position
    }
  }

}

