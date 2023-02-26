const {expect} = require("chai");
const deploy = require('../scripts/deploy');
const env = require("../.env.json");
const {upgrades} = require("hardhat");

describe("Test Baggage", function () {
    let simpleNFT, m4mNFT, components, registry, m4mBaggage;
    let owner, gameOperatorAddr, gameSignerAddr;
    let operatorSigningKey, gameSigningKey;
    let simpleNFTId = 0;
    let m4mNFTId = 0;
    let gameId = 123123;
    let uuid = '12312312313132';
    let initComponentIds = [0, 1, 2, 3];
    let initComponentAmounts = [2, 2, 2, 2];
    it('init', async function () {
        let deployments = await deploy.deploy();
        simpleNFT = deployments.simpleM4mNFT;
        m4mNFT = deployments.m4mNFT;
        components = deployments.m4mComponent;
        registry = deployments.m4mNFTRegistry;
        [owner] = await ethers.getSigners();
        operatorSigningKey = new ethers.utils.SigningKey('0x' + env.PRIVATE_KEY_2);
        gameSigningKey = new ethers.utils.SigningKey('0x' + env.PRIVATE_KEY_3);
        gameOperatorAddr = ethers.utils.computeAddress(operatorSigningKey.publicKey);
        gameSignerAddr = ethers.utils.computeAddress(gameSigningKey.publicKey)
        await registry.setOperator(gameOperatorAddr);
        await deployments.m4mDao.setConvertibleList(simpleNFT.address, true);
        let hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['address', 'uint'], [simpleNFT.address, simpleNFTId])]);
        m4mNFTId = ethers.BigNumber.from(hash);
        let M4mBaggage = await ethers.getContractFactory('M4mBaggage');
        m4mBaggage = await upgrades.deployProxy(M4mBaggage, [registry.address]);
        await m4mBaggage.setGameSignerAndOperator(gameId, gameSignerAddr, gameOperatorAddr);
        // mint some components
        await components.prepareNewToken(0, 'M4m 2D Style', '2D-STYLE');
        await components.prepareNewToken(1, 'M4m 3D Style', '3D-STYLE');
        await components.prepareNewToken(2, 'M4m Red HAIR', 'RED-HAIR');
        await components.prepareNewToken(3, 'M4m White COMPLEXION', 'WHITE-COMPLEXION');
        let uuid = '1231231321323';
        hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['address', 'string', 'uint[4]', 'uint[4]'],
                [owner.address, uuid, initComponentIds, initComponentAmounts])]);
        let sig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
        await registry.claimLoot(uuid, initComponentIds, initComponentAmounts, sig);
        // mint 1 m4mNFT
        await simpleNFT.mint(owner.address, 'testetstetstsetstestsest');
        await simpleNFT.setApprovalForAll(registry.address, true);
        hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['uint', 'uint[4]', 'uint[4]'], [m4mNFTId, initComponentIds, initComponentAmounts])]);
        sig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
        await registry.convertNFT(simpleNFT.address, simpleNFTId, initComponentIds, initComponentAmounts, sig);
        // set approval
        await m4mNFT.setApprovalForAll(m4mBaggage.address, true);
        await components.setApprovalForAll(m4mBaggage.address, true);
    });
    it('upgrade registry to v2', async function () {
        let M4mNFTRegistryV2 = await ethers.getContractFactory('M4mNFTRegistryV2');
        registry = await upgrades.upgradeProxy(registry.address, M4mNFTRegistryV2, {
            call: {
                fn: 'initializeV2',
                args: [m4mBaggage.address]
            }
        });
        expect(await registry.m4mBaggage()).to.eq(m4mBaggage.address);
    });
    it('game begin', async function () {
        await m4mBaggage.gameBegin(gameId, uuid, m4mNFTId, initComponentIds, initComponentAmounts);
        expect(await m4mNFT.ownerOf(m4mNFTId)).to.eq(m4mBaggage.address);
        for (const componentId of initComponentIds) {
            expect(await components.totalSupply(componentId)).to.eq(4);
            expect(await components.balanceOf(owner.address, componentId)).to.eq(0);
            expect(await components.balanceOf(m4mBaggage.address, componentId)).to.eq(0);
            expect(await components.balanceOf(registry.address, componentId)).to.eq(4);
        }
        let [status, , ,] = await registry.getTokenStatus(m4mNFTId);
        // status is locked
        expect(status).to.eq(2);
    });
    it('game end', async function () {
        // prepare new component
        await components.prepareNewToken(4, 'M4m White COMPLEXION 2', 'WHITE-COMPLEXION-2');
        let lootIds = [4];
        let lootAmounts = [1];
        let lostIds = [0, 1, 2, 3];
        let lostAmounts = [1, 1, 1, 1];
        let info = await m4mBaggage.lockedNFTs(m4mNFTId);
        let hash = ethers.utils.solidityKeccak256(['bytes'],
            [ethers.utils.solidityPack(['address', 'uint', 'uint', 'string', 'uint[1]', 'uint[1]', 'uint[4]', 'uint[4]'],
                [info.owner, m4mNFTId, info.gameId, info.uuid, lootIds, lootAmounts, lostIds, lostAmounts])]);
        let operatorSig = ethers.utils.joinSignature(await operatorSigningKey.signDigest(hash));
        let gameSignerSig = ethers.utils.joinSignature(await gameSigningKey.signDigest(hash));
        let emptySig = Buffer.from('');
        // should revert without sig
        await expect(m4mBaggage.gameEnd(m4mNFTId, lootIds, lootAmounts, lostIds, lostAmounts, emptySig, emptySig))
            .to.revertedWith('no permission');
        let snapshot = await ethers.provider.send("evm_snapshot");
        await m4mBaggage.gameEnd(m4mNFTId, lootIds, lootAmounts, lostIds, lostAmounts, emptySig, gameSignerSig);
        await ethers.provider.send("evm_revert", [snapshot]);
        snapshot = await ethers.provider.send("evm_snapshot");
        await m4mBaggage.gameEnd(m4mNFTId, lootIds, lootAmounts, lostIds, lostAmounts, operatorSig, emptySig);
        await ethers.provider.send("evm_revert", [snapshot]);
        let [, otherAcc,] = await ethers.getSigners();
        await m4mBaggage.connect(otherAcc).gameEnd(m4mNFTId, lootIds, lootAmounts, lostIds, lostAmounts, operatorSig, gameSignerSig);
        // check
        let [status, , ,] = await registry.getTokenStatus(m4mNFTId);
        // status is unlocked
        expect(status).to.eq(1);
        expect(await m4mNFT.ownerOf(m4mNFTId)).to.eq(owner.address);
        for (const componentId of initComponentIds) {
            expect(await components.totalSupply(componentId)).to.eq(3); // lost 1
            expect(await components.balanceOf(owner.address, componentId)).to.eq(0);
            expect(await components.balanceOf(m4mBaggage.address, componentId)).to.eq(0);
            expect(await components.balanceOf(registry.address, componentId)).to.eq(3);
        }
        let componentId = lootIds[0];
        expect(await components.totalSupply(componentId)).to.eq(1); // own loots
        expect(await components.balanceOf(owner.address, componentId)).to.eq(1);
        expect(await components.balanceOf(m4mBaggage.address, componentId)).to.eq(0);
        expect(await components.balanceOf(registry.address, componentId)).to.eq(0);
        // game is settled
        expect(await m4mBaggage.isGameSettled(owner.address, m4mNFTId, gameId, info.uuid));
    });
    it('could set operator and signer only once', async function(){
        await expect(m4mBaggage.setGameSignerAndOperator(gameId, gameSignerAddr, gameOperatorAddr)).to.revertedWith('only once');
    })
});