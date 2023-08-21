// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibUtil} from "../shared/libraries/LibUtil.sol";
import {LibMeta} from "../shared/libraries/LibMeta.sol";
import {ERC1155Meta} from "../shared/facets/ERC1155/meta/ERC1155Meta.sol";
import {ERC1155Base} from "../shared/facets/ERC1155/base/ERC1155Base.sol";
import {TribalRegistryInternal, TribalRegistryStorage, TribalData} from "./TribalRegistryInternal.sol";

struct TribalMember {
    string name;
    uint256 dob;
    string location;
    string usGovernmentName;
    string sex;
    string[] languages;
    string imageCID;
    uint256 tribalNumber;
    address[] tribalAffiliations;
}

struct TribalMembershipStorage {
    mapping(uint256 => mapping(address => TribalMember)) members;
    uint256 totalMembers;
    bool initialized;
}

library LibTribalMembership {
    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.tribal-membership.storage");

    function diamondStorage() internal pure returns (TribalMembershipStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

contract TribalMembershipInternal is ERC1155Base, ERC1155Meta, TribalRegistryInternal {
    modifier onlyChief(uint256 tribeId) {
        require(LibMeta.msgSender() == _getTribe(tribeId).chief, "Unauthorized");
        _;
    }

    modifier onlyInitialized() {
        require(_tribalMemberStore().initialized, "Contract not initialized");
        _;
    }
    function _tribalMemberStore() internal pure returns (TribalMembershipStorage storage store) {
        store = LibTribalMembership.diamondStorage();
    }
        /**
     * @dev Initializes the contract
     */
    function _initializeTribalMemebrship() external {
        require(!_tribalMemberStore().initialized, "Contract already initialized");
        _tribalMemberStore().initialized = true;
    }

}

contract TribalMembership is TribalMembershipInternal {
    /**
     * @dev Registers a new tribe with the given name and chief address
     * @param name The name of the tribe
     * @param chief The address of the chief or leader of the tribe
     */
    function registerTribe(string memory name, address chief) external {
        _addTribe(name, chief);
    }

    /**
     * @dev Adds tribal documents to a specific tribe
     * @param tribeId The ID of the tribe to add documents to
     * @param cid The CID of the document on IPFS
     * @param fileName The name of the document
     * @param hash The hash value of the document
     */
    function addTribalDocs(
        uint256 tribeId,
        string memory cid,
        string memory fileName,
        bytes memory hash
    ) external onlyChief(tribeId) {
        _addTribalDocs(tribeId, cid, fileName, hash);
    }

    /**
     * @dev Retrieves the details of a specific tribe
     * @param tribeId The ID of the tribe to retrieve details for
     * @return name The name of the tribe
     * @return chief The address of the chief or leader of the tribe
     * @return tribalDocs An array of document IDs associated with the tribe
     * @return registrationTimestamp The timestamp of when the tribe was registered
     */
    function getTribe(uint256 tribeId)
        external
        view
        returns (
            string memory name,
            address chief,
            uint256[] memory tribalDocs,
            uint256 registrationTimestamp
        )
    {
        TribalData memory tribe = _getTribe(tribeId);

        name = tribe.name;
        chief = tribe.chief;
        tribalDocs = tribe.tribalDocs;
        registrationTimestamp = tribe.registrationTimestamp;
    }

    /**
     * @dev Retrieves the total number of registered tribes
     * @return totalTribes The total number of registered tribes
     */
    function getTotalTribes() external view returns (uint256 totalTribes) {
        totalTribes = _tribalRegStore().totalTribes;
    }

    /**
     * @dev Registers a member of a tribe with their identification information
     * @param tribeId The ID of the tribe the member belongs to
     * @param memberAddress The address of the member
     * @param name The name of the member
     * @param dob The date of birth of the member
     * @param location The location of the member
     * @param usGovernmentName The US government name of the member
     * @param sex The gender/sex of the member
     * @param languages The languages spoken by the member
     * @param imageCID The CID of the member's image on IPFS
     * @param tribalNumber The unique tribal number assigned to the member
     * @param tribalAffiliations The addresses of the member's tribal affiliations
     */
    function registerMember(
        uint256 tribeId,
        address memberAddress,
        string memory name,
        uint256 dob,
        string memory location,
        string memory usGovernmentName,
        string memory sex,
        string[] memory languages,
        string memory imageCID,
        uint256 tribalNumber,
        address[] memory tribalAffiliations
    ) external onlyChief(tribeId) {
        _tribalMemberStore().members[tribeId][memberAddress] = TribalMember({
            name: name,
            dob: dob,
            location: location,
            usGovernmentName: usGovernmentName,
            sex: sex,
            languages: languages,
            imageCID: imageCID,
            tribalNumber: tribalNumber,
            tribalAffiliations: tribalAffiliations
        });
    }

    /**
     * @dev Retrieves the information of a member in a tribe
     * @param tribeId The ID of the tribe the member belongs to
     * @param memberAddress The address of the member
     * @return name The name of the member
     * @return dob The date of birth of the member
     * @return location The location of the member
     * @return usGovernmentName The US government name of the member
     * @return sex The gender/sex of the member
     * @return languages The languages spoken by the member
     * @return imageCID The CID of the member's image on IPFS
     * @return tribalNumber The unique tribal number assigned to the member
     * @return tribalAffiliations The addresses of the member's tribal affiliations
     */
    function getMember(uint256 tribeId, address memberAddress)
        external
        view
        returns (
            string memory name,
            uint256 dob,
            string memory location,
            string memory usGovernmentName,
            string memory sex,
            string[] memory languages,
            string memory imageCID,
            uint256 tribalNumber,
            address[] memory tribalAffiliations
        )
    {
        TribalMember memory member = _tribalMemberStore().members[tribeId][memberAddress];

        name = member.name;
        dob = member.dob;
        location = member.location;
        usGovernmentName = member.usGovernmentName;
        sex = member.sex;
        languages = member.languages;
        imageCID = member.imageCID;
        tribalNumber = member.tribalNumber;
        tribalAffiliations = member.tribalAffiliations;
    }
}
