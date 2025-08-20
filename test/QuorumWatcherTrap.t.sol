// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {QuorumWatcherTrap} from "src/QuorumWatcherTrap.sol";
import {QuorumWatcherResponse} from "src/QuorumWatcherResponse.sol";
import {MockERC20} from "src/mocks/MockERC20.sol";
import {Deploy} from "script/Deploy.s.sol";

contract QuorumWatcherTrapTest is Test {
    QuorumWatcherTrap public trap;
    MockERC20 public mockToken;
    address public trackedAddress;
    address public whitelistedUser;
    address public nonWhitelistedUser;

    function setUp() public {
        // Deploy the trap contract
        trap = new QuorumWatcherTrap();

        // Get the hardcoded addresses from the trap contract
        address tokenAddress = address(trap.token());
        trackedAddress = trap.trackedAddress();

        // Deploy a template MockERC20 to get the runtime bytecode
        MockERC20 template = new MockERC20("Mock Token", "MTKN", 18);
        vm.etch(tokenAddress, address(template).code);
        mockToken = MockERC20(tokenAddress);

        // Set up users
        whitelistedUser = address(this);
        nonWhitelistedUser = address(0x456);

        // Mint some tokens to the tracked address
        mockToken.mint(trackedAddress, 2000 * 1e18);
    }

    function test_Collect() public {
        console.log("whitelistedUser:", whitelistedUser);
        console.log("is whitelisted:", trap.whitelist(whitelistedUser));
        vm.prank(whitelistedUser);
        bytes memory data = trap.collect();
        uint256 balance = abi.decode(data, (uint256));
        assertEq(balance, 2000 * 1e18, "Collected balance should be 2000e18");
    }

    function test_ShouldRespond_False_BalanceIncrease() public {
        bytes[] memory data = new bytes[](2);
        vm.prank(whitelistedUser);
        data[0] = trap.collect();

        // Increase the balance
        mockToken.mint(trackedAddress, 500 * 1e18);

        vm.prank(whitelistedUser);
        data[1] = trap.collect();

        (bool should, ) = trap.shouldRespond(data);
        assertFalse(should, "Should not respond when balance increases");
    }

    function test_ShouldRespond_False_BalanceDrop_BelowThreshold() public {
        bytes[] memory data = new bytes[](2);
        vm.prank(whitelistedUser);
        data[0] = trap.collect();

        // Decrease the balance, but not enough to trigger the threshold
        mockToken.burn(trackedAddress, 500 * 1e18);

        vm.prank(whitelistedUser);
        data[1] = trap.collect();

        (bool should, ) = trap.shouldRespond(data);
        assertFalse(should, "Should not respond when balance drop is below threshold");
    }

    function test_ShouldRespond_True_BalanceDrop_AboveThreshold() public {
        bytes[] memory data = new bytes[](2);
        vm.prank(whitelistedUser);
        data[0] = trap.collect();

        // Decrease the balance enough to trigger the threshold
        mockToken.burn(trackedAddress, 1500 * 1e18);

        vm.prank(whitelistedUser);
        data[1] = trap.collect();

        (bool should, bytes memory responseData) = trap.shouldRespond(data);
        assertTrue(should, "Should respond when balance drop is above threshold");

        // Check the response data
        (address _trackedAddress, uint256 initialBalance, uint256 currentBalance, uint256 balanceDrop) = abi.decode(
            responseData,
            (address, uint256, uint256, uint256)
        );

        assertEq(_trackedAddress, trackedAddress, "Tracked address in response data is incorrect");
        assertEq(initialBalance, 2000 * 1e18, "Initial balance in response data is incorrect");
        assertEq(currentBalance, 500 * 1e18, "Current balance in response data is incorrect");
        assertEq(balanceDrop, 1500 * 1e18, "Balance drop in response data is incorrect");
    }

    function test_Whitelist_OnlyWhitelistedCanCollect() public {
        vm.prank(whitelistedUser);
        trap.collect();
    }

    function test_Whitelist_NonWhitelistedCannotCollect() public {
        vm.prank(nonWhitelistedUser);
        vm.expectRevert("QuorumWatcherTrap: Caller is not whitelisted");
        trap.collect();
    }

    function test_Whitelist_AddAndRemoveOperator() public {
        // Add a new operator
        vm.prank(whitelistedUser);
        trap.addOperator(nonWhitelistedUser);

        // Now the new operator can collect
        vm.prank(nonWhitelistedUser);
        trap.collect();

        // Remove the operator
        vm.prank(whitelistedUser);
        trap.removeOperator(nonWhitelistedUser);

        // Now the removed operator cannot collect
        vm.prank(nonWhitelistedUser);
        vm.expectRevert("QuorumWatcherTrap: Caller is not whitelisted");
        trap.collect();
    }
}