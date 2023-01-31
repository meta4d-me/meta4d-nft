// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';
import '@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol';
import './SimpleM4mNFT.sol';
import './interfaces/IM4mNFTRegistry.sol';
import "./interfaces/version-nft/IManager.sol";

contract Zip is Ownable, ERC721Holder, ERC1155Holder {

    /// @notice baseURI is used for SimpleM4mNFT
    string public baseURI;
    SimpleM4mNFT public simpleM4mNFT;
    IM4mNFTRegistry public registry;
    IManager public manager;

    constructor(string memory _baseURI, SimpleM4mNFT _simpleM4mNFT, IM4mNFTRegistry _registry, IManager _manager) Ownable(){
        baseURI = _baseURI;
        simpleM4mNFT = _simpleM4mNFT;
        registry = _registry;
        manager = _manager;

        _simpleM4mNFT.setApprovalForAll(address(_registry), true);
        _registry.components().setApprovalForAll(address(_registry), true);
    }

    function updateBaseURI(string memory newURI) public onlyOwner {
        baseURI = newURI;
    }

    function mintM4mNFT(address owner, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) public {
        uint tokenId = simpleM4mNFT.tokenIndex();
        simpleM4mNFT.mint(address(this), baseURI);
        registry.convertNFT(IERC721(simpleM4mNFT), tokenId, componentIds, amounts, sig);
        uint m4mTokenId = uint(keccak256(abi.encodePacked(simpleM4mNFT, tokenId)));
        registry.m4mNFT().safeTransferFrom(address(this), owner, m4mTokenId);
    }

    function changeComponents(uint m4mTokenId, uint[]memory outComponentIds, uint[]memory outAmounts,
        uint[]memory inComponentIds, uint[]memory inAmounts) public {
        // transfer M4M NFT in
        registry.m4mNFT().safeTransferFrom(msg.sender, address(this), m4mTokenId);
        // split firstly
        registry.splitM4mNFT(m4mTokenId, outComponentIds, outAmounts);
        // transfer components to user
        registry.components().safeBatchTransferFrom(address(this), msg.sender, outComponentIds, outAmounts, '');
        // assemble
        registry.components().safeBatchTransferFrom(msg.sender, address(this), inComponentIds, inAmounts, '');
        registry.assembleM4mNFT(m4mTokenId, inComponentIds, inAmounts);
        // transfer M4M NFT out
        registry.m4mNFT().safeTransferFrom(address(this), msg.sender, m4mTokenId);
    }

    function changeComponentsAndRecordVersion(uint m4mTokenId, uint[]memory outComponentIds, uint[]memory outAmounts,
        uint[]memory inComponentIds, uint[]memory inAmounts, string memory oldVersion) public {
        changeComponents(m4mTokenId, outComponentIds, outAmounts, inComponentIds, inAmounts);
        uint chainId;
        assembly {
            chainId := chainid()
        }
        manager.setInfo(IManager.Token(chainId, address(registry.m4mNFT()), m4mTokenId), oldVersion);
    }
}
