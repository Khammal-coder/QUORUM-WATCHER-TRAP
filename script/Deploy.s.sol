// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MockERC20} from "src/mocks/MockERC20.sol";
import {QuorumWatcherResponse} from "src/QuorumWatcherResponse.sol";

contract Deploy is Script {
    function run() external returns (address, address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the MockERC20 token
        MockERC20 mockToken = new MockERC20("Mock Token", "MTKN", 18);

        // Deploy the QuorumWatcherResponse contract
        // The QuorumWatcherResponse contract no longer requires a prover address.
        QuorumWatcherResponse responseContract = new QuorumWatcherResponse();

        vm.stopBroadcast();

        console.log("MockERC20 deployed at:", address(mockToken));
        console.log("QuorumWatcherResponse deployed at:", address(responseContract));

        return (address(mockToken), address(responseContract));
    }
}