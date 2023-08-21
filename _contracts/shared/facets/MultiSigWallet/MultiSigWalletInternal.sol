// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.8;

import {
    LibMultiSigWallet,
    MultiSigWalletStorage,
    Transaction
} from "../../libraries/LibMultiSigWallet.sol";

import {MultiSigWalletModifiers} from "./MultiSigWalletModifiers.sol";

contract MultiSigWalletInternal is MultiSigWalletModifiers {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex, bytes txData);

    function _init(address[] memory __owners, uint __numConfirmationsRequired) internal {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        require(__owners.length > 0, "owners required");
        require(
            __numConfirmationsRequired > 0 &&
                __numConfirmationsRequired <= __owners.length,
            "invalid number of required confirmations"
        );

        for (uint i = 0; i < __owners.length; i++) {
            address owner = __owners[i];

            require(owner != address(0), "invalid owner");
            require(!ds.isOwner[owner], "owner not unique");

            ds.isOwner[owner] = true;
            ds.owners.push(owner);
        }

        ds.numConfirmationsRequired = __numConfirmationsRequired;
    }

    function _owners () internal view returns (address[] memory owners) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        owners = ds.owners;
    }
    function _isOwner (address _account) internal view returns (bool isOwner) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        isOwner = ds.isOwner[_account];
    }
    function _numConfirmationsRequired () internal view returns (uint256 confirmed) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        confirmed = ds.numConfirmationsRequired;
    }
    function _isConfirmed (uint _id, address _account) internal view returns (bool isConfirmed) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        isConfirmed = ds.isConfirmed[_id][_account];
    }
    function _transactions () internal view returns (Transaction[] memory transactions) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        transactions = ds.transactions;
    }
    function _submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) internal onlyOwner {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
       uint txIndex = ds.transactions.length;

        ds.transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function _confirmTransaction(
        uint _txIndex
    ) internal onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        Transaction storage transaction = ds.transactions[_txIndex];
        transaction.numConfirmations += 1;
        ds.isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function _executeTransaction(
        uint _txIndex
    ) internal onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        Transaction storage transaction = ds.transactions[_txIndex];

        require(
            transaction.numConfirmations >= ds.numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        (bool success, bytes memory _txData) = payable(address(transaction.to))
            .call{value: transaction.value}(
                transaction.data
            );
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex, _txData);
    }

    function _revokeConfirmation(
        uint _txIndex
    ) internal onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        Transaction storage transaction = ds.transactions[_txIndex];

        require(ds.isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        ds.isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function _getOwners() internal view returns (address[] memory) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
       return ds.owners;
    }

    function _getTransactionCount() internal view returns (uint) {
         MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
       return ds.transactions.length;
    }

    function _getTransaction(uint _txIndex) internal view returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        Transaction storage transaction = ds.transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}
