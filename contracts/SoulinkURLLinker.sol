// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/ISoulinkURLLinker.sol";

contract SoulinkURLLinker is ISoulinkURLLinker {

    ISoulink public immutable soulink;

    struct URL {
        string platform;
        string url;
    }

    mapping(uint256 => URL[]) public urls;

    constructor(ISoulink _soulink) {
        soulink = _soulink;
    }

    function addURL(uint256 soulinkId, string calldata platform, string calldata url) external {
        require(msg.sender == soulink.ownerOf(soulinkId));
        urls[soulinkId].push(URL({ platform: platform, url: url }));
        emit AddURL(soulinkId, platform, url);
    }

    function urlsLength(uint256 soulinkId) external view returns (uint256) {
        return urls[soulinkId].length;
    }
}
