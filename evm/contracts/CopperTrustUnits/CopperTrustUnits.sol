// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import { ERC20Base } from "../shared/facets/ERC20/ERC20Base.sol";
import { ERC20Meta } from "../shared/facets/ERC20/meta/ERC20Meta.sol";
import { ERC20Capped } from "../shared/facets/ERC20/extension/ERC20Capped.sol";
import { ERC20MintBurn } from "../shared/facets/ERC20/extension/ERC20MintBurn.sol";
import { ERC20BaseInternal } from "../shared/facets/ERC20/ERC20BaseInternal.sol";
import { ERC20CappedInternal } from "../shared/facets/ERC20/extension/ERC20CappedInternal.sol";

contract CopperTrustUnits is ERC20Base, ERC20MintBurn, ERC20Meta, ERC20Capped {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint8 decimals,
        uint256 cap,
        address[] memory minters,
        address[] memory burners
    ) {
        _initialize(initialSupply, decimals);
        _initERC20Meta(name, symbol);
        _initERC20Capped(cap);
        _initializeERC20MintBurn(minters, burners);

    }
    function _beforeTransfer() internal virtual override(ERC20BaseInternal, ERC20CappedInternal) {
        super._beforeTransfer();
    }
    function transfer (address to, uint256 value) external virtual override(ERC20Base, ERC20Capped) returns (bool) {
        return ERC20Capped(address(this)).transfer(to, value);
    }
    function version () external pure returns (string memory) {
        return '0.0.1';
    }
}