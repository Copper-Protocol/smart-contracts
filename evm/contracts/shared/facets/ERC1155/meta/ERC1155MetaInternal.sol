// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibUtil} from "../../../libraries/LibUtil.sol";
import {LibERC1155Meta, ERC1155MetaStorage} from "./LibERC1155Meta.sol";

contract ERC1155MetaInternal {
    function _metaStore() internal pure returns (ERC1155MetaStorage storage store) {
        store = LibERC1155Meta.diamondStorage();
    }
   function _name() internal view returns (string memory) {
        return _metaStore().name;
    }

    function _symbol() internal view returns (string memory) {
        return _metaStore().symbol;
    }

    function _uriPrefix() internal view returns (string memory) {
        return _metaStore().uriPrefix;
    }


}