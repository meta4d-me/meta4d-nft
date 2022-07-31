// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

import './interfaces/IM4mDAO.sol';

contract M4mDao is OwnableUpgradeable, IM4mDAO {

    /// @notice NFT that can be converted to M4mNFT
    mapping(IERC721 => bool) public override convertibleList;

    event SetConvertibleList(IERC721 nft, bool enabled);

    function initialize() public initializer {
        __Ownable_init_unchained();
    }

    function setConvertibleList(IERC721 nft, bool enabled) public override onlyOwner {
        convertibleList[nft] = enabled;
        emit SetConvertibleList(nft, enabled);
    }
}
