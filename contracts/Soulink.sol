// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./interfaces/IERC721Metadata.sol";

// import "./interfaces/ISoulink.sol";

contract Soulink is Ownable, ERC165, EIP712, IERC721Metadata {
    using Strings for uint256;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    string private _name = "Soulink";
    string private _symbol = "SL";

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    // keccak256("RequestLink(address to,uint256 deadline)");
    bytes32 private constant _REQUESTLINK_TYPEHASH = 0xc3b100a7bf35d534e6c9e325adabf47ef6ec87fd4874fe5d08986fbf0ad1efc4;

    mapping(address => bool) public isMinter;
    mapping(address => mapping(address => bool)) internal _isLinked;

    string internal __baseURI;

    constructor() EIP712(_name, "1") {
        isMinter[msg.sender] = true;

        __baseURI = "https://api.soul.ink/metadata/";
    }

    function _baseURI() internal view returns (string memory) {
        return __baseURI;
    }

    function setBaseURI(string calldata baseURI_) external onlyOwner {
        __baseURI = baseURI_;
        // emit SetBaseURI(baseURI_);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC721Metadata).interfaceId || super.supportsInterface(interfaceId);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _requireMinted(uint256 tokenId) internal view {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] = 1;
        _owners[tokenId] = to;
        _totalSupply++;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);

        delete _balances[owner];
        delete _owners[tokenId];
        _totalSupply--;

        emit Transfer(owner, address(0), tokenId);
    }

    function setMinter(address target, bool _isMinter) external onlyOwner {
        require(isMinter[target] != _isMinter, "Soulink: Permission not changed");
        isMinter[target] = _isMinter;
        // emit SetMinter(target, _isMinter);
    }

    function getTokenId(address owner) external pure returns (uint256) {
        return _getTokenId(owner);
    }

    function _getTokenId(address owner) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(owner)));
    }

    function mint(address to) external returns (uint256 tokenId) {
        require(isMinter[msg.sender], "Soulink: Forbidden");
        require(balanceOf(to) == 0, "can have only 1 token");
        tokenId = _getTokenId(to);
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        require(_getTokenId(msg.sender) == tokenId, "ERC721: caller is not token owner");
        _burn(tokenId);
    }

    function isLinked(address a, address b) external view returns (bool) {
        (address user0, address user1) = sortAddrs(a, b);
        return _isLinked[user0][user1];
    }

    function sortAddrs(address addrA, address addrB) internal pure returns (address addr0, address addr1) {
        require(addrA != addrB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (addr0, addr1) = addrA < addrB ? (addrA, addrB) : (addrB, addrA);
        require(addr0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    /**
        0: msg.sender
        1: to
    */
    function setLink(
        address to,
        bytes[2] calldata sigs,
        uint256[2] calldata deadlines
    ) external {
        require(block.timestamp <= deadlines[0] && block.timestamp <= deadlines[1], "expired");

        bytes32 hash0 = _hashTypedDataV4(keccak256(abi.encode(_REQUESTLINK_TYPEHASH, to, deadlines[0])));
        require(ECDSA.recover(hash0, sigs[0]) == msg.sender, "ERC20Permit: invalid signature");

        bytes32 hash1 = _hashTypedDataV4(keccak256(abi.encode(_REQUESTLINK_TYPEHASH, msg.sender, deadlines[1])));
        require(ECDSA.recover(hash1, sigs[1]) == to, "ERC20Permit: invalid signature");

        (address user0, address user1) = sortAddrs(msg.sender, to);
        require(!_isLinked[user0][user1], "ALREADY_LINKED");
        _isLinked[user0][user1] = true;
        // emit SetLink(msg.sender, to);
    }

    function breakLink(address to) external {
        (address user0, address user1) = sortAddrs(msg.sender, to);
        require(_isLinked[user0][user1], "NOT_LINKED");
        delete _isLinked[user0][user1];
        // emit BreakLink(msg.sender, to);
    }
}
