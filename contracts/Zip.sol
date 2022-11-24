// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';
import './SimpleM4mNFT.sol';
import './interfaces/IM4mNFTRegistry.sol';

contract Zip is Ownable, ERC721Holder {

    /// @notice baseURI is used for SimpleM4mNFT
    string public baseURI;
    SimpleM4mNFT public simpleM4mNFT;
    IM4mNFTRegistry public registry;

    constructor(string memory _baseURI, SimpleM4mNFT _simpleM4mNFT, IM4mNFTRegistry _registry) Ownable(){
        baseURI = _baseURI;
        simpleM4mNFT = _simpleM4mNFT;
        registry = _registry;

        _simpleM4mNFT.setApprovalForAll(address(_registry), true);
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
}
