// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {ERC173BaseInternal} from "./ERC173BaseInternal.sol";

contract ERC173Base is ERC173BaseInternal {
  function transferOwnership(address newOwner) external {
      _transferOwnership(newOwner);
  }

  // IRREVERSABLE - DISABLES OWNER FUNCTIONALITY COMPLETELY and INDEFINITELY
  function renounceOwnership() external {
        _renounceOwnership();
  }

}