// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {
    LibMultiSigWallet,
    MultiSigWalletStorage,
    Transaction
} from "../../libraries/LibMultiSigWallet.sol";
import {LibMeta} from "../../../shared/libraries/LibMeta.sol";

contract MultiSigWalletModifiers {
    modifier onlyOwner() {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        require(ds.isOwner[LibMeta.msgSender()], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        require(_txIndex < ds.transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
       require(!ds.transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        MultiSigWalletStorage storage ds = LibMultiSigWallet.diamondStorage();
        require(!ds.isConfirmed[_txIndex][LibMeta.msgSender()], "tx already confirmed");
        _;
    }

}
