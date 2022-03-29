// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

// @dev manage all kinds of components

contract M4mComponentsRegistry is OwnableUpgradeable {

    mapping(string => uint) public attrToTokenId;

    function initialize() public initializer {
        __Ownable_init_unchained();
    }

}
