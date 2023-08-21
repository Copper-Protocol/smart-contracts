
import {LibMeta} from "../../libraries/LibMeta.sol";
import {AccessControlInternal} from "../../facets/AccessControl/AccessControl/AccessControlInternal.sol";
import {AccessControlModifiers} from "../../facets/AccessControl/AccessControl/AccessControlModifiers.sol";
import {LibAccessControl, AccessControlStorage} from "../../libraries/LibAccessControl.sol";

import {IERC165} from "../../interfaces/IERC165.sol";
import {IERC173} from "../../interfaces/IERC173.sol";

import {ERC20BaseStorage, LibERC20Base} from "./LibERC20.sol";

contract ERC20BaseModifiers {

    // Modifier to restrict access to only the admin
    modifier onlyAdmin() {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();

        require(acl.hasAdminRole(LibMeta.msgSender()), "Only admin can call this function");
        _;
    }

    // Modifier to restrict access to only minters
    modifier onlyMinter() {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        require(acl.hasRole(AccessControlModifiers.acl.ROLE_COPPER_MINTER, LibMeta.msgSender()), "Only minter can call this function");
        _;
    }

    // Modifier to restrict access to only burners
    modifier onlyBurner() {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        require(acl.hasRole(AccessControlModifiers.acl.ROLE_COPPER_BURNER, LibMeta.msgSender()), "Only burner can call this function");
        _;
    }
    modifier isInitialized () {
        ERC20BaseStorage storage erc20Store = LibAccessControl.diamondStorage();
        require(erc20Store.ERC20_INIT, "NOT INITIALIZED");
        _;
    }
    modifier notInitialized () {
        ERC20BaseStorage storage erc20Store = LibAccessControl.diamondStorage();
        require(!erc20Store.ERC20_INIT, "ALREADY INITIALIZED");
        _;
    }
}
