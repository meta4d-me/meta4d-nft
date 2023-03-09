const {Contract} = require("ethers");
const {Provider} = require("@ethersproject/providers");

// connect to wallet or rpc endpoint
const provider = new Provider('node url');
// create contract instance
const baggage = new Contract('baggage address', 'abi', provider);
/* lock components */
// user selected component or game server selected
let inComponentIds = [1, 2, 3];
let inComponentAmounts = [1, 1, 1];
// a unique id to identify this role, should be Numberish
let m4mTokenId = 12312312312313;
// pre-assigned id for the game
let gameId = 1;
let tx = await baggage.lockComponents(m4mTokenId, gameId, inComponentIds, inComponentAmounts);
console.log("lock component to enter game, %s", tx.hash)

/* settle loots */
let lootIds = [6];
let lootAmounts = [1];
let lostIds = [5];
let lostAmounts = [1];
let nonce = 1;
// a hex-encoded signature
let signerSig = await sigServer.signSettleLoots(m4mTokenId, nonce, lootIds, lootAmounts, lostIds, lostAmounts);
let sig = Buffer.from(signerSig.substring(2), 'hex');
tx = await baggage.settleLoots(m4mTokenId, nonce, lootIds, lootAmounts, lostIds, lostAmounts, sig, Buffer.from(''));
console.log("settle loots, %s", tx.hash)

/* unlock components after game over */
let outIds = [5];
signerSig = await sigServer.signUnlockComponents(m4mTokenId, outIds);
sig = Buffer.from(signerSig.substring(2), 'hex');
tx = await baggage.unlockComponents(m4mTokenId, outIds, sig, Buffer.from(''));
console.log("unlock components after game over, %s", tx.hash)
