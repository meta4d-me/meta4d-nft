// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol';

import './interfaces/IM4mNFT.sol';
import './interfaces/IM4mNFTRegistry.sol';

// @dev config attribute value when mint NFT
contract M4mNFT is ERC721EnumerableUpgradeable, IM4mNFT {
    using StringsUpgradeable for uint256;

    string private baseURI;
    address public override registry;

    function initialize(string memory __baseURI, address _registry) public initializer {
        __ERC721Enumerable_init();
        baseURI = __baseURI;
        registry = _registry;
    }

    /// @notice
    function burn(uint256 tokenId) public override {
        require(msg.sender == registry, "ill registry");
        _burn(tokenId);
    }

    function mint(address to, uint tokenId) public override {
        require(msg.sender == registry, 'ill registry');
        _safeMint(to, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return string(abi.encodePacked(baseURI, uint(uint160(address(this))).toHexString(), "/"));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        (IM4mNFTRegistry.TokenStatus status,,,) = IM4mNFTRegistry(registry).getTokenStatus(tokenId);
        require(status != IM4mNFTRegistry.TokenStatus.Locked, 'token locked');
    }
}
