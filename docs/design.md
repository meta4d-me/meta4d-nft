# Meta4d.me Contract Design Docs

## M4MDao

- set convertable list
    - determine which NFT could convert to M4M-NFT
- convert NFT to M4M-NFT
    - confirm whether NFT could be converted
    - save original NFT, mint M4M-NFT to user

## M4MNFTRegistry

- generate initial attributes for M4M-NFT
    - only operator could call
    - attributes is ERC1155, bind to M4M-NFT
    - attributes is saved by M4MNFTRegistry
- redeem NFT by burn M4M-NFT
    - require burn M4M-NFT with its initial attributes
- split initial attributes
    - could only be split once
    - unbind ERC1155 from M4M-NFT
    - transfer ERC1155 to user
- assemble attributes
    - require M4M-NFT owned any attributes or it has been split
    - could assemble any times
- split redundant attributes
    - could only be called after redeem
    - transfer ERC1155 to user