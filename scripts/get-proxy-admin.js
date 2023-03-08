const {upgrades} = require("hardhat");

async function main() {
    // registry
    let admin = await upgrades.erc1967.getAdminAddress("0xc9d7d33f679000d7621ea381569259eb599ab1c4");
    console.log(admin);
    // dao
    admin = await upgrades.erc1967.getAdminAddress("0x38cd1db1b3eafee726f790470bd675d2d7850a86");
    console.log(admin);
    // m4m nft
    admin = await upgrades.erc1967.getAdminAddress("0xfa860d48571fa0d19324cbde77e0fbdfdffb0a47");
    console.log(admin);
    // component
    admin = await upgrades.erc1967.getAdminAddress("0xb6bb4812a8e075cbad0128e318203553c4ca463d");
    console.log(admin);
}

main().then()
