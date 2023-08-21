// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibUtil} from "../../../libraries/LibUtil.sol";
import {LibERC1155Base, ERC1155BaseStorage} from "./LibERC1155Base.sol";

contract ERC1155BaseInternal {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    function _baseStore () internal pure returns (ERC1155BaseStorage storage store) {
        store = LibERC1155Base.diamondStorage();
    }

    function _balanceOf(address _owner, uint256 _id) internal view returns (uint256) {
        return _baseStore().balances[_owner][_id];
    }

    function _balanceOfBatch(address[] memory _owners, uint256[] memory _ids) internal view returns (uint256[] memory) {
        require(_owners.length == _ids.length, "Array lengths must match");

        uint256[] memory batchBalances = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; i++) {
            batchBalances[i] = _baseStore().balances[_owners[i]][_ids[i]];
        }

        return batchBalances;
    }

    function _setApprovalForAll(address _operator, bool _approved) internal {
        _baseStore().operatorApproval[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function _isApprovedForAll(address _owner, address _operator) internal view returns (bool) {
        return _baseStore().operatorApproval[_owner][_operator];
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value
    ) internal {
        require(_to != address(0), "Invalid recipient address");

        _baseStore().balances[_from][_id] -= _value;
        _baseStore().balances[_to][_id] += _value;

        emit TransferSingle(msg.sender, _from, _to, _id, _value);
    }

    function _safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values
    ) internal {
        require(_to != address(0), "Invalid recipient address");
        require(_ids.length == _values.length, "Array lengths must match");

        for (uint256 i = 0; i < _ids.length; i++) {
            _baseStore().balances[_from][_ids[i]] -= _values[i];
            _baseStore().balances[_to][_ids[i]] += _values[i];
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _values);
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return _id > 0 && LibUtil._stringCompare(_baseStore().tokenURIs[_id], "");
    }
    function _uri(uint256 _id) internal view returns (string memory) {
        require(_exists(_id), "Token does not exist");
        return string(LibUtil._uintToString(_id));
    }

    function _addToken(uint256 _id, string memory __uri) internal {
        require(!_exists(_id), "Token already exists");

        _baseStore().tokenURIs[_id] = __uri;
        _baseStore().tokenIds.push(_id);

        emit URI(__uri, _id);
    }
}
