// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

import './interfaces/IM4mDAO.sol';
import './interfaces/IM4mNFT.sol';

contract M4mDao is OwnableUpgradeable, ERC721HolderUpgradeable, IM4mDAO {

    /// @notice NFT that can be converted to M4mNFT
    mapping(IERC721 => bool) public override convertibleList;

    IM4mNFT public override m4mNFT;

    mapping(uint => mapping(address => mapping(IERC721 => mapping(uint => bool)))) public override convertRecord;

    /* events */
    event SetConvertibleList(IERC721 nft, bool enabled);
    event ConvertToM4mNFT(address owner, IERC721 origin, uint tokenId, uint m4mTokenId);
    event Redeem(address owner, IERC721 origin, uint tokenId, uint m4mTokenId);

    function initialize(IM4mNFT _m4mNFT) public initializer {
        __Ownable_init_unchained();
        __ERC721Holder_init_unchained();
        m4mNFT = _m4mNFT;
    }

    function setConvertibleList(IERC721 nft, bool enabled) public override onlyOwner {
        convertibleList[nft] = enabled;
        emit SetConvertibleList(nft, enabled);
    }

    function convertToM4mNFT(IERC721 origin, uint tokenId) public override {
        origin.safeTransferFrom(msg.sender, address(this), tokenId);
        uint m4mTokenId = m4mNFT.mint(msg.sender);
        convertRecord[m4mTokenId][msg.sender][origin][tokenId] = true;
        emit ConvertToM4mNFT(msg.sender, origin, tokenId, m4mTokenId);
    }

    function redeem(uint m4mTokenId, IERC721 origin, uint tokenId) public override {
        require(convertRecord[m4mTokenId][msg.sender][origin][tokenId], 'no record');
        origin.safeTransferFrom(address(this), msg.sender, tokenId);
        m4mNFT.burn(tokenId);
        convertRecord[m4mTokenId][msg.sender][origin][tokenId] = false;
        emit Redeem(msg.sender, origin, tokenId, m4mTokenId);
    }
}
