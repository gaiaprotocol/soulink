// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Soulink is Ownable, ERC721 {

    event SetBaseURI(string uri);
    event SetMinter(address minter);
    event SetLink(uint256 indexed id, string platform, string url);

    string internal __baseURI;
    uint256 public nextId;
    address public minter;

    mapping(uint256 => mapping(string => string)) public links;

    constructor() ERC721("Soulink", "SL") {
        __baseURI = "https://api.soul.ink/metadata/";
    }

    function _baseURI() internal view override returns (string memory) {
        return __baseURI;
    }

    function setBaseURI(string calldata uri) external onlyOwner {
        __baseURI = uri;
        emit SetBaseURI(uri);
    }

    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
        emit SetMinter(_minter);
    }

    function mint(address to) external {
        require(msg.sender == minter);
        _mint(to, nextId);
        nextId += 1;
    }

    function burn(uint256 id) external {
        require(msg.sender == ownerOf(id));
        _burn(id);
    }

    function setLink(uint256 id, string calldata platform, string calldata url) external {
        require(msg.sender == ownerOf(id));
        links[id][platform] = url;
        emit SetLink(id, platform, url);
    }
}
