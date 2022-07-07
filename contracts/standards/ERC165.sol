// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

abstract contract ERC165 is IERC165 {
  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
      return interfaceId == type(IERC165).interfaceId;
  }
}