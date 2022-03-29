// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import './interfaces/IM4mNFT.sol';
import './interfaces/IM4mComponents.sol';
import './interfaces/IM4mNFTRegistry.sol';

// @dev manage all kinds of components

contract M4mNFTRegistry is OwnableUpgradeable, IM4mNFTRegistry {

    /// @notice Meta-4D.me NFT
    address public override m4mNFT;

    IM4mComponents public components;

    // attrName => tokenIds
    mapping(AttrName => uint[]) private _attrTokenIds;
    // attrName => tokenId => enabled
    mapping(AttrName => mapping(uint => bool)) public override attrTokenIdEnabled;

    // TODO: init component
    function initialize(IM4mComponents _components, address _m4mNFT) public initializer {
        __Ownable_init_unchained();

        components = _components;
        m4mNFT = _m4mNFT;
    }

    function addComponent(uint tokenId, AttrName attrName, string memory name, string memory symbol,
        string memory value) public override onlyOwner {
        require(!attrTokenIdEnabled[attrName][tokenId], 'existed');
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
        IM4mNFT(m4mNFT).mintByRegistry(msg.sender, style, hair, complexion, upper, lower, shoesAndSocks, earrings,
            necklace, glass, backendEnv, frontendEnv);
    }

    function attrTokenIds(AttrName attrName) public override view returns (uint[] memory tokenIds){
        tokenIds = _attrTokenIds[attrName];
    }
}
