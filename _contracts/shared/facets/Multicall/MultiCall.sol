// SPDX-License-Identifier: FRAKTAL-PROTOCOL
pragma solidity 0.8.8;
pragma abicoder v2;

import { IERC20 } from '../../interfaces/IERC20.sol';
import { IWETH } from '../../interfaces/IWETH.sol';
import { MultiCallInternal } from "./MultiCallInternal.sol";

contract MultiCall is MultiCallInternal{
  function call(address payable _to, uint256 _value, bytes memory _data) external onlyOwner 
    returns (bytes memory result, bool success) {
      (result, success) = _call(_to, _value, _data);
  }
  function multiCall (address[] memory _recipients, uint256[] memory _values, bytes[] memory _data)
    external returns (bytes[] memory results, bool[] memory success){
      (results, success) = _multiCall(_recipients, _values, _data);

  }
}