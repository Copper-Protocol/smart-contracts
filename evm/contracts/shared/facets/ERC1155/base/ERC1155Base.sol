// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibUtil} from "../../../libraries/LibUtil.sol";
import {ERC1155BaseInternal} from "./ERC1155BaseInternal.sol";

contract ERC1155Base is ERC1155BaseInternal {

    function uri(uint256 _id) external view returns (string memory) {
        return _uri(_id);
    }

    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {
        return _balanceOf(_owner, _id);
    }

    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids) external view returns (uint256[] memory) {
        return _balanceOfBatch(_owners, _ids);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        _setApprovalForAll(_operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return _isApprovedForAll(_owner, _operator);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value
    ) external {
        _safeTransferFrom(_from, _to, _id, _value);
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values
    ) external {
        _safeBatchTransferFrom(_from, _to, _ids, _values);
    }
}
