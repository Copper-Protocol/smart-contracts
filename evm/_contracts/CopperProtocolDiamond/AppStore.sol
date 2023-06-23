// SPDX-License-Identifier: FRAKTAL-PROTOCOl
pragma solidity 0.8.8;

import {IWETH} from './interfaces/IWETH.sol';
import {IERC20} from './interfaces/IERC20.sol';
// import {IERC1155} from './interfaces/IERC1155.sol';

library LibAppStore {

}

struct AppStore {
  string VERSION;
  IWETH WETH;
  address owner;
  // IERC1155 daoNFT;
}