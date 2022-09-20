// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import './IM4mNFT.sol';
import './IM4mComponents.sol';

interface IM4mNFTRegistry {

    function dao() external view returns (IM4mDAO);

    function m4mNFT() external view returns (IM4mNFT);

    function components() external view returns (IM4mComponents);

    function operator() external view returns (address);

    enum TokenStatus{NotExist, Initialized, Locked, Redeemed}
    function getTokenStatus(uint tokenId) external view returns (TokenStatus, bytes32, IERC721, uint);

    function getTokenComponentAmount(uint tokenId, uint componentId) external view returns (uint);

    function getTokenComponentAmounts(uint tokenId, uint[] memory componentIds) external view returns (uint[] memory);

    function convertNFT(IERC721 original, uint tokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) external;

    function splitM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts) external;

    function assembleM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts) external;

    function redeem(uint m4mTokenId, uint[]memory componentIds, uint[]memory amounts) external;

    function claimLoot(uint[]memory componentIds, uint[]memory amounts, bytes memory sig) external;

    function lock(uint tokenId) external;

    function unlock(uint tokenId) external;
}
