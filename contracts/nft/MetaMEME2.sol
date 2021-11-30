// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import {IRPCRouter} from '../RPCRouter.sol';

/// @dev MEME is Meta NFT example, maybe some emoji, some cop?
/// @dev use IPFS to store NFT resource, so we specify uri when user mint nft
contract MetaMEME2 is ERC721, Ownable {

    IRPCRouter public rpcRouter;

    uint public tokenIndex;

    bool public mintPaused;

    mapping(uint => string) private tokenUri;

    mapping(uint => address) public minter;

    /* event */
    event MintPaused(bool paused);
    event BaseURIUpdated(string oldURI, string newURI);

    constructor(IRPCRouter router)ERC721("Meta MEME", "META-MEME") Ownable(){
        rpcRouter = router;
    }

    function pauseMint(bool paused) public onlyOwner {
        mintPaused = paused;
        emit MintPaused(paused);
    }

    /// @notice everyone could mint Meta MEME
    /// @notice we use a simple auto-increment tokenId
    function mint(address to, string memory uri) public {
        require(!mintPaused, 'mint paused');
        rpcRouter.spendRPCWithFixedAmountFee(msg.sender);
        _mint(to, tokenIndex);
        tokenUri[tokenIndex] = uri;
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }

    function safeMint(address to, string memory uri) public {
        require(!mintPaused, 'mint paused');
        rpcRouter.spendRPCWithFixedAmountFee(msg.sender);
        _safeMint(to, tokenIndex);
        tokenUri[tokenIndex] = uri;
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }
    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenUri[tokenId];
    }
}
