// SPDX-License-Identifier: FRAKTAL-PROTOCOL
pragma solidity 0.8.18;


/******************************************************************************\
* Author: Kryptokajun <kryptokajun@proton.me> (https://twitter.com/kryptokajun1)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import {LibDiamond} from "../../shared/libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../../shared/interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../../shared/interfaces/IDiamondCut.sol";
import { IERC173 } from "../../shared/interfaces/IERC173.sol";
import { IERC165 } from "../../shared/interfaces/IERC165.sol";
import { IWETH } from "../../shared/interfaces/IWETH.sol";
import { AppStore } from "../AppStore.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

contract DiamondInit {
    AppStore internal s;
    // You can add parameters to this function in order to pass in
    // data to set your own state variables
    function init(address _weth) external {
        
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        
        // add your own state variables 
        s.WETH = IWETH(_weth);

        // EIP-2535 specifies that the `diamondCut` function takes two optional 
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface 
    }


}
