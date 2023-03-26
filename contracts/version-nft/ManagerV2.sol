// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import "../interfaces/version-nft/IManager.sol";
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import "./Manager.sol";

contract ManagerV2 is IManagerV2, Manager {

    function setInfoByPermit(Token memory token, string memory uri, bytes memory sig) public {
        require(bytes(uri).length > 0, 'illegal uri');
        bytes32 key = encode(token);
        address sender = ECDSA.recover(keccak256(abi.encodePacked(key, uri)), sig);
        if (bytes(info[key][sender]).length == 0) {
            creators[key].push(sender);
        }
        info[key][sender] = uri;
    }
}
