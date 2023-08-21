// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import { IERC20 } from "../../interfaces/IERC20.sol";
import { AccessControlInternal } from "../AccessControl/AccessControl/AccessControlInternal.sol";
import { IDocumentRegistry } from "../../interfaces/IDocumentRegistry.sol";
import { LibTrust, TrustStorage } from "./LibTrust.sol";
import { TrusteeData } from "./LibTrust.sol";
import { LibMeta } from "../../libraries/LibMeta.sol";

/**
 * @title TrustInternal
 * @dev Internal contract that implements the core functionality for the private contract.
 */
contract TrustInternal is AccessControlInternal {
    address immutable deployer = msg.sender;
    bytes32 public constant TRUSTEE_ROLE = keccak256("TRUSTEE_ROLE");
    bytes32 public constant TRUSTEE_ADMIN_ROLE = keccak256("TRUSTEE_ADMIN_ROLE");
    bytes32 public constant GRANTOR_ROLE = keccak256("GRANTOR_ROLE");

    /**
     * @dev Event emitted when a trustee is added to the trust.
     * @param trustee The address of the trustee added.
     */
    event TrusteeAdded(address indexed trustee);

    /**
     * @dev Event emitted when a trustee is revoked from the trust.
     * @param trustee The address of the trustee revoked.
     */
    event TrusteeRevoked(address indexed trustee);

    /**
     * @dev Event emitted when a trustee declines the trust position.
     * @param trustee The address of the trustee who declined.
     */
    event TrusteeDeclined(address indexed trustee);

    /**
     * @dev Event emitted when a trustee accepts the trust position.
     * @param trustee The address of the trustee who accepted.
     */
    event TrusteeAccepted(address indexed trustee);
    modifier onlyDeployer () {
        require(deployer == LibMeta.msgSender(), "UNAUTHORIZED: NOT DEPLOYER");

        _;
    }
    modifier onlyGrantor() {
        require(_hasRole(GRANTOR_ROLE, LibMeta.msgSender()), "Caller is not a grantor");
        _;
    }

    modifier onlyAcceptedTrustee() {
        require(_isTrusteeAccepted(LibMeta.msgSender()), "Trustee not accepted");
        _;
    }

    modifier onlyNotAcceptedTrustee() {
        require(!_isTrusteeAccepted(LibMeta.msgSender()), "Trustee already accepted");
        _;
    }

    /**
     * @dev Initialize the Trust contract.
     * @param _beneficialInterestUnits The ERC20 token contract representing the beneficial interest units.
     * @param _trusteeAcceptanceString The trustee acceptance string.
     * @param _documentRegistry The address of the document registry contract.
     * @param _grantors The array of grantors.
     */
    function _initialize(
        IERC20 _beneficialInterestUnits,
        bytes calldata _trusteeAcceptanceString,
        IDocumentRegistry _documentRegistry,
        // uint256 _trustDeclaration,
        // uint256 _trustIndenture,
        address[] calldata _grantors
    ) internal {
        require(!LibTrust.diamondStorage().TRUST_INIT, "Trust already initialized");
        _trustStore().beneficialInterestUnits = _beneficialInterestUnits;
        _trustStore().trusteeAcceptanceString = _trusteeAcceptanceString;
        _trustStore().docReg = _documentRegistry;

        // _setTrustDeclaration(_trustDeclaration);
        // _setTrustIndenture(_trustIndenture);

        for (uint256 i = 0; i < _grantors.length; i++) {
            _addGrantor(_grantors[i]);
        }

        _setTrustInit(true);
    }
    function _setInitialTrustees (address[] calldata trustees) internal {
        uint i = 0;
        uint total = trustees.length;
        for (i; i < total; i++) {
            _trustStore().trustees[_trustStore().totalTrustees].trustee = trustees[i];
            _trustStore().totalTrustees++;
        }
    }
    function _owner () internal view returns(address owner_) {
        owner_ = _trustStore().owner;
    }
    /**
     * @dev Internal function to get the trust storage struct.
     * @return trustStore The reference to the trust storage struct.
     */
    function _trustStore() internal pure returns (TrustStorage storage trustStore) {
        trustStore = LibTrust.diamondStorage();
    }

    /**
     * @dev Internal function to get the TrusteeData struct for a given trustee address.
     * @param _trustee The trustee address.
     * @return trusteeData The TrusteeData storage struct for the given trustee.
     */
    function _getTrusteeData(address _trustee) internal view returns (TrusteeData storage trusteeData) {
        uint256 trusteeIndex = _getTrusteeIndex(_trustee);
        return _trustStore().trustees[trusteeIndex];
    }

    /**
     * @dev Internal function to get the index of a trustee in the TrustStorage mapping.
     * @param _trustee The trustee address.
     * @return trusteeIndex The index of the trustee in the TrustStorage mapping.
     */
    function _getTrusteeIndex(address _trustee) internal view returns (uint256 trusteeIndex) {
        for (uint256 i = 0; i < _trustStore().totalTrustees; i++) {
            if (_trustStore().trustees[i].trustee == _trustee) {
                return i;
            }
        }
        revert("Trustee not found");
    }

    /**
     * @dev Internal function to increment the totalTrustees count in TrustStorage.
     */
    function _incrementTotalTrustees() internal {
        _trustStore().totalTrustees++;
    }
    function _getAllTrustees () internal view returns(TrusteeData[] memory trustees) {
        uint i = 0;
        uint totalTrustees = _trustStore().totalTrustees;
        trustees = new TrusteeData[](totalTrustees);

        for (i; i < totalTrustees; i++) {
            trustees[i] = _trustStore().trustees[i];
        }
    }

    /**
     * @dev Internal function to add a trustee to the TrustStorage mapping.
     * @param _trustee The trustee address.
     */
    function _addTrustee(
        address _trustee
        // bytes memory _acceptedSignature,
        // uint256 _acceptanceBlock
    ) internal {
        uint256 trusteeIndex = _trustStore().totalTrustees;
        TrusteeData storage trusteeData = _trustStore().trustees[trusteeIndex];
        trusteeData.trustee = _trustee;
        trusteeData.accepted = false;
        trusteeData.revoked = false;
        trusteeData.declined = false;
        trusteeData.acceptedSignature = "";
        trusteeData.acceptanceBlock = 0;
        _incrementTotalTrustees();
    }

    /**
     * @dev Internal function to revoke a trustee's status in the TrustStorage mapping.
     * @param _trustee The trustee address.
     */
    function _revokeTrustee(address _trustee) internal {
        TrusteeData storage trusteeData = _getTrusteeData(_trustee);
        trusteeData.revoked = true;
    }

    /**
     * @dev Internal function to decline a trustee's position in the TrustStorage mapping.
     * @param _trustee The trustee address.
     */
    function _declineTrustee(address _trustee) internal {
        TrusteeData storage trusteeData = _getTrusteeData(_trustee);
        trusteeData.declined = true;
    }

    /**
     * @dev Internal function to accept a trustee's position in the TrustStorage mapping.
     * @param _trustee The trustee address.
     */
    function _acceptTrustee(address _trustee) internal {
        TrusteeData storage trusteeData = _getTrusteeData(_trustee);
        trusteeData.accepted = true;
    }

    /**
     * @dev Internal function to get the array of approved tokens from TrustStorage.
     * @return approvedTokens The array of approved tokens.
     */
    function _getApprovedTokens() internal view returns (IERC20[] storage approvedTokens) {
        approvedTokens = _trustStore().approvedTokens;
    }

    /**
     * @dev Internal function to add an approved token to the array in TrustStorage.
     * @param _token The token contract address.
     */
    function _addApprovedToken(IERC20 _token) internal {
        _trustStore().approvedTokens.push(_token);
    }

    /**
     * @dev Internal function to remove an approved token from the array in TrustStorage.
     * @param _index The index of the approved token to remove.
     */
    function _removeApprovedToken(uint256 _index) internal {
        require(_index < _trustStore().approvedTokens.length, "Invalid token index");

        if (_index != _trustStore().approvedTokens.length - 1) {
            _trustStore().approvedTokens[_index] = _trustStore().approvedTokens[_trustStore().approvedTokens.length - 1];
        }

        _trustStore().approvedTokens.pop();
    }

    /**
     * @dev Internal function to get the trustee balances for a specific token and spender from TrustStorage.
     * @param _trustee The trustee address.
     * @param _token The token address.
     * @param _spender The spender address.
     * @return balance The trustee balance for the specified token and spender.
     */
    function _getTrusteeBalances(address _trustee, address _token, address _spender) internal view returns (uint256 balance) {
        balance = _trustStore().trusteeBalances[_trustee][_token][_spender];
    }

    /**
     * @dev Internal function to set the trustee balances for a specific token and spender in TrustStorage.
     * @param _trustee The trustee address.
     * @param _token The token address.
     * @param _spender The spender address.
     * @param _balance The balance to set for the trustee, token, and spender.
     */
    function _setTrusteeBalances(
        address _trustee,
        address _token,
        address _spender,
        uint256 _balance
    ) internal {
        _trustStore().trusteeBalances[_trustee][_token][_spender] = _balance;
    }

    /**
     * @dev Internal function to set the initialization status of the trust in TrustStorage.
     * @param _initialized The initialization status to set.
     */
    function _setTrustInit(bool _initialized) internal {
        _trustStore().TRUST_INIT = _initialized;
    }

    /**
     * @dev Internal function to set the trust declaration in TrustStorage.
     * @param _declaration The trust declaration value to set.
     */
    function _setTrustDeclaration(uint256 _declaration) internal {
        _trustStore().trustDeclaration = _declaration;
    }

    /**
     * @dev Internal function to set the trust indenture in TrustStorage.
     * @param _indenture The trust indenture value to set.
     */
    function _setTrustIndenture(uint256 _indenture) internal {
        _trustStore().trustIndenture = _indenture;
    }

    /**
     * @dev Internal function to get the document registry contract from TrustStorage.
     * @return docReg The document registry contract.
     */
    function _getDocumentRegistry() internal view returns (IDocumentRegistry docReg) {
        docReg = _trustStore().docReg;
    }

    /**
     * @dev Internal function to set the document registry contract in TrustStorage.
     * @param _documentRegistry The document registry contract to set.
     */
    function _setDocumentRegistry(IDocumentRegistry _documentRegistry) internal {
        _trustStore().docReg = _documentRegistry;
    }

    /**
     * @dev Internal function to check if a trustee has been revoked in TrustStorage.
     * @param _trustee The trustee address to check.
     * @return revoked A boolean indicating if the trustee has been revoked.
     */
    function _isTrusteeRevoked(address _trustee) internal view returns (bool revoked) {
        TrusteeData storage trusteeData = _getTrusteeData(_trustee);
        revoked = trusteeData.revoked;
    }

    /**
     * @dev Internal function to check if a trustee has accepted the position in TrustStorage.
     * @param _trustee The trustee address to check.
     * @return accepted A boolean indicating if the trustee has accepted the position.
     */
    function _isTrusteeAccepted(address _trustee) internal view returns (bool accepted) {
        TrusteeData storage trusteeData = _getTrusteeData(_trustee);
        accepted = trusteeData.accepted;
    }

    /**
     * @dev Internal function to get the array of grantors from TrustStorage.
     * @return grantors The array of grantors.
     */
    function _getGrantors() internal view returns (address[] memory grantors) {
        grantors = new address[](_trustStore().totalGrantors);
        for (uint256 i = 0; i < _trustStore().totalGrantors; i++) {
            grantors[i] = _trustStore().grantors[i];
        }
    }

    /**
     * @dev Internal function to add a grantor to the TrustStorage mapping.
     * @param _grantor The grantor address.
     */
    function _addGrantor(address _grantor) internal {
        uint256 totalGrantors = _trustStore().totalGrantors;
        _trustStore().grantors[totalGrantors] = _grantor;
        _trustStore().totalGrantors++;
    }
}
