// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol';
import "./IM4mComponents.sol";

interface IM4mComponentsV2 is IM4mComponents {

    function baggage() external view returns (address);

    struct PrepareAndMintParam {
        uint tokenId;
        bool prepare;
        string name;
        string symbol;
        uint amount;
    }

    function prepareAndMint(address to, PrepareAndMintParam[] memory params) external;
}
