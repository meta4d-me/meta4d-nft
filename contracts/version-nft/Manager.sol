// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import "../interfaces/version-nft/IManager.sol";

contract Manager is IManager {

    mapping(bytes32 => mapping(address => string)) public info;

    mapping(bytes32 => address[]) internal creators;

    function encode(Token memory token) internal pure returns (bytes32){
        return keccak256(abi.encodePacked(token.chainId, token.nft, token.tokenId));
    }

    function setInfo(Token memory token, string memory uri) public {
        require(bytes(uri).length > 0, 'illegal uri');
        bytes32 key = encode(token);
        if (bytes(info[key][msg.sender]).length == 0) {
            creators[key].push(msg.sender);
        }
        info[key][msg.sender] = uri;
    }

    function getInfo(Token memory token, address creator) public view returns (string memory){
        return info[encode(token)][creator];
    }

    function getLatestInfoAll(Token memory token) public view returns (address[] memory _creators, string[] memory _uris){
        bytes32 key = encode(token);
        _creators = creators[key];
        _uris = new string[](_creators.length);
        for (uint i = 0; i < _creators.length; i++) {
            _uris[i] = info[key][_creators[i]];
        }
    }
}
