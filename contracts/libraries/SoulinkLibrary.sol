// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library SoulinkLibrary {
    function _getTokenId(address owner) internal pure returns (uint256 id) {
        assembly {
            id := owner
        }
    }

    function _sort(uint256 idA, uint256 idB) internal pure returns (uint256 id0, uint256 id1) {
        require(idA != idB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (id0, id1) = idA < idB ? (idA, idB) : (idB, idA);
        require(id0 != uint256(0), "UniswapV2Library: ZERO_ADDRESS");
    }
}
