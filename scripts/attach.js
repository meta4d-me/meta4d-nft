async function deploy() {
    const M4mNFTRegistry = await ethers.getContractFactory('M4mNFTRegistry');
    const m4mNFTRegistry = await M4mNFTRegistry.attach('0xc9d7d33f679000d7621ea381569259eb599ab1c4');

    const M4mNFT = await ethers.getContractFactory('M4mNFT');
    const m4mNFT = await M4mNFT.attach('0xfa860d48571fa0d19324cbde77e0fbdfdffb0a47');

    const M4mDao = await ethers.getContractFactory('M4mDao');
    const m4mDao = await M4mDao.attach('0x38cd1db1b3eafee726f790470bd675d2d7850a86');

    const M4mComponent = await ethers.getContractFactory('M4mComponent');
    const m4mComponent = await M4mComponent.attach('0xb6bb4812a8e075cbad0128e318203553c4ca463d');

    const SimpleM4mNFT = await ethers.getContractFactory('SimpleM4mNFT');
    const simpleM4mNFT = await SimpleM4mNFT.attach('0x1a8a1dfd9063eae42a2b8339966fbea388430ca4');

    return {m4mNFT, m4mDao, m4mNFTRegistry, m4mComponent, simpleM4mNFT};
}

module.exports = {
    deploy
}
