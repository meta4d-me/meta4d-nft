// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import "./M4mComponent.sol";
import './interfaces/IM4mComponentsV2.sol';

contract M4mComponentV2 is M4mComponent, IM4mComponentsV2 {

    address public baggage;

    function initializeV2(address _baggage) public reinitializer(2) {
        baggage = _baggage;
    }

    function prepareAndMint(address to, PrepareAndMintParam[] memory params) public override {
        require(msg.sender == baggage, 'only baggage');
        uint[] memory tokenIds = new uint[](params.length);
        uint[] memory amounts = new uint[](params.length);
        for (uint i = 0; i < params.length; i++) {
            PrepareAndMintParam memory param = params[i];
            if (param.prepare) {
                _prepareNewToken(param.tokenId, param.name, param.symbol);
            } else {
                checkInit(param.tokenId);
            }
            totalSupply[param.tokenId] += param.amount;
            tokenIds[i] = param.tokenId;
            amounts[i] = param.amount;
        }
        _mintBatch(to, tokenIds, amounts, '');
    }
}
