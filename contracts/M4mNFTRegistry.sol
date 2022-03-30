// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol';

import './interfaces/IM4mNFT.sol';
import './interfaces/IM4mComponents.sol';
import './interfaces/IM4mNFTRegistry.sol';

// @dev manage all kinds of components

contract M4mNFTRegistry is OwnableUpgradeable, ERC721HolderUpgradeable, IM4mNFTRegistry {

    /// @notice Meta-4D.me NFT
    address public override m4mNFT;

    IM4mComponents public components;

    // attrName => tokenIds
    mapping(AttrName => uint[]) private _attrTokenIds;
    // attrName => tokenId => enabled
    mapping(AttrName => mapping(uint => bool)) public override attrTokenIdEnabled;

    function initialize(IM4mComponents _components, address _m4mNFT) public initializer {
        __Ownable_init_unchained();
        __ERC721Holder_init_unchained();

        components = _components;
        m4mNFT = _m4mNFT;

        // TODO: init value correctly
        addComponentInternal(0, AttrName.STYLE, 'M4m 2D Style', '2D-STYLE', '2D');
        addComponentInternal(1, AttrName.STYLE, 'M4m 3D Style', '3D-STYLE', '3D');
        addComponentInternal(2, AttrName.HAIR, 'M4m Red HAIR', 'RED-HAIR', 'RED');
        addComponentInternal(3, AttrName.COMPLEXION, 'M4m White COMPLEXION', 'WHITE-COMPLEXION', 'WHITE');
        addComponentInternal(4, AttrName.UPPER, 'M4m Jacket UPPER', 'Jacket-UPPER', 'Jacket');
        addComponentInternal(5, AttrName.LOWER, 'M4m Skirt LOWER', 'Skirt-LOWER', 'Skirt');
        addComponentInternal(6, AttrName.SHOES_AND_SOCKS, 'M4m Test SHOES_AND_SOCKS', 'Test-SHOES_AND_SOCKS', 'Test');
        addComponentInternal(7, AttrName.EARRINGS, 'M4m Test EARRINGS', 'Test-SHOES_AND_SOCKS', 'Test');
        addComponentInternal(8, AttrName.NECKLACE, 'M4m Test NECKLACE', 'Test-NECKLACE', 'Test');
        addComponentInternal(9, AttrName.GLASS, 'M4m Test GLASS', 'Test-GLASS', 'Test');
        addComponentInternal(10, AttrName.BACKEND_ENV, 'M4m Test BACKEND_ENV', 'Test-BACKEND_ENV', 'Test');
        addComponentInternal(11, AttrName.FRONTEND_ENV, 'M4m Test FRONTEND_ENV', 'Test-FRONTEND_ENV', 'Test');
    }

    function addComponent(uint tokenId, AttrName attrName, string memory name, string memory symbol,
        string memory value) public override onlyOwner {
        require(!attrTokenIdEnabled[attrName][tokenId], 'existed');
        addComponentInternal(tokenId, attrName, name, symbol, value);
    }

    function addComponentInternal(uint tokenId, AttrName attrName, string memory name, string memory symbol,
        string memory value) private {
        components.prepareNewToken(tokenId, name, symbol, value);
        _attrTokenIds[attrName].push(tokenId);
        attrTokenIdEnabled[attrName][tokenId] = true;
    }

    function splitM4mNFT(uint tokenId) public {
        IM4mNFT(m4mNFT).safeTransferFrom(msg.sender, address(this), tokenId);
        (uint[]memory ids, uint[]memory amounts) = genIdsAndAmounts(tokenId);
        components.mintBatch(msg.sender, ids, amounts);
    }

    /// @notice redeem original NFT
    function assembleM4mNFT(uint tokenId) public {
        (uint[]memory ids, uint[]memory amounts) = genIdsAndAmounts(tokenId);
        components.burnBatch(msg.sender, ids, amounts);
        IM4mNFT(m4mNFT).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function genIdsAndAmounts(uint tokenId) private view returns (uint[]memory ids, uint[]memory amounts){
        ids = new uint[](11);
        IM4mNFT _m4mNFT = IM4mNFT(m4mNFT);
        ids[0] = _m4mNFT.getStyle(tokenId);
        ids[1] = _m4mNFT.getHair(tokenId);
        ids[2] = _m4mNFT.getComplexion(tokenId);
        ids[3] = _m4mNFT.getUpper(tokenId);
        ids[4] = _m4mNFT.getLower(tokenId);
        ids[5] = _m4mNFT.getShoesAndSocks(tokenId);
        ids[6] = _m4mNFT.getEarrings(tokenId);
        ids[7] = _m4mNFT.getNecklace(tokenId);
        ids[8] = _m4mNFT.getGlass(tokenId);
        ids[9] = _m4mNFT.getBackendEnv(tokenId);
        ids[10] = _m4mNFT.getFrontendEnv(tokenId);
        amounts = new uint[](11);
        for (uint i = 0; i < 11; i++) {
            amounts[i] = 1;
        }
    }

    function assembleM4mNFT(uint style, uint hair, uint complexion, uint upper, uint lower, uint shoesAndSocks,
        uint earrings, uint necklace, uint glass, uint backendEnv, uint frontendEnv) public {
        require(attrTokenIdEnabled[AttrName.STYLE][style], 'ill style');
        require(attrTokenIdEnabled[AttrName.HAIR][hair], 'ill hair');
        require(attrTokenIdEnabled[AttrName.COMPLEXION][complexion], 'ill complexion');
        require(attrTokenIdEnabled[AttrName.UPPER][upper], 'ill upper');
        require(attrTokenIdEnabled[AttrName.LOWER][lower], 'ill lower');
        require(attrTokenIdEnabled[AttrName.SHOES_AND_SOCKS][shoesAndSocks], 'ill shoesAndSocks');
        require(attrTokenIdEnabled[AttrName.EARRINGS][earrings], 'ill earrings');
        require(attrTokenIdEnabled[AttrName.NECKLACE][necklace], 'ill necklace');
        require(attrTokenIdEnabled[AttrName.GLASS][glass], 'ill glass');
        require(attrTokenIdEnabled[AttrName.BACKEND_ENV][backendEnv], 'ill backendEnv');
        require(attrTokenIdEnabled[AttrName.FRONTEND_ENV][frontendEnv], 'ill frontendEnv');

        uint[] memory amounts = new uint[](11);
        for (uint i = 0; i < 11; i++) {
            amounts[i] = 1;
        }
        uint[] memory ids = new uint[](11);
        ids[0] = style;
        ids[1] = hair;
        ids[2] = complexion;
        ids[3] = upper;
        ids[4] = lower;
        ids[5] = shoesAndSocks;
        ids[6] = earrings;
        ids[7] = necklace;
        ids[8] = glass;
        ids[9] = backendEnv;
        ids[10] = frontendEnv;
        components.burnBatch(msg.sender, ids, amounts);
        IM4mNFT(m4mNFT).mintByRegistry(msg.sender, style, hair, complexion, upper, lower, shoesAndSocks, earrings,
            necklace, glass, backendEnv, frontendEnv);
    }

    function attrTokenIds(AttrName attrName) public override view returns (uint[] memory tokenIds){
        tokenIds = _attrTokenIds[attrName];
    }
}
