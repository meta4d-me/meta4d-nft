// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IM4mBaggageWithoutRole {
    struct LockedEmptyNFT {
        address owner;
        uint gameId;
        uint usedNonce; // self increment off chain
    }

    function lockComponents(uint m4mTokenId, uint gameId, uint[] memory inComponentIds, uint[] memory inAmounts) external;

    function unlockComponents(uint m4mTokenId, uint[] memory outComponentIds, bytes memory operatorSig, bytes memory gameSignerSig) external;

    function settleLoots(uint m4mTokenId, uint nonce,
        uint[] memory lootIds, uint[] memory lootAmounts,
        uint[] memory lostIds, uint[] memory lostAmounts,
        bytes memory operatorSig, bytes memory gameSignerSig) external;

    function lockedComponents(uint m4mTokenId, uint componentId) external view returns (uint);

    function lockedEmptyNFTs(uint m4mTokenId) external view returns (address owner, uint gameId, uint usedNonce);
}
