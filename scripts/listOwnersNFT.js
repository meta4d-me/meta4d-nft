async function main() {
    const owner = '0x23324ed44904260fe555b18e5ba95c6030b9227d';
    const Loot = await ethers.getContractFactory('Loot');
    const loot = await Loot.attach('0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7');
    const balance = await loot.balanceOf(owner);
    console.log('balance is', balance.toString());
    for (let i = 0; balance.gt(i); i++) {
        const tokenId = await loot.tokenOfOwnerByIndex(owner, i);
        console.log(tokenId.toString(), await loot.getWeapon(tokenId));
    }
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });