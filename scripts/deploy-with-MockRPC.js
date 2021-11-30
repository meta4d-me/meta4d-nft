async function main() {
    const MockRPC = await ethers.getContractFactory("MockRPC");
    let rpc = await MockRPC.deploy();
    console.log('rpc deploy tx send, pending addr', rpc.address);
    await rpc.deployed();
    console.log('rpc deployed');
    let globalBurnRate = await rpc.globalBurnRate();

    const RPCRouter = await ethers.getContractFactory("RPCRouter");
    let router = await RPCRouter.deploy(rpc.address);
    console.log('RPCRouter deploy tx send, pending addr', router.address);
    await router.deployed();
    console.log('router deployed');

    const MetaMEME = await ethers.getContractFactory("MetaMEME");
    let meme = await MetaMEME.deploy(router.address, "http://api.meta4d.me/v1/meme/");
    console.log('MEME deploy tx send, pending addr', meme.address);
    await meme.deployed();
    console.log('meme deployed');
    await router.setFixedAmountFee(meme.address, 0, globalBurnRate);
    console.log('router config fixed mint MEME fee');

    const MetaMEME2 = await ethers.getContractFactory("MetaMEME2");
    let meme2 = await MetaMEME2.deploy(router.address);
    console.log('MEME2 deploy tx send, pending addr', meme2.address);
    await meme2.deployed();
    console.log('meme2 deployed');
    await router.setFixedAmountFee(meme2.address, 0, globalBurnRate);
    console.log('router config fixed mint MEME2 fee');

    const MetaBatchMeme = await ethers.getContractFactory("MetaBatchMEME");
    let batchMeme = await MetaBatchMeme.deploy();
    console.log('BatchMEME deploy tx send, pending addr', batchMeme.address);
    await batchMeme.deployed();
    console.log('batchMeme deployed');
    await router.setFixedAmountFee(batchMeme.address, 0, globalBurnRate);
    console.log('router config fixed mint BatchMEME fee');

    /* deploy market */
    const Market = await ethers.getContractFactory("Market");
    let marketLogic = await Market.deploy();
    console.log('Market deploy tx send, pending addr', marketLogic.address);
    await marketLogic.deployed();
    console.log('marketLogic deployed');

    const MarketProxy = await ethers.getContractFactory("MarketProxy");
    // we should specify gasLimit, because marketLogic has not deployed
    let marketState = await MarketProxy.deploy(marketLogic.address, Buffer.from(''), router.address, rpc.address);
    console.log('MarketProxy deploy tx send, pending addr', marketState.address);
    await marketState.deployed();
    console.log('marketState deployed');
    await router.setFixedRateFee(marketState.address, 0, globalBurnRate);
    console.log('router config market fee');

    let market = await Market.attach(marketState.address);
    await market.setSupportedNFT(meme.address, true);
    await market.setSupportedNFT(meme2.address, true);
    await market.setSupportedNFT(batchMeme.address, true);
    console.log('market supported MEME, MEME2, BatchMEME');

    let deployments = {
        MockRPC: rpc.address,
        RPCRouter: router.address,
        MetaMEME: meme.address,
        MetaMEME2: meme2.address,
        MetaBatchMeme: batchMeme.address,
        Market: marketLogic.address,
        MarketProxy: marketState.address,
    };
    console.log('deploy successfully', deployments);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
