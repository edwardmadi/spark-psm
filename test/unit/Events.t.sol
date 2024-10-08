// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import { MockERC20, PSMTestBase } from "test/PSMTestBase.sol";

contract PSMEventTests is PSMTestBase {

    event Swap(
        address indexed assetIn,
        address indexed assetOut,
        address sender,
        address indexed receiver,
        uint256 amountIn,
        uint256 amountOut,
        uint256 referralCode
    );

    event Deposit(
        address indexed asset,
        address indexed user,
        address indexed receiver,
        uint256 assetsDeposited,
        uint256 sharesMinted
    );

    event Withdraw(
        address indexed asset,
        address indexed user,
        address indexed receiver,
        uint256 assetsWithdrawn,
        uint256 sharesBurned
    );

    address sender   = makeAddr("sender");
    address receiver = makeAddr("receiver");

    function test_deposit_events() public {
        vm.startPrank(sender);

        dai.mint(sender, 100e18);
        dai.approve(address(psm), 100e18);

        vm.expectEmit(address(psm));
        emit Deposit(address(dai), sender, receiver, 100e18, 100e18);
        psm.deposit(address(dai), receiver, 100e18);

        usdc.mint(sender, 100e6);
        usdc.approve(address(psm), 100e6);

        vm.expectEmit(address(psm));
        emit Deposit(address(usdc), sender, receiver, 100e6, 100e18);
        psm.deposit(address(usdc), receiver, 100e6);

        sDai.mint(sender, 100e18);
        sDai.approve(address(psm), 100e18);

        vm.expectEmit(address(psm));
        emit Deposit(address(sDai), sender, receiver, 100e18, 125e18);
        psm.deposit(address(sDai), receiver, 100e18);
    }

    function test_withdraw_events() public {
        _deposit(address(dai),  sender, 100e18);
        _deposit(address(usdc), sender, 100e6);
        _deposit(address(sDai), sender, 100e18);

        vm.startPrank(sender);

        vm.expectEmit(address(psm));
        emit Withdraw(address(dai), sender, receiver, 100e18, 100e18);
        psm.withdraw(address(dai), receiver, 100e18);

        vm.expectEmit(address(psm));
        emit Withdraw(address(usdc), sender, receiver, 100e6, 100e18);
        psm.withdraw(address(usdc), receiver, 100e6);

        vm.expectEmit(address(psm));
        emit Withdraw(address(sDai), sender, receiver, 100e18, 125e18);
        psm.withdraw(address(sDai), receiver, 100e18);
    }

    function test_swap_events() public {
        dai.mint(address(psm),  1000e18);
        usdc.mint(address(psm), 1000e6);
        sDai.mint(address(psm), 1000e18);

        vm.startPrank(sender);

        _swapEventTest(address(dai), address(usdc), 100e18, 100e6, 1);
        _swapEventTest(address(dai), address(sDai), 100e18, 80e18, 2);

        _swapEventTest(address(usdc), address(dai),  100e6, 100e18, 3);
        _swapEventTest(address(usdc), address(sDai), 100e6, 80e18,  4);

        _swapEventTest(address(sDai), address(dai),  100e18, 125e18, 5);
        _swapEventTest(address(sDai), address(usdc), 100e18, 125e6,  6);
    }

    function _swapEventTest(
        address assetIn,
        address assetOut,
        uint256 amountIn,
        uint256 expectedAmountOut,
        uint16  referralCode
    ) internal {
        MockERC20(assetIn).mint(sender, amountIn);
        MockERC20(assetIn).approve(address(psm), amountIn);

        vm.expectEmit(address(psm));
        emit Swap(assetIn, assetOut, sender, receiver, amountIn, expectedAmountOut, referralCode);
        psm.swapExactIn(assetIn, assetOut, amountIn, 0, receiver, referralCode);
    }

}
