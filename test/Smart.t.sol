// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {Smart} from "src/Smart.sol";

contract SmartTest is Test {
    Smart public smart;
    address deployer;
    address alice;
    address bob;
    address charlie;

    uint256 _targetInterval = 10 minutes;
    uint256 _defaultAmount = 10_000e18;
    uint256 _mintCap = 1_000_000_000e18;
    address liquidityProvider = deployer;
    uint256 lpAmount = 1_000_000e18;

    function setUp() public {
        deployer = vm.addr(1);
        vm.label(deployer, "deployer");
        alice = vm.addr(2);
        vm.label(alice, "alice");
        bob = vm.addr(3);
        vm.label(bob, "bob");
        charlie = vm.addr(4);
        vm.label(charlie, "charlie");

        smart = new Smart(_targetInterval, _defaultAmount, _mintCap, liquidityProvider, lpAmount);
    }

    function test_claim_RIPBozo() public {
        vm.prank(alice);
        vm.expectRevert(Smart.RIPBozo.selector);
        smart.claim();
    }

    function test_claim_success() public {
        vm.warp(block.timestamp + smart.TARGET_INTERVAL());
        smart.prepapreClaim();
        vm.prank(alice);
        smart.claim();

        assertEq(smart.DEFAULT_AMOUNT(), smart.balanceOf(alice), "Alice was not minted correctly");
    }

    function test_claim_success_early_minting() public {
        smart.prepapreClaim();
        vm.prank(alice);
        smart.claim();
        assertEq(smart.DEFAULT_AMOUNT() / 2, smart.balanceOf(alice), "Alice was not minted correctly");
    }

    function test_claim_OnlyOneClaimPerWallet() public {
        smart.prepapreClaim();
        vm.startPrank(alice);
        smart.claim();
        vm.expectRevert(Smart.OnlyOneClaimPerWallet.selector);
        smart.claim();
    }

    function test_claim_success_below_mintcap() public {
        smart = new Smart(_targetInterval, 998_000_000e18, _mintCap, liquidityProvider, lpAmount);
        vm.warp(block.timestamp + smart.TARGET_INTERVAL());
        smart.prepapreClaim();
        vm.startPrank(alice);
        smart.claim();
        vm.warp(block.timestamp + smart.TARGET_INTERVAL());
        smart.prepapreClaim();
        vm.startPrank(bob);
        smart.claim();

        assertEq(1_000_000e18, smart.balanceOf(bob), "Bob was not minted correctly");
    }

    function test_claim_MintCapExceeded() public {
        smart = new Smart(_targetInterval, 998_000_000e18, _mintCap, liquidityProvider, lpAmount);
        vm.warp(block.timestamp + smart.TARGET_INTERVAL());
        smart.prepapreClaim();
        vm.startPrank(alice);
        smart.claim();
        vm.warp(block.timestamp + smart.TARGET_INTERVAL());
        smart.prepapreClaim();
        vm.startPrank(bob);
        smart.claim();

        vm.warp(block.timestamp + smart.TARGET_INTERVAL());
        smart.prepapreClaim();
        vm.startPrank(charlie);
        vm.expectRevert(Smart.MintCapExceeded.selector);
        smart.claim();
    }
}
