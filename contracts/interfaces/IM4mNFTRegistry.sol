// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

interface IM4mNFTRegistry {

    function operator() external view returns (address);

    function m4mNFT() external view returns (address);

    function splitM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) external;

    function assembleOriginalM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) external;

    function assembleM4mNFT(uint[]memory componentIds, uint[]memory amounts, bytes memory sig) external;
}
