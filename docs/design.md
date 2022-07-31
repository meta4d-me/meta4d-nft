# Meta4d.me Contract Design Docs

## M4MDao

- set convertable list
    - determine which NFT could convert to M4M-NFT

## M4M-NFT

- only registry could mint and burn

## M4MNFTRegistry

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