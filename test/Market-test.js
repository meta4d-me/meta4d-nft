const {expect} = require("chai");

// const emptyAddr = ethers.utils.getAddress("0x0000000000000000000000000000000000000000");
describe('Meta NFT Market', function () {
    let rpc, globalBurnRate, globalTaxRate;
    let router;
    let meme;
    let batchMeme;
    let owner;
    let user;
    let baseURI = "http://api.meta4d.me/v1/meme/";
    let marketLogic;
    let marketState;
    let market, feeRate;
    let tokenId;
    let batchMemeTokenId = 0;
    let batchMemeAmount = 100;
    let multiplier = ethers.BigNumber.from('1000000000000000000');
    beforeEach('initialize', async function () {
        const MockRPC = await ethers.getContractFactory("MockRPC");
        rpc = await MockRPC.deploy();
        globalBurnRate = await rpc.globalBurnRate();
        globalTaxRate = await rpc.globalTaxRate();
        const RPCRouter = await ethers.getContractFactory("RPCRouter");
        router = await RPCRouter.deploy(rpc.address);
        const MetaMEME = await ethers.getContractFactory("MetaMEME");
        meme = await MetaMEME.deploy(router.address, baseURI);
        const MetaBatchMeme = await ethers.getContractFactory("MetaBatchMEME");
        batchMeme = await MetaBatchMeme.deploy();
        [owner, user] = await ethers.getSigners();
        expect(await meme.owner()).to.equal(owner.address);

        /* deploy market */
        const Market = await ethers.getContractFactory("Market");
        marketLogic = await Market.deploy();
        const MarketProxy = await ethers.getContractFactory("MarketProxy");
        marketState = await MarketProxy.deploy(marketLogic.address, Buffer.from(''), router.address, rpc.address);
        market = await Market.attach(marketState.address);

        /* transfer rpc and set fee rate */
        let amount = ethers.BigNumber.from('100000000000000000000');
        await rpc.transfer(user.address, amount);
        await rpc.connect(user).approve(router.address, amount);
        await rpc.approve(router.address, amount.mul(100));
        await rpc.approve(market.address, amount.mul(100));
        // 1%
        feeRate = ethers.BigNumber.from('10000000000000000');
        await router.setFixedRateFee(market.address, feeRate, globalBurnRate);

        await router.setFixedAmountFee(meme.address, 0, globalBurnRate);
        await router.setFixedAmountFee(batchMeme.address, 0, globalBurnRate);

        // support NFT
        await market.setSupportedNFT(meme.address, true);
        await market.setSupportedNFT(batchMeme.address, true);
        expect(await market.supportedNFT(meme.address)).to.equal(true);
        expect(await market.supportedNFT(batchMeme.address)).to.equal(true);
        // mint nft first
        tokenId = await meme.tokenIndex();
        await meme.connect(user).mint(user.address);
        await meme.connect(user).approve(market.address, tokenId);
        await batchMeme.mint(user.address, batchMemeTokenId, batchMemeAmount, Buffer.from(''));
        await batchMeme.connect(user).setApprovalForAll(market.address, true);
    });
    it('ERC721 one price order', async function () {
        /* make order */
        let minPrice = ethers.BigNumber.from('100000000000000000000');
        let maxPrice = minPrice;
        let startBlock = ethers.BigNumber.from(await network.provider.send('eth_blockNumber')).add(1);
        let duration = 10;
        await market.connect(user).makeOrder(true, meme.address, tokenId, 1, minPrice, maxPrice, startBlock, duration);
        let orderId = await market.ordersNum();
        let order = await market.orders(orderId);
        expect(order.status).to.equal(0);
        expect(order.tokenId).to.equal(tokenId);
        expect(order.nft).to.equal(meme.address);
        expect(order.is721).to.equal(true);
        expect(order.seller).to.equal(user.address);
        expect(order.initAmount).to.equal(1);
        expect(order.minPrice).to.equal(minPrice);
        expect(order.maxPrice).to.equal(maxPrice);
        expect(order.startBlock).to.equal(startBlock);
        expect(order.duration).to.equal(duration);
        expect(order.amount).to.equal(1);
        expect(order.finalPrice).to.equal(0);
        let buyers = await market.orderBuyers(orderId);
        expect(buyers.length).to.equal(0);
        expect(await meme.ownerOf(order.tokenId)).to.equal(market.address);

        /* take order */
        let amountOut = order.amount;
        let buyerBalanceBefore = await rpc.balanceOf(owner.address);
        let sellerBalanceBefore = await rpc.balanceOf(user.address);
        let feeBalanceBefore = await rpc.balanceOf(router.address);
        await market.takeOrder(orderId, amountOut);
        let buyerBalanceAfter = await rpc.balanceOf(owner.address);
        let sellerBalanceAfter = await rpc.balanceOf(user.address);
        let feeBalanceAfter = await rpc.balanceOf(router.address);
        // check order status
        order = await market.orders(orderId);
        expect(order.status).to.equal(2);
        expect(order.finalPrice).to.equal(order.minPrice);
        buyers = await market.orderBuyers(orderId);
        expect(buyers.length).to.equal(1);
        expect(buyers[0]).to.equal(owner.address);

        // check asset
        expect(await meme.ownerOf(order.tokenId)).to.equal(owner.address);
        let buyerBalanceChange = buyerBalanceBefore.sub(buyerBalanceAfter);
        let sellerBalanceChange = sellerBalanceAfter.sub(sellerBalanceBefore);
        let feeBalanceChange = feeBalanceAfter.sub(feeBalanceBefore);
        let volume = order.finalPrice;
        let burned = volume.mul(globalBurnRate).div(multiplier);
        let tax = volume.sub(burned).mul(globalTaxRate).div(multiplier);
        expect(feeBalanceChange).to.equal(volume.sub(burned).sub(tax).mul(feeRate).div(multiplier));
        expect(buyerBalanceChange).to.equal(volume.sub(tax)); // buyer is RPC.taxTo
        expect(feeBalanceChange.add(sellerBalanceChange)).to.equal(buyerBalanceChange.sub(burned));
    });
    it('ERC721 Dutch auction', async function () {
        /* make order */
        let minPrice = ethers.BigNumber.from('100000000000000000000');
        let maxPrice = minPrice.mul(2);
        let startBlock = ethers.BigNumber.from(await network.provider.send('eth_blockNumber')).add(1);
        let duration = 10;
        await market.connect(user).makeOrder(true, meme.address, tokenId, 1, minPrice, maxPrice, startBlock, duration);
        let orderId = await market.ordersNum();
        let order = await market.orders(orderId);
        expect(await market.getPrice(orderId)).to.equal(order.maxPrice);

        /* fast forward 5 block */
        while (true) {
            let height = ethers.BigNumber.from(await network.provider.send('eth_blockNumber'));
            if (height.gte(startBlock.add(5))) {
                break;
            }
            await network.provider.send('evm_mine');
        }
        // check price
        let height = ethers.BigNumber.from(await network.provider.send('eth_blockNumber'));
        let priceCalculated = order.maxPrice.sub(order.maxPrice.sub(order.minPrice).mul(height.sub(order.startBlock))
            .div(order.duration));
        expect(await market.getPrice(orderId)).to.equal(priceCalculated);
        // snapshot
        let snapshot = await network.provider.send('evm_snapshot');
        /* take order */
        let priceExecuted = order.maxPrice.sub(order.maxPrice.sub(order.minPrice).mul(height.add(1).sub(order.startBlock))
            .div(order.duration));
        let amountOut = order.amount;
        let buyerBalanceBefore = await rpc.balanceOf(owner.address);
        let sellerBalanceBefore = await rpc.balanceOf(user.address);
        let feeBalanceBefore = await rpc.balanceOf(router.address);
        await market.takeOrder(orderId, amountOut);
        let buyerBalanceAfter = await rpc.balanceOf(owner.address);
        let sellerBalanceAfter = await rpc.balanceOf(user.address);
        let feeBalanceAfter = await rpc.balanceOf(router.address);
        // check order status
        order = await market.orders(orderId);
        expect(order.status).to.equal(2);
        expect(order.finalPrice).to.equal(priceExecuted);
        let buyers = await market.orderBuyers(orderId);
        expect(buyers.length).to.equal(1);
        expect(buyers[0]).to.equal(owner.address);

        // check asset
        expect(await meme.ownerOf(order.tokenId)).to.equal(owner.address);
        let buyerBalanceChange = buyerBalanceBefore.sub(buyerBalanceAfter);
        let sellerBalanceChange = sellerBalanceAfter.sub(sellerBalanceBefore);
        let feeBalanceChange = feeBalanceAfter.sub(feeBalanceBefore);
        let volume = priceExecuted;
        let burned = volume.mul(globalBurnRate).div(multiplier);
        let tax = volume.sub(burned).mul(globalTaxRate).div(multiplier);
        expect(feeBalanceChange).to.equal(volume.sub(burned).sub(tax).mul(feeRate).div(multiplier));
        expect(buyerBalanceChange).to.equal(volume.sub(tax)); // buyer is RPC.taxTo
        expect(feeBalanceChange.add(sellerBalanceChange)).to.equal(buyerBalanceChange.sub(burned));

        /* revert take order and fast forward enough block */
        await network.provider.send('evm_revert', [snapshot]);
        while (true) {
            let height = ethers.BigNumber.from(await network.provider.send('eth_blockNumber'));
            if (height.gte(startBlock.add(duration))) {
                break;
            }
            await network.provider.send('evm_mine');
        }
        expect(await market.getPrice(orderId)).to.equal(order.minPrice);
        await market.takeOrder(orderId, amountOut);
        // check order status
        order = await market.orders(orderId);
        expect(order.status).to.equal(2);
        expect(order.finalPrice).to.equal(order.minPrice);
    });
    it('cancel ERC721 order', async function () {
        /* make order */
        let minPrice = ethers.BigNumber.from('100000000000000000000');
        let maxPrice = minPrice.mul(2);
        let startBlock = ethers.BigNumber.from(await network.provider.send('eth_blockNumber')).add(1);
        let duration = 10;
        await market.connect(user).makeOrder(true, meme.address, tokenId, 1, minPrice, maxPrice, startBlock, duration);
        let orderId = await market.ordersNum();
        let order = await market.orders(orderId);
        expect(await meme.ownerOf(order.tokenId)).to.equal(market.address);
        // snapshot
        let snapshot = await network.provider.send('evm_snapshot');
        // cancel order
        await market.connect(user).cancelOrder(orderId);
        expect(await meme.ownerOf(order.tokenId)).to.equal(user.address);
        order = await market.orders(orderId);
        expect(order.status).to.equal(4);
        expect(order.amount).to.equal(0);
        expect(order.finalPrice).to.equal(0);
        await expect(market.getPrice(orderId)).to.be.revertedWith("canceled order");

        // revert
        await network.provider.send('evm_revert', [snapshot]);
        // take order
        order = await market.orders(orderId);
        await market.takeOrder(orderId, order.amount);
        order = await market.orders(orderId);
        expect(order.status).to.equal(2);
        // cannot cancel SOLD order
        await expect(market.connect(user).cancelOrder(orderId)).to.be.revertedWith('illegal order status');
    });
    it('ERC1155 partially sold order', async function () {
        /* make order */
        let minPrice = ethers.BigNumber.from('100000000000000000000');
        let maxPrice = minPrice.mul(2);
        let startBlock = ethers.BigNumber.from(await network.provider.send('eth_blockNumber')).add(1);
        let duration = 10;
        let orderAmount = 20;
        await market.connect(user).makeOrder(false, batchMeme.address, batchMemeTokenId, orderAmount, minPrice,
            maxPrice, startBlock, duration);
        // check asset
        expect(await batchMeme.balanceOf(market.address, batchMemeTokenId)).to.equal(orderAmount);
        expect(await batchMeme.balanceOf(user.address, batchMemeTokenId)).to.equal(batchMemeAmount - orderAmount);

        /* take order */
        let orderId = await market.ordersNum();
        let takeAmount = orderAmount / 2;
        let buyerBalanceBefore = await rpc.balanceOf(owner.address);
        let sellerBalanceBefore = await rpc.balanceOf(user.address);
        let feeBalanceBefore = await rpc.balanceOf(router.address);
        await market.takeOrder(orderId, takeAmount);
        let buyerBalanceAfter = await rpc.balanceOf(owner.address);
        let sellerBalanceAfter = await rpc.balanceOf(user.address);
        let feeBalanceAfter = await rpc.balanceOf(router.address);
        // check asset
        expect(await batchMeme.balanceOf(market.address, batchMemeTokenId)).to.equal(orderAmount - takeAmount);
        expect(await batchMeme.balanceOf(owner.address, batchMemeTokenId)).to.equal(takeAmount);
        let buyerBalanceChange = buyerBalanceBefore.sub(buyerBalanceAfter);
        let sellerBalanceChange = sellerBalanceAfter.sub(sellerBalanceBefore);
        let feeBalanceChange = feeBalanceAfter.sub(feeBalanceBefore);
        let order = await market.orders(orderId);
        let height = ethers.BigNumber.from(await network.provider.send('eth_blockNumber'));
        let priceExecuted = order.maxPrice.sub(order.maxPrice.sub(order.minPrice).mul(height.sub(order.startBlock))
            .div(order.duration));
        let volume = priceExecuted.mul(takeAmount);
        let burned = volume.mul(globalBurnRate).div(multiplier);
        let tax = volume.sub(burned).mul(globalTaxRate).div(multiplier);
        expect(feeBalanceChange).to.equal(volume.sub(burned).sub(tax).mul(feeRate).div(multiplier));
        expect(buyerBalanceChange).to.equal(volume.sub(tax));
        expect(feeBalanceChange.add(sellerBalanceChange)).to.equal(buyerBalanceChange.sub(burned));
        // check order status
        expect(order.status).to.equal(1);
        expect(order.amount).to.equal(orderAmount - takeAmount);
        expect(order.finalPrice).to.equal(0);
        let buyers = await market.orderBuyers(orderId);
        expect(buyers.length).to.equal(1);
        expect(buyers[0]).to.equal(owner.address);

        /* SOLD and check finalPrice */
        let snapshot = await network.provider.send('evm_snapshot');
        await market.takeOrder(orderId, takeAmount);
        height = ethers.BigNumber.from(await network.provider.send('eth_blockNumber'));
        priceExecuted = order.maxPrice.sub(order.maxPrice.sub(order.minPrice).mul(height.sub(order.startBlock))
            .div(order.duration));
        order = await market.orders(orderId);
        expect(order.status).to.equal(2);
        expect(order.amount).to.equal(0);
        expect(order.finalPrice).to.equal(priceExecuted);
        buyers = await market.orderBuyers(orderId);
        expect(buyers.length).to.equal(2);
        expect(buyers[1]).to.equal(owner.address);

        /* revert second takeOrder, cancel order */
        await network.provider.send('evm_revert', [snapshot]);
        await market.connect(user).cancelOrder(orderId);
        // check order status
        order = await market.orders(orderId);
        expect(order.status).to.equal(3);
        expect(order.amount).to.equal(0);
        expect(order.finalPrice).to.equal(0);
        buyers = await market.orderBuyers(orderId);
        expect(buyers.length).to.equal(1);
        expect(buyers[0]).to.equal(owner.address);
    });
    it('market upgrade', async function () {
        const Market = await ethers.getContractFactory("Market");
        marketLogic = await Market.deploy();
        await marketState.updateTo(marketLogic.address);
        expect(await marketState.implementation()).to.equal(marketLogic.address);
    });
});
