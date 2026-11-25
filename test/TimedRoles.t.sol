// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {TimedRoles} from "../src/TimedRoles.sol";
import {TestBase} from "./TestBase.sol";

contract TimedRolesTest is TestBase {
    TimedRoles private registry;
    address private constant MEMBER = address(0xA11CE);
    bytes32 private constant EDITOR = keccak256("EDITOR");

    function setUp() public {
        vm.warp(100);
        registry = new TimedRoles();
    }

    function testGrantReplacementAndExactExpiry() public {
        assertTrue(!registry.hasRole(EDITOR, MEMBER));
        registry.grant(EDITOR, MEMBER, 120);
        assertTrue(registry.hasRole(EDITOR, MEMBER));
        assertTrue(!registry.hasRole(keccak256("OTHER"), MEMBER));
        registry.grant(EDITOR, MEMBER, 200);

        vm.warp(199);
        assertTrue(registry.hasRole(EDITOR, MEMBER));
        vm.warp(200);
        assertTrue(!registry.hasRole(EDITOR, MEMBER));
    }

    function testRevocationClearsActiveRole() public {
        registry.grant(EDITOR, MEMBER, 120);
        registry.revoke(EDITOR, MEMBER);
        assertEq(registry.expiresAt(EDITOR, MEMBER), 0);
        assertTrue(!registry.hasRole(EDITOR, MEMBER));
    }

    function testOnlyAdminCanGrantOrRevoke() public {
        vm.prank(MEMBER);
        vm.expectRevert(TimedRoles.Unauthorized.selector);
        registry.grant(EDITOR, MEMBER, 120);

        vm.prank(MEMBER);
        vm.expectRevert(TimedRoles.Unauthorized.selector);
        registry.revoke(EDITOR, MEMBER);
    }

    function testRejectsInvalidGrants() public {
        vm.expectRevert(TimedRoles.InvalidAccount.selector);
        registry.grant(EDITOR, address(0), 120);

        vm.expectRevert(TimedRoles.InvalidExpiry.selector);
        registry.grant(EDITOR, MEMBER, block.timestamp);
    }

    function testFuzzRoleLifetime(uint64 duration) public {
        vm.assume(duration > 0);
        uint256 deadline = block.timestamp + duration;
        registry.grant(EDITOR, MEMBER, deadline);
        vm.warp(deadline - 1);
        assertTrue(registry.hasRole(EDITOR, MEMBER));
        vm.warp(deadline);
        assertTrue(!registry.hasRole(EDITOR, MEMBER));
    }
}
