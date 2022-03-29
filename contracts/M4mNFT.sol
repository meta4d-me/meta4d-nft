// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol';

import './interfaces/IM4mNFT.sol';
import './interfaces/IM4mNFTRegistry.sol';

// @dev config attribute value when mint NFT
contract M4mConfigurableNFT is OwnableUpgradeable, ERC721EnumerableUpgradeable, IM4mNFT {

    string private baseURI;
    IM4mNFTRegistry public override registry;

    /* override attributes */
    mapping(uint => uint) public override getStyle;

    mapping(uint => uint) public override getHair;

    mapping(uint => uint)public override  getComplexion;

    mapping(uint => uint)public override  getUpper;

    mapping(uint => uint) public override getLower;

    mapping(uint => uint) public override getShoesAndSocks;

    mapping(uint => uint) public override getEarrings;

    mapping(uint => uint) public override getNecklace;

    mapping(uint => uint) public override getGlass;

    mapping(uint => uint) public override getBackendEnv;

    mapping(uint => uint) public override getFrontendEnv;

    function initialize(string memory __baseURI, IM4mNFTRegistry _registry) public initializer {
        __Ownable_init_unchained();

        baseURI = __baseURI;
        registry = _registry;
    }

    function mintByRegistry(address to, uint style, uint hair, uint complexion,
        uint upper, uint lower, uint shoesAndSocks, uint earrings,
        uint necklace, uint glass, uint backendEnv, uint frontendEnv)
    public override returns (uint tokenId){
        require(msg.sender == address(registry));
        tokenId = totalSupply();
        _mint(to, tokenId, style, hair, complexion, upper, lower, shoesAndSocks, earrings, necklace, glass,
            backendEnv, frontendEnv);
    }

    function mintByOwner(address to, uint style, uint hair, uint complexion,
        uint upper, uint lower, uint shoesAndSocks, uint earrings,
        uint necklace, uint glass, uint backendEnv, uint frontendEnv)
    public override onlyOwner returns (uint tokenId){
        tokenId = totalSupply();
        _mint(to, tokenId, style, hair, complexion, upper, lower, shoesAndSocks, earrings, necklace, glass,
            backendEnv, frontendEnv);
    }

    function mint(address to) public override returns (uint tokenId){
        tokenId = totalSupply();
        uint style = pluck(tokenId, IM4mNFTRegistry.AttrName.STYLE);
        uint hair = pluck(tokenId, IM4mNFTRegistry.AttrName.HAIR);
        uint complexion = pluck(tokenId, IM4mNFTRegistry.AttrName.COMPLEXION);
        uint upper = pluck(tokenId, IM4mNFTRegistry.AttrName.UPPER);
        uint lower = pluck(tokenId, IM4mNFTRegistry.AttrName.LOWER);
        uint shoesAndSocks = pluck(tokenId, IM4mNFTRegistry.AttrName.SHOES_AND_SOCKS);
        uint earrings = pluck(tokenId, IM4mNFTRegistry.AttrName.EARRINGS);
        uint necklace = pluck(tokenId, IM4mNFTRegistry.AttrName.NECKLACE);
        uint glass = pluck(tokenId, IM4mNFTRegistry.AttrName.GLASS);
        uint backendEnv = pluck(tokenId, IM4mNFTRegistry.AttrName.BACKEND_ENV);
        uint frontendEnv = pluck(tokenId, IM4mNFTRegistry.AttrName.FRONTEND_ENV);

        _mint(to, tokenId, style, hair, complexion, upper, lower, shoesAndSocks, earrings, necklace, glass, backendEnv,
            frontendEnv);
    }

    function _mint(address to, uint tokenId, uint style, uint hair, uint complexion,
        uint upper, uint lower, uint shoesAndSocks, uint earrings,
        uint necklace, uint glass, uint backendEnv, uint frontendEnv) private {

        getStyle[tokenId] = style;
        getHair[tokenId] = hair;
        getComplexion[tokenId] = complexion;
        getUpper[tokenId] = upper;
        getLower[tokenId] = lower;
        getShoesAndSocks[tokenId] = shoesAndSocks;
        getEarrings[tokenId] = earrings;
        getNecklace[tokenId] = necklace;
        getGlass[tokenId] = glass;
        getBackendEnv[tokenId] = backendEnv;
        getFrontendEnv[tokenId] = frontendEnv;

        _safeMint(to, tokenId);
    }

    function pluck(uint256 tokenId, IM4mNFTRegistry.AttrName attrName) private view returns (uint) {
        uint[] memory sourceArray = registry.attrTokenIds(attrName);
        uint256 rand = uint256(keccak256(abi.encodePacked(blockhash(block.number), attrName, toString(tokenId))));
        return sourceArray[rand % sourceArray.length];
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
