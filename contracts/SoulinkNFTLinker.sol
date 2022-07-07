// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/ISoulinkNFTLinker.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SoulinkNFTLinker is ISoulinkNFTLinker {

    ISoulink public immutable soulink;

    struct NFT {
        address addr;
        uint256 tokenId;
    }

    mapping(uint256 => mapping(string => NFT)) private _nfts;

    constructor(ISoulink _soulink) {
        soulink = _soulink;
    }

    function setNFT(uint256 soulinkId, string memory slot, address nft, uint256 nftId) external {
        require(msg.sender == soulink.ownerOf(soulinkId));
        require(msg.sender == IERC721(nft).ownerOf(nftId));
        _nfts[soulinkId][slot] = NFT({ addr: nft, tokenId: nftId });
        emit SetNFT(soulinkId, slot, nft, nftId);
    }

    function nfts(uint256 soulinkId, string memory slot) external view returns (address, uint256) {
        NFT memory nft = _nfts[soulinkId][slot];
        if (soulink.ownerOf(soulinkId) == IERC721(nft.addr).ownerOf(nft.tokenId)) {
            return (nft.addr, nft.tokenId);
        } else {
            return (address(0), 0);
        }
    }
}
