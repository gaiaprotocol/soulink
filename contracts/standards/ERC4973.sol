// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.6;

import "./ERC721.sol";
import "../interfaces/IERC4973.sol";

abstract contract ERC4973 is ERC721, IERC4973 {

  constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

  function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
    return
      interfaceId == type(IERC4973).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  function burn(uint256 tokenId) public virtual override {
    require(msg.sender == ownerOf(tokenId), "burn: sender must be owner");
    _burn(tokenId);
  }

  function _mint(
    address to,
    uint256 tokenId
  ) internal virtual override {
    super._mint(to, tokenId);
    emit Attest(to, tokenId);
  }

  function _burn(uint256 tokenId) internal virtual override {
    address owner = ownerOf(tokenId);
    super._burn(tokenId);
    emit Revoke(owner, tokenId);
  }
}