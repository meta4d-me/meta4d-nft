// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

// @dev manage all kinds of components

contract M4mComponentsRegistry is OwnableUpgradeable {

    // mapping source attribute to tokenId
    mapping(string => mapping(string => uint)) public source;

    // mapping metadata attribute to tokenId
    mapping(string => mapping(string => uint)) public metadata;

    function initialize() public initializer {
        __Ownable_init_unchained();

        source['style']['2D'] = 1;
        source['style']['3D'] = 2;

        metadata['appearance']['hair'] = 3;
        metadata['appearance']['complexion'] = 4;
        metadata['clothing']['upper'] = 5;
        metadata['clothing']['lower'] = 6;
        metadata['clothing']['shoesAndSocks'] = 7;
        metadata['ornament']['tattoo'] = 8;
        metadata['ornament']['earrings'] = 9;
        metadata['ornament']['necklace'] = 10;
        metadata['ornament']['glass'] = 11;
        metadata['environment']['backend'] = 12;
        metadata['environment']['frontend'] = 13;
    }

    function sourceAvailable(string memory arg1, string memory arg2) public view returns (bool){
        return source[arg1][arg2] > 0;
    }

    function metadataAvailable(string memory arg1, string memory arg2) public view returns (bool){
        return metadata[arg1][arg2] > 0;
    }
}
