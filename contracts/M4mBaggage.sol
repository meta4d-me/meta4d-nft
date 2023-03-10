// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/cryptography/SignatureCheckerUpgradeable.sol';

import "./interfaces/IM4mBaggage.sol";
import './interfaces/IM4mNFT.sol';
import './interfaces/IM4mComponents.sol';
import './interfaces/IM4mNFTRegistryV2.sol';

/// @notice store gaming prop, manage game operator
contract M4mBaggage is IM4mBaggage, OwnableUpgradeable, ERC721HolderUpgradeable, ERC1155HolderUpgradeable {

    IM4mNFTRegistryV2 public registry;

    mapping(uint => GameOwner) public getGameOwner;

    /// @notice m4mTokenId => nftInfo
    mapping(uint => LockedNFT) public lockedNFTs;

    /// @notice keccak(LockedNFT) => bool
    mapping(bytes32 => bool) internal _isGameSettled;

    function initialize(IM4mNFTRegistryV2 reg) public initializer {
        __Ownable_init_unchained();
        __ERC721Holder_init_unchained();
        __ERC1155Holder_init_unchained();

        registry = reg;
        reg.components().setApprovalForAll(address(reg), true);
    }

    function setGameSignerAndOperator(uint gameId, address gameSigner, address operator) public onlyOwner {
        require(gameId > 0, "ill gameId");
        require(getGameOwner[gameId].operator == address(0), 'only once');
        require(operator != address(0) && gameSigner != address(0), 'ill op/signer');
        getGameOwner[gameId] = GameOwner(gameSigner, operator);

        emit OperatorUpdated(gameId, operator);
        emit SignerUpdated(gameId, operator);
    }

    function transferOperator(uint gameId, address newOperator) public {
        require(getGameOwner[gameId].operator == msg.sender, 'only operator');
        getGameOwner[gameId].operator = newOperator;

        emit OperatorUpdated(gameId, newOperator);
    }

    function transferSigner(uint gameId, address newSigner) public {
        require(getGameOwner[gameId].signer == msg.sender, 'only operator');
        getGameOwner[gameId].signer = newSigner;

        emit SignerUpdated(gameId, newSigner);
    }

    function gameBegin(uint gameId, string memory uuid, uint m4mTokenId,
        uint[] memory inComponentIds, uint[] memory inAmounts) public override {
        // transfer M4M NFT into self
        registry.m4mNFT().safeTransferFrom(msg.sender, address(this), m4mTokenId, '');
        // transfer other components in
        registry.components().safeBatchTransferFrom(msg.sender, address(this), inComponentIds, inAmounts, '');
        // assemble components
        registry.assembleM4mNFT(m4mTokenId, inComponentIds, inAmounts);
        // lock m4m nft
        registry.lock(m4mTokenId);
        LockedNFT memory info = LockedNFT(msg.sender, gameId, uuid);
        lockedNFTs[m4mTokenId] = info;
        emit GameBegin(m4mTokenId, info);
    }

    /// @notice in PVP, both winners and losers need to settle.
    /// @notice we burn the components from losers and mint to winner
    function gameEnd(uint m4mTokenId,
        uint[] memory lootIds, uint[] memory lootAmounts,
        uint[] memory lostIds, uint[] memory lostAmounts,
        bytes memory operatorSig, bytes memory gameSignerSig
    ) public override {
        LockedNFT memory lockedInfo = lockedNFTs[m4mTokenId];
        bytes memory settleInfo = abi.encodePacked(lockedInfo.owner, m4mTokenId, lockedInfo.gameId, lockedInfo.uuid);
        bytes32 hash = keccak256(settleInfo);
        require(!_isGameSettled[hash], 'ended');
        _isGameSettled[hash] = true;
        delete lockedNFTs[m4mTokenId];

        settleInfo = abi.encodePacked(settleInfo, lootIds, lootAmounts, lostIds, lostAmounts);
        hash = keccak256(settleInfo);
        uint votes = msg.sender == lockedInfo.owner ? 1 : 0;
        votes += checkSig(lockedInfo.gameId, hash, operatorSig, gameSignerSig);
        require(votes >= 2, 'no permission');

        // mint loot to user
        registry.mintLoot(lockedInfo.owner, lootIds, lootAmounts);
        // unlock m4m nft
        registry.unlock(m4mTokenId);
        // split and burn lost components
        registry.splitM4mNFT(m4mTokenId, lostIds, lostAmounts);
        registry.components().burnBatch(address(this), lostIds, lostAmounts);
        // transfer m4m nft to owner
        registry.m4mNFT().safeTransferFrom(address(this), lockedInfo.owner, m4mTokenId, '');

        emit GameSettled(m4mTokenId, lockedInfo);
    }

    function checkSig(uint gameId, bytes32 hash, bytes memory operatorSig, bytes memory gameSignerSig) internal view returns (uint){
        GameOwner memory signerAndOperator = getGameOwner[gameId];
        uint votes = 0;
        if (SignatureCheckerUpgradeable.isValidSignatureNow(signerAndOperator.signer, hash, gameSignerSig)) {
            votes++;
        }
        if (SignatureCheckerUpgradeable.isValidSignatureNow(signerAndOperator.operator, hash, operatorSig)) {
            votes++;
        }
        return votes;
    }

    function isGameSettled(address owner, uint m4mTokenId, uint gameId, string memory uuid) public override view returns (bool){
        bytes32 hash = keccak256(abi.encodePacked(owner, m4mTokenId, gameId, uuid));
        return _isGameSettled[hash];
    }
}
