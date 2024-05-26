
# Vault Contract

## Overview

The Vault contract is a Solidity smart contract designed to securely manage the deposits and withdrawals of ERC-20 tokens of a user. It includes features like whitelisting of tokens, pausing and unpausing of deposit/withdrawal functions, and access control for administrative functions.

## Features

- **Deposit and Withdrawal**: Users can deposit and withdraw whitelisted ERC-20 tokens deposited by them.
- **Token Whitelisting**: Admin can whitelist tokens that are allowed for deposit.
- **Pause/Unpause**: Admin can pause or unpause the contract, restricting or allowing deposits and withdrawals.
- **Access Control**: Only admin can pause/unpause the contract and whitelist tokens.

## Requirements

- [Solidity](https://soliditylang.org/)
- [Foundry](https://getfoundry.sh/)

## Setup

1. **Clone the repository**:
   ```bash
   git clone [REPOSITORY_URL]
   cd [REPOSITORY_DIRECTORY]
   ```

2. **Compile the contract**:
   ```bash
   forge build
   ```

## Running Tests

To run the test suite:

```bash
forge test
```

This command will execute the test cases defined in the `test/Vault.t.sol` file, ensuring the contract functions as expected.
