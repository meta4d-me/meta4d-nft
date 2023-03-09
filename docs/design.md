# Meta4d.me Contract Design Docs

## Definition

### Account

A user address is regarded as a user account.

### Game Role

One account can own unlimited number of game roles. The role is `M4M NFT` on chain.

Users are allowed to convert their own NFT (OriginalNFT) to 'M4M NFT'. The system will allocate initial equipment to
users' roles (M4M-NFT) according to the rarity of OriginalNFT.

Currently, there are two types of OriginalNFT that can be converted: SimpleM4mNFT and SimpleM4mNFTV2.

The conversion of OriginalNFT to M4M-NFT involves the distribution of equipment, so the signature of M4M operator is
required. The current signature function is placed in m4m-backend.

When calling m4m-backend to get the signature required by the conversion process, you need to provide the m4mTokenId
parameter. This parameter is the identification of M4M NFT on the chain, which is a 256 bit Uint. The generation method
of this parameter is keccak256(abi.encodePackaged(originalNFTAddress,originalNFTTokenId)). This parameter can be
generated offline by itself.

#### SimpleM4mNFT

SimpleM4mNFT is an NFT contract that allows users to mint NFT by themselves. Its tokenId is controlled by the contract
and is a self-increasing ID (called tokenIndex). Each minting, the tokenIndex increases by 1.

You can read its current tokenIndex from chain, and use the tokenIndex as the tokenId to generate m4mTokenId. If
multiple users read the tokenIndex at same time, the same m4mTokenId will be generated. If it is a concurrent `read` ->
`Generating m4mTokenId` -> `calling m4mBackend to obtain signature` -> `converting to M4M-NFT` will cause concurrency
problems, that is, multiple users will get the same M4M-NFT parameters, but only one user will get M4M-NFT. That is,
only one user can successfully create a role.

#### SimpleM4mNFTV2

SimpleM4mNFTV2 improves the shortcomings of SimpleM4mNFT, and its tokenId is controlled off chain. Therefore, in case of
concurrency, each user can be assigned a different tokenId.

#### Zip合约

When creating a Role, users need to mint SimpleM4mNFT first, and then convert it to M4M-NFT. This requires users to send
two transactions. So the Zip contract is used to package two transactions into one. The user only needs to call the Zip
contract once to complete the conversion process.

In addition, the zip contract can also help users to complete one-key replacement, that is, the user's disassembly and
dressing components are combined into a transaction.

### Component

Component is all game props such as equipment, fashion, potion, etc. Each prop is distinguished by a 256 bit Uint.

A Role can carry an unlimited number of Components at the contract. User binds the component to Role through the
contract interface of wearing equipment, and takes off the component through the contract interface of dismantling
equipment.

The component on the contract belongs to M4M-NFT, which is transferred with the transfer of M4M-NFT. Only the
disassembled component can be transferred separately.

### Baggage

Baggage is not a backpack in the game concept, but an auxiliary contract, which is used to assist users to enter the
game and lock the role (put on, take off some specified components, and then lock).

At the same time, Baggage also manages the signer and operator of each game as the management contract of game signature
authority.

Baggage supports both NFT-owned and NFT-empty roles. Note that these two roles cannot be mixed when locking and
unlocking.

## Contracts

### M4MDao

- set convertable list
    - determine which NFT could convert to M4M-NFT

### M4M-NFT

- only registry could mint and burn

### M4MNFTRegistry

- convert NFT to M4M-NFT
    - confirm whether NFT could be converted
    - save original NFT, mint M4M-NFT to user
    - generate initial attributes for M4M-NFT, operator sign attributes
    - attributes is ERC1155, bind to M4M-NFT
    - attributes is saved by M4MNFTRegistry
- split attributes
    - unbind ERC1155 from M4M-NFT
    - transfer ERC1155 to user
    - if there are redundant attributes after redeem, anyone could get these
- assemble attributes
    - require M4M-NFT owned any attributes or it has been split
    - could assemble any times
- redeem NFT by burn M4M-NFT
    - require burn M4M-NFT with its initial attributes
- lock and unlock
    - could not transfer, split, assemble and redeem locked token
- claim loots
    - mint components to user after game end, require operator sig

### SimpleM4mNFT

SimpleM4mNFT is temporarily used as the user's original NFT, which can be mint by the user.

### Zip

-Package the process of creating roles into a transaction.
-Package the change (wear and take off) components into a transaction.

### Baggage

- Package the operations that users need to perform when entering the game into a transaction
    - Transferring the user's M4M-NFT into Baggage contract (equivalent to locking the user's role in the chain)
    - Assemble the equipment users need to bring into the game on the M4M-NFT
    - Lock M4M-NFT
- Settle a game
    - Destroy the components lost by the user (for example, equipment lost to other users, or consumables used)
    - Distribute the loots to the user, directly send it to the user's account address, not assemble it to the role
    - unlock M4M-NFT
    - Turn M4M-NFT back to the user
    - This function requires the signature of the game's signer or operator, and the user sends the transaction
        - Three roles: user, game signer, and operator. The results can be settled after two roles are approved
        - The user acknowledges this result by sending a transaction, and the singer/operator's sign this result. If
          the user refuses to accept the game result, anyone could send a transaction after obtaining the signature of
          the signer and operator to settle the game

> note: lock and settle is 1-1 corresponding. If the lock is a Role with M4M-NFT, it can only be settled once, and then
> the NFT will be unlocked. If the lock is a Role without M4M-NFT, it can be settled multiple times, and should unlock
> manually.
