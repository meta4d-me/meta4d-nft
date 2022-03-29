// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import './M4mNFT.sol';

// @dev config attribute value when mint NFT
contract M4mConfigurableNFT is OwnableUpgradeable, M4mNFT {

    /* override attributes */
    mapping(uint => string) public override getStyle;

    mapping(uint => string) public override getHair;

    mapping(uint => string)public override  getComplexion;

    mapping(uint => string)public override  getUpper;

    mapping(uint => string) public override getLower;

    mapping(uint => string) public override getShoesAndSocks;

    mapping(uint => string) public override getEarrings;

    mapping(uint => string) public override getNecklace;

    mapping(uint => string) public override getGlass;

    mapping(uint => string) public override getBackendEnv;

    mapping(uint => string) public override getFrontendEnv;

    function initialize(string memory _baseURI) public override initializer {
        __Ownable_init_unchained();

        M4mNFT.initialize(_baseURI);
    }

    function mintByOwner(address to, string memory style, string memory hair, string memory complexion,
        string memory upper, string memory lower, string memory shoesAndSocks, string memory earrings,
        string memory necklace, string memory glass, string memory backendEnv, string memory frontendEnv)
    public onlyOwner {
        _mint(to, totalSupply(), style, hair, complexion, upper, lower, shoesAndSocks, earrings, necklace, glass,
            backendEnv, frontendEnv);
    }

    function mint(address to) public override {
        uint tokenId = totalSupply();
        string memory _style = pluck(tokenId, 'style', style);
        string memory _hair = pluck(tokenId, 'hair', hair);
        string memory _complexion = pluck(tokenId, 'complexion', complexion);
        string memory _upper = pluck(tokenId, 'upper', upper);
        string memory _lower = pluck(tokenId, 'lower', lower);
        string memory _shoesAndSocks = pluck(tokenId, 'shoesAndSocks', shoesAndSocks);
        string memory _earrings = pluck(tokenId, 'earrings', earrings);
        string memory _necklace = pluck(tokenId, 'necklace', necklace);
        string memory _glass = pluck(tokenId, 'glass', glass);
        string memory _backendEnv = pluck(tokenId, 'backendEnv', backendEnv);
        string memory _frontendEnv = pluck(tokenId, 'frontendEnv', frontendEnv);

        _mint(to, tokenId, _style, _hair, _complexion, _upper, _lower, _shoesAndSocks, _earrings, _necklace, _glass,
            _backendEnv, _frontendEnv);
    }

    function _mint(address to, uint tokenId, string memory style, string memory hair, string memory complexion,
        string memory upper, string memory lower, string memory shoesAndSocks, string memory earrings,
        string memory necklace, string memory glass, string memory backendEnv, string memory frontendEnv) private {

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
}
