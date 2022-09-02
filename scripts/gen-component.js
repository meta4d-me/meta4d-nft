async function genComponent() {
    let M4mComponent = await ethers.getContractFactory('M4mComponent');
    let contract = await M4mComponent.attach('0xb6bb4812a8e075cbad0128e318203553c4ca463d');
    const components = [
        {
            name: "Skull Head",
            symbol: "SH",
            id: 31,
        },
        {
            name: "Clown Head",
            symbol: "CH",
            id: 32,
        },
        {
            name: "Dirty Braid Explosive Hair",
            symbol: "DBEH",
            id: 33,
        },
        {
            name: "Headphones",
            symbol: "HH",
            id: 34,
        },
        {
            name: "Hip hop Sunglasses",
            symbol: "HHS",
            id: 35,
        },
        {
            name: "Football in Hand",
            symbol: "FiH",
            id: 36,
        },
        {
            name: "Laptop in Hand",
            symbol: "LiH",
            id: 37,
        },
        {
            name: "Coffee Cup in Hand",
            symbol: "CCiH",
            id: 38,
        },
        {
            name: "Light Saber in Hand",
            symbol: "LSiH",
            id: 39,
        },
        {
            name: "Keyboard in Hand",
            symbol: "KiH",
            id: 40,
        }
    ];
    const owner = await ethers.getSigner();
    let startNonce = await ethers.provider.getTransactionCount(owner.address);
    for (const component of components) {
        let tx = await contract.prepareNewToken(component.id, component.name, component.symbol, {nonce: startNonce});
        console.log("prepare tx %s for %s", tx.hash, component.id);
        startNonce++;
    }
}

genComponent().then();
