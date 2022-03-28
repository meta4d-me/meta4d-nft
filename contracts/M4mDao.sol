// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol';

contract M4mDao is OwnableUpgradeable, ERC721HolderUpgradeable {

    function initialize() public initializer  {
        __Ownable_init_unchained();
        __ERC721Holder_init_unchained();
    }
}
