// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IResPublicaAsset is IERC20 {
    function mint(address recipient, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address from, uint256 amount) external;

    function isMinter() external returns (bool);

    function minter() external view returns (address);
}

interface IResPublicaCash is IResPublicaAsset {
    function globalBurnRate() external view returns (uint);

    function globalTaxRate() external view returns (uint);

    function spend(address sender, address recipient, uint amount, uint burnRate) external;
}