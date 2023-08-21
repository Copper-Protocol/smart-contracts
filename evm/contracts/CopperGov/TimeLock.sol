// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

contract TimeLock {
    uint256 public constant MIN_DELAY = 1 days; // Minimum timelock delay (1 day for example)
    mapping(bytes32 => bool) public queuedTransactions;
    mapping(bytes32 => uint256) public executionTime;
    uint256 public delay;

    address public admin;

    event NewDelay(uint256 delay);
    event QueuedTransaction(bytes32 txHash, address target, uint256 value, string signature, bytes data, uint256 eta);
    event ExecuteTransaction(bytes32 txHash, address target, uint256 value, string signature, bytes data, uint256 eta);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(uint256 _delay) {
        require(_delay >= MIN_DELAY, "Timelock delay must be at least 1 day");
        admin = msg.sender;
        delay = _delay;
    }

    function setDelay(uint256 _delay) external onlyAdmin {
        require(_delay >= MIN_DELAY, "Timelock delay must be at least 1 day");
        delay = _delay;
        emit NewDelay(_delay);
    }

    function queueTransaction(address target, uint256 value, string calldata signature, bytes calldata data) external onlyAdmin returns (bytes32) {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, block.timestamp + delay));
        queuedTransactions[txHash] = true;
        executionTime[txHash] = block.timestamp + delay;

        emit QueuedTransaction(txHash, target, value, signature, data, block.timestamp + delay);
        return txHash;
    }

    function executeTransaction(address target, uint256 value, string calldata signature, bytes calldata data, uint256 eta) external onlyAdmin {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Transaction is not queued");
        require(block.timestamp >= eta, "Transaction has not surpassed time lock");
        require(block.timestamp <= eta + 2 days, "Transaction is stale");

        queuedTransactions[txHash] = false;
        executionTime[txHash] = 0;

        (bool success, ) = target.call{value: value}(abi.encodePacked(bytes4(keccak256(bytes(signature))), data));
        require(success, "Transaction execution failed");

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);
    }
}
