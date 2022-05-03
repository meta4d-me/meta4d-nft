// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol';

import './interfaces/IM4mNFT.sol';

// @dev config attribute value when mint NFT
contract M4mNFT is OwnableUpgradeable, ERC721EnumerableUpgradeable, IM4mNFT {

    string private baseURI;
    IM4mNFTRegistry public override registry;
    IM4mDAO public override dao;

    function initialize(string memory __baseURI, IM4mNFTRegistry _registry, IM4mDAO _dao) public initializer {
        __Ownable_init_unchained();

        baseURI = __baseURI;
        registry = _registry;
        dao = _dao;
    }

    function burn(uint256 tokenId) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "caller is not owner nor approved");
        _burn(tokenId);
    }

    function mintByRegistry(address to)
    public override returns (uint tokenId){
        require(msg.sender == address(registry));
        tokenId = totalSupply();
        _safeMint(to, tokenId);
    }

    function mint(address to) public override returns (uint tokenId){
        require(msg.sender == owner() || msg.sender == address(dao), 'only owner or dao');
        tokenId = totalSupply();
        _safeMint(to, tokenId);
    }

    function mintBatch(address to, uint num) public onlyOwner override returns (uint tokenId){
        tokenId = totalSupply();
        for (uint i = 0; i < num; i++) {
            _safeMint(to, tokenId + i);
        }
    }

    function mintBatch(address[] memory to, uint num) public onlyOwner override returns (uint tokenId){
        require(to.length == num, 'ill param');
        tokenId = totalSupply();
        for (uint i = 0; i < num; i++) {
            _safeMint(to[i], tokenId + i);
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
