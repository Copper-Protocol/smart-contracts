// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import { IERC20 } from "../../interfaces/IERC20.sol";
import { AccessControlInternal } from "../AccessControl/AccessControl/AccessControlInternal.sol"; // Import the relevant AccessControlInternal contract
import {IDocumentRegistry} from "../../interfaces/IDocumentRegistry.sol";

struct TrusteeData {
  address trustee;
  bool accepted;
  bool revoked;
  bool declined; // if true and accepted is false, the person declined the trustee position, if true and accepted is true, the trustee resigned
  
  bytes acceptedSignature;
  uint256 acceptanceBlock;
  uint256 revocationBlock;
}

struct TrustStorage {
  address owner;
  mapping(uint256 => address) grantors;
  uint256 totalGrantors;
  mapping(uint256 => TrusteeData) trustees;
  uint256 totalTrustees;

  IERC20 beneficialInterestUnits;
  bytes trusteeAcceptanceString;
  IERC20[] approvedTokens;
  mapping(address => mapping(address => mapping(address => uint256))) trusteeBalances; // spendable, (no authorization approval) balances for each trustee
  bool TRUST_INIT;

  uint256 trustDeclaration;
  uint256 trustIndenture;
  IDocumentRegistry docReg;

  
  mapping(address => mapping(address =>bool)) trusteeVote; // 
}

library LibTrust {
  bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.trust.storage");

  /**
   *  @dev Returns the access control storage struct
   *  @return ds Access control storage struct
  */
  function diamondStorage() internal pure returns (TrustStorage storage ds) {
    bytes32 position = STORAGE_POSITION;
    assembly {
        ds.slot := position
    }
  }
}
