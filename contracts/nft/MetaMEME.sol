// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import {IRPCRouter} from '../RPCRouter.sol';

/// @dev MEME is Meta NFT example, maybe some emoji, some cop?
contract MetaMEME is ERC721, Ownable {

    IRPCRouter public rpcRouter;

    uint public tokenIndex;
    string public baseURI;

    bool public mintPaused;

    mapping(uint => address) public minter;

    /* event */
    event MintPaused(bool paused);
    event BaseURIUpdated(string oldURI, string newURI);

    constructor(IRPCRouter router, string memory uri)ERC721("Meta MEME", "META-MEME") Ownable(){
        rpcRouter = router;
        baseURI = uri;
    }

    function pauseMint(bool paused) public onlyOwner {
        mintPaused = paused;
        emit MintPaused(paused);
    }

    /// @notice everyone could mint Meta MEME
    /// @notice we use a simple auto-increment tokenId
    function mint(address to) public {
        require(!mintPaused, 'mint paused');
        rpcRouter.spendRPCWithFixedAmountFee(msg.sender);
        _mint(to, tokenIndex);
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }

    function safeMint(address to) public {
        require(!mintPaused, 'mint paused');
        rpcRouter.spendRPCWithFixedAmountFee(msg.sender);
        _safeMint(to, tokenIndex);
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        string memory oldURI = baseURI;
        baseURI = newBaseURI;
        emit BaseURIUpdated(oldURI, newBaseURI);
    }

    function _baseURI() internal override view returns (string memory){
        return baseURI;
    }
}
