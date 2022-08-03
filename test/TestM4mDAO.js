const {expect} = require("chai");
const deploy = require('../scripts/deploy');

describe("Meta-4d.me DAO", function () {
    let dao, m4mNFT, otherNFT;
    let owner;
    it('deploy', async function () {
        let deployments = await deploy.deploy();
        dao = deployments.m4mDao;
        m4mNFT = deployments.m4mNFT;
        owner = await ethers.getSigner();
        const NFT = await ethers.getContractFactory('M4mNFT');
        otherNFT = await NFT.deploy();
        await otherNFT.initialize('test', deployments.m4mNFTRegistry.address, dao.address);
    });
    it('set convertible list', async function () {
        expect(await dao.convertibleList(otherNFT.address)).to.eq(false);
        await dao.setConvertibleList(otherNFT.address, true);
        expect(await dao.convertibleList(otherNFT.address)).to.eq(true);
    });
});