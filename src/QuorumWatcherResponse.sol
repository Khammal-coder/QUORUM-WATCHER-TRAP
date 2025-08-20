// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title QuorumWatcherResponse
/// @notice This contract is called by a Drosera prover when the QuorumWatcherTrap is triggered.
/// @dev The prover address is set in the constructor and is the only address authorized to call executeResponse.
contract QuorumWatcherResponse {
    address public immutable prover;

    /// @notice An event that is emitted when the trap is triggered and a response is executed.
    event QuorumAlert(address indexed trackedAddress, uint256 initialBalance, uint256 currentBalance, uint256 balanceDrop);

    /// @notice The constructor sets the address of the trusted Drosera prover.
    /// @param _prover The address of the Drosera prover for the target network.
    constructor(address _prover) {
        prover = _prover;
    }

    /// @notice A modifier to ensure that only the designated prover can call a function.
    modifier onlyProver() {
        require(msg.sender == prover, "QuorumWatcherResponse: Caller is not the prover");
        _;
    }

    /// @notice This function is called by the Drosera prover when the trap is triggered.
    /// @param data The encoded data from the QuorumWatcherTrap, containing details about the balance drop.
    function executeResponse(bytes calldata data) external onlyProver {
        (address trackedAddress, uint256 initialBalance, uint256 currentBalance, uint256 balanceDrop) = abi.decode(
            data,
            (address, uint256, uint256, uint256)
        );

        emit QuorumAlert(trackedAddress, initialBalance, currentBalance, balanceDrop);
    }
}
