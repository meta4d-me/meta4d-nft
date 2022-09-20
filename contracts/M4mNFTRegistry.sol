// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/cryptography/SignatureCheckerUpgradeable.sol';

import './interfaces/IM4mNFT.sol';
import './interfaces/IM4mComponents.sol';
import './interfaces/IM4mNFTRegistry.sol';

contract M4mNFTRegistry is OwnableUpgradeable, ERC721HolderUpgradeable, ERC1155HolderUpgradeable, IM4mNFTRegistry {

    IM4mDAO public override dao;

    /// @notice Meta-4D.me NFT
    IM4mNFT public override m4mNFT;

    IM4mComponents public components;

    address public operator;

    struct SplitToken {
        IERC721 original;
        uint originalTokenId;

        TokenStatus status;
        bytes32 originalAttrHash; // kecca256(abi.encodePacked(tokenIds, amounts))
        mapping(uint => uint) components; // component token id => amount
    }

    mapping(uint => SplitToken) public splitTokens;

    mapping(bytes32 => bool) public claimedLoot;

    /* events */
    event SetOperator(address newOperator);
    event ConvertToM4mNFT(address owner, IERC721 original, uint originalTokenId, uint m4mTokenId);
    event Initialize(uint m4mTokenId, uint[] componentIds, uint[] amount);
    event ClaimedLoot(address owner, uint[] componentIds, uint[] amount);
    event Split(uint m4mTokenId, uint[] componentIds, uint[] amount);
    event Assemble(uint m4mTokenId, uint[] componentIds, uint[] amount);
    event Redeem(address owner, IERC721 original, uint originalTokenId, uint m4mTokenId);

    function initialize(IM4mComponents _components, IM4mNFT _m4mNFT, IM4mDAO _dao) public initializer {
        __Ownable_init_unchained();
        __ERC721Holder_init_unchained();
        __ERC1155Holder_init_unchained();

        components = _components;
        m4mNFT = _m4mNFT;
        operator = msg.sender;
        dao = _dao;
    }

    function setOperator(address newOperator) public onlyOwner {
        operator = newOperator;
        emit SetOperator(newOperator);
    }

    /// @notice user convert original NFT to m4mNFT, and bind attributes
    function convertNFT(IERC721 original, uint originalTokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig)
    public override {
        require(dao.convertibleList(original), 'cannot convert');
        original.safeTransferFrom(msg.sender, address(this), originalTokenId);
        uint m4mTokenId = uint(keccak256(abi.encodePacked(original, originalTokenId)));
        m4mNFT.mint(msg.sender, m4mTokenId);
        SplitToken storage splitToken = initializeM4mNFT(m4mTokenId, componentIds, amounts, sig);
        splitToken.original = original;
        splitToken.originalTokenId = originalTokenId;
        emit ConvertToM4mNFT(msg.sender, original, originalTokenId, m4mTokenId);
    }

    function initializeM4mNFT(uint m4mTokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig)
    private returns (SplitToken storage splitToken){
        require(componentIds.length == amounts.length, "ill params");
        splitToken = splitTokens[m4mTokenId];
        require(splitToken.status == TokenStatus.NotExist || splitToken.status == TokenStatus.Redeemed, 'ill status');
        // check owner, not approval
        require(m4mNFT.ownerOf(m4mTokenId) == msg.sender, 'ill owner');
        bytes32 hash = keccak256(abi.encodePacked(m4mTokenId, componentIds, amounts));
        require(SignatureCheckerUpgradeable.isValidSignatureNow(operator, hash, sig), 'ill sig');

        splitToken.status = TokenStatus.Initialized;
        splitToken.originalAttrHash = hash;
        for (uint i = 0; i < componentIds.length; i++) {
            require(amounts[i] > 0, 'ill amount');
            splitToken.components[componentIds[i]] = amounts[i];
        }
        components.mintBatch(address(this), componentIds, amounts);
        emit Initialize(m4mTokenId, componentIds, amounts);
    }

    function splitM4mNFT(uint m4mTokenId, uint[]memory componentIds, uint[]memory amounts) public override {
        require(componentIds.length == amounts.length && amounts.length > 0, "ill params");
        SplitToken storage splitToken = splitTokens[m4mTokenId];
        require(splitToken.status == TokenStatus.Initialized, 'ill status');
        // check redeemed or owner
        /// @dev anyone could split redundant attrs after redeem
        require(splitToken.status == TokenStatus.Redeemed || m4mNFT.ownerOf(m4mTokenId) == msg.sender, 'ill status');

        for (uint i = 0; i < componentIds.length; i++) {
            require(amounts[i] > 0, 'ill amount');
            // if component is not enough, revert here
            splitToken.components[componentIds[i]] -= amounts[i];
        }
        components.safeBatchTransferFrom(address(this), msg.sender, componentIds, amounts, '');
        emit Split(m4mTokenId, componentIds, amounts);
    }

    /// @notice don't require msg.sender is the owner of tokenId. In other words, you can assemble components to NFT
    /// owned by other one
    function assembleM4mNFT(uint m4mTokenId, uint[]memory componentIds, uint[]memory amounts) public override {
        require(componentIds.length == amounts.length && amounts.length > 0, "ill params");
        SplitToken storage splitToken = splitTokens[m4mTokenId];
        require(splitToken.status == TokenStatus.Initialized, 'ill status');

        for (uint i = 0; i < componentIds.length; i++) {
            require(amounts[i] > 0, 'ill amount');
            splitToken.components[componentIds[i]] += amounts[i];
        }
        components.safeBatchTransferFrom(msg.sender, address(this), componentIds, amounts, '');
        emit Assemble(m4mTokenId, componentIds, amounts);
    }

    function redeem(uint m4mTokenId, uint[]memory componentIds, uint[]memory amounts) public override {
        require(componentIds.length == amounts.length && amounts.length > 0, "ill params");
        SplitToken storage splitToken = splitTokens[m4mTokenId];
        require(splitToken.status == TokenStatus.Initialized, 'ill status');
        bytes32 hash = keccak256(abi.encodePacked(m4mTokenId, componentIds, amounts));
        require(hash == splitToken.originalAttrHash, 'ill attrs');
        require(m4mNFT.ownerOf(m4mTokenId) == msg.sender, 'ill owner');

        /* burn components */
        for (uint i = 0; i < componentIds.length; i++) {
            require(amounts[i] > 0, 'ill amount');
            // if component is not enough, revert here
            splitToken.components[componentIds[i]] -= amounts[i];
        }
        components.burnBatch(address(this), componentIds, amounts);
        splitToken.status = TokenStatus.Redeemed;

        /* burn m4mNFT and redeem original nft */
        splitToken.original.safeTransferFrom(address(this), msg.sender, splitToken.originalTokenId);
        m4mNFT.burn(m4mTokenId);
        emit Redeem(msg.sender, splitToken.original, splitToken.originalTokenId, m4mTokenId);
    }

    function claimLoot(string memory uuid, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) public override {
        require(componentIds.length == amounts.length, 'ill param');
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, uuid, componentIds, amounts));
        require(!claimedLoot[hash], 'already claimed');
        require(SignatureCheckerUpgradeable.isValidSignatureNow(operator, hash, sig), 'ill sig');
        components.mintBatch(msg.sender, componentIds, amounts);
        claimedLoot[hash] = true;
        emit ClaimedLoot(msg.sender, componentIds, amounts);
    }

    function lock(uint m4mTokenId) public override {
        SplitToken storage splitToken = splitTokens[m4mTokenId];
        require(splitToken.status == TokenStatus.Initialized, 'ill status');
        require(m4mNFT.ownerOf(m4mTokenId) == msg.sender, 'ill owner');

        splitToken.status = TokenStatus.Locked;
    }

    function unlock(uint m4mTokenId) public override {
        SplitToken storage splitToken = splitTokens[m4mTokenId];
        require(splitToken.status == TokenStatus.Locked, 'ill status');
        require(m4mNFT.ownerOf(m4mTokenId) == msg.sender, 'ill owner');

        splitToken.status = TokenStatus.Initialized;
    }

    function getTokenStatus(uint m4mTokenId) public view returns (TokenStatus, bytes32, IERC721, uint){
        SplitToken storage splitToken = splitTokens[m4mTokenId];
        return (splitToken.status, splitToken.originalAttrHash, splitToken.original, splitToken.originalTokenId);
    }

    function getTokenComponentAmount(uint m4mTokenId, uint componentId) public view returns (uint){
        SplitToken storage splitToken = splitTokens[m4mTokenId];
        return (splitToken.components[componentId]);
    }

    function getTokenComponentAmounts(uint m4mTokenId, uint[] memory componentIds) external view returns (uint[] memory){
        SplitToken storage splitToken = splitTokens[m4mTokenId];
        uint[] memory result = new uint[](componentIds.length);
        for (uint i = 0; i < componentIds.length; i++) {
            result[i] = splitToken.components[componentIds[i]];
        }
        return result;
    }
}
