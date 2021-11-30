// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "hardhat/console.sol";
import {ERC20, ERC20Burnable} from '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

// Res Publica Cash
// only treasury could mint
contract MockRPC is ERC20Burnable, Ownable {

    uint public globalBurnRate;
    uint public globalTaxRate;
    address public taxTo;

    constructor() ERC20('Res Publica Cash', 'RPC') Ownable() {
        // 2%
        globalBurnRate = 2e16;
        // 1.5%
        globalTaxRate = 15e15;
        taxTo = msg.sender;

        _mint(_msgSender(), 50000000000 * (10 ** decimals()));
    }

    // Ensure consistency with real RPC
    function spend(address sender, address recipient, uint amount, uint burnRate) public returns (bool){
        if (amount == 0) {
            return true;
        }
        if (burnRate == 0) {
            burnRate = globalBurnRate;
        } else {
            require(burnRate >= globalBurnRate, 'lower burnRate');
        }
        uint burnAmount = amount * burnRate / 1e18;
        super.burnFrom(sender, burnAmount);
        amount -= burnAmount;
        if (amount == 0) {
            return true;
        }
        if (taxTo != recipient && globalTaxRate > 0) {
            uint tax = amount * globalTaxRate / 1e18;
            if (tax > 0) {
                /// @notice RPC.transfer only returns true or revert, so we don't need to check return value
                transferFrom(sender, taxTo, tax);
                amount -= tax;
            }
        }
        transferFrom(sender, recipient, amount);
        return true;
    }
}
