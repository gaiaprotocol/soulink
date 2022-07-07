// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ISoulinkMinter.sol";

contract SoulinkMinter is Ownable, ISoulinkMinter {

    ISoulink public immutable soulink;
    address payable public feeTo;
    uint256 public mintPrice;

    uint256 public limit;

    constructor(
        ISoulink _soulink,
        address payable _feeTo,
        uint256 _limit,
        uint256 _mintPrice
    ) {
        soulink = _soulink;
        feeTo = _feeTo;
        limit = _limit;
        mintPrice = _mintPrice;

        emit SetFeeTo(_feeTo);
        emit SetLimit(_limit);
        emit SetMintPrice(_mintPrice);
    }

    function setFeeTo(address payable _feeTo) external onlyOwner {
        feeTo = _feeTo;
        emit SetFeeTo(_feeTo);
    }

    function setLimit(uint256 _limit) external onlyOwner {
        limit = _limit;
        emit SetLimit(_limit);
    }

    function setMintPrice(uint256 _price) external onlyOwner {
        mintPrice = _price;
        emit SetMintPrice(_price);
    }

    function mint() payable public returns (uint256 id) {
        require(soulink.nextId() < limit, "SoulinkMinter: Limit exceeded");
        require(msg.value == mintPrice);
        id = soulink.mint(msg.sender);
        feeTo.transfer(msg.value);
    }
}
