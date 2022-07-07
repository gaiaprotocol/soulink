// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ISoulink.sol";

interface ISoulinkNFTLinker {
    event AddNFT(uint256 indexed soulinkId, address indexed nft, uint256 indexed nftId);

    function soulink() external view returns (ISoulink);
    function nfts(uint256 soulinkId, uint256 index) external view returns (address nft, uint256 nftId);
    function nftsLength(uint256 soulinkId) external view returns (uint256);
}
