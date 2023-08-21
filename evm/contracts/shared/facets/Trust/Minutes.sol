// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import { IERC20 } from "../../interfaces/IERC20.sol";
import { TrustInternal } from "./TrustInternal.sol";
import { IDocumentRegistry } from "../../interfaces/IDocumentRegistry.sol";
import { LibMeta } from "../../libraries/LibMeta.sol";
import { TrusteeData } from "./LibTrust.sol";

enum MeetingStatus { CREATED, STARTED, ADJOURNED, CANCELLED, POSTPOSED }

struct Meeting {
  address creator;
  string title;
  uint256 date;
  address[] invited;
  address[] attendees;
  
}

struct MinutesStorage {
  string VERSION;
  mapping(uint256 => Meeting) meetings;
}

library LibMinutes {
  bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.minutes.storage");

  /**
   *  @dev Returns the access control storage struct
   *  @return ds Access control storage struct
  */
  function diamondStorage() internal pure returns (MinutesStorage storage ds) {
    bytes32 position = STORAGE_POSITION;
    assembly {
        ds.slot := position
    }
  }
}

contract MinutesInternal {
  function _createMeeting (string memory _title, uint256 _date, address[] memory invited) internal {

  }
  function _cancelMeeting (uint256 _id) internal {

  }
  
}

contract Minutes {

}