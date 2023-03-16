// SPDX-License-Identifier: AGPL-3.0
pragma solidity =0.8.12;

import '@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol';

import './interfaces/IM4mComponents.sol';

contract M4mComponent is ERC1155Upgradeable, OwnableUpgradeable, IM4mComponents {
    using StringsUpgradeable for uint256;

    mapping(uint => string) public override name;
    mapping(uint => string) public override symbol;
    mapping(uint => uint) public override totalSupply;

    address public override registry;

    address public operator;

    string public baseURI;

    /* events */
    event PreparedComponent(uint tokenId, string _name, string _symbol);
    event SetOperator(address newOperator);

    function initialize(address _registry) public initializer {
        __ERC1155_init_unchained("");
        __Ownable_init_unchained();
        registry = _registry;
    }

    function setOperator(address newOperator) public onlyOwner {
        operator = newOperator;
        emit SetOperator(newOperator);
    }

    // @notice we can prepare new token many times as long as it's supply is 0
    function prepareNewToken(uint tokenId, string memory _name, string memory _symbol)
    public {
        require(msg.sender == owner() || msg.sender == operator, 'ill caller');
        _prepareNewToken(tokenId, _name, _symbol);
    }

    function _prepareNewToken(uint tokenId, string memory _name, string memory _symbol) internal {
        require(totalSupply[tokenId] == 0, 'existed');
        name[tokenId] = _name;
        symbol[tokenId] = _symbol;

        emit PreparedComponent(tokenId, _name, _symbol);
    }

    function burn(address account, uint256 id, uint256 value) public override {
        require(account == _msgSender() || isApprovedForAll(account, _msgSender()), "caller is not owner nor approved");

        totalSupply[id] -= value;
        _burn(account, id, value);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) public override {
        require(account == _msgSender() || isApprovedForAll(account, _msgSender()), "caller is not owner nor approved");
        for (uint i = 0; i < values.length; i++) {
            totalSupply[ids[i]] -= values[i];
        }
        _burnBatch(account, ids, values);
    }

    function mint(address to, uint tokenId, uint amount) public override {
        require(msg.sender == registry, 'only registry');
        checkInit(tokenId);
        totalSupply[tokenId] += amount;
        _mint(to, tokenId, amount, '');
    }

    function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) public override {
        require(msg.sender == registry, 'only registry');
        for (uint256 i = 0; i < tokenIds.length; i++) {
            checkInit(tokenIds[i]);
            totalSupply[tokenIds[i]] += amounts[i];
        }
        _mintBatch(to, tokenIds, amounts, '');
    }

    function checkInit(uint tokenId) internal view {
        string memory _name = name[tokenId];
        require(bytes(_name).length > 0, 'no attr');
    }

    function setBaseURI(string memory base) public {
        require(msg.sender == owner() || msg.sender == operator, 'ill caller');
        baseURI = base;
    }

    function uri(uint256 id) public override view returns (string memory){
        return string(abi.encodePacked(baseURI, uint(uint160(address(this))).toHexString(), "/", id.toString()));
    }
}
