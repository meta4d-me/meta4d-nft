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

Set uri for specified token. Note that one msg. sender can only set one version of URI. If it is set multiple times,
only the latest URI will be retained

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
