const {upgrades} = require("hardhat");

async function main() {
    // upgrade registry to v2
    const M4mNFTRegistryV2 = await ethers.getContractFactory('M4mNFTRegistryV2');
    await upgrades.upgradeProxy('0xc9d7d33f679000d7621ea381569259eb599ab1c4', M4mNFTRegistryV2);
    console.log("send M4mNFTRegistryV2 upgrade tx");
    // deploy SimpleM4mNFT V2
    const SimpleM4mNFTV2 = await ethers.getContractFactory('SimpleM4mNFTV2');
    const simpleNFT = await SimpleM4mNFTV2.deploy('Simple Meta-4d.me NFT V2', 'sM4MV2');
    console.log("deploy simple NFT V2 %s", simpleNFT.address);
    await simpleNFT.deployed();
    // deploy Zip V2
    const ZipV2 = await ethers.getContractFactory('ZipV2');
    const zip = await ZipV2.deploy('QmUbe9cwdyQDbcFjUTWW8untZwoQ2S6vy22ESKTW3MAdHs', "0x1a8a1dfd9063eae42a2b8339966fbea388430ca4",
        "0xc9d7d33f679000d7621ea381569259eb599ab1c4", "0xd8b1FB6c7f7A2d3Ed5CECF87cBa516c245f3BbAf", "0x77F9d4fFB0b535864f8d6D38f563a996B7d2aFd8");
    console.log("deploy ZipV2 %s", zip.address);
    // deploy baggage
    const M4mBaggage = await ethers.getContractFactory('M4mBaggage');
    const m4mBaggage = await upgrades.deployProxy(M4mBaggage, ["0xc9d7d33f679000d7621ea381569259eb599ab1c4"]);
    console.log("deploy M4mBaggage %s", m4mBaggage.address);
}

main().then()
