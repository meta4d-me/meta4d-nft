// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import './IM4mNFT.sol';
import './IM4mComponents.sol';

interface IM4mNFTRegistry {

    function dao() external view returns (IM4mDAO);

    function m4mNFT() external view returns (IM4mNFT);

    function components() external view returns (IM4mComponents);

    function operator() external view returns (address);

    enum TokenStatus{NotExist, Initialized, Redeemed}
    function getSplitToken(uint tokenId) external view returns (TokenStatus, bytes32);

    function getSplitTokenComponentAmount(uint componentId) external view returns (uint);

    /// @param m4mTokenId m4mTokenId
    /// @param user user
    /// @param nft the original nft will be converted
    /// @param originalTokenId originalTokenId
    function convertRecord(uint m4mTokenId, address user, IERC721 nft, uint originalTokenId) external view returns (bool);

    function convertNFT(IERC721 original, uint tokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) external;

    function splitM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts) external;

    function assembleM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts) external;

    function redeem(IERC721 origin, uint tokenId, uint m4mTokenId, uint[]memory componentIds, uint[]memory amounts) external;
}
