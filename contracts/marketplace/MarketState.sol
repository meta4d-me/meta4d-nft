// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IRPCRouter} from '../RPCRouter.sol';

contract MarketState is Ownable {
    IRPCRouter public rpcRouter;
    IERC20 public RPC;

    enum OrderStatus{INIT, PARTIAL_SOLD, SOLD, PARTIAL_SOLD_CANCELED, CANCELED}

    struct Order {
        OrderStatus status;
        uint tokenId;
        address nft; // ERC721 or ERC1155
        bool is721;

        address seller;
        uint initAmount;
        uint minPrice;
        uint maxPrice;
        uint startBlock;
        uint duration; // blocks

        uint amount; // remained amount
        uint finalPrice; // the price of order when NFT is sold, if there are no buyers, the final price is 0
        address[] buyers;
    }

    uint public ordersNum;
    mapping(uint => Order) public orders;

    mapping(address => bool) public supportedNFT;

    constructor(IRPCRouter router, IERC20 rpc)Ownable(){
        rpcRouter = router;
        RPC = rpc;
    }
}