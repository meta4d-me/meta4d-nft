// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IResPublicaAsset.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {ERC20Burnable} from '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';

//////////////////////
// 1. collect fee from NFT market, and NFT minting
// 2. fee is [RPC](Res Publica Cash)
// 3. administer fee rate of all actions
// 4. use router to charge, users could approve RPC only once for all actions
// 5. payment comprised by [burned, tax, applicationFee, to]
//////////////////////

interface IRPCRouter {
    // return the amount of fee collected
    function spendRPCWithFixedAmountFee(address payer) external returns (uint);

    // return the amount of fee collected and `to` received
    function spendRPCWithFixedRateFee(address payer, address recipient, uint volume) external returns (uint, uint);
}

contract RPCRouter is IRPCRouter, Ownable {
    using SafeERC20 for IERC20;

    IResPublicaCash public RPC;

    struct FeeCfg {
        uint amountOrRate;
        uint burnRate;
        bool initialized;
    }
    /// @dev fee amount is fixed, such as NFT mint
    /// @dev contract => fee config with fixed amount
    mapping(address => FeeCfg) public fixedAmountFee;
    /// @dev fee rate is fixed, such as NFT trading
    /// @dev contract => fee config with fixed rate
    mapping(address => FeeCfg) public fixedRateFee;

    /* event */
    event FixedAmountFeeUpdated(address nft, uint amount, uint burnRate);
    event FixedRateFeeUpdated(address market, uint feeRate, uint burnRate);
    event FeeCollected(address market, address payer, uint amount);
    event WithdrawFee(address feeTo, uint amount);
    event BurnFee(uint amount);

    constructor(IResPublicaCash _RPC){
        RPC = _RPC;
    }

    /* admin functions */

    function setFixedAmountFee(address app, uint amount, uint burnRate) public onlyOwner {
        require(app != address(0), 'illegal application contract');
        require(burnRate >= RPC.globalBurnRate(), 'illegal burn rate');
        fixedAmountFee[app].amountOrRate = amount;
        fixedAmountFee[app].burnRate = burnRate;
        fixedAmountFee[app].initialized = true;
        emit FixedAmountFeeUpdated(app, amount, burnRate);
    }

    function setFixedRateFee(address nft, uint feeRate, uint burnRate) public onlyOwner {
        require(nft != address(0), 'illegal application contract');
        require(burnRate >= RPC.globalBurnRate(), 'illegal burn rate');
        fixedRateFee[nft].amountOrRate = feeRate;
        fixedRateFee[nft].burnRate = burnRate;
        fixedRateFee[nft].initialized = true;
        emit FixedRateFeeUpdated(nft, feeRate, burnRate);
    }

    function spendRPCWithFixedAmountFee(address payer) public override returns (uint feeCollected) {
        FeeCfg storage cfg = fixedAmountFee[msg.sender];
        require(cfg.initialized, 'msg.sender has not permission');
        if (cfg.amountOrRate > 0) {
            feeCollected = spend(payer, cfg.amountOrRate, cfg.burnRate);
            emit FeeCollected(msg.sender, payer, feeCollected);
        }
    }

    function spendRPCWithFixedRateFee(address payer, address recipient, uint volume)
    public override returns (uint feeCollected, uint recipientReceived){
        if (volume > 0) {
            FeeCfg storage cfg = fixedRateFee[msg.sender];
            require(cfg.initialized, 'msg.sender has not permission');
            uint received = spend(payer, volume, cfg.burnRate);
            uint feeRate = cfg.amountOrRate;
            feeCollected = received * feeRate / 1e18;
            recipientReceived = received - feeCollected;
            IERC20(RPC).safeTransfer(recipient, recipientReceived);
            emit FeeCollected(msg.sender, payer, feeCollected);
        }
    }

    // spend rpc to self, return received RPC num
    function spend(address payer, uint amount, uint burnRate) internal returns (uint){
        address self = address(this);
        uint balanceBefore = RPC.balanceOf(self);
        RPC.spend(payer, self, amount, burnRate);
        uint balanceAfter = RPC.balanceOf(self);
        return balanceAfter - balanceBefore;
    }

    function withdrawFee(address feeTo) public onlyOwner {
        uint balance = RPC.balanceOf(address(this));
        IERC20(RPC).safeTransfer(feeTo, balance);
        emit WithdrawFee(feeTo, balance);
    }

    function burnFee(uint amount) public onlyOwner {
        ERC20Burnable(address(RPC)).burn(amount);
        emit BurnFee(amount);
    }
}
