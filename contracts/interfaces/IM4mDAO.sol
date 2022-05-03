// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './IM4mNFT.sol';

interface IM4mDAO {

    function m4mNFT() external view returns (IM4mNFT);

    function convertibleList(IERC721 nft) external view returns (bool);

    /// @param m4mTokenId m4mTokenId
    /// @param user user
    /// @param nft the original nft will be converted
    /// @param originalTokenId originalTokenId
    function convertRecord(uint m4mTokenId, address user, IERC721 nft, uint originalTokenId) external view returns (bool);

    function setConvertibleList(IERC721 nft, bool enabled) external;

    function convertToM4mNFT(IERC721 origin, uint tokenId) external;

    function redeem(uint m4mTokenId, IERC721 origin, uint tokenId) external;
}
