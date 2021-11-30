const {expect} = require("chai");

/// @notice we test fee collecting at other test case
describe("RPC Router", function () {
    let rpc;
    let router;
    let feeTo;
    let owner;
    let globalTaxRate, globalBurnRate;
    beforeEach('deploy contract', async function () {
        const MockRPC = await ethers.getContractFactory("MockRPC");
        rpc = await MockRPC.deploy();
        globalBurnRate = await rpc.globalBurnRate();
        globalTaxRate = await rpc.globalTaxRate();
        const RPCRouter = await ethers.getContractFactory("RPCRouter");
        router = await RPCRouter.deploy(rpc.address);
        [owner, feeTo] = await ethers.getSigners();
        expect(await router.owner()).to.equal(owner.address);
    });
    it('configure', async function () {
        // use any address as nft and market contract address
        let [_, nft, market] = await ethers.getSigners();
        let fixedAmount = ethers.BigNumber.from('1000000000000000000'); // 1e18
        let fixedRate = ethers.BigNumber.from('10000000000000000'); // 1e16
        await router.setFixedAmountFee(nft.getAddress(), fixedAmount, globalBurnRate);
        await router.setFixedRateFee(market.getAddress(), fixedRate, globalBurnRate); // 1%

        expect((await router.fixedAmountFee(nft.getAddress()))[0]).to.equal(fixedAmount);
        expect((await router.fixedRateFee(market.getAddress()))[0]).to.equal(fixedRate);
    });
    it('withdraw & burn fee', async function () {
        let amount = ethers.BigNumber.from('100000000000000000000'); // 100
        rpc.transfer(router.address, amount);
        expect(await rpc.balanceOf(router.address)).to.equal(amount);

        amount = amount.div(2);
        await router.burnFee(amount);
        expect(await rpc.balanceOf(router.address)).to.equal(amount);

        await router.withdrawFee(feeTo.address);
        expect(await rpc.balanceOf(router.address)).to.equal(0);
        expect(await rpc.balanceOf(feeTo.address)).to.equal(amount);
    });
});