const deploy = require('./deploy');

async function main() {
    const contracts = await deploy.deploy();
    const addresses = {
        m4mDAO: contracts.m4mDao.address,
        m4mNFT: contracts.m4mNFT.address,
        m4mRegistry: contracts.m4mNFTRegistry.address,
        m4mComponent: contracts.m4mComponent.address,
        simpleM4mNFT: contracts.simpleM4mNFT.address,
    }
    console.log(JSON.stringify(addresses));
}

main().then();
