// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/cryptography/SignatureCheckerUpgradeable.sol';

import './interfaces/IM4mNFT.sol';
import './interfaces/IM4mComponents.sol';
import './interfaces/IM4mNFTRegistry.sol';

// @dev manage all kinds of components

contract M4mNFTRegistry is OwnableUpgradeable, ERC721HolderUpgradeable, ERC1155HolderUpgradeable, IM4mNFTRegistry {

    IM4mDAO public override dao;

    /// @notice Meta-4D.me NFT
    IM4mNFT public override m4mNFT;

    IM4mComponents public components;

    address public operator;

    struct SplitToken {
        TokenStatus status;
        bytes32 originalAttrHash; // kecca256(abi.encodePacked(tokenIds, amounts))
        mapping(uint => uint) components; // component token id => amount
    }

    mapping(uint => SplitToken) public splitTokens;
    mapping(uint => mapping(address => mapping(IERC721 => mapping(uint => bool)))) public override convertRecord;

    /* events */
    event SetOperator(address newOperator);
    event ConvertToM4mNFT(address owner, IERC721 origin, uint tokenId, uint m4mTokenId);
    event Initialize(uint m4mTokenId, uint[] componentIds, uint[] amount);
    event Split(uint m4mTokenId, uint[] componentIds, uint[] amount);
    event Assemble(uint m4mTokenId, uint[] componentIds, uint[] amount);
    event Redeem(address owner, IERC721 origin, uint tokenId, uint m4mTokenId);

    function initialize(IM4mComponents _components, IM4mNFT _m4mNFT) public initializer {
        __Ownable_init_unchained();
        __ERC721Holder_init_unchained();
        __ERC1155Holder_init_unchained();

        components = _components;
        m4mNFT = _m4mNFT;
        operator = msg.sender;
    }

    function setOperator(address newOperator) public onlyOwner {
        operator = newOperator;
        emit SetOperator(newOperator);
    }

    /// @notice user convert original NFT to m4mNFT, and bind attributes
    function convertNFT(IERC721 origin, uint tokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig)
    public override {
        require(dao.convertibleList(origin), 'cannot convert');
        origin.safeTransferFrom(msg.sender, address(this), tokenId);
        uint m4mTokenId = m4mNFT.mint(msg.sender);
        convertRecord[m4mTokenId][msg.sender][origin][tokenId] = true;
        initializeM4mNFT(m4mTokenId, componentIds, amounts, sig);
        emit ConvertToM4mNFT(msg.sender, origin, tokenId, m4mTokenId);
    }

    function initializeM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) private {
        require(componentIds.length == amounts.length, "ill params");
        SplitToken storage splitToken = splitTokens[tokenId];
        require(splitToken.status == TokenStatus.NotExist, 'ill status');
        // check owner, not approval
        require(m4mNFT.ownerOf(tokenId) == msg.sender, 'ill owner');
        bytes32 hash = keccak256(abi.encodePacked(componentIds, amounts));
        require(SignatureCheckerUpgradeable.isValidSignatureNow(operator, hash, sig), 'ill sig');

        splitToken.status = TokenStatus.Initialized;
        splitToken.originalAttrHash = hash;
        for (uint i = 0; i < componentIds.length; i++) {
            require(amounts[i] > 0, 'ill amount');
            splitToken.components[componentIds[i]] = amounts[i];
        }
        components.mintBatch(address(this), componentIds, amounts);
        emit Initialize(tokenId, componentIds, amounts);
    }

    function splitM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts) public override {
        require(componentIds.length == amounts.length && amounts.length > 0, "ill params");
        SplitToken storage splitToken = splitTokens[tokenId];
        require(splitToken.status == TokenStatus.Initialized, 'ill status');
        // check redeemed or owner
        /// @dev user could split redundant attrs after redeem
        require(splitToken.status == TokenStatus.Redeemed || m4mNFT.ownerOf(tokenId) == msg.sender, 'ill status');

        for (uint i = 0; i < componentIds.length; i++) {
            require(amounts[i] > 0, 'ill amount');
            // if component is not enough, revert here
            splitToken.components[componentIds[i]] -= amounts[i];
        }
        components.safeBatchTransferFrom(address(this), msg.sender, componentIds, amounts, '');
        emit Split(tokenId, componentIds, amounts);
    }

    /// @notice don't require msg.sender is the owner of tokenId. In other words, you can assemble components to NFT
    /// owned by other one
    function assembleM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts) public override {
        require(componentIds.length == amounts.length && amounts.length > 0, "ill params");
        SplitToken storage splitToken = splitTokens[tokenId];
        require(splitToken.status == TokenStatus.Initialized, 'ill status');

        for (uint i = 0; i < componentIds.length; i++) {
            require(amounts[i] > 0, 'ill amount');
            splitToken.components[componentIds[i]] += amounts[i];
        }
        components.safeBatchTransferFrom(msg.sender, address(this), componentIds, amounts, '');
        emit Assemble(tokenId, componentIds, amounts);
    }

    function redeem(IERC721 origin, uint tokenId, uint m4mTokenId, uint[]memory componentIds, uint[]memory amounts)
    public override {
        require(componentIds.length == amounts.length && amounts.length > 0, "ill params");
        SplitToken storage splitToken = splitTokens[m4mTokenId];
        require(splitToken.status == TokenStatus.Initialized, 'ill status');
        bytes32 hash = keccak256(abi.encodePacked(componentIds, amounts));
        require(hash == splitToken.originalAttrHash, 'ill attrs');

        /* burn components */
        for (uint i = 0; i < componentIds.length; i++) {
            require(amounts[i] > 0, 'ill amount');
            // if component is not enough, revert here
            splitToken.components[componentIds[i]] -= amounts[i];
        }
        components.burnBatch(msg.sender, componentIds, amounts);

        /* burn m4mNFT and redeem original nft */
        require(convertRecord[m4mTokenId][msg.sender][origin][tokenId], 'no record');
        origin.safeTransferFrom(address(this), msg.sender, tokenId);
        m4mNFT.burn(tokenId);
        convertRecord[m4mTokenId][msg.sender][origin][tokenId] = false;
        emit Redeem(msg.sender, origin, tokenId, m4mTokenId);
    }

    function getSplitToken(uint tokenId) public view returns (TokenStatus, bytes32){
        SplitToken storage splitToken = splitTokens[tokenId];
        return (splitToken.status, splitToken.originalAttrHash);
    }

    function getSplitTokenComponentAmount(uint componentId) public view returns (uint){
        SplitToken storage splitToken = splitTokens[componentId];
        return (splitToken.components[componentId]);
    }
}
