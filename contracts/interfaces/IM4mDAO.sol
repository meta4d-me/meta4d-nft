// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './IM4mNFT.sol';

interface IM4mDAO {

    function m4mNFT() external view returns (IM4mNFT);

    function convertibleList(IERC721 nft) external view returns (bool);

    function setConvertibleList(IERC721 nft, bool enabled) external;

    function convertToM4mNFT(IERC721 origin, uint tokenId) external;
}
