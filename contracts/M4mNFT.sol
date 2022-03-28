// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol';

// @dev Meta-4d for me NFT with random attributes
contract M4mNFT is ERC721EnumerableUpgradeable {

    string[] private style;
    string[] private hair;
    string[] private complexion;
    string[] private upper;
    string[] private lower;
    string[] private shoesAndSocks;
    string[] private tattoo;
    string[] private earrings;
    string[] private necklace;
    string[] private glass;
    string[] private backendEnv;
    string[] private frontendEnv;

    /* initialize */
    function initialize() public initializer {
        __ERC721Enumerable_init();
        style = ['2D', '3D'];
    }

    // tokenId starts from 0
    function mint(address to) public {
        _safeMint(to, totalSupply());
    }

    /* view function */
    function getStyle(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'style', style);
    }

    function getHair(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'hair', hair);
    }

    function getComplexion(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'complexion', complexion);
    }

    function getUpper(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'upper', upper);
    }

    function getLower(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'lower', lower);
    }

    function getShoesAndSocks(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'shoesAndSocks', shoesAndSocks);
    }

    function getEarrings(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'earrings', earrings);
    }

    function getNecklace(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'necklace', necklace);
    }

    function getGlass(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'glass', glass);
    }

    function getBackendEnv(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'backendEnv', backendEnv);
    }

    function getFrontendEnv(uint tokenId) public virtual view returns (string) {
        return pluck(tokenId, 'frontendEnv', frontendEnv);
    }

    /* private function */
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId))));
        string memory output = sourceArray[rand % sourceArray.length];
        return output;
    }
}
