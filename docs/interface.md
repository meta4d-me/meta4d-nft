# Meta-4d.me Contract Interface

## Convert NFT to M4M-NFT

```solidity
    function convertNFT(IERC721 original, uint originalTokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) external;
```

### usage

```js
/* generate param */
let hash = ethers.utils.solidityKeccak256(['bytes'],
    [ethers.utils.solidityPack(['address', 'uint'],
        [original_addr, ethers.BigNumber.from(original_token_id)])]);
let m4m_token_id = ethers.BigNumber.from(hash);
let componentIds = [1, 2, 3, 4];
let componentNums = componentIds.map(r => ethers.BigNumber.from(1));
const sigHash = ethers.utils.solidityKeccak256(['bytes'],
    [ethers.utils.solidityPack(['uint', `uint[${componentIds.length}]`, `uint[${componentNums.length}]`],
        [m4m_token_id, componentIds, componentNums])]);
const operator = new ethers.utils.SigningKey('0x' + 'OPERATOR_PRIV_KEY');
const sig = ethers.utils.joinSignature(await operator.signDigest(sigHash));
/* invoke contract */
// set approve to registry
original.setApprovalForAll(m4mRegistry.address);
// convert
m4mRegistry.convertNFT(original_addr, original_token_id, componentIds, componentNums, sig);
```

## Split and Assemble

```solidity
    function splitM4mNFT(uint m4mTokenId, uint[]memory componentIds, uint[]memory amounts) external;

    function assembleM4mNFT(uint m4mTokenId, uint[]memory componentIds, uint[]memory amounts) external;
```

## Redeem

```solidity
    function redeem(uint m4mTokenId, uint[]memory componentIds, uint[]memory amounts) external;
```

## Lock and Unlock

```solidity
    function lock(uint m4mTokenId) external;

    function unlock(uint m4mTokenId) external;
```

## Query Info

```solidity
    enum TokenStatus{NotExist, Initialized, Locked, Redeemed}
/// @return TokenStatus status of token
/// @return bytes32 original attr hash of m4m nft
/// @return IERC721 converted nft address
/// @return uint converted nft token id
    function getTokenStatus(uint m4mTokenId) external view returns (TokenStatus, bytes32, IERC721, uint);

// return amount of component specified by componentId
    function getTokenComponentAmount(uint m4mTokenId, uint componentId) external view returns (uint);

// return amounts of component specified by componentIds
    function getTokenComponentAmounts(uint m4mTokenId, uint[] memory componentIds) external view returns (uint[] memory);
```

## Set URI of specified version

```solidity
struct Token {
    uint chainId;
    address nft;
    uint tokenId;
}

    function setInfo(Token memory token, string memory uri) external;
```

Set uri for specified token. Note that one msg.sender can only set one version of URI. If it is set multiple times,
only the latest URI will be retained

## Set URI of specified version By Permit

```solidity
function setInfoByPermit(Token memory token, string memory uri, bytes memory sig) external;
```

The version creator is signer that generate `sig`.

> [how to generate sig](../test/TestVersionNFT.js#L29-L41)

## Get URI of specified version

```solidity
function getInfo(Token memory token, address creator) external view returns (string memory);
```

return the URI set by msg.sender.

## Get all URI info

```solidity
function getLatestInfoAll(Token memory token) external view returns (address[] memory creators, string[] memory uris);
```

Returns all URIs set by all msg.senders.

## Zip

### mint M4M-NFT

```solidity
function mintM4mNFT(address owner, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) external;
```

zip mint simple m4m nft and convert simple to M4M nft at one transaction.

### mint M4M-NFT V2

```solidity
function mintM4mNFTV2(address owner, uint originalTokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) external;
```

zip mint simple m4m nft v2 and convert simple to M4M nft at one transaction, user should specify the tokenId of simple
m4m nft v2.

#### Usage

```js
let SimpleM4mNFT = await ethers.getContractFactory('SimpleM4mNFT')
let simpleM4mNFT = await SimpleM4mNFT.attach('0x1a8a1dfd9063eae42a2b8339966fbea388430ca4');
let tokenId = await simpleM4mNFT.tokenIndex();
// request to m4m backend to get convert params
let resp = await request(`/api/v1/m4m-nft/initialization?original_addr=${simpleM4mNFT.address}&&original_token_id=${tokenId.toString()}&&chain_name=mumbai`);
let Zip = await ethers.getContractFactory('Zip');
let zip = await Zip.attach('0x3eb8c78d907342bd216ee122b8fcb9ca6bad4bfb');
// mint M4M-NFT to `to` address
await zip.mintM4mNFT(to, resp.component_ids, resp.component_nums, resp.sig);
```

### change components

```solidity
function changeComponents(uint m4mTokenId, uint[]memory outComponentIds, uint[]memory outAmounts,
    uint[]memory inComponentIds, uint[]memory inAmounts) external;
```

zip split and assemble M4M nft at one transaction.

#### Usage

```js
// set M4M NFT and M4MComponent approval to zip contract
await m4mNFT.setApprovalForAll(zip.address, true);
await components.setApprovalForAll(zip.address, true);
let outComponentIds = [1, 2, 3];
let outAmounts = [1, 1, 1];
let inComponentIds = [11, 12, 13];
let inAmounts = [1, 1, 1];
await zip.changeComponents(m4mNFTId, outComponentIds, outAmounts, inComponentIds, inAmounts);
```

### change components and record old version

```solidity
function changeComponentsAndRecordVersion(uint m4mTokenId, uint[]memory outComponentIds, uint[]memory outAmounts,
    uint[]memory inComponentIds, uint[]memory inAmounts, string memory oldVersion) external;
```

zip split and assemble M4M nft at one transaction.

#### Usage

```js
// set M4M NFT and M4MComponent approval to zip contract
await m4mNFT.setApprovalForAll(zip.address, true);
await components.setApprovalForAll(zip.address, true);
let outComponentIds = [1, 2, 3];
let outAmounts = [1, 1, 1];
let inComponentIds = [11, 12, 13];
let inAmounts = [1, 1, 1];
let oldVersion = "ipfs://oldoldoldoldold"
await zip.changeComponentsAndRecordVersion(m4mNFTId, outComponentIds, outAmounts, inComponentIds, inAmounts, oldVersion);
```

## Baggage

Refer [interface](../contracts/interfaces/IM4mBaggage.sol) and [case](../test/TestBaggage.js)

### game begin

```solidity
function gameBegin(uint gameId, string memory uuid, uint m4mTokenId, uint[] memory inComponentIds, uint[] memory inAmounts) external;
```

- gameId: identification of game
- uuid: unique id of each round of each game
- m4mTokenId: token id of M4M-NFT
- inComponents: used components, transfer into baggage and locked into M4M-NFT
- inAmounts: the amounts of corresponding inComponents;

### game end

settle use state after game end.

```solidity
function gameEnd(uint m4mTokenId,
    uint[] memory lootIds, uint[] memory lootAmounts,
    uint[] memory lostIds, uint[] memory lostAmounts,
    bytes memory operatorSig, bytes memory gameSignerSig) external;
```

- m4mTokenId: token id of M4M-NFT
- lootIds: the components that rewarded by users
- lootAmounts: the amounts of corresponding lootIds
- lostIds: the components that lost by users
- lostAmounts: the amounts of corresponding lostIds
- operatorSig: sig of game operator, generated method is [here](../test/TestBaggage.js#L91)
- gameSignerSig: sig of game signer, generated method is [here](../test/TestBaggage.js#L92)

### lockComponents

```solidity
function lockComponents(uint m4mTokenId, uint gameId, uint[] memory inComponentIds, uint[] memory inAmounts);
```

- lock user's components to `gameId` game
- the corresponding M4M-NFT of `m4mTokenId` should be empty, and could be minted at any time later
    - If the TokenId on the chain of M4M-NFT subsequently mint is required to be consistent with this `m4mTokenId`,
      the `m4mTokenId` should be generated by BigNumber.from(keccak256(abi.encodePacked(originalNFTAddr,
      originalTokenId))), refer [here](../test/TestBaggage.js#L29-L31). The originalNFT should be controlled by game
      owner.

### appendLock

```solidity
function appendLock(uint m4mTokenId, uint[] memory inComponentIds, uint[] memory inAmounts) external;
```

- lock user's components to locked game
- the role corresponding to `m4mTokenId` should be locked

### unlockComponents

```solidity
function unlockComponents(uint m4mTokenId, uint nonce, uint[] memory outComponentIds, bytes memory operatorSig, bytes memory gameSignerSig);
```

- unlock user's all components of `outComponentIds`
- delete lock record

> note: Because the contract will delete the lock record, all locked components of the user need to be passed as params
> when unlocking, otherwise the remaining components will be locked in the contract and cannot be taken out

### settleLoots

```solidity
function settleLoots(uint m4mTokenId, uint nonce,
    uint[] memory lootIds, uint[] memory lootAmounts,
    uint[] memory lostIds, uint[] memory lostAmounts,
    bytes memory operatorSig, bytes memory gameSignerSig);
```

- mint `lootIds` components to user's address
- burn `lostIds` components from locked components
- nonce is used to prevent replay attacks, and is strictly incremented by 1 from 1, that is, init nonce value should be
  1, not 0. And after value should be 2,3,4...
