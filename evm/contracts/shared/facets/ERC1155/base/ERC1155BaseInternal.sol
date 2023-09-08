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
    function _mint(
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) internal {
        require(_to != address(0), "Invalid recipient address");
        require(_id > 0, "Invalid token ID");

        _baseStore().balances[_to][_id] += _value;

        emit TransferSingle(msg.sender, address(0), _to, _id, _value);

        // if (_to.isContract()) {
        //     _doSafeTransferAcceptanceCheck(msg.sender, msg.sender, _to, _id, _value, _data);
        // }
    }

    function _burn(
        address _from,
        uint256 _id,
        uint256 _value
    ) internal {
        require(_from != address(0), "Invalid sender address");
        require(_id > 0, "Invalid token ID");
        require(_baseStore().balances[_from][_id] >= _value, "Insufficient balance");

        _baseStore().balances[_from][_id] -= _value;

        emit TransferSingle(msg.sender, _from, address(0), _id, _value);
    }
    /**
     * @dev Internal function to check if a recipient contract supports the ERC-1155 interface and handle safe transfers.
     *
     * @param _operator Address which initiated the transfer.
     * @param _from Address which previously owned the token.
     * @param _to Address which will receive the token.
     * @param _id ID of the token to transfer.
     * @param _value Amount of tokens to transfer.
     * @param _data Data to send along with the call if the recipient is a contract.
     *
     * @return `true` if the recipient accepts the transfer, `false` otherwise.
     */
    function _doSafeTransferAcceptanceCheck(
        address _operator,
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) internal returns (bool) {
        // Check if the recipient `_to` is a contract.
        // if (!_to.isContract()) {
        //     return true; // No need for acceptance check for non-contract recipients.
        // }

        // Attempt to call the `onERC1155Received` function on the recipient contract.
        // If it's not implemented, the call will revert, indicating refusal.
        (bool success, bytes memory data) = _to.call(
            abi.encodeWithSelector(
                bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")),
                _operator,
                _from,
                _id,
                _value,
                _data
            )
        );

        if (!success) {
            if (data.length > 0) {
                // Revert with the returned data from the call.
                assembly {
                    let data_size := mload(data)
                    revert(add(32, data), data_size)
                }
            } else {
                revert("Transfer to non-ERC1155Receiver contract"); // Revert with a generic message.
            }
        }

        // Check the returned data to determine acceptance.
        return (data.length > 0 && abi.decode(data, (bool)));
    }

}
