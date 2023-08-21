// SPDX-License-Identifier: FRAKTAL-PROTOCOL
pragma solidity 0.8.8;
pragma abicoder v2;

import { IERC20 } from '../../interfaces/IERC20.sol';
import { IWETH } from '../../interfaces/IWETH.sol';
import {AppStore} from '../../AppStore.sol';
import {LibMeta} from '../../libraries/LibMeta.sol';
import {LibMultiSigWallet} from "../../libraries/LibMultiSigWallet.sol";
import {LibAccessControl} from "../../libraries/LibAccessControl.sol";
import {AccessControlModifiers} from "../../facets/AccessControlModifiers.sol";

contract MultiCallInternal {
    // AppStore internal s;
    // address private owner;
    // address private executor;
    // IWETH private WETH;

    modifier onlyExecutor() {
        require(LibMeta.msgSender() == s.executor);
        _;
    }

    modifier onlyOwner() {
        require(LibMeta.msgSender() == s.owner);
        _;
    }

    function _init(address _executor) public payable {

        s.owner = LibMeta.msgSender();
        // s.WETH = IWETH(_weth);
        s.executor = _executor;
        if (msg.value > 0) {
            s.WETH.deposit{value: msg.value}();
        }
    }

    // function _uniswapWeth(uint256 _wethAmountToFirstMarket, uint256 _ethAmountToCoinbase, address[] memory _targets, bytes[] memory _payloads) internal onlyExecutor {
    //     require (_targets.length == _payloads.length);
    //     uint256 _wethBalanceBefore = IERC20(address(s.WETH)).balanceOf(address(this));
    //     s.WETH.transfer(_targets[0], _wethAmountToFirstMarket);
    //     for (uint256 i = 0; i < _targets.length; i++) {
    //         (bool _success, bytes memory _response) = _targets[i].call(_payloads[i]);
    //         require(_success); _response;
    //     }

    //     uint256 _wethBalanceAfter = IERC20(address(s.WETH)).balanceOf(address(this));
    //     require(_wethBalanceAfter > _wethBalanceBefore + _ethAmountToCoinbase);
    //     if (_ethAmountToCoinbase == 0) return;

    //     uint256 _ethBalance = address(this).balance;
    //     if (_ethBalance < _ethAmountToCoinbase) {
    //         s.WETH.withdraw(_ethAmountToCoinbase - _ethBalance);
    //     }
    //     block.coinbase.transfer(_ethAmountToCoinbase);
    // }

    function _call(address payable _to, uint256 _value, bytes memory _data) internal onlyOwner 
    returns (bytes memory result, bool success) {
        require(_to != address(0));
        (success, result) = _to.call{value: _value}(_data);
    }

    function _multiCall (address[] memory _recipients, uint256[] memory values, bytes[] memory _data)
    internal returns (bytes[] memory results, bool[] memory success){
        require(_recipients.length == values.length, 'MISMATCH LENGTHS');
        require(_data.length == values.length, 'MISMATCH LENGTHS');
        results = new bytes[](_recipients.length);
        uint i = 0;
        for (i; i < _recipients.length;i++) {
            // results[i] = _call(payable(_recipients[i]), values[i], _data[i]);
            (results[i], success[i]) = _call(payable(_recipients[i]), values[i], _data[i]);
        }
    }
}
