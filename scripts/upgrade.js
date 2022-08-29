async function main() {
    const M4mComponent = await ethers.getContractFactory('M4mComponent');
    await upgrades.upgradeProxy('0xb6bb4812a8e075cbad0128e318203553c4ca463d', M4mComponent);
    console.log("send M4mComponent upgrade tx");

    const M4mNFT = await ethers.getContractFactory('M4mNFT');
    await upgrades.upgradeProxy('0xfa860d48571fa0d19324cbde77e0fbdfdffb0a47', M4mNFT,{call:'initializeV2'});
    console.log("send M4mNFT upgrade tx");
}

main().then()
