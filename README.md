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
    - The `executeResponse()` function is called by a trusted Drosera prover.
    - It emits a `QuorumAlert` event with the information about the balance drop.

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

The deployment process is divided into two main steps:

### Step 1: Deploy the Response Contract (with Foundry)

The `QuorumWatcherResponse` contract needs to be deployed to the blockchain before the trap can be deployed. This is because the address of the response contract needs to be included in the `drosera.toml` file.

1.  **Set up your environment:** You will need to have an RPC URL and a private key for the account you want to deploy from. You can set these as environment variables:
    ```bash
    export RPC_URL=<your_rpc_url>
    export PRIVATE_KEY=<your_private_key>
    ```
2.  **Run the deployment script:** Use the following Foundry command to deploy the `QuorumWatcherResponse` contract:
    ```bash
    forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
    ```
3.  **Get the contract address:** The script will print the address of the deployed `QuorumWatcherResponse` contract. Copy this address.

### Step 2: Deploy the Trap Contract (with Drosera CLI)

Now that you have the address of the response contract, you can deploy the main trap.

1.  **Update `drosera.toml`:** Open the `drosera.toml` file and replace the placeholder for `response_contract` with the actual address of the `QuorumWatcherResponse` contract that you deployed in the previous step.
2.  **Deploy the trap:** Use the Drosera CLI to deploy the trap.
    ```bash
    drosera traps deploy quorumwatchertrap
    ```

This will deploy the `QuorumWatcherTrap` contract and register it with the Drosera network. The network will then start monitoring the trap and trigger the response contract if the conditions are met.