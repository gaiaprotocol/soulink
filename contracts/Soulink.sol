// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./libraries/SoulinkLibrary.sol";
import "./interfaces/IERC721Metadata.sol";

// import "./interfaces/ISoulink.sol";

contract Soulink is Ownable, ERC165, EIP712, IERC721Metadata {
    using Strings for uint256;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    string private _name = "Soulink";
    string private _symbol = "SL";

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    uint128 private _totalSupply;
    uint128 private _burnCount;

    // keccak256("RequestLink(address to,uint256 deadline)");
    bytes32 private constant _REQUESTLINK_TYPEHASH = 0xc3b100a7bf35d534e6c9e325adabf47ef6ec87fd4874fe5d08986fbf0ad1efc4;

    mapping(address => bool) public isMinter;
    mapping(uint256 => mapping(uint256 => bool)) internal _isLinked;
    mapping(uint256 => uint256) internal _internalId;

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
        return _totalSupply - _burnCount;
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
        _burnCount++;

        emit Transfer(owner, address(0), tokenId);
    }

    function setMinter(address target, bool _isMinter) external onlyOwner {
        require(isMinter[target] != _isMinter, "Soulink: Permission not changed");
        isMinter[target] = _isMinter;
        // emit SetMinter(target, _isMinter);
    }

    function getTokenId(address owner) public pure returns (uint256) {
        return SoulinkLibrary._getTokenId(owner);
    }

    function mint(address to) external returns (uint256 tokenId) {
        require(isMinter[msg.sender], "Soulink: Forbidden");
        require(balanceOf(to) == 0, "can have only 1 token");
        tokenId = getTokenId(to);
        _mint(to, tokenId);
        _internalId[tokenId] = _totalSupply; //_internalId starts from 1
    }

    function burn(uint256 tokenId) external {
        require(getTokenId(msg.sender) == tokenId, "ERC721: caller is not token owner");
        _burn(tokenId);
        delete _internalId[tokenId];
        // emit ResetLink(tokenId);
    }

    function isLinked(uint256 id0, uint256 id1) external view returns (bool) {
        (uint256 iId0, uint256 iId1) = _getInternalIds(id0, id1);
        return _isLinked[iId0][iId1];
    }

    function _getInternalIds(uint256 id0, uint256 id1) internal view returns (uint256 iId0, uint256 iId1) {
        _requireMinted(id0);
        _requireMinted(id1);

        (iId0, iId1) = SoulinkLibrary._sort(_internalId[id0], _internalId[id1]);
    }

    /**
        0: id of msg.sender
        1: id of target
    */
    function setLink(
        uint256 targetId,
        bytes[2] calldata sigs,
        uint256[2] calldata deadlines
    ) external {
        require(block.timestamp <= deadlines[0] && block.timestamp <= deadlines[1], "expired");

        uint256 myId = getTokenId(msg.sender);

        bytes32 hash0 = _hashTypedDataV4(keccak256(abi.encode(_REQUESTLINK_TYPEHASH, targetId, deadlines[0])));
        SignatureChecker.isValidSignatureNow(msg.sender, hash0, sigs[0]);

        bytes32 hash1 = _hashTypedDataV4(keccak256(abi.encode(_REQUESTLINK_TYPEHASH, myId, deadlines[1])));
        SignatureChecker.isValidSignatureNow(address(uint160(targetId)), hash1, sigs[1]);

        (uint256 iId0, uint256 iId1) = _getInternalIds(myId, targetId);
        require(!_isLinked[iId0][iId1], "ALREADY_LINKED");
        _isLinked[iId0][iId1] = true;
        // emit SetLink(myId, targetId);
    }

    function breakLink(uint256 targetId) external {
        uint256 myId = getTokenId(msg.sender);
        (uint256 iId0, uint256 iId1) = _getInternalIds(myId, targetId);
        require(_isLinked[iId0][iId1], "NOT_LINKED");
        delete _isLinked[iId0][iId1];
        // emit BreakLink(myId, targetId);
    }
}
