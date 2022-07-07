// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ISoulink.sol";

interface ISoulinkURLLinker {
    event AddURL(uint256 indexed soulinkId, string indexed platform, string url);

    function soulink() external view returns (ISoulink);
    function urls(uint256 soulinkId, uint256 index) external view returns (string memory platform, string memory url);
    function urlsLength(uint256 soulinkId) external view returns (uint256);
}
