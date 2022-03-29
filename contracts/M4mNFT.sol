// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol';

// @dev Meta-4d for me NFT with random attributes
contract M4mNFT is ERC721EnumerableUpgradeable {

    string[] internal style;
    string[] internal hair;
    string[] internal complexion;
    string[] internal upper;
    string[] internal lower;
    string[] internal shoesAndSocks;
    string[] internal tattoo;
    string[] internal earrings;
    string[] internal necklace;
    string[] internal glass;
    string[] internal backendEnv;
    string[] internal frontendEnv;

    string private baseURI;

    // TODO: init attributes
    /* initialize */
    function initialize(string memory _baseURI) public virtual initializer {
        __ERC721Enumerable_init();
        baseURI = _baseURI;
        style = ['2D', '3D'];
    }

    // tokenId starts from 0
    function mint(address to) public virtual {
        _safeMint(to, totalSupply());
    }

    /* view function */
    function getStyle(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'style', style);
    }

    function getHair(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'hair', hair);
    }

    function getComplexion(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'complexion', complexion);
    }

    function getUpper(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'upper', upper);
    }

    function getLower(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'lower', lower);
    }

    function getShoesAndSocks(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'shoesAndSocks', shoesAndSocks);
    }

    function getEarrings(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'earrings', earrings);
    }

    function getNecklace(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'necklace', necklace);
    }

    function getGlass(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'glass', glass);
    }

    function getBackendEnv(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'backendEnv', backendEnv);
    }

    function getFrontendEnv(uint tokenId) external virtual view returns (string memory) {
        return pluck(tokenId, 'frontendEnv', frontendEnv);
    }

    /* private function */
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        // use block hash to increase randomness
        uint256 rand = random(string(abi.encodePacked(blockhash(block.number), keyPrefix, toString(tokenId))));
        string memory output = sourceArray[rand % sourceArray.length];
        return output;
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
