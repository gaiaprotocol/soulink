// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";

// import "./IERC4973.sol";

interface ISoulink is IERC721Metadata {
    event SetMinter(address indexed target, bool indexed isMinter);
    event SetContractURI(string uri);
    event SetBaseURI(string uri);

    function totalSupply() external view returns (uint256);

    function isMinter(address target) external view returns (bool);

    function getTokenId(address owner) external pure returns (uint256);

    function mint(address to) external returns (uint256 id);

    function burn(uint256 tokenId) external;

    function isLinked(uint256 id0, uint256 id1) external view returns (bool);

    function setLink(
        uint256 targetId,
        bytes[2] calldata sigs,
        uint256[2] calldata deadlines
    ) external;

    function breakLink(uint256 targetId) external;
}
