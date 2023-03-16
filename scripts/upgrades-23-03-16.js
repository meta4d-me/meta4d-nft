const {upgrades} = require("hardhat");

async function main() {
    // upgrade components
    const M4mComponentV2 = await ethers.getContractFactory('M4mComponentV2');
    await upgrades.upgradeProxy('0xb6bb4812a8e075cbad0128e318203553c4ca463d', M4mComponentV2, {
        call: {
            fn: 'initializeV2',
            args: ['0xdd5b1C4685A34Ff07A21Ca2507D4b80e60EbC85f']
        }
    })
    console.log("send M4mComponentV2 upgrade tx");
    // upgrade M4mBaggageWithoutRole
    const M4mBaggageWithoutRole = await ethers.getContractFactory('M4mBaggageWithoutRole');
    await upgrades.upgradeProxy('0xdd5b1C4685A34Ff07A21Ca2507D4b80e60EbC85f', M4mBaggageWithoutRole)
    console.log("send M4mBaggageWithoutRole upgrade tx");
}

main().then()
