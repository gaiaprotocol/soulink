// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ISoulink.sol";

interface ISoulinkMinter {
    event SetMintPrice(uint256 mintPrice);
    event SetFeeTo(address payable feeTo);
    event SetLimit(uint256 limit);

    function soulink() external view returns (ISoulink);
    function feeTo() external view returns (address payable);
    function mintPrice() external view returns (uint256);
    function limit() external view returns (uint256);
    function mint() payable external returns (uint256 id);
}
