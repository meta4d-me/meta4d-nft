const {expect} = require("chai");
const deploy = require('../scripts/deploy');

describe("Meta-4d.me DAO", function () {
    let dao, nft, otherNFT;
    let owner;
    it('deploy', async function () {
        let deployments = await deploy.deploy();
        dao = deployments.m4mDao;
        nft = deployments.m4mNFT;
        owner = await ethers.getSigner();
        const NFT = await ethers.getContractFactory('M4mNFT');
        otherNFT = await NFT.deploy();
        await otherNFT.initialize('test', deployments.m4mNFTRegistry.address);
    });
    it('set convertible list', async function () {
        expect(await dao.convertibleList(otherNFT.address)).to.eq(false);
        await dao.setConvertibleList(otherNFT.address, true);
        expect(await dao.convertibleList(otherNFT.address)).to.eq(true);
    });
    it('convert to m4mNFT', async function () {
        await otherNFT.mint(owner.address);
        await otherNFT.setApprovalForAll(dao.address, true);
        await dao.convertToM4mNFT(otherNFT.address, 0);
        expect(await otherNFT.ownerOf(0)).to.eq(dao.address);
        expect(await nft.ownerOf(0)).to.eq(owner.address);
        expect(await dao.convertRecord(0, owner.address, otherNFT.address, 0)).to.eq(true);
    });
    it('redeem originalNFT', async function () {
        await nft.setApprovalForAll(dao.address, true);
        await dao.redeem(0, otherNFT.address, 0);
        expect(await otherNFT.ownerOf(0)).to.eq(owner.address);
        expect(await nft.balanceOf(dao.address)).to.eq(0);
        expect(await nft.balanceOf(owner.address)).to.eq(0);
        expect(await dao.convertRecord(0, owner.address, otherNFT.address, 0)).to.eq(false);
    });
});