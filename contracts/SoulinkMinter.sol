// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/ISoulinkMinter.sol";
import "./interfaces/IDiscountDB.sol";

contract SoulinkMinter is Ownable, ISoulinkMinter {
    ISoulink public immutable soulink;
    uint96 public mintPrice;
    address public feeTo;
    uint96 public limit;
    address public discountDB;

    constructor(ISoulink _soulink) {
        soulink = _soulink;
        feeTo = msg.sender;
        limit = type(uint96).max;
        mintPrice = 0.1 ether;

        emit SetFeeTo(msg.sender);
        emit SetLimit(type(uint96).max);
        emit SetMintPrice(0.1 ether);
    }

    function setFeeTo(address _feeTo) external onlyOwner {
        feeTo = _feeTo;
        emit SetFeeTo(_feeTo);
    }

    function setLimit(uint96 _limit) external onlyOwner {
        limit = _limit;
        emit SetLimit(_limit);
    }

    function setMintPrice(uint96 _price) external onlyOwner {
        mintPrice = _price;
        emit SetMintPrice(_price);
    }

    function setDiscountDB(address db) external onlyOwner {
        discountDB = db;
        // emit SetDiscountDB(db);
    }

    function mint(bool discount, bytes calldata data) public payable returns (uint256 id) {
        require(soulink.totalSupply() < limit, "SoulinkMinter: Limit exceeded");
        uint256 _mintPrice = mintPrice;
        if (discount) {
            require(discountDB != address(0), "No discountDB");
            uint16 dcRate = IDiscountDB(discountDB).getDiscountRate(msg.sender, _mintPrice, data);
            _mintPrice = (_mintPrice * (10000 - dcRate)) / 10000;
        }
        require(msg.value == _mintPrice, "INVALID_MINTPRICE");
        id = soulink.mint(msg.sender);
        Address.sendValue(payable(feeTo), msg.value);
    }
}
