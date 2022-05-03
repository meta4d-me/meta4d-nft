// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

import './IM4mNFTRegistry.sol';
import './IM4mDAO.sol';

interface IM4mNFT is IERC721Upgradeable {

    function registry() external view returns (IM4mNFTRegistry);

    function dao() external view returns (IM4mDAO);

    function burn(uint256 tokenId) external;

    /// @notice mint a NFT with randomness attribute
    function mint(address to) external returns (uint tokenId);

    function mintByRegistry(address to) external returns (uint tokenId);

    function mintBatch(address to, uint num) external returns (uint tokenId);

    function mintBatch(address[] memory to, uint num) external returns (uint tokenId);
}
