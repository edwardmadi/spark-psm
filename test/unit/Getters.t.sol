// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import { MockRateProvider, PSMTestBase } from "test/PSMTestBase.sol";

import { PSM3Harness } from "test/unit/harnesses/PSM3Harness.sol";

contract PSMHarnessTests is PSMTestBase {

    PSM3Harness psmHarness;

    function setUp() public override {
        super.setUp();
        psmHarness = new PSM3Harness(
            address(dai),
            address(usdc),
            address(sDai),
            address(rateProvider)
        );
    }

    function test_getAsset0Value() public view {
        assertEq(psmHarness.getAsset0Value(1), 1);
        assertEq(psmHarness.getAsset0Value(2), 2);
        assertEq(psmHarness.getAsset0Value(3), 3);

        assertEq(psmHarness.getAsset0Value(100e18), 100e18);
        assertEq(psmHarness.getAsset0Value(200e18), 200e18);
        assertEq(psmHarness.getAsset0Value(300e18), 300e18);

        assertEq(psmHarness.getAsset0Value(100_000_000_000e18), 100_000_000_000e18);
        assertEq(psmHarness.getAsset0Value(200_000_000_000e18), 200_000_000_000e18);
        assertEq(psmHarness.getAsset0Value(300_000_000_000e18), 300_000_000_000e18);
    }

    function testFuzz_getAsset0Value(uint256 amount) public view {
        amount = _bound(amount, 0, 1e45);

        assertEq(psmHarness.getAsset0Value(amount), amount);
    }

    function test_getAsset1Value() public view {
        assertEq(psmHarness.getAsset1Value(1), 1e12);
        assertEq(psmHarness.getAsset1Value(2), 2e12);
        assertEq(psmHarness.getAsset1Value(3), 3e12);

        assertEq(psmHarness.getAsset1Value(100e6), 100e18);
        assertEq(psmHarness.getAsset1Value(200e6), 200e18);
        assertEq(psmHarness.getAsset1Value(300e6), 300e18);

        assertEq(psmHarness.getAsset1Value(100_000_000_000e6), 100_000_000_000e18);
        assertEq(psmHarness.getAsset1Value(200_000_000_000e6), 200_000_000_000e18);
        assertEq(psmHarness.getAsset1Value(300_000_000_000e6), 300_000_000_000e18);
    }

    function testFuzz_getAsset1Value(uint256 amount) public view {
        amount = _bound(amount, 0, 1e45);

        assertEq(psmHarness.getAsset1Value(amount), amount * 1e12);
    }

    function test_getAsset2Value() public {
        assertEq(psmHarness.getAsset2Value(1, false), 1);
        assertEq(psmHarness.getAsset2Value(2, false), 2);
        assertEq(psmHarness.getAsset2Value(3, false), 3);
        assertEq(psmHarness.getAsset2Value(4, false), 5);

        // Rounding up
        assertEq(psmHarness.getAsset2Value(1, true), 2);
        assertEq(psmHarness.getAsset2Value(2, true), 3);
        assertEq(psmHarness.getAsset2Value(3, true), 4);
        assertEq(psmHarness.getAsset2Value(4, true), 5);

        assertEq(psmHarness.getAsset2Value(1e18, false), 1.25e18);
        assertEq(psmHarness.getAsset2Value(2e18, false), 2.5e18);
        assertEq(psmHarness.getAsset2Value(3e18, false), 3.75e18);
        assertEq(psmHarness.getAsset2Value(4e18, false), 5e18);

        // No rounding but shows why rounding occurred at lower values
        assertEq(psmHarness.getAsset2Value(1e18, true), 1.25e18);
        assertEq(psmHarness.getAsset2Value(2e18, true), 2.5e18);
        assertEq(psmHarness.getAsset2Value(3e18, true), 3.75e18);
        assertEq(psmHarness.getAsset2Value(4e18, true), 5e18);

        mockRateProvider.__setConversionRate(1.6e27);

        assertEq(psmHarness.getAsset2Value(1, false), 1);
        assertEq(psmHarness.getAsset2Value(2, false), 3);
        assertEq(psmHarness.getAsset2Value(3, false), 4);
        assertEq(psmHarness.getAsset2Value(4, false), 6);

        // Rounding up
        assertEq(psmHarness.getAsset2Value(1, true), 2);
        assertEq(psmHarness.getAsset2Value(2, true), 4);
        assertEq(psmHarness.getAsset2Value(3, true), 5);
        assertEq(psmHarness.getAsset2Value(4, true), 7);

        assertEq(psmHarness.getAsset2Value(1e18, false), 1.6e18);
        assertEq(psmHarness.getAsset2Value(2e18, false), 3.2e18);
        assertEq(psmHarness.getAsset2Value(3e18, false), 4.8e18);
        assertEq(psmHarness.getAsset2Value(4e18, false), 6.4e18);

        // No rounding but shows why rounding occurred at lower values
        assertEq(psmHarness.getAsset2Value(1e18, true), 1.6e18);
        assertEq(psmHarness.getAsset2Value(2e18, true), 3.2e18);
        assertEq(psmHarness.getAsset2Value(3e18, true), 4.8e18);
        assertEq(psmHarness.getAsset2Value(4e18, true), 6.4e18);

        mockRateProvider.__setConversionRate(0.8e27);

        assertEq(psmHarness.getAsset2Value(1, false), 0);
        assertEq(psmHarness.getAsset2Value(2, false), 1);
        assertEq(psmHarness.getAsset2Value(3, false), 2);
        assertEq(psmHarness.getAsset2Value(4, false), 3);

        // Rounding up
        assertEq(psmHarness.getAsset2Value(1, true), 1);
        assertEq(psmHarness.getAsset2Value(2, true), 2);
        assertEq(psmHarness.getAsset2Value(3, true), 3);
        assertEq(psmHarness.getAsset2Value(4, true), 4);

        assertEq(psmHarness.getAsset2Value(1e18, false), 0.8e18);
        assertEq(psmHarness.getAsset2Value(2e18, false), 1.6e18);
        assertEq(psmHarness.getAsset2Value(3e18, false), 2.4e18);
        assertEq(psmHarness.getAsset2Value(4e18, false), 3.2e18);

        // No rounding but shows why rounding occurred at lower values
        assertEq(psmHarness.getAsset2Value(1e18, true), 0.8e18);
        assertEq(psmHarness.getAsset2Value(2e18, true), 1.6e18);
        assertEq(psmHarness.getAsset2Value(3e18, true), 2.4e18);
        assertEq(psmHarness.getAsset2Value(4e18, true), 3.2e18);
    }

    function testFuzz_getAsset2Value_roundDown(uint256 conversionRate, uint256 amount) public {
        conversionRate = _bound(conversionRate, 0, 1000e27);
        amount         = _bound(amount,         0, SDAI_TOKEN_MAX);

        mockRateProvider.__setConversionRate(conversionRate);

        assertEq(psmHarness.getAsset2Value(amount, false), amount * conversionRate / 1e27);
    }

    function test_getAssetValue() public view {
        assertEq(psmHarness.getAssetValue(address(dai), 1, false), psmHarness.getAsset0Value(1));
        assertEq(psmHarness.getAssetValue(address(dai), 2, false), psmHarness.getAsset0Value(2));
        assertEq(psmHarness.getAssetValue(address(dai), 3, false), psmHarness.getAsset0Value(3));

        assertEq(psmHarness.getAssetValue(address(dai), 1, true), psmHarness.getAsset0Value(1));
        assertEq(psmHarness.getAssetValue(address(dai), 2, true), psmHarness.getAsset0Value(2));
        assertEq(psmHarness.getAssetValue(address(dai), 3, true), psmHarness.getAsset0Value(3));

        assertEq(psmHarness.getAssetValue(address(dai), 1e18, false), psmHarness.getAsset0Value(1e18));
        assertEq(psmHarness.getAssetValue(address(dai), 2e18, false), psmHarness.getAsset0Value(2e18));
        assertEq(psmHarness.getAssetValue(address(dai), 3e18, false), psmHarness.getAsset0Value(3e18));

        assertEq(psmHarness.getAssetValue(address(dai), 1e18, true), psmHarness.getAsset0Value(1e18));
        assertEq(psmHarness.getAssetValue(address(dai), 2e18, true), psmHarness.getAsset0Value(2e18));
        assertEq(psmHarness.getAssetValue(address(dai), 3e18, true), psmHarness.getAsset0Value(3e18));

        assertEq(psmHarness.getAssetValue(address(usdc), 1, false), psmHarness.getAsset1Value(1));
        assertEq(psmHarness.getAssetValue(address(usdc), 2, false), psmHarness.getAsset1Value(2));
        assertEq(psmHarness.getAssetValue(address(usdc), 3, false), psmHarness.getAsset1Value(3));

        assertEq(psmHarness.getAssetValue(address(usdc), 1, true), psmHarness.getAsset1Value(1));
        assertEq(psmHarness.getAssetValue(address(usdc), 2, true), psmHarness.getAsset1Value(2));
        assertEq(psmHarness.getAssetValue(address(usdc), 3, true), psmHarness.getAsset1Value(3));

        assertEq(psmHarness.getAssetValue(address(usdc), 1e6, false), psmHarness.getAsset1Value(1e6));
        assertEq(psmHarness.getAssetValue(address(usdc), 2e6, false), psmHarness.getAsset1Value(2e6));
        assertEq(psmHarness.getAssetValue(address(usdc), 3e6, false), psmHarness.getAsset1Value(3e6));

        assertEq(psmHarness.getAssetValue(address(usdc), 1e6, true), psmHarness.getAsset1Value(1e6));
        assertEq(psmHarness.getAssetValue(address(usdc), 2e6, true), psmHarness.getAsset1Value(2e6));
        assertEq(psmHarness.getAssetValue(address(usdc), 3e6, true), psmHarness.getAsset1Value(3e6));

        assertEq(psmHarness.getAssetValue(address(sDai), 1, false), psmHarness.getAsset2Value(1, false));
        assertEq(psmHarness.getAssetValue(address(sDai), 2, false), psmHarness.getAsset2Value(2, false));
        assertEq(psmHarness.getAssetValue(address(sDai), 3, false), psmHarness.getAsset2Value(3, false));

        assertEq(psmHarness.getAssetValue(address(sDai), 1e18, false), psmHarness.getAsset2Value(1e18, false));
        assertEq(psmHarness.getAssetValue(address(sDai), 2e18, false), psmHarness.getAsset2Value(2e18, false));
        assertEq(psmHarness.getAssetValue(address(sDai), 3e18, false), psmHarness.getAsset2Value(3e18, false));

        assertEq(psmHarness.getAssetValue(address(sDai), 1, true), psmHarness.getAsset2Value(1, true));
        assertEq(psmHarness.getAssetValue(address(sDai), 2, true), psmHarness.getAsset2Value(2, true));
        assertEq(psmHarness.getAssetValue(address(sDai), 3, true), psmHarness.getAsset2Value(3, true));

        assertEq(psmHarness.getAssetValue(address(sDai), 1e18, true), psmHarness.getAsset2Value(1e18, true));
        assertEq(psmHarness.getAssetValue(address(sDai), 2e18, true), psmHarness.getAsset2Value(2e18, true));
        assertEq(psmHarness.getAssetValue(address(sDai), 3e18, true), psmHarness.getAsset2Value(3e18, true));
    }

    function testFuzz_getAssetValue(uint256 amount) public view {
        amount = _bound(amount, 0, SDAI_TOKEN_MAX);

        // `asset0` and `asset1` return the same values whether `roundUp` is true or false
        assertEq(psmHarness.getAssetValue(address(dai),  amount, false), psmHarness.getAsset0Value(amount));
        assertEq(psmHarness.getAssetValue(address(dai),  amount, false), psmHarness.getAsset0Value(amount));
        assertEq(psmHarness.getAssetValue(address(usdc), amount, true),  psmHarness.getAsset1Value(amount));
        assertEq(psmHarness.getAssetValue(address(usdc), amount, true),  psmHarness.getAsset1Value(amount));

        // `asset2` returns different values depending on the value of `roundUp`, but always same as underlying function
        assertEq(psmHarness.getAssetValue(address(sDai), amount, false), psmHarness.getAsset2Value(amount, false));
        assertEq(psmHarness.getAssetValue(address(sDai), amount, true),  psmHarness.getAsset2Value(amount, true));
    }

    function test_getAssetValue_zeroAddress() public {
        vm.expectRevert("PSM3/invalid-asset");
        psmHarness.getAssetValue(address(0), 1, false);
    }

}

contract GetPsmTotalValueTests is PSMTestBase {

    function test_totalAssets_balanceChanges() public {
        dai.mint(address(psm), 1e18);

        assertEq(psm.totalAssets(), 1e18);

        usdc.mint(address(psm), 1e6);

        assertEq(psm.totalAssets(), 2e18);

        sDai.mint(address(psm), 1e18);

        assertEq(psm.totalAssets(), 3.25e18);

        dai.burn(address(psm), 1e18);

        assertEq(psm.totalAssets(), 2.25e18);

        usdc.burn(address(psm), 1e6);

        assertEq(psm.totalAssets(), 1.25e18);

        sDai.burn(address(psm), 1e18);

        assertEq(psm.totalAssets(), 0);
    }

    function test_totalAssets_conversionRateChanges() public {
        assertEq(psm.totalAssets(), 0);

        dai.mint(address(psm),  1e18);
        usdc.mint(address(psm), 1e6);
        sDai.mint(address(psm), 1e18);

        assertEq(psm.totalAssets(), 3.25e18);

        mockRateProvider.__setConversionRate(1.5e27);

        assertEq(psm.totalAssets(), 3.5e18);

        mockRateProvider.__setConversionRate(0.8e27);

        assertEq(psm.totalAssets(), 2.8e18);
    }

    function test_totalAssets_bothChange() public {
        assertEq(psm.totalAssets(), 0);

        dai.mint(address(psm),  1e18);
        usdc.mint(address(psm), 1e6);
        sDai.mint(address(psm), 1e18);

        assertEq(psm.totalAssets(), 3.25e18);

        mockRateProvider.__setConversionRate(1.5e27);

        assertEq(psm.totalAssets(), 3.5e18);

        sDai.mint(address(psm), 1e18);

        assertEq(psm.totalAssets(), 5e18);
    }

    function testFuzz_totalAssets(
        uint256 daiAmount,
        uint256 usdcAmount,
        uint256 sDaiAmount,
        uint256 conversionRate
    )
        public
    {
        daiAmount      = _bound(daiAmount,      0,         DAI_TOKEN_MAX);
        usdcAmount     = _bound(usdcAmount,     0,         USDC_TOKEN_MAX);
        sDaiAmount     = _bound(sDaiAmount,     0,         SDAI_TOKEN_MAX);
        conversionRate = _bound(conversionRate, 0.0001e27, 1000e27);

        dai.mint(address(psm),  daiAmount);
        usdc.mint(address(psm), usdcAmount);
        sDai.mint(address(psm), sDaiAmount);

        mockRateProvider.__setConversionRate(conversionRate);

        assertEq(
            psm.totalAssets(),
            daiAmount + (usdcAmount * 1e12) + (sDaiAmount * conversionRate / 1e27)
        );
    }

}
