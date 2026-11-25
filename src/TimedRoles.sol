// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

contract TimedRoles {
    error Unauthorized();
    error InvalidAccount();
    error InvalidExpiry();

    address public immutable admin;
    mapping(bytes32 role => mapping(address account => uint256)) public expiresAt;

    event Granted(bytes32 indexed role, address indexed account, uint256 expiry);
    event Revoked(bytes32 indexed role, address indexed account);

    constructor() {
        admin = msg.sender;
    }

    function grant(bytes32 role, address account, uint256 expiry) external {
        if (msg.sender != admin) revert Unauthorized();
        if (account == address(0)) revert InvalidAccount();
        if (expiry <= block.timestamp) revert InvalidExpiry();

        expiresAt[role][account] = expiry;
        emit Granted(role, account, expiry);
    }

    function revoke(bytes32 role, address account) external {
        if (msg.sender != admin) revert Unauthorized();

        delete expiresAt[role][account];
        emit Revoked(role, account);
    }

    function hasRole(bytes32 role, address account) external view returns (bool) {
        return expiresAt[role][account] > block.timestamp;
    }
}
