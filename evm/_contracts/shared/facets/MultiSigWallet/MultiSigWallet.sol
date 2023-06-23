// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Transaction} from '../../libraries/LibMultiSigWallet.sol';
import {MultiSigWalletInternal} from "./MultiSigWalletInternal.sol";

contract MultiSigWallet is MultiSigWalletInternal {
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
    function init(address[] memory _owners, uint __numConfirmationsRequired) external {
        _init(_owners, __numConfirmationsRequired);
    }
    function owners () external view returns (address[] memory owners_) {
        owners_ = _owners();
    }
    function isOwner (address _account) external view returns (bool isOwner_) {
        isOwner_ =_isOwner(_account);
    }
    function numConfirmationsRequired () external view returns (uint256 confirmed) {
        confirmed =_numConfirmationsRequired();
    }
    function isConfirmed (uint _id, address _account) external view returns (bool isConfirmed_) {
        isConfirmed_ =_isConfirmed(_id, _account);
    }
    function transactions () external view returns (Transaction[] memory transactions_) {
        transactions_ =_transactions();
    }
   function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) external {
        _submitTransaction(_to, _value, _data);
    }
    function confirmTransaction(uint _txIndex) external {
        _confirmTransaction(_txIndex);
    }

    function executeTransaction(uint _txIndex) external {
        _executeTransaction(_txIndex);
    }
    function revokeConfirmation(
        uint _txIndex
    ) external {
        _revokeConfirmation(_txIndex);
    }
    function getOwners() external view returns (address[] memory) {
        return _getOwners();
    }
    function getTransactionCount() external view returns (uint count) {
        count = _getTransactionCount();
    }
    function getTransaction(uint _txIndex) external view returns (
        address to,
        uint value,
        bytes memory data,
        bool executed,
        uint numConfirmations
    )
    {
       (to, value, data, executed, numConfirmations) = _getTransaction(_txIndex);

    }
}
