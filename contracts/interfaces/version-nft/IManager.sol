// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

interface IManager {
    struct Token {
        uint chainId;
        address nft;
        uint tokenId;
    }

    /// creator is msg.sender
    function setInfo(Token memory token, string memory uri) external;

    function getInfo(Token memory token, address creator) external view returns (string memory);

    function getLatestInfoAll(Token memory token) external view returns (address[] memory creators, string[] memory uris);
}

interface IManagerV2 is IManager {
    /// creator is signer
    function setInfoByPermit(Token memory token, string memory uri, bytes memory sig) external;
}
