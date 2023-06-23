// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {LibMeta} from "../../libraries/LibMeta.sol";
import {LibVault} from "../../libraries/LibVault.sol";

contract VaultModifiers {

    modifier onlyToken(address _token) {
        require(address(LibVault.diamondStorage().token) == _token, "Vault: invalid token");
        _;
    }

}


