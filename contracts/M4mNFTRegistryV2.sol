// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import './M4mNFTRegistry.sol';
import "./interfaces/IM4mNFTRegistryV2.sol";

contract M4mNFTRegistryV2 is M4mNFTRegistry, IM4mNFTRegistryV2 {

    address public override m4mBaggage;

    function initialize(address baggage) public reinitializer(2) {
        m4mBaggage = baggage;
    }

    function mintLoot(address to, uint[]memory componentIds, uint[]memory amounts) public override {
        require(msg.sender == m4mBaggage, 'only baggage');
        components.mintBatch(to, componentIds, amounts);
    }
}
