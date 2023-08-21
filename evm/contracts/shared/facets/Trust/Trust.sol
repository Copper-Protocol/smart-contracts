// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import { IERC20 } from "../../interfaces/IERC20.sol";
import { TrustInternal } from "./TrustInternal.sol";
import { IDocumentRegistry } from "../../interfaces/IDocumentRegistry.sol";
import { LibMeta } from "../../libraries/LibMeta.sol";
import { TrusteeData } from "./LibTrust.sol";

/**
 * @title Trust
 * @dev Contract that represents a private trust.
 */
contract Trust is TrustInternal {
  constructor () {
    _trustStore().owner = deployer;
  }
    /**
     * @dev Initializes the Trust contract.
     * @param _beneficialInterestUnits The ERC20 token contract representing the beneficial interest units.
     * @param _trusteeAcceptanceString The trustee acceptance string.
     * @param _documentRegistry The address of the document registry contract.
     */

    function initialize(
        IERC20 _beneficialInterestUnits,
        bytes calldata _trusteeAcceptanceString,
        IDocumentRegistry _documentRegistry,
        address[] calldata _grantors,
        address[] calldata _trustees
    ) external onlyDeployer {
      _initialize(
        _beneficialInterestUnits,
        _trusteeAcceptanceString,
        _documentRegistry,
        _grantors
      );

      _setInitialTrustees (_trustees);
    }
    /**
     * @dev Adds a trustee to the trust.
     * @param _trustee The address of the trustee to add.
     */
    function addTrustee(
        address _trustee
    ) external onlyNotAcceptedTrustee {
        _addTrustee(_trustee);
        emit TrusteeAdded(_trustee);
    }

    /**
     * @dev Revokes a trustee from the trust.
     * @param _trustee The address of the trustee to revoke.
     */
    function revokeTrustee(address _trustee) external onlyDeployer {
        require(!_isTrusteeRevoked(_trustee), "Trustee already revoked");
        _revokeTrustee(_trustee);
        emit TrusteeRevoked(_trustee);
    }

    /**
     * @dev Declines the trust position.
     */
    function declineTrustee() external onlyNotAcceptedTrustee {
        _declineTrustee(msg.sender);
        emit TrusteeDeclined(msg.sender);
    }

    /**
     * @dev Accepts the trust position.
     */
    function acceptTrustee() external onlyNotAcceptedTrustee {
        _acceptTrustee(msg.sender);
        emit TrusteeAccepted(msg.sender);
    }

    function getAllTrustees () external view returns(TrusteeData[] memory trustees) {
      trustees = _getAllTrustees ();
    }
    function getTrusteeData(address _trustee) external view returns(TrusteeData memory trustee) {
      trustee = _getTrusteeData(_trustee);
    }
}
