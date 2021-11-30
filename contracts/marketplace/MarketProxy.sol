// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1967Proxy} from '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol';
import './MarketState.sol';

/// @notice instead of using the admin at ERC1967Proxy, we use the owner at MarketState.Ownable for the convenience
contract MarketProxy is MarketState, ERC1967Proxy {

    constructor(address _logic, bytes memory data, IRPCRouter router, IERC20 rpc)
    ERC1967Proxy(_logic, data) MarketState(router, rpc){
    }

    function updateTo(address newImplementation) public onlyOwner {
        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) public onlyOwner {
        _upgradeToAndCall(newImplementation, data, forceCall);
    }

    function upgradeToAndCallSecure(address newImplementation, bytes memory data, bool forceCall) public onlyOwner {
        _upgradeToAndCallSecure(newImplementation, data, forceCall);
    }

    function implementation() public view returns (address){
        return _implementation();
    }
}