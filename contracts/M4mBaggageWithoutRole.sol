// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/cryptography/SignatureCheckerUpgradeable.sol';

import "./interfaces/IM4mBaggageWithoutRole.sol";
import "./M4mBaggage.sol";

/// @notice store gaming prop, manage game operator
contract M4mBaggageWithoutRole is M4mBaggage, IM4mBaggageWithoutRole {

    // m4mTokenId => componentId => amount
    mapping(uint => mapping(uint => uint)) public lockedComponents;
    // m4mTokenId => LockedEmptyNFT
    mapping(uint => LockedEmptyNFT) public lockedEmptyNFTs;

    /// @dev there are no values need to init
    //    function initialize(IM4mNFTRegistryV2 reg) public reinitializer(2) {
    //
    //    }


    function lockComponents(uint m4mTokenId, uint gameId, uint[] memory inComponentIds, uint[] memory inAmounts) public {
        require(inComponentIds.length == inAmounts.length && inComponentIds.length > 0, "ill param");
        require(lockedNFTs[m4mTokenId].owner == address(0), "duplicated M4mNFT");
        // check owner
        address existedOwner = lockedEmptyNFTs[m4mTokenId].owner;
        if (existedOwner == address(0)) { // lock firstly
            lockedEmptyNFTs[m4mTokenId].owner = msg.sender;
        } else {
            // cannot change owner, means that, disable role exchange
            require(existedOwner == msg.sender, 'owner required');
            // check gameId, if not 0, the role has been locked
            require(lockedEmptyNFTs[m4mTokenId].gameId==0,'cannot lock again');
        }
        // update gameId only, don't update nonce
        lockedEmptyNFTs[m4mTokenId].gameId = gameId;

        // transfer components in
        registry.components().safeBatchTransferFrom(msg.sender, address(this), inComponentIds, inAmounts, '');
        for (uint i = 0; i < inComponentIds.length; i++) {
            lockedComponents[m4mTokenId][inComponentIds[i]] += inAmounts[i];
        }
    }

    function unlockComponents(uint m4mTokenId, uint nonce, uint[] memory outComponentIds, bytes memory operatorSig, bytes memory gameSignerSig) public {
        LockedEmptyNFT memory lockedInfo = lockedEmptyNFTs[m4mTokenId];
        require(lockedInfo.usedNonce == nonce - 1, 'ill nonce');
        // update states
        lockedEmptyNFTs[m4mTokenId].usedNonce = nonce;
        // reset game id
        lockedEmptyNFTs[m4mTokenId].gameId = 0;

        uint[] memory outAmounts = new uint[](outComponentIds.length);
        for (uint i = 0; i < outComponentIds.length; i++) {
            outAmounts[i] = lockedComponents[m4mTokenId][outComponentIds[i]];
            lockedComponents[m4mTokenId][outComponentIds[i]] = 0;
        }

        bytes32 hash = keccak256(abi.encodePacked(m4mTokenId, nonce, lockedInfo.gameId, outComponentIds));
        uint votes = msg.sender == lockedInfo.owner ? 1 : 0;
        votes += checkSig(lockedInfo.gameId, hash, operatorSig, gameSignerSig);
        require(votes >= 2, 'no permission');
        // transfer components out
        registry.components().safeBatchTransferFrom(address(this), lockedInfo.owner, outComponentIds, outAmounts, '');
    }

    function settleLoots(uint m4mTokenId, uint nonce,
        uint[] memory lootIds, uint[] memory lootAmounts,
        uint[] memory lostIds, uint[] memory lostAmounts,
        bytes memory operatorSig, bytes memory gameSignerSig) public {

        LockedEmptyNFT memory lockedInfo = lockedEmptyNFTs[m4mTokenId];
        require(lockedInfo.usedNonce == nonce - 1, 'ill nonce');
        lockedEmptyNFTs[m4mTokenId].usedNonce = nonce;

        bytes32 hash = keccak256(abi.encodePacked(m4mTokenId, lockedInfo.gameId, nonce, lootIds, lootAmounts, lostIds, lostAmounts));
        uint votes = msg.sender == lockedInfo.owner ? 1 : 0;
        votes += checkSig(lockedInfo.gameId, hash, operatorSig, gameSignerSig);
        require(votes >= 2, 'no permission');

        // mint loots to user
        registry.mintLoot(lockedEmptyNFTs[m4mTokenId].owner, lootIds, lootAmounts);
        // burn components from locked components
        for (uint i = 0; i < lostIds.length; i++) {
            lockedComponents[m4mTokenId][lostIds[i]] -= lostAmounts[i];
        }
        registry.components().burnBatch(address(this), lostIds, lostAmounts);
    }
}
