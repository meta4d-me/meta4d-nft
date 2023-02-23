// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IM4mBaggage {

    struct GameOwner {
        address signer;
        address operator;
    }

    struct LockedNFT {
        address owner;
        uint gameId; // which game
        bytes32 uuid; // which round of game
    }

    event OperatorUpdated(uint gameId, address operator);
    event SignerUpdated(uint gameId, address signer);
    event GameBegin(uint m4mTokenId, LockedNFT info);
    event GameSettled(uint m4mTokenId, LockedNFT info);

    /// @notice could only set once
    function setGameOperator(uint gameId, address gameSigner, address operator) external;

    /// @notice only old operator of gameId could transfer to new operator
    function transferOperator(uint gameId, address newOperator) external;

    /// @notice only old signer of gameId could transfer to new signer
    function transferSigner(uint gameId, address newSigner) external;

    function getGameOwner(uint gameId) external view returns (address signer, address operator);

    /// @notice enter game, transfer M4M-NFT and some components to self, assemble components to M4M-NFT and then lock it
    /// @notice one m4m nft could only play one game at the same time
    function gameBegin(uint gameId, string memory uuid, uint m4mTokenId, uint[] memory inComponentIds, uint[] memory inAmounts) external;

    /// @notice exit game, unlock M4M-NFT, claim loots, return M4M-NFT and components, burn some components
    function gameEnd(uint m4mTokenId,
        uint[] memory lootIds, uint[] memory lootAmounts,
        uint[] memory lostIds, uint[] memory lostAmounts,
        bytes memory operatorSig, bytes memory gameSignerSig) external;

    function isGameSettled(address owner, uint m4mTokenId, uint gameId, string memory uuid) external returns (bool);
}
