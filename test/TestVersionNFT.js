const {expect} = require("chai");
const env = require("../.env.json");

describe("Test Version NFT", function () {
    let manager;
    let token = {
        chainId: 1,
        nft: '0xfa860d48571fa0d19324cbde77e0fbdfdffb0a47',
        tokenId: 0,
    }
    it('deploy', async function () {
        let Manager = await ethers.getContractFactory('ManagerV2');
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
    it('test info by permit', async function () {
        let uri = 'ipfs://ccc';
        let tokenHash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['uint', 'address', 'uint'], [token.chainId, token.nft, token.tokenId])]);
        let hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['bytes32', 'string'], [tokenHash, uri])]);
        let operatorSigningKey = new ethers.utils.SigningKey('0x' + env.PRIVATE_KEY_2);
        let sig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
        await manager.setInfoByPermit(token, uri, sig);
        let signerAddr = ethers.utils.computeAddress(operatorSigningKey.publicKey);
        let info = await manager.getInfo(token, signerAddr);
        expect(info).to.eq(uri);
    });
});
