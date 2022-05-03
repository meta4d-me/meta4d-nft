// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/cryptography/SignatureCheckerUpgradeable.sol';

import './interfaces/IM4mNFT.sol';
import './interfaces/IM4mComponents.sol';
import './interfaces/IM4mNFTRegistry.sol';

import 'hardhat/console.sol';

// @dev manage all kinds of components

contract M4mNFTRegistry is OwnableUpgradeable, ERC721HolderUpgradeable, IM4mNFTRegistry {

    /// @notice Meta-4D.me NFT
    address public override m4mNFT;

    IM4mComponents public components;

    address public operator;

    event SetOperator(address newOperator);

    function initialize(IM4mComponents _components, address _m4mNFT) public initializer {
        __Ownable_init_unchained();
        __ERC721Holder_init_unchained();

        components = _components;
        m4mNFT = _m4mNFT;
        operator = msg.sender;
    }

    function setOperator(address newOperator) public onlyOwner {
        operator = newOperator;
        emit SetOperator(newOperator);
    }

    function splitM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) public {
        IM4mNFT(m4mNFT).safeTransferFrom(msg.sender, address(this), tokenId);
        bytes32 hash = keccak256(abi.encodePacked(componentIds, amounts));
        require(SignatureCheckerUpgradeable.isValidSignatureNow(operator, hash, sig), 'ill sig');
        components.mintBatch(msg.sender, componentIds, amounts);
    }

    /// @notice redeem original NFT
    function assembleOriginalM4mNFT(uint tokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) public {
        bytes32 hash = keccak256(abi.encodePacked(componentIds, amounts));
        require(SignatureCheckerUpgradeable.isValidSignatureNow(operator, hash, sig), 'ill sig');
        components.burnBatch(msg.sender, componentIds, amounts);
        IM4mNFT(m4mNFT).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function assembleM4mNFT(uint[]memory componentIds, uint[]memory amounts, bytes memory sig) public {
        bytes32 hash = keccak256(abi.encodePacked(componentIds, amounts));
        require(SignatureCheckerUpgradeable.isValidSignatureNow(operator, hash, sig), 'ill sig');
        components.burnBatch(msg.sender, componentIds, amounts);
        IM4mNFT(m4mNFT).mintByRegistry(msg.sender);
    }
}
