// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {Shit} from "src/Shit.sol";

contract ShitTest is Test {
    Shit public shit;
    address deployer;
    address alice;
    address bob;
    address charlie;

    uint256 _targetInterval = 15 minutes;
    uint256 _defaultAmount = 690_420e18;
    uint256 _mintCap = 690_420_000e18;
    address liquidityProvider = 0x46A9515Ebf8B6DD55e968f7459E0eb00AE8a65b1;
    uint256 lpAmount = 207_126_000e18;

    function setUp() public {
        deployer = vm.addr(1);
        vm.label(deployer, "deployer");
        vm.label(liquidityProvider, "liquidityProvider");
        alice = vm.addr(2);
        vm.label(alice, "alice");
        bob = vm.addr(3);
        vm.label(bob, "bob");
        charlie = vm.addr(4);
        vm.label(charlie, "charlie");

        shit = new Shit(_targetInterval, _defaultAmount, _mintCap, liquidityProvider, lpAmount);
    }

    function test_claim_RIPBozo() public {
        vm.prank(alice);
        vm.expectRevert(Shit.RIPBozo.selector);
        shit.claim();
    }

    function test_claim_success() public {
        vm.warp(block.timestamp + shit.TARGET_INTERVAL());
        shit.prepareClaim();
        vm.prank(alice);
        shit.claim();

        assertEq(shit.DEFAULT_AMOUNT(), shit.balanceOf(alice), "Alice was not minted correctly");
    }

    function test_claim_success_early_minting() public {
        shit.prepareClaim();
        vm.prank(alice);
        shit.claim();
        assertEq(shit.DEFAULT_AMOUNT(), shit.balanceOf(alice), "Alice was not minted correctly");
    }

    function test_claim_OnlyOneClaimPerWallet() public {
        shit.prepareClaim();
        vm.startPrank(alice);
        shit.claim();
        vm.expectRevert(Shit.OnlyOneClaimPerWallet.selector);
        shit.claim();
    }

    function test_claim_success_below_mintcap() public {
        uint256 testDefaultAmount = (_mintCap - lpAmount) / 2 - 1; // Slightly less than half to stay below mint cap
        shit = new Shit(_targetInterval, testDefaultAmount, _mintCap, liquidityProvider, lpAmount);

        vm.warp(block.timestamp + shit.TARGET_INTERVAL());
        shit.prepareClaim();
        vm.prank(alice);
        shit.claim();

        vm.warp(block.timestamp + shit.TARGET_INTERVAL());
        shit.prepareClaim();
        vm.prank(bob);
        shit.claim();

        uint256 expectedBobBalance = testDefaultAmount;
        assertEq(expectedBobBalance, shit.balanceOf(bob), "Bob was not minted correctly");
    }

    function test_claim_MintCapExceeded() public {
        uint256 testDefaultAmount = (_mintCap - lpAmount) / 2; // Each claim will mint half the remaining tokens
        shit = new Shit(_targetInterval, testDefaultAmount, _mintCap, liquidityProvider, lpAmount);

        vm.warp(block.timestamp + shit.TARGET_INTERVAL());
        shit.prepareClaim();
        vm.prank(alice);
        shit.claim();

        vm.warp(block.timestamp + shit.TARGET_INTERVAL());
        shit.prepareClaim();
        vm.prank(bob);
        shit.claim();

        vm.warp(block.timestamp + shit.TARGET_INTERVAL());
        shit.prepareClaim();
        vm.prank(charlie);
        vm.expectRevert(Shit.MintCapExceeded.selector);
        shit.claim();
    }
}
