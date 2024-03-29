const {expect} = require("chai");
const deploy = require('../scripts/deploy');
const env = require("../.env.json");

describe("Test Zip", function () {
    let simpleNFT, m4mNFT, components, registry, versionManager, dao;
    let owner;
    let operatorSigningKey;
    let simpleNFTId = 0;
    let m4mNFTId = 0;
    let zip;
    it('deploy', async function () {
        let Manager = await ethers.getContractFactory('Manager');
        versionManager = await Manager.deploy();
        let deployments = await deploy.deploy();
        simpleNFT = deployments.simpleM4mNFT;
        m4mNFT = deployments.m4mNFT;
        components = deployments.m4mComponent;
        registry = deployments.m4mNFTRegistry;
        dao = deployments.m4mDao;
        [owner] = await ethers.getSigners();
        operatorSigningKey = new ethers.utils.SigningKey('0x' + env.PRIVATE_KEY_2);
        await registry.setOperator(ethers.utils.computeAddress(operatorSigningKey.publicKey));
        await dao.setConvertibleList(simpleNFT.address, true);
        let hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['address', 'uint'], [simpleNFT.address, simpleNFTId])]);
        m4mNFTId = ethers.BigNumber.from(hash);
        let Zip = await ethers.getContractFactory('Zip');
        zip = await Zip.deploy('QmUbe9cwdyQDbcFjUTWW8untZwoQ2S6vy22ESKTW3MAdHs', simpleNFT.address, registry.address, versionManager.address);
    });
    it('add new attribute value', async function () {
        await components.prepareNewToken(0, 'M4m 2D Style', '2D-STYLE');
        await components.prepareNewToken(1, 'M4m 3D Style', '3D-STYLE');
        await components.prepareNewToken(2, 'M4m Red HAIR', 'RED-HAIR');
        await components.prepareNewToken(3, 'M4m White COMPLEXION', 'WHITE-COMPLEXION');
        await components.prepareNewToken(4, 'M4m Jacket UPPER', 'Jacket-UPPER');
        await components.prepareNewToken(5, 'M4m Skirt LOWER', 'Skirt-LOWER');
        await components.prepareNewToken(6, 'M4m Test SHOES_AND_SOCKS', 'Test-SHOES_AND_SOCKS');
        await components.prepareNewToken(7, 'M4m Test EARRINGS', 'Test-SHOES_AND_SOCKS');
        await components.prepareNewToken(8, 'M4m Test NECKLACE', 'Test-NECKLACE');
        await components.prepareNewToken(9, 'M4m Test GLASS', 'Test-GLASS');
        await components.prepareNewToken(10, 'M4m Test BACKEND_ENV', 'Test-BACKEND_ENV');
        await components.prepareNewToken(11, 'M4m Test FRONTEND_ENV', 'Test-FRONTEND_ENV');
        await components.prepareNewToken(12, 'M4m Test1 HAIR', 'Test1-HAIR');
        await components.prepareNewToken(13, 'M4m Test1 COMPLEXION', 'Test1-COMPLEXION');
        await components.prepareNewToken(14, 'M4m Test1 UPPER', 'Test1-UPPER');
        await components.prepareNewToken(15, 'M4m Test1 LOWER', 'Test1-LOWER');
        await components.prepareNewToken(16, 'M4m Test1 SHOES_AND_SOCKS', 'Test1-SHOES_AND_SOCKS');
        await components.prepareNewToken(17, 'M4m Test1 EARRINGS', 'Test1-SHOES_AND_SOCKS');
        await components.prepareNewToken(18, 'M4m Test1 NECKLACE', 'Test1-NECKLACE');
        await components.prepareNewToken(19, 'M4m Test1 GLASS', 'Test1-GLASS');
        await components.prepareNewToken(20, 'M4m Test1 BACKEND_ENV', '2D-BACKEND_ENV');
        await components.prepareNewToken(21, 'M4m Test1 FRONTEND_ENV', '2D-FRONTEND_ENV');
    });
    it('Test Zip Mint', async function () {
        let componentIds = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let amounts = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
        let hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['uint', 'uint[11]', 'uint[11]'], [m4mNFTId, componentIds, amounts])]);
        let sig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
        await zip.mintM4mNFT(owner.address, componentIds, amounts, sig);
        expect(await m4mNFT.ownerOf(m4mNFTId)).to.eq(owner.address);
        expect(await simpleNFT.ownerOf(simpleNFTId)).to.eq(registry.address);
        for (const id of componentIds) {
            expect(await components.totalSupply(id)).to.eq(1);
            expect(await components.balanceOf(registry.address, id)).to.eq(1);
            expect(await registry.getTokenComponentAmount(m4mNFTId, id)).to.eq(1);
        }
        const tokenStatus = await registry.getTokenStatus(m4mNFTId);
        expect(tokenStatus[0]).to.eq(1);
        expect(tokenStatus[1]).to.eq(hash);
        expect(tokenStatus[2]).to.eq(simpleNFT.address);
        expect(tokenStatus[3]).to.eq(simpleNFTId);
    });
    it('Test Change', async function () {
        await m4mNFT.setApprovalForAll(zip.address, true);
        await components.setApprovalForAll(zip.address, true);
        // prepare some new components
        let uuid = "asdsdadsadsadas";
        let inComponentIds = [11, 12, 13];
        let inAmounts = [1, 1, 1];
        let hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['address', 'string', 'uint[3]', 'uint[3]'],
                [owner.address, uuid, inComponentIds, inAmounts])]);
        let sig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
        await registry.claimLoot(uuid, inComponentIds, inAmounts, sig);

        let outComponentIds = [1, 2, 3];
        let outAmounts = [1, 1, 1];
        await zip.changeComponents(m4mNFTId, outComponentIds, outAmounts, inComponentIds, inAmounts);

        expect(await m4mNFT.ownerOf(m4mNFTId)).to.eq(owner.address);
        for (const id of inComponentIds) {
            expect(await components.totalSupply(id)).to.eq(1);
            expect(await components.balanceOf(registry.address, id)).to.eq(1);
            expect(await registry.getTokenComponentAmount(m4mNFTId, id)).to.eq(1);
        }
        for (const id of outComponentIds) {
            expect(await components.totalSupply(id)).to.eq(1);
            expect(await components.balanceOf(owner.address, id)).to.eq(1);
            expect(await registry.getTokenComponentAmount(m4mNFTId, id)).to.eq(0);
        }
    });
    it('Test Change And Record Version', async function () {
        await m4mNFT.setApprovalForAll(zip.address, true);
        await components.setApprovalForAll(zip.address, true);
        // prepare some new components
        let uuid = "asdsdadsadsadsfadsfasfasfadfafas";
        let inComponentIds = [14, 15, 16];
        let inAmounts = [1, 1, 1];
        let hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['address', 'string', 'uint[3]', 'uint[3]'],
                [owner.address, uuid, inComponentIds, inAmounts])]);
        let sig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
        await registry.claimLoot(uuid, inComponentIds, inAmounts, sig);

        let outComponentIds = [11, 12, 13];
        let outAmounts = [1, 1, 1];
        let oldVersion = "asdaaaaaaaaaaaaaaaaaaaaaaaaaa";
        await zip.changeComponentsAndRecordVersion(m4mNFTId, outComponentIds, outAmounts, inComponentIds, inAmounts, oldVersion);

        expect(await m4mNFT.ownerOf(m4mNFTId)).to.eq(owner.address);
        for (const id of inComponentIds) {
            expect(await components.totalSupply(id)).to.eq(1);
            expect(await components.balanceOf(registry.address, id)).to.eq(1);
            expect(await registry.getTokenComponentAmount(m4mNFTId, id)).to.eq(1);
        }
        for (const id of outComponentIds) {
            expect(await components.totalSupply(id)).to.eq(1);
            expect(await components.balanceOf(owner.address, id)).to.eq(1);
            expect(await registry.getTokenComponentAmount(m4mNFTId, id)).to.eq(0);
        }
        let {chainId} = await ethers.provider.network;
        expect(await versionManager.getInfo({
            chainId: chainId,
            tokenId: m4mNFTId,
            nft: m4mNFT.address,
        }, zip.address)).to.eq(oldVersion);
    });
    it('Test ZipV2 Mint', async function () {
        // deploy SimpleM4mNFTV2
        const SimpleM4mNFTV2 = await ethers.getContractFactory('SimpleM4mNFTV2');
        const simpleNFTV2 = await SimpleM4mNFTV2.deploy('Simple Meta-4d.me NFT V2', 'sM4MV2');
        // set convertable
        await dao.setConvertibleList(simpleNFTV2.address, true)
        // deploy Zip V2
        const ZipV2 = await ethers.getContractFactory('ZipV2');
        zip = await ZipV2.deploy('QmUbe9cwdyQDbcFjUTWW8untZwoQ2S6vy22ESKTW3MAdHs', simpleNFT.address, registry.address,
            versionManager.address, simpleNFTV2.address);
        // calculate new m4m nft id
        let hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['address', 'uint'], [simpleNFTV2.address, simpleNFTId])]);
        m4mNFTId = ethers.BigNumber.from(hash);

        let componentIds = [19, 20, 21];
        let amounts = [1, 1, 1];
        hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['uint', 'uint[3]', 'uint[3]'], [m4mNFTId, componentIds, amounts])]);
        let sig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
        await zip.mintM4mNFTV2(owner.address, simpleNFTId, componentIds, amounts, sig);

        expect(await m4mNFT.ownerOf(m4mNFTId)).to.eq(owner.address);
        expect(await simpleNFT.ownerOf(simpleNFTId)).to.eq(registry.address);
        for (const id of componentIds) {
            expect(await components.totalSupply(id)).to.eq(1);
            expect(await components.balanceOf(registry.address, id)).to.eq(1);
            expect(await registry.getTokenComponentAmount(m4mNFTId, id)).to.eq(1);
        }
        const tokenStatus = await registry.getTokenStatus(m4mNFTId);
        expect(tokenStatus[0]).to.eq(1);
        expect(tokenStatus[1]).to.eq(hash);
        expect(tokenStatus[2]).to.eq(simpleNFTV2.address);
        expect(tokenStatus[3]).to.eq(simpleNFTId);
    });
});
