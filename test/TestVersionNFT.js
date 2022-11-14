const {expect} = require("chai");

describe("Test Version NFT", function () {
    let manager;
    let token = {
        chainId: 1,
        nft: '0xfa860d48571fa0d19324cbde77e0fbdfdffb0a47',
        tokenId: 0,
    }
    it('deploy', async function () {
        let Manager = await ethers.getContractFactory('Manager');
        manager = await Manager.deploy();
    });
    it('test info', async function () {
        let signers = await ethers.getSigners();
        let uri = 'ipfs://aaa';
        await manager.connect(signers[0]).setInfo(token, uri);
        expect(await manager.getInfo(token, signers[0].address)).to.eq(uri);
        uri = 'ipfs://bbb';
        await manager.connect(signers[1]).setInfo(token, uri);
        expect(await manager.getInfo(token, signers[1].address)).to.eq(uri);
        let {_creators, _uris} = await manager.getLatestInfoAll(token);
        expect(_creators.length).to.eq(2);
        expect(_uris.length).to.eq(2);

        await expect(manager.setInfo(token, '')).to.be.revertedWith('illegal uri');
    });
});
