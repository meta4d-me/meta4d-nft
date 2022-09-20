async function deploy() {
    const M4mNFTRegistry = await ethers.getContractFactory('M4mNFTRegistry');
    const m4mNFTRegistry = await upgrades.deployProxy(M4mNFTRegistry, [], {initializer: false});
    console.log("send M4mNFTRegistry deploy tx", m4mNFTRegistry.deployTransaction.hash);

    const M4mNFT = await ethers.getContractFactory('M4mNFT');
    const m4mNFT = await upgrades.deployProxy(M4mNFT, ['ipfs://test/', m4mNFTRegistry.address]);
    console.log("send M4mNFT deploy tx", m4mNFT.deployTransaction.hash);

    const M4mDao = await ethers.getContractFactory('M4mDao');
    const m4mDao = await upgrades.deployProxy(M4mDao, []);
    console.log("send M4mDao deploy tx", m4mDao.deployTransaction.hash);

    const M4mComponent = await ethers.getContractFactory('M4mComponent');
    const m4mComponent = await upgrades.deployProxy(M4mComponent, [m4mNFTRegistry.address]);
    console.log("send M4mComponent deploy tx", m4mComponent.deployTransaction.hash);

    const SimpleM4mNFT = await ethers.getContractFactory('SimpleM4mNFT');
    const simpleM4mNFT = await SimpleM4mNFT.deploy('Simple Meta-4d.me NFT', 'sM4M');
    console.log("send SimpleM4mNFT deploy tx", simpleM4mNFT.deployTransaction.hash);

    await m4mNFTRegistry.deployed();
    console.log("m4mNFTRegistry deployed");
    await m4mNFT.deployed();
    console.log("m4mNFT deployed");
    await m4mDao.deployed();
    console.log("m4mDao deployed");
    await m4mComponent.deployed();
    console.log("m4mComponent deployed");
    await simpleM4mNFT.deployed();
    console.log("simpleM4mNFT deployed");

    await m4mNFTRegistry.initialize(m4mComponent.address, m4mNFT.address, m4mDao.address);
    console.log("m4mNFTRegistry initialized");
    const [_, operator] = await ethers.getSigners()
    await m4mNFTRegistry.setOperator(operator.address);
    console.log("m4mNFTRegistry setOperator");

    return {m4mNFT, m4mDao, m4mNFTRegistry, m4mComponent, simpleM4mNFT};
}

module.exports = {
    deploy
}
