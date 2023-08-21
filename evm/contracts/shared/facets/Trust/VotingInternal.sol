// // SPDX-License-Identifier: COPPER-PROTOCOL
// pragma solidity ^0.8.0;

// import { IERC20 } from "../../interfaces/IERC20.sol";
// import { TrustInternal } from "./TrustInternal.sol";
// import { IDocumentRegistry } from "../../interfaces/IDocumentRegistry.sol";
// import { LibTrust, TrustStorage } from "./LibTrust.sol";
// import { LibUtil } from "../../libraries/LibUtil.sol";
// import { LibMeta } from "../../libraries/LibMeta.sol";

// struct Proposal {
//   address proposer;
//   string proposalName;
//   uint256 docId; // DocumentRegistry id 
//   uint256 startTime;
//   uint256 endTime;
//   uint256 votesFor;
//   uint256 votesAgainst;
//   bool executed;
//   bool approved;
//   mapping(address => bool) voted;
// }

// struct VotingStorage {
//   mapping(uint256 => Proposal) proposals;
//   uint256 proposalCount;

//   uint256 VOTING_DURATION; // Adjust as needed
//   bool _init;
// }

// library LibVoting {
//   bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.voting.storage");

//   /**
//    * @dev Returns the voting storage struct.
//    * @return ds The reference to the voting storage struct.
//    */
//   function diamondStorage() internal pure returns (VotingStorage storage ds) {
//     bytes32 position = STORAGE_POSITION;
//     assembly {
//         ds.slot := position
//     }
//   }
// }

// contract VotingInternal is TrustInternal {
//   event ProposalAdded(
//     address indexed proposer,
//     string proposalName,
//     string proposalDocId,
//     uint256 startTime,
//     uint256 endTime
//   );

//   event ProposalApproved(uint256 proposalId);

//   event ProposalRejected(uint256 proposalId);

//   event ProposalExecuted(uint256 proposalId);

//   event VoteCasted(uint256 proposalId, address voter, bool support);

//   function _addProposalDoc (
//     string memory name,
//     uint256 docType,
//     uint256 datetimePublished,
//     bytes32 contentHash,
//     string memory url
//   ) internal {
//     uint256 docId = _getDocumentRegistry().addDocument(name, docType, datetimePublished, contentHash, url);
//   }

//   function _votingStore () internal pure returns (VotingStorage storage store) {
//     store = LibVoting.diamondStorage();
//   }

//   function _createProposal (string memory proposalName, uint256 docId, uint256 startTime, uint256 endTime, bytes32 contentHash, string memory url) internal {
//     address proposer = LibMeta.msgSender();
//     uint256 docType = _getDocumentRegistry().getDocTypeByName("VOTING_PROPOSAL");
//     uint256 datetimePublished = block.timestamp;
//     _addProposalDoc(proposalName, docType, datetimePublished, contentHash, url);
//     uint256 proposalId = _votingStore().proposalCount;
//     Proposal storage proposal = _votingStore().proposals[proposalId];
//     proposal.proposer = proposer;
//     proposal.proposalName = proposalName;
//     proposal.docId = docId;
//     proposal.startTime = startTime;
//     proposal.endTime = endTime;
//     proposal.votesFor = 0;
//     proposal.votesAgainst = 0;
//     proposal.executed = false;
//     proposal.approved = false;
//     _votingStore().proposalCount++;
//   }

//   function _approveProposal (uint256 proposalId) internal {
//     Proposal storage proposal = _getProposal(proposalId);
//     require(!proposal.executed, "Proposal already executed");
//     require(!proposal.approved, "Proposal already approved");
//     require(block.timestamp >= proposal.endTime, "Voting period not ended");

//     uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
//     require(totalVotes > 0, "No votes recorded");

//     uint256 threshold = totalVotes / 2; // Simple majority threshold

//     if (proposal.votesFor > threshold) {
//       proposal.approved = true;
//       emit ProposalApproved(proposalId);
//     } else {
//       emit ProposalRejected(proposalId);
//     }
//   }

//   function _executeProposal (uint256 proposalId) internal {
//     Proposal storage proposal = _getProposal(proposalId);
//     require(!proposal.executed, "Proposal already executed");
//     require(proposal.approved, "Proposal not approved");

//     // Perform the execution of the proposal here

//     proposal.executed = true;
//     emit ProposalExecuted(proposalId);
//   }

//   function _rejectProposal (uint256 proposalId) internal {
//     Proposal storage proposal = _getProposal(proposalId);
//     require(!proposal.executed, "Proposal already executed");
//     require(!proposal.approved, "Proposal already approved");

//     proposal.approved = false;
//     emit ProposalRejected(proposalId);
//   }

//   function _getProposal (uint256 proposalId) internal view returns (Proposal storage proposal) {
//     require(proposalId < _votingStore().proposalCount, "Invalid proposalId");
//     proposal = _votingStore().proposals[proposalId];
//   }

// function _getProposals(uint256[] memory proposalIds) internal view returns (Proposal[] storage proposals) {
//   uint256 totalIds = proposalIds.length;
//   // proposals = new Proposal[](totalIds);

//   for (uint256 i = 0; i < totalIds; i++) {
//     uint256 proposalId = proposalIds[i];
//     require(proposalId < _votingStore().proposalCount, "Invalid proposalId");
//     Proposal storage storageProposal = _votingStore().proposals[proposalId];
//     Proposal storage memoryProposal;
//     memoryProposal.proposer = storageProposal.proposer;
//     memoryProposal.proposalName = storageProposal.proposalName;
//     memoryProposal.docId = storageProposal.docId;
//     memoryProposal.startTime = storageProposal.startTime;
//     memoryProposal.endTime = storageProposal.endTime;
//     memoryProposal.votesFor = storageProposal.votesFor;
//     memoryProposal.votesAgainst = storageProposal.votesAgainst;
//     memoryProposal.executed = storageProposal.executed;
//     memoryProposal.approved = storageProposal.approved;
//     proposals[i] = memoryProposal;
//   }
// }



//   function _vote (uint256 proposalId, bool support) internal {
//     Proposal storage proposal = _getProposal(proposalId);
//     require(!proposal.voted[msg.sender], "Already voted");
//     require(block.timestamp >= proposal.startTime, "Voting not started");
//     require(block.timestamp < proposal.endTime, "Voting period ended");

//     proposal.voted[msg.sender] = true;

//     if (support) {
//       proposal.votesFor++;
//       emit VoteCasted(proposalId, msg.sender, true);
//     } else {
//       proposal.votesAgainst++;
//       emit VoteCasted(proposalId, msg.sender, false);
//     }
//   }
// }
