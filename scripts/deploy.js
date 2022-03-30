async function deploy() {
    const M4mNFT = await ethers.getContractFactory('M4mNFT');
    const m4mNFT = await upgrades.deployProxy(M4mNFT, [], {initializer: false});

    const M4mDao = await ethers.getContractFactory('M4mDao');
    const m4mDao = await upgrades.deployProxy(M4mDao, [m4mNFT.address]);

    const M4mNFTRegistry = await ethers.getContractFactory('M4mNFTRegistry');
    const m4mNFTRegistry = await upgrades.deployProxy(M4mNFTRegistry, [], {initializer: false});

    const M4mComponent = await ethers.getContractFactory('M4mComponent');
    const m4mComponent = await upgrades.deployProxy(M4mComponent, ['ipfs://test/', m4mNFTRegistry.address]);

    await m4mNFT.initialize('ipfs://test/', m4mNFTRegistry.address);
    await m4mNFTRegistry.initialize(m4mComponent.address, m4mNFT.address);
    return {m4mNFT, m4mDao, m4mNFTRegistry, m4mComponent};
}

module.exports = {
    deploy
}