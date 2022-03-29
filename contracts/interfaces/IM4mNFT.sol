// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';
import './IM4mNFTRegistry.sol';

interface IM4mNFT is IERC721Upgradeable {

    /* attribute function */
    /// @notice these function should return corresponding tokenId at M4mComponents
    function getStyle(uint tokenId) external view returns (uint);

    function getHair(uint tokenId) external view returns (uint);

    function getComplexion(uint tokenId) external view returns (uint);

    function getUpper(uint tokenId) external view returns (uint);

    function getLower(uint tokenId) external view returns (uint);

    function getShoesAndSocks(uint tokenId) external view returns (uint);

    function getEarrings(uint tokenId) external view returns (uint);

    function getNecklace(uint tokenId) external view returns (uint);

    function getGlass(uint tokenId) external view returns (uint);

    function getBackendEnv(uint tokenId) external view returns (uint);

    function getFrontendEnv(uint tokenId) external view returns (uint);

    function registry() external view returns (IM4mNFTRegistry);

    /// @notice mint a NFT with randomness attribute
    function mint(address to) external returns (uint tokenId);

    function mintByRegistry(address to, uint style, uint hair, uint complexion, uint upper, uint lower,
        uint shoesAndSocks, uint earrings, uint necklace, uint glass, uint backendEnv, uint frontendEnv)
    external returns (uint tokenId);

    function mintByOwner(address to, uint style, uint hair, uint complexion, uint upper, uint lower,
        uint shoesAndSocks, uint earrings, uint necklace, uint glass, uint backendEnv, uint frontendEnv)
    external returns (uint tokenId);
}
