async function main() {
    const M4mNFTRegistry = await ethers.getContractFactory('M4mNFTRegistry');
    await upgrades.upgradeProxy('0xb8c01243da1bdba77f02e2f805bfacc461020d47',M4mNFTRegistry);
    console.log("send M4mNFTRegistry upgrade tx");

    const M4mNFT = await ethers.getContractFactory('M4mNFT');
    await upgrades.upgradeProxy('0xba29d16b4488ec344ebd7e627df8c60b6b35f746',M4mNFT);
    console.log("send M4mNFT upgrade tx");
}

main().then()
