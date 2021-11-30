const {expect} = require("chai");

describe("Meta Meme", function () {
    let rpc;
    let router;
    let meme;
    let owner;
    let user;
    let baseURI = "http://api.meta4d.me/v1/meme/";
    beforeEach('deploy contract', async function () {
        const MockRPC = await ethers.getContractFactory("MockRPC");
        rpc = await MockRPC.deploy();
        const RPCRouter = await ethers.getContractFactory("RPCRouter");
        router = await RPCRouter.deploy(rpc.address);
        const MetaMEME = await ethers.getContractFactory("MetaMEME");
        meme = await MetaMEME.deploy(router.address, baseURI);
        [owner, user] = await ethers.getSigners();
        expect(await meme.owner()).to.equal(owner.address);
        // transfer some rpc to user
        let amount = ethers.BigNumber.from('100000000000000000000');
        await rpc.transfer(user.address, amount);
        await rpc.connect(user).approve(router.address, amount);
    });
    it("mint & transfer & uri", async function () {
        // config NFT mint fee
        const fee = ethers.BigNumber.from('1000000000000000000');
        let globalBurnRate = await rpc.globalBurnRate();
        await router.setFixedAmountFee(meme.address, fee, globalBurnRate);

        // mint MEME
        expect(await meme.mintPaused()).to.equal(false);
        let rpcBalanceBefore = await rpc.balanceOf(user.address);
        let feeBefore = await rpc.balanceOf(router.address);
        await meme.connect(user).mint(user.address);

        let globalTaxRate = await rpc.globalTaxRate();
        let multiplier = ethers.BigNumber.from('1000000000000000000');
        let burned = fee.mul(globalBurnRate).div(multiplier);
        let tax = fee.sub(burned).mul(globalTaxRate).div(multiplier);
        let rpcBalanceAfter = await rpc.balanceOf(user.address);
        let feeAfter = await rpc.balanceOf(router.address);
        expect(feeAfter.sub(feeBefore)).to.equal(fee.sub(burned).sub(tax));
        expect(rpcBalanceBefore.sub(rpcBalanceAfter)).to.equal(fee);
        expect(await meme.balanceOf(user.address)).to.equal(1);
        let tokenId = 0;
        expect(await meme.ownerOf(tokenId)).to.equal(user.address);
        expect(await meme.minter(tokenId)).to.equal(user.address);
        expect(await meme.tokenIndex()).to.equal(1);
        expect(await meme.tokenURI(tokenId)).to.equal(baseURI + tokenId);

        // transfer
        /// @notice ethers doesn't support invoke overwrite function straightly
        await meme.connect(user)['transferFrom(address,address,uint256)'](user.address, owner.address, tokenId);
        expect(await meme.ownerOf(tokenId)).to.equal(owner.address);
        expect(await meme.minter(tokenId)).to.equal(user.address);

        // pause mint
        await meme.pauseMint(true);
        expect(await meme.mintPaused()).to.equal(true);
        // mint should revert
        await expect(meme.mint(owner.address)).to.be.revertedWith("mint paused");
    });
});
