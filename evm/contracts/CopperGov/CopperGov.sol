// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {TimeLock} from "./TimeLock.sol";
import {LibMeta} from "../shared/libraries/LibMeta.sol";

struct Proposal {
  address proposer;
  string description;
  uint256 votesFor;
  uint256 votesAgainst;
  bool executed;
  bool active;
}


struct CopperGovStorage {

  mapping(uint256 => Proposal) proposals;
  uint256 proposalCount;

  uint256 votingDuration;
  uint256 votingStartTime;
  uint256 votingEndTime;

  address admin;
  TimeLock timelock;
}

library LibCopperGov {

    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.copper-gov.storage");

    /**
     * @dev Returns the access control storage struct
     * @return ds Access control storage struct
     */
    function diamondStorage() internal pure returns (CopperGovStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
contract CopperGovInternal {
  event ProposalCreated(uint256 proposalId, address proposer, string description);
  event ProposalExecuted(uint256 proposalId);
  event TransactionQueued(uint256 proposalId, bytes32 txHash);

  modifier onlyAdmin() {
    require(LibMeta.msgSender() == _admin(), "Only admin can call this function");
    _;
  }

  function _initialize(uint256 _votingDuration_, uint256 _timelockDuration_) internal {
    require(_votingDuration_ > 0, "Voting duration must be greater than zero");
    _govStore().admin = LibMeta.msgSender();
    _govStore().votingDuration = _votingDuration_;
    _govStore().timelock = new TimeLock(_timelockDuration_);
  }
  function _govStore () internal pure returns(CopperGovStorage storage store) {
    store = LibCopperGov.diamondStorage();
  }
  // function _proposals () internal pure returns (Proposal[] memory proposals_) {
  //   proposals_ = _govStore().proposals;
  // }
  function _getProposal (uint id) internal view returns(Proposal memory proposal) {
    proposal = _getProposal(id);
  }
  function _proposalCount () internal view returns (uint proposalCount_) {
    proposalCount_ = _govStore().proposalCount;
  }
  function _votingDuration () internal view returns (uint votingDuration_) {
    votingDuration_ = _govStore().votingDuration;

  }
  function _votingStartTime () internal view returns (uint votingStartTime_) {
    votingStartTime_ = _govStore().votingStartTime;

  }
  function _votingEndTime () internal view returns (uint votingEndTime_) {
    votingEndTime_ = _govStore().votingEndTime;

  }
  function _admin () internal view returns (address admin_) {
    admin_ = _govStore().admin;

  }
  function _timelock () internal view returns (TimeLock timelock_) {
    timelock_ = _govStore().timelock;

  }

  function _createProposal(string calldata _description) internal {
    require(_getProposal(_proposalCount()).active == false, "An active proposal already exists.");
    Proposal memory newProposal = Proposal({
      proposer: LibMeta.msgSender(),
      description: _description,
      votesFor: 0,
      votesAgainst: 0,
      executed: false,
      active: true
    });
   _govStore().proposals[_proposalCount()] = newProposal;
    _govStore().proposalCount++;
    _govStore().votingStartTime = block.timestamp;
    _govStore().votingEndTime = block.timestamp + _votingDuration();

    emit ProposalCreated(_proposalCount() - 1, LibMeta.msgSender(), _description);
  }

  function _vote(uint256 _proposalId, bool _inSupport) internal {
    // Same as before
  }

  function _executeProposal(uint256 _proposalId) internal {
    // Ensure the proposal is valid and voting has ended
    require(_getProposal(_proposalId).active == true, "The proposal does not exist or is inactive.");
    require(block.timestamp >= _govStore().votingEndTime, "Voting is still ongoing.");
    require(_getProposal(_proposalId).executed == false, "The proposal has already been executed.");
    require(_getProposal(_proposalId).votesFor > _getProposal(_proposalId).votesAgainst, "The proposal did not receive enough votes.");

    Proposal memory proposal = _getProposal(_proposalId);
    proposal.executed = true;

    // Queue the transaction in the TimeLock contract for execution
    bytes32 txHash = _timelock().queueTransaction(address(this), 0, "", abi.encodeWithSignature("executeProposal(uint256)", _proposalId));

    emit ProposalExecuted(_proposalId);

    // Emit event with the queued transaction hash
    emit TransactionQueued(_proposalId, txHash);
  }

  function _cancelProposal(uint256 _proposalId) internal {
    // Same as before
  }

  // Additional functions to interact with the TimeLock contract
  function _setTimeLockDelay(uint256 _delay) internal onlyAdmin {
    _timelock().setDelay(_delay);
  }

  function _queueTimeLockTransaction(address _target, uint256 _value, string calldata _signature, bytes calldata _data) internal onlyAdmin returns (bytes32) {
    return _timelock().queueTransaction(_target, _value, _signature, _data);
  }

  function _executeTimeLockTransaction(address _target, uint256 _value, string calldata _signature, bytes calldata _data, uint256 _eta) internal onlyAdmin {
    _timelock().executeTransaction(_target, _value, _signature, _data, _eta);
  }
}

contract CopperGov {




}
