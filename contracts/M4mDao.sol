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

    /* events */
    event SetConvertibleList(IERC721 nft, bool enabled);

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
        m4mNFT.mint(msg.sender);
    }
}
