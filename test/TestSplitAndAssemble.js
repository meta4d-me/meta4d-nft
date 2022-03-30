const {expect} = require("chai");
const deploy = require('../scripts/deploy');
const AttrName = {
    STYLE: 0,
    HAIR: 1,
    COMPLEXION: 2,
    UPPER: 3,
    LOWER: 4,
    SHOES_AND_SOCKS: 5,
    EARRINGS: 6,
    NECKLACE: 7,
    GLASS: 8,
    BACKEND_ENV: 9,
    FRONTEND_ENV: 10
};

describe("Split and Assemble", function () {
    let nft, components, registry;
    let owner;
    it('deploy', async function () {
        let deployments = await deploy.deploy();
        nft = deployments.m4mNFT;
        components = deployments.m4mComponent;
        registry = deployments.m4mNFTRegistry;
        owner = await ethers.getSigner();
    });
    it('add new attribute value', async function () {
        await registry.addComponent(12, AttrName.HAIR, 'M4m Test1 HAIR', 'Test1-HAIR', 'Test1');
        await registry.addComponent(13, AttrName.COMPLEXION, 'M4m Test1 COMPLEXION', 'Test1-COMPLEXION', 'Test1');
        await registry.addComponent(14, AttrName.UPPER, 'M4m Test1 UPPER', 'Test1-UPPER', 'Test1');
        await registry.addComponent(15, AttrName.LOWER, 'M4m Test1 LOWER', 'Test1-LOWER', 'Test1');
        await registry.addComponent(16, AttrName.SHOES_AND_SOCKS, 'M4m Test1 SHOES_AND_SOCKS', 'Test1-SHOES_AND_SOCKS', 'Test1');
        await registry.addComponent(17, AttrName.EARRINGS, 'M4m Test1 EARRINGS', 'Test1-SHOES_AND_SOCKS', 'Test1');
        await registry.addComponent(18, AttrName.NECKLACE, 'M4m Test1 NECKLACE', 'Test1-NECKLACE', 'Test1');
        await registry.addComponent(19, AttrName.GLASS, 'M4m Test1 GLASS', 'Test1-GLASS', 'Test1');
        await registry.addComponent(20, AttrName.BACKEND_ENV, 'M4m Test1 BACKEND_ENV', '2D-BACKEND_ENV', 'Test1');
        await registry.addComponent(21, AttrName.FRONTEND_ENV, 'M4m Test1 FRONTEND_ENV', '2D-FRONTEND_ENV', 'Test1');
        expect((await registry.attrTokenIds(AttrName.STYLE)).length).to.eq(2);
        expect((await registry.attrTokenIds(AttrName.HAIR)).length).to.eq(2);
        expect((await registry.attrTokenIds(AttrName.COMPLEXION)).length).to.eq(2);
        expect((await registry.attrTokenIds(AttrName.UPPER)).length).to.eq(2);
        expect((await registry.attrTokenIds(AttrName.LOWER)).length).to.eq(2);
        expect((await registry.attrTokenIds(AttrName.SHOES_AND_SOCKS)).length).to.eq(2);
        expect((await registry.attrTokenIds(AttrName.EARRINGS)).length).to.eq(2);
        expect((await registry.attrTokenIds(AttrName.NECKLACE)).length).to.eq(2);
        expect((await registry.attrTokenIds(AttrName.GLASS)).length).to.eq(2);
        expect((await registry.attrTokenIds(AttrName.BACKEND_ENV)).length).to.eq(2);
        expect((await registry.attrTokenIds(AttrName.FRONTEND_ENV)).length).to.eq(2);
    });
    it('mint a random NFT', async function () {
        await nft.mint(owner.address);
        const m4mNFT0 = await fetchNFT(nft, components, 0);
        console.log(JSON.stringify(m4mNFT0, '', '   '));
    });
    it('mint a NFT', async function () {
        const style = await registry.attrTokenIds(AttrName.STYLE);
        const hair = await registry.attrTokenIds(AttrName.HAIR);
        const complexion = await registry.attrTokenIds(AttrName.COMPLEXION);
        const upper = await registry.attrTokenIds(AttrName.UPPER);
        const lower = await registry.attrTokenIds(AttrName.LOWER);
        const shoesAndSocks = await registry.attrTokenIds(AttrName.SHOES_AND_SOCKS);
        const earrings = await registry.attrTokenIds(AttrName.EARRINGS);
        const necklace = await registry.attrTokenIds(AttrName.NECKLACE);
        const glass = await registry.attrTokenIds(AttrName.GLASS);
        const backendEnv = await registry.attrTokenIds(AttrName.BACKEND_ENV);
        const frontendEnv = await registry.attrTokenIds(AttrName.FRONTEND_ENV);
        await nft.mintByOwner(owner.address, style[0], hair[0], complexion[0], upper[0], lower[0], shoesAndSocks[0],
            earrings[0], necklace[0], glass[0], backendEnv[0], frontendEnv[0]);
        const m4mNFT1 = await fetchNFT(nft, components, 1);
        console.log(JSON.stringify(m4mNFT1, '', '   '));
    });
    it('cannot mint a NFT with error attribute value', async function () {
        const style = await registry.attrTokenIds(AttrName.STYLE);
        const complexion = await registry.attrTokenIds(AttrName.COMPLEXION);
        const upper = await registry.attrTokenIds(AttrName.UPPER);
        const lower = await registry.attrTokenIds(AttrName.LOWER);
        const shoesAndSocks = await registry.attrTokenIds(AttrName.SHOES_AND_SOCKS);
        const earrings = await registry.attrTokenIds(AttrName.EARRINGS);
        const necklace = await registry.attrTokenIds(AttrName.NECKLACE);
        const backendEnv = await registry.attrTokenIds(AttrName.BACKEND_ENV);
        await expect(nft.mintByOwner(owner.address, style[0], style[0], complexion[0], upper[0], lower[0], shoesAndSocks[0],
            earrings[0], necklace[0], style[0], backendEnv[0], style[0])).to.be.reverted;
    });
    it('split', async function () {
        await nft.setApprovalForAll(registry.address, true);
        await registry.splitM4mNFT(0);
        expect(await nft.ownerOf(0)).to.eq(registry.address);
        const componentsBalance = await getComponentsBalanceOfNFT(owner, nft, components, 0);
        for (const componentsBalanceElement of componentsBalance) {
            expect(componentsBalanceElement).to.eq(1);
        }
    });
    it('assemble to new NFT', async function () {
        await components.setApprovalForAll(registry.address, true);
        let snapshot = await network.provider.send("evm_snapshot");
        const componentsTokenIds = await fetchComponentsTokenId(nft, 0);
        await registry.functions[
            'assembleM4mNFT(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256)']
        (componentsTokenIds[0], componentsTokenIds[1], componentsTokenIds[2], componentsTokenIds[3], componentsTokenIds[4],
            componentsTokenIds[5], componentsTokenIds[6], componentsTokenIds[7], componentsTokenIds[8],
            componentsTokenIds[9], componentsTokenIds[10]);
        expect(await nft.ownerOf(2)).to.eq(owner.address);
        const componentsBalance = await getComponentsBalanceOfNFT(owner, nft, components, 2);
        for (const componentsBalanceElement of componentsBalance) {
            expect(componentsBalanceElement).to.eq(0);
        }
        await network.provider.send("evm_revert", [snapshot]);
    });
    it('assemble to original NFT', async function () {
        await registry.functions['assembleM4mNFT(uint256)'](0);
        expect(await nft.ownerOf(0)).to.eq(owner.address);
        const componentsBalance = await getComponentsBalanceOfNFT(owner, nft, components, 0);
        for (const componentsBalanceElement of componentsBalance) {
            expect(componentsBalanceElement).to.eq(0);
        }
    });
})

async function fetchNFT(m4mNFT, m4mComponents, tokenId) {
    return {
        style: await m4mComponents.attrValue(await m4mNFT.getStyle(tokenId)),
        hair: await m4mComponents.attrValue(await m4mNFT.getHair(tokenId)),
        complexion: await m4mComponents.attrValue(await m4mNFT.getComplexion(tokenId)),
        upper: await m4mComponents.attrValue(await m4mNFT.getUpper(tokenId)),
        lower: await m4mComponents.attrValue(await m4mNFT.getLower(tokenId)),
        shoesAndSocks: await m4mComponents.attrValue(await m4mNFT.getShoesAndSocks(tokenId)),
        earrings: await m4mComponents.attrValue(await m4mNFT.getEarrings(tokenId)),
        necklace: await m4mComponents.attrValue(await m4mNFT.getNecklace(tokenId)),
        glass: await m4mComponents.attrValue(await m4mNFT.getGlass(tokenId)),
        backendEnv: await m4mComponents.attrValue(await m4mNFT.getBackendEnv(tokenId)),
        frontendEnv: await m4mComponents.attrValue(await m4mNFT.getFrontendEnv(tokenId))
    };
}


async function fetchComponentsTokenId(nft, tokenId) {
    return [
        await nft.getStyle(tokenId), await nft.getHair(tokenId), await nft.getComplexion(tokenId),
        await nft.getUpper(tokenId), await nft.getLower(tokenId), await nft.getShoesAndSocks(tokenId),
        await nft.getEarrings(tokenId), await nft.getNecklace(tokenId), await nft.getGlass(tokenId),
        await nft.getBackendEnv(tokenId), await nft.getFrontendEnv(tokenId)
    ];
}

async function getComponentsBalanceOfNFT(owner, nft, components, tokenId) {
    const accounts = [];
    for (let i = 0; i < 11; i++) {
        accounts.push(owner.address)
    }
    return await components.balanceOfBatch(accounts, await fetchComponentsTokenId(nft, tokenId));
}