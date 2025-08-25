# Quorum Watcher Trap Project

This project implements a Drosera-powered trap to monitor the token balance of a major stakeholder and trigger a response if their balance drops significantly.

## How it Works

The system is designed to detect when a large token holder (a "whale") starts selling off their tokens. This is a common signal that can affect the stability of a protocol or DAO. By detecting this early, the system can trigger a response to alert the community or take other automated actions.

The core of the system is the `QuorumWatcherTrap` contract, which is a Drosera trap. This trap is designed to be monitored by the Drosera network of nodes. The nodes will periodically call the `collect()` function on the trap to get the current token balance of the address being watched.

The Drosera nodes then use the collected data to call the `shouldRespond()` function on the trap. This function contains the logic to determine if a response should be triggered. In this case, it checks if the token balance has dropped by a certain threshold.

If `shouldRespond()` returns `true`, the Drosera network will trigger a transaction to the `QuorumWatcherResponse` contract, which will then execute a predefined action, such as emitting an event.

## Components

### 1. `QuorumWatcherTrap.sol`

- **Purpose:** This is the main trap contract that implements the `ITrap` interface from the Drosera protocol.
- **Functionality:**
    - It hardcodes the address of the token to be monitored (`token`) and the address of the stakeholder to be watched (`trackedAddress`).
    - The `collect()` function returns the current balance of the `trackedAddress`.
    - The `shouldRespond()` function compares the balance over time and returns `true` if the balance has dropped by more than the `BALANCE_THRESHOLD`.

### 2. `QuorumWatcherResponse.sol`

- **Purpose:** This contract is called by the Drosera network when the trap is triggered.
- **Functionality:**
    - The `executeResponse()` function is called by the Drosera network.
    - It emits a `QuorumAlert` event with information about the balance drop.

### 3. `MockERC20.sol`

- **Purpose:** This is a simple ERC20 token implementation used for testing purposes.
- **Functionality:**
    - It allows for minting and burning of tokens, which is necessary to simulate balance changes in the tests.

### 4. `Deploy.s.sol`

- **Purpose:** This is a Foundry script to deploy the `QuorumWatcherResponse` and `MockERC20` contracts.
- **Functionality:**
    - It simplifies the deployment process by deploying all the necessary contracts (except the main trap) in a single command.

### 5. `QuorumWatcherTrap.t.sol`

- **Purpose:** This is the test suite for the `QuorumWatcherTrap` contract.
- **Functionality:**
    - It uses Foundry to test all the functionality of the trap, including the `collect` and `shouldRespond` functions.

### 6. `drosera.toml`

- **Purpose:** This is the configuration file for the Drosera trap.
- **Functionality:**
    - It specifies the path to the trap contract, the address of the response contract, the function to be called on the response contract, and other parameters for the Drosera network.

## Deployment Process

For detailed deployment instructions, please see the `DEPLOY_DETAILS.md` file.