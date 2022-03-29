// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

interface IM4mNFTRegistry {

    enum AttrName{STYLE, HAIR, COMPLEXION, UPPER, LOWER, SHOES_AND_SOCKS, EARRINGS, NECKLACE, GLASS, BACKEND_ENV,
        FRONTEND_ENV}

    function attrTokenIds(AttrName attrName) external view returns (uint[] memory tokenIds);

    function attrTokenIdEnabled(AttrName attrName, uint tokenId) external view returns (bool enabled);

    function m4mNFT() external view returns (address);

    function addComponent(uint tokenId, AttrName attrName, string memory name, string memory symbol,
        string memory value) external;

    function splitM4mNFT(uint tokenId) external;

    function assembleM4mNFT(uint tokenId) external;

    function assembleM4mNFT(uint style, uint hair, uint complexion, uint upper, uint lower, uint shoesAndSocks,
        uint earrings, uint necklace, uint glass, uint backendEnv, uint frontendEnv) external;
}
