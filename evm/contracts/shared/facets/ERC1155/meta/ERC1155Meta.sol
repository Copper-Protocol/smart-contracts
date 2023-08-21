// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibUtil} from "../../../libraries/LibUtil.sol";
import {ERC1155MetaInternal} from "./ERC1155MetaInternal.sol";

contract ERC1155Meta is ERC1155MetaInternal {
    function name() external view returns (string memory) {
        return _name();
    }

    function symbol() external view returns (string memory) {
        return _symbol();
    }

    function uriPrefix () external view returns (string memory uriPrefix_) {
        uriPrefix_ = _uriPrefix();
    }
}