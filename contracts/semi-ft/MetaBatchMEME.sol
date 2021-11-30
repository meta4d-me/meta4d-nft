// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

/// @dev BatchMEME is Meta NFT example, maybe some emoji, some cop?
/// @notice only owner could mint BatchMeme, not everyone, so we don't charge handling fee
contract MetaBatchMEME is ERC1155, Ownable {

    // event URI(string _value, uint256 indexed _id);
    mapping(uint => address) public minter;

    constructor()ERC1155("http://api.meta4d.me/v1/batch-meme/{id}.json") Ownable(){
    }

    function mint(address to, uint256 id, uint256 amount, bytes memory data) public onlyOwner {
        _mint(to, id, amount, data);
        minter[id] = msg.sender;
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
        for (uint i = 0; i < ids.length; i++) {
            minter[ids[i]] = msg.sender;
        }
    }

    function burn(uint256 id, uint256 amount) public {
        _burn(msg.sender, id, amount);
        minter[id] = address(0);
    }

    function burnBatch(uint256[] memory ids, uint256[] memory amounts) public {
        _burnBatch(msg.sender, ids, amounts);
        for (uint i = 0; i < ids.length; i++) {
            minter[ids[i]] = address(0);
        }
    }
}
