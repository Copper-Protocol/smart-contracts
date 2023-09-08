// SPDX-License: COPPER-PROTOCOL
pragma solidity 0.8.18;

import {LibMeta} from "../shared/libraries/LibMeta.sol";
import {ERC1155BaseInternal} from "../shared/facets/ERC1155/base/ERC1155BaseInternal.sol";
import {ERC1155MetaInternal} from "../shared/facets/ERC1155/meta/ERC1155MetaInternal.sol";
import {IERC20} from "../shared/interfaces/IERC20.sol";

struct Bond {
    address issuer;
    uint256 principalAmount;
    uint256 interestRate; // In basis points (e.g., 500 for 5%)
    uint256 maturityDate;
    bool redeemed;
}

struct CopperBondsStorage {
    mapping(uint256 => Bond) bonds;
    uint256 bondCounter;

    IERC20 bondToken; // The ERC-20 token representing bonds
}

library LibCopperBonds {
    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.copper-bonds.storage");

    function diamondStorage() internal pure returns (CopperBondsStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}


contract CopperBondsInternal is ERC1155BaseInternal {
    event BondIssued(uint256 bondId, address issuer, uint256 principalAmount, uint256 interestRate, uint256 maturityDate);

    function _internal(address _bondTokenAddress) internal {
        CopperBondsStorage storage s = LibCopperBonds.diamondStorage();
        s.bondToken = IERC20(_bondTokenAddress);
    }

    function _issueBond(uint256 _principalAmount, uint256 _interestRate, uint256 _maturityDate) internal returns (uint256) {
        CopperBondsStorage storage s = LibCopperBonds.diamondStorage();
        s.bondCounter++;
        uint256 bondId =s.bondCounter; // Assign a unique bond ID for each bond
        s.bonds[bondId] = Bond(LibMeta.msgSender(), _principalAmount, _interestRate, _maturityDate, false);

        // Mint an ERC-1155 Bond Token representing the bond instance
        _mint(LibMeta.msgSender(), bondId, 1, "");

        s.bondToken.transferFrom(LibMeta.msgSender(), address(this), _principalAmount); // Lock bond amount as collateral
        emit BondIssued(bondId, LibMeta.msgSender(), _principalAmount, _interestRate, _maturityDate);
        return bondId;
    }

    // Function to get bond details by ID
    function _getBondDetails(uint256 _bondId) internal view returns (Bond memory) {
            CopperBondsStorage storage s = LibCopperBonds.diamondStorage();
            return s.bonds[_bondId];
    }
}