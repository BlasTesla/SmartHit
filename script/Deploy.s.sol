// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Smart} from "src/Smart.sol";

contract DeployScript is Script {
    Smart public smart;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        uint256 _targetInterval = 10 minutes;
        uint256 _defaultAmount = 500_000e18;
        uint256 _mintCap = 500_000_000e18;
        address liquidityProvider = 0x3B3AD2B24CDf754cBAF32f0D2CBb86D11Dc3803A;
        uint256 lpAmount = 1_000_000e18;
        smart = new Smart(_targetInterval, _defaultAmount, _mintCap, liquidityProvider, lpAmount);

        vm.stopBroadcast();
    }
}
