const {create} = require('ipfs-http-client');
const ipfs = create({
    host: 'ipfs.infura.io',
    port: 5001,
    protocol: 'https'
})

describe("test simple M4mNFT", async () => {
    let simpleM4mNFT;
    let owner, accountA;
    it('init', async () => {
        const SimpleM4mNFT = await ethers.getContractFactory('SimpleM4mNFT');
        simpleM4mNFT = await SimpleM4mNFT.deploy("SimpleM4mNFT", "SM4m");
        [owner, accountA] = await ethers.getSigners();
    });
    it('mint nft', async () => {
        // upload image to ipfs
        const img0 = await ipfs.add({path: "../assets/SimpleM4mNFT-0.png"});
        const img1 = await ipfs.add({path: "../assets/SimpleM4mNFT-1.png"});
        // upload json file to ipfs
        let meta0 = {
            "description": "Simple Meta4d-me NFT(for test)",
            "external_url": "https://meta4d.me",
            "image": "ipfs://" + img0.cid.toString(),
            "name": "Simple M4m NFT 0",
            "attributes": [
                {
                    "trait_type": "Style",
                    "value": "3D"
                },
                {
                    "trait_type": "Glass",
                    "value": "Gray"
                },
                {
                    "trait_type": "Level",
                    "value": 1,
                },
                {
                    "display_type": "date",
                    "trait_type": "birthday",
                    "value": (Date.now() / 1000).toFixed()
                }
            ],
        };
        let meta1 = {
            "description": "Simple Meta4d-me NFT(for test)",
            "external_url": "https://meta4d.me",
            "image": "ipfs://" + img1.cid.toString(),
            "name": "Simple M4m NFT 1",
            "attributes": [
                {
                    "trait_type": "Style",
                    "value": "2D"
                },
                {
                    "trait_type": "Glass",
                    "value": "Dark"
                },
                {
                    "trait_type": "Level",
                    "value": 1,
                },
                {
                    "display_type": "date",
                    "trait_type": "birthday",
                    "value": (Date.now() / 1000).toFixed()
                }
            ],
        };
        const ipfsMeta0 = await ipfs.add(JSON.stringify(meta0));
        const ipfsMeta1 = await ipfs.add(JSON.stringify(meta1));
        await simpleM4mNFT.mint(owner.address, ipfsMeta0.cid.toString());
        await simpleM4mNFT.mint(accountA.address, "");
        await simpleM4mNFT.mint(owner.address, ipfsMeta1.cid.toString());
    })
    it('list all tokens of owner', async () => {
        const balance = await simpleM4mNFT.balanceOf(owner.address);
        for (let i = 0; balance.gt(i); i++) {
            const tokenId = await simpleM4mNFT.tokenOfOwnerByIndex(owner.address, i);
            const uri = await simpleM4mNFT.tokenURI(tokenId);
            console.log(tokenId, uri);
        }
    })
});
