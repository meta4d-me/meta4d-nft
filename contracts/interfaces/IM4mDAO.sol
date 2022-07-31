// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

interface IM4mDAO {

    function convertibleList(IERC721 nft) external view returns (bool);

    function setConvertibleList(IERC721 nft, bool enabled) external;
}
