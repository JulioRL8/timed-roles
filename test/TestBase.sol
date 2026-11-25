// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

interface Vm {
    function addr(uint256 privateKey) external returns (address);
    function assume(bool condition) external;
    function chainId(uint256 newChainId) external;
    function deal(address account, uint256 newBalance) external;
    function expectEmit(bool topic1, bool topic2, bool topic3, bool data, address emitter) external;
    function expectRevert(bytes4 selector) external;
    function prank(address sender) external;
    function sign(uint256 privateKey, bytes32 digest) external returns (uint8 v, bytes32 r, bytes32 s);
    function warp(uint256 timestamp) external;
}

abstract contract TestBase {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    error AssertionFailed();
    error UintMismatch(uint256 actual, uint256 expected);
    error AddressMismatch(address actual, address expected);
    error BytesMismatch(bytes32 actual, bytes32 expected);

    function assertTrue(bool condition) internal pure {
        if (!condition) revert AssertionFailed();
    }

    function assertEq(uint256 actual, uint256 expected) internal pure {
        if (actual != expected) revert UintMismatch(actual, expected);
    }

    function assertEq(address actual, address expected) internal pure {
        if (actual != expected) revert AddressMismatch(actual, expected);
    }

    function assertEq(bytes32 actual, bytes32 expected) internal pure {
        if (actual != expected) revert BytesMismatch(actual, expected);
    }
}
