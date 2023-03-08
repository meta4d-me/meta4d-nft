// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import './Zip.sol';
import './SimpleM4mNFTV2.sol';

contract ZipV2 is Zip {

    SimpleM4mNFTV2 public simpleM4mNFTV2;

    constructor(string memory _baseURI, SimpleM4mNFT _simpleM4mNFT, IM4mNFTRegistry _registry, IManager _manager,
        SimpleM4mNFTV2 _simpleM4mNFTV2) Zip(_baseURI, _simpleM4mNFT, _registry, _manager){

        simpleM4mNFTV2 = _simpleM4mNFTV2;
        _simpleM4mNFTV2.setApprovalForAll(address(_registry), true);
    }

    function mintM4mNFTV2(address owner, uint originalTokenId, uint[]memory componentIds, uint[]memory amounts, bytes memory sig) public {
        simpleM4mNFTV2.mint(originalTokenId, address(this), baseURI);
        registry.convertNFT(IERC721(simpleM4mNFTV2), originalTokenId, componentIds, amounts, sig);
        uint m4mTokenId = uint(keccak256(abi.encodePacked(simpleM4mNFTV2, originalTokenId)));
        registry.m4mNFT().safeTransferFrom(address(this), owner, m4mTokenId);
    }

}
