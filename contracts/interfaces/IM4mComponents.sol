// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol';

import './IM4mNFTRegistry.sol';

interface IM4mComponents is IERC1155Upgradeable {

    function registry() external view returns (IM4mNFTRegistry);

    function name(uint tokenId) external view returns (string memory);

    function symbol(uint tokenId) external view returns (string memory);

    function attrValue(uint tokenId) external view returns (string memory);

    function totalSupply(uint tokenId) external view returns (uint);

    function prepareNewToken(uint tokenId, string memory name, string memory symbol, string memory attrValue) external;

    function mint(address to, uint tokenId, uint amount) external;

    function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) external;

    function burn(address account, uint256 id, uint256 value) external;

    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) external;
}
