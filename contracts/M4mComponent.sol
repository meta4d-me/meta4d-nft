// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

contract M4mComponent is ERC1155Upgradeable, OwnableUpgradeable {

    function initialize(string memory uri) public initializer  {
        __ERC1155_init_unchained(uri);
        __Ownable_init_unchained();
    }
}
