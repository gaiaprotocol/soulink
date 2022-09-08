// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract SoulinkSignatureChecker is EIP712 {

    // keccak256("RequestLink(uint256 targetId,uint256 deadline)");
    bytes32 private constant _REQUESTLINK_TYPEHASH = 0xa09d82e5227cc630e060d997b23666070a7c20039c7884fd8280a04dcaef5042;

    constructor() EIP712("Soulink", "1") {}

    function checkSignature(
        address from,
        uint256 toId,
        uint256 fromDeadline,
        bytes calldata fromSig
    ) external view {
        require(
            SignatureChecker.isValidSignatureNow(
                from,
                _hashTypedDataV4(keccak256(abi.encode(_REQUESTLINK_TYPEHASH, toId, fromDeadline))),
                fromSig
            ),
            "INVALID_SIGNATURE"
        );
    }
}
