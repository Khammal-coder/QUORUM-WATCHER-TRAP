// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";
import {IERC20} from "src/interfaces/IERC20.sol";

/// @title QuorumWatcherTrap
/// @notice This trap monitors an address's token balance and triggers if the balance
///         drops by a significant amount (the BALANCE_THRESHOLD).
/// @dev The token and trackedAddress are hardcoded. This contract is intended to be
///      deployed via the Drosera platform, which does not support constructor arguments.
contract QuorumWatcherTrap is ITrap {
    // @dev The address of the ERC20 token to monitor.
    //      HARDCODED: Replace with the actual token address on the target network.
    IERC20 public constant token = IERC20(0x240ba5511552443631553a59f49334A438ea4653);

    // @dev The address of the major stakeholder whose balance is being monitored.
    //      HARDCODED: Replace with the actual address of the stakeholder to watch.
    address public constant trackedAddress = 0x59E2612551442b74683215932482259BA2b48239;

    // @dev The minimum balance drop required to trigger the trap.
    uint256 public constant BALANCE_THRESHOLD = 1000 * 1e18; // Example: 1000 tokens with 18 decimals

    /// @notice The constructor is empty as there is no whitelist to initialize.
    constructor() {}

    /// @notice Collects the current balance of the tracked address.
    /// @return A bytes array containing the encoded balance of the tracked address.
    function collect() external view override returns (bytes memory) {
        uint256 balance = token.balanceOf(trackedAddress);
        return abi.encode(balance);
    }

    /// @notice Determines if a response should be triggered based on a series of collected data points.
    /// @param data An array of bytes arrays, where each inner array is the return value of a `collect()` call.
    /// @return A boolean indicating whether to respond, and a bytes array containing data for the response contract.
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // We need at least two data points to compare the balance change.
        if (data.length < 2) {
            return (false, "");
        }

        // Decode the balances from the first and last data points.
        uint256 initialBalance = abi.decode(data[0], (uint256));
        uint256 currentBalance = abi.decode(data[data.length - 1], (uint256));

        // Check if the balance has dropped. We are only interested in when a stakeholder sells off, not buys more.
        if (initialBalance > currentBalance) {
            uint256 balanceDrop = initialBalance - currentBalance;

            // If the balance drop exceeds the threshold, trigger a response.
            if (balanceDrop >= BALANCE_THRESHOLD) {
                // Encode the relevant information for the response contract.
                bytes memory responseData = abi.encode(trackedAddress, initialBalance, currentBalance, balanceDrop);
                return (true, responseData);
            }
        }

        return (false, "");
    }
}