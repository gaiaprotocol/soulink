// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/ISoulinkURLLinker.sol";

contract SoulinkURLLinker is ISoulinkURLLinker {

    ISoulink public immutable soulink;

    struct URL {
        string name;
        string url;
        string image;
    }

    mapping(uint256 => URL[]) public urls;

    constructor(ISoulink _soulink) {
        soulink = _soulink;
    }

    function addURL(uint256 soulinkId, string calldata name, string calldata url, string calldata image) external {
        require(msg.sender == soulink.ownerOf(soulinkId));
        urls[soulinkId].push(URL({ name: name, url: url, image: image }));
        emit AddURL(soulinkId, name, url, image);
    }

    function urlsLength(uint256 soulinkId) external view returns (uint256) {
        return urls[soulinkId].length;
    }
}
