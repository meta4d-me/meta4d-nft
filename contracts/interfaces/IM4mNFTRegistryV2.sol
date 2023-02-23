// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import './IM4mNFT.sol';
import './IM4mComponents.sol';
import "./IM4mNFTRegistry.sol";

/// @notice integrate with m4m baggage
interface IM4mNFTRegistryV2 is IM4mNFTRegistry {
    function m4mBaggage() external view returns (address);

    function mintLoot(address to, uint[]memory componentIds, uint[]memory amounts) external;
}
