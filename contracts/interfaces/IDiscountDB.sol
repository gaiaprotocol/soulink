// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDiscountDB {
    function getDiscountRate(
        address target,
        uint256 mintPrice,
        bytes calldata data
    ) external view returns (uint16);
}
