// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import "./IERC4973.sol";

interface ISoulink is IERC721Metadata, IERC4973 {
    event SetMinter(address indexed target, bool indexed isMinter);
    event SetContractURI(string uri);
    event SetBaseURI(string uri);

    function nextId() external view returns (uint256);

    function isMinter(address target) external view returns (bool);

    function contractURI() external view returns (string calldata);

    function mint(address to) external returns (uint256 id);

    function mintBatch(uint256 limit) external;
}
