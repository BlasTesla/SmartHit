// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {TERC20} from "../lib/t-erc20/src/TERC20.sol";

contract Smart is TERC20 {
    uint256 lastClaim;
    uint256 volatilityAccumulator;

    uint256 public immutable DEFAULT_AMOUNT;
    uint256 public immutable TARGET_INTERVAL;
    uint256 public immutable MINT_CAP;

    mapping(address => bool) hasClaimed;

    error MintCapExceeded();
    error WalletHasAlreadyClaimed();
    error RIPBozo();
    error OnlyOneClaimPerWallet();

    constructor(
        uint256 _targetInterval,
        uint256 _defaultAmount,
        uint256 _mintCap,
        address liquidityProvider,
        uint256 lpAmount
    ) {
        TARGET_INTERVAL = _targetInterval;
        DEFAULT_AMOUNT = _defaultAmount;
        MINT_CAP = _mintCap;
        lastClaim = block.timestamp;
        volatilityAccumulator = _targetInterval;
        _mint(liquidityProvider, lpAmount);
    }

    function claim() external {
        assembly {
            if iszero(tload(0)) {
                mstore(0x00, 0x33adb0bc) // `RIPBozo()`.
                revert(0x1c, 0x04)
            }
        }
        if (hasClaimed[msg.sender]) {
            revert OnlyOneClaimPerWallet();
        }
        volatilityAccumulator = volatilityAccumulator + (block.timestamp - lastClaim) >> 1;
        uint256 amount = (DEFAULT_AMOUNT * volatilityAccumulator) / TARGET_INTERVAL;
        amount = (amount > DEFAULT_AMOUNT) ? DEFAULT_AMOUNT : amount;
        uint256 supply = totalSupply();

        // mintcap already hit
        if (supply == MINT_CAP) {
            revert MintCapExceeded();
        }
        // ensure we hit the mintcap
        else if (supply + amount > MINT_CAP) {
            amount = MINT_CAP - supply;
        }
        hasClaimed[msg.sender] = true;
        lastClaim = block.timestamp;
        _mint(msg.sender, amount);
    }

    function prepapreClaim() external {
        assembly {
            tstore(0, 1)
        }
    }

    function name() public view virtual override returns (string memory) {
        return "Smart Token";
    }

    function symbol() public view virtual override returns (string memory) {
        return "SMART";
    }

    function permit(address, address, uint256, uint256, uint8, bytes32, bytes32) public override {
        revert RIPBozo();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        uint256 size;
        if (from != address(0)) {
            assembly {
                size := extcodesize(from)
                if iszero(size) {
                    mstore(0x00, 0x33adb0bc) // `RIPBozo()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }
}
