// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import { LibMeta } from "../../../libraries/LibMeta.sol";
// import { AccessControlInternal } from "../../../facets/AccessControl/AccessControl/AccessControlInternal.sol";
// import { AccessControlModifiers } from "../../../facets/AccessControl/AccessControl/AccessControlModifiers.sol";
// import { LibAccessControl, AccessControlStorage } from "../../../libraries/LibAccessControl.sol";
import { ERC20BaseStorage, LibERC20Base } from "../LibERC20.sol";

struct ERC20MintBurnStorage {
    bool ERC20_MINT_BURN_INIT;
}

library LibERC20MintBurn {

    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.ERC20MintBurn.storage");

    /**
     * @dev Returns the ERC20 mint/burn storage struct
     * @return ds ERC20 mint/burn storage struct
     */
    function diamondStorage() internal pure returns (ERC20MintBurnStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

}
