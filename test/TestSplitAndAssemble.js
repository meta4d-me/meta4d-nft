const {expect} = require("chai");
const deploy = require('../scripts/deploy');
const env = require('../.env.json');

describe("Split and Assemble", function () {
    let simpleNFT, m4mNFT, components, registry;
    let owner;
    let operatorSigningKey;
    it('deploy', async function () {
        let deployments = await deploy.deploy();
        simpleNFT = deployments.simpleM4mNFT;
        m4mNFT = deployments.m4mNFT;
        components = deployments.m4mComponent;
        registry = deployments.m4mNFTRegistry;
        [owner] = await ethers.getSigners();
        operatorSigningKey = new ethers.utils.SigningKey('0x' + env.PRIVATE_KEY_2);
        await registry.setOperator(ethers.utils.computeAddress(operatorSigningKey.publicKey));
        await deployments.m4mDao.setConvertibleList(simpleNFT.address, true);
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
    it('mint a NFT', async function () {
        await simpleNFT.mint(owner.address, 'testetstetstsetstestsest');
        expect(await simpleNFT.balanceOf(owner.address)).to.eq(1);
    });
    it('split', async function () {
        await simpleNFT.setApprovalForAll(registry.address, true);
        let componentIds = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let amounts = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
        let hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['uint[11]', 'uint[11]'], [componentIds, amounts])]);
        let sig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
        await registry.convertNFT(simpleNFT.address, 0, componentIds, amounts, sig);
        expect(await m4mNFT.ownerOf(0)).to.eq(owner.address);
        expect(await simpleNFT.ownerOf(0)).to.eq(registry.address);
        for (const id of componentIds) {
            expect(await components.balanceOf(registry.address, id)).to.eq(1);
            expect(await registry.getSplitTokenComponentAmount(0, id)).to.eq(1);
        }
        const splitToken = await registry.getSplitToken(0);
        expect(splitToken[0]).to.eq(1);
        expect(splitToken[1]).to.eq(hash);
    });
    it('split', async function () {
        await components.setApprovalForAll(registry.address, true);
        let componentIds = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let amounts = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
        let hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['uint[11]', 'uint[11]'], [componentIds, amounts])]);
        let sig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
        await registry.assembleM4mNFT(componentIds, amounts, sig);
        expect(await m4mNFT.ownerOf(1)).to.eq(owner.address);
        for (const id of componentIds) {
            expect(await components.totalSupply(id)).to.eq(0);
        }
    });
    // it('assemble to original NFT', async function () {
    //     let componentIds = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    //     let amounts = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
    //     let hash = ethers.utils.solidityKeccak256(['bytes'],
    //         [ethers.utils.solidityPack(['uint[11]', 'uint[11]'], [componentIds, amounts])]);
    //     let sig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
    //     await registry.assembleOriginalM4mNFT(0, componentIds, amounts, sig);
    //     expect(await m4mNFT.ownerOf(0)).to.eq(owner.address);
    //     for (const id of componentIds) {
    //         expect(await components.balanceOf(owner.address, id)).to.eq(0);
    //         expect(await components.totalSupply(id)).to.eq(0);
    //     }
    // });
})
