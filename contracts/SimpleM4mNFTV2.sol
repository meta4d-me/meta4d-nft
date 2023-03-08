// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract SimpleM4mNFTV2 is ERC721Enumerable {

    bool public mintPaused;

    mapping(uint => string) private metaUri;

    mapping(uint => address) public minter;

    constructor(string memory name_, string memory symbol_)ERC721(name_, symbol_){}

    modifier tokenIdNotUsed(uint tokenId){
        require(minter[tokenId] == address(0), "tokenId used");
        _;
    }

    function mint(uint tokenIndex, address to, string memory ipfsHash) public tokenIdNotUsed(tokenIndex) {
        _mint(to, tokenIndex);
        metaUri[tokenIndex] = ipfsHash;
        minter[tokenIndex] = msg.sender;
    }

    function safeMint(uint tokenIndex, address to, string memory ipfsHash) public tokenIdNotUsed(tokenIndex) {
        _safeMint(to, tokenIndex);
        metaUri[tokenIndex] = ipfsHash;
        minter[tokenIndex] = msg.sender;
    }

    function safeMintBatch(uint[] memory tokenIndex, address to, string memory ipfsHash) public {
        for (uint i = 0; i < tokenIndex.length; i++) {
            safeMint(tokenIndex[i], to, ipfsHash);
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked('ipfs://', metaUri[tokenId]));
    }
}
