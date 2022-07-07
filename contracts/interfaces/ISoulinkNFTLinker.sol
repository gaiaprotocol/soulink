// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ISoulink.sol";

interface ISoulinkNFTLinker {
    event SetNFT(uint256 indexed soulinkId, string indexed slot, address indexed nft, uint256 nftId);

    function soulink() external view returns (ISoulink);
    function nfts(uint256 soulinkId, string memory slot) external view returns (address nft, uint256 nftId);
}
