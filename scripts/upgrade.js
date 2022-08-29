async function main() {
    const M4mComponent = await ethers.getContractFactory('M4mComponent');
    await upgrades.upgradeProxy('0xb6bb4812a8e075cbad0128e318203553c4ca463d', M4mComponent);
    console.log("send M4mComponent upgrade tx");

    const M4mNFT = await ethers.getContractFactory('M4mNFT');
    await upgrades.upgradeProxy('0xba29d16b4488ec344ebd7e627df8c60b6b35f746', M4mNFT);
    console.log("send M4mNFT upgrade tx");
}

main().then()
