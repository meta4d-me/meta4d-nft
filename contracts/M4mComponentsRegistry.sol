// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

// @dev manage all kinds of components

contract M4mComponentsRegistry is OwnableUpgradeable {

    mapping(string => mapping(string => bool)) public source;

    mapping(string => mapping(string => bool)) public metadata;

    function initialize() public initializer {
        __Ownable_init_unchained();

        source['style']['2D'] = true;
        source['style']['3D'] = true;

        metadata['appearance']['hair'] = true;
        metadata['appearance']['complexion'] = true;
        metadata['clothing']['upper'] = true;
        metadata['clothing']['lower'] = true;
        metadata['clothing']['shoesAndSocks'] = true;
        metadata['ornament']['tattoo'] = true;
        metadata['ornament']['earrings'] = true;
        metadata['ornament']['necklace'] = true;
        metadata['ornament']['glass'] = true;
        metadata['environment']['backend'] = true;
        metadata['environment']['frontend'] = true;
    }

    function sourceAvailable(string memory arg1, string memory arg2) public view returns (bool){
        return source[arg1][arg2];
    }

    function metadataAvailable(string memory arg1, string memory arg2) public view returns (bool){
        return metadata[arg1][arg2];
    }
}
