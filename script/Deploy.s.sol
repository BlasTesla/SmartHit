// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Shit} from "src/Shit.sol";

contract DeployScript is Script {
    Shit public shit;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        uint256 _targetInterval = 15 minutes;
        uint256 _defaultAmount = 690_420e18;
        uint256 _mintCap = 690_420_000e18;
        address liquidityProvider = 0x46A9515Ebf8B6DD55e968f7459E0eb00AE8a65b1;
        uint256 lpAmount = 207_126_000e18;
        shit = new Shit(_targetInterval, _defaultAmount, _mintCap, liquidityProvider, lpAmount);

        vm.stopBroadcast();
    }
}
