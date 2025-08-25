// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title QuorumWatcherResponse
/// @notice This contract is called by a Drosera prover when the QuorumWatcherTrap is triggered.
contract QuorumWatcherResponse {
    /// @notice An event that is emitted when the trap is triggered and a response is executed.
    event QuorumAlert(address indexed trackedAddress, uint256 initialBalance, uint256 currentBalance, uint256 balanceDrop);

    /// @notice The constructor is empty as there is no prover to set.
    constructor() {}

    /// @notice This function is called by the Drosera prover when the trap is triggered.
    /// @param trackedAddress The address of the stakeholder being watched.
    /// @param initialBalance The initial balance of the stakeholder.
    /// @param currentBalance The current balance of the stakeholder.
    /// @param balanceDrop The amount by which the balance has dropped.
    function executeResponse(
        address trackedAddress,
        uint256 initialBalance,
        uint256 currentBalance,
        uint256 balanceDrop
    ) external {
        emit QuorumAlert(trackedAddress, initialBalance, currentBalance, balanceDrop);
    }
}