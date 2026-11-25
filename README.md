# Timed Roles

An access registry for roles that expire automatically at a specified timestamp.

## How it works

1. Deploy from the address that will administer the registry.
2. Call `grant(role, account, expiresAt)` to assign a role. Granting it again replaces the previous deadline.
3. Use `hasRole(role, account)` to check access. The admin can call `revoke` to end access immediately.

Role identifiers are arbitrary bytes32 values. The admin is immutable, and integrations must query this registry to enforce the role.

## Build and test

Install [Foundry](https://getfoundry.sh/) and run these commands from this directory. Forge selects Solidity 0.8.36 from `foundry.toml`. The project has no third-party Solidity dependencies.

```bash
forge build
forge test -vv
forge coverage --exclude-tests
```

## Local deployment

Start a fresh `anvil` node in a separate terminal. Deploy with the first unlocked account on that local node.

```bash
export RPC_URL=http://127.0.0.1:8545
export ANVIL_ACCOUNT=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
forge create src/TimedRoles.sol:TimedRoles --rpc-url "$RPC_URL" --from "$ANVIL_ACCOUNT" --unlocked --broadcast
```

## Local example

Set `CONTRACT` to the address printed by `forge create` and keep using the same terminal.

```bash
export ETH_RPC_URL="$RPC_URL"
CONTRACT=0x... # Replace with your deployed address.
ROLE=$(cast keccak "EDITOR")
MEMBER=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
EXPIRY=$(($(date +%s) + 3600))
cast send "$CONTRACT" 'grant(bytes32,address,uint256)' "$ROLE" "$MEMBER" "$EXPIRY" --from "$ANVIL_ACCOUNT" --unlocked
cast call "$CONTRACT" 'hasRole(bytes32,address)(bool)' "$ROLE" "$MEMBER"
```

## Test cases

Foundry reports 5 passing tests and 100% coverage on contract lines, statements, branches and functions.

- Grant, replacement, expiry at the exact deadline and revocation.
- Unauthorized calls, zero addresses, and non-future deadlines.
- Fuzzed grant lifetimes.
