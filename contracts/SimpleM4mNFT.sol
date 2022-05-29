// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract SimpleM4mNFT is ERC721Enumerable {

    uint public tokenIndex;

    bool public mintPaused;

    mapping(uint => string) private metaUri;

    mapping(uint => address) public minter;

    constructor(string memory name_, string memory symbol_)ERC721(name_, symbol_){}

    function mint(address to, string memory ipfsHash) public {
        _mint(to, tokenIndex);
        metaUri[tokenIndex] = ipfsHash;
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }

    function safeMint(address to, string memory ipfsHash) public {
        _safeMint(to, tokenIndex);
        metaUri[tokenIndex] = ipfsHash;
        minter[tokenIndex] = msg.sender;
        tokenIndex++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked('ipfs://', metaUri[tokenId]));
    }
}
