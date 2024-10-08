// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import { HandlerBase, PSM3 } from "test/invariant/handlers/HandlerBase.sol";

import { StdCheats } from "forge-std/StdCheats.sol";

import { DSRAuthOracle } from "lib/xchain-dsr-oracle/src/DSRAuthOracle.sol";
import { IDSROracle }    from "lib/xchain-dsr-oracle/src/interfaces/IDSROracle.sol";

contract TimeBasedRateHandler is HandlerBase, StdCheats {

    uint256 public dsr;

    uint256 constant TWENTY_PCT_APY_DSR = 1.000000005781378656804591712e27;

    DSRAuthOracle public dsrOracle;

    uint256 public setPotDataCount;
    uint256 public warpCount;

    constructor(PSM3 psm_, DSRAuthOracle dsrOracle_) HandlerBase(psm_) {
        dsrOracle = dsrOracle_;
    }

    // This acts as a receiver on an L2.
    function setPotData(uint256 newDsr) external {
        // 1. Setup and bounds
        dsr = _bound(newDsr, 1e27, TWENTY_PCT_APY_DSR);

        // Update rho to be current, update chi based on current rate
        uint256 rho = block.timestamp;
        uint256 chi = dsrOracle.getConversionRate(rho);

        // 2. Cache starting state
        uint256 startingConversion = psm.convertToAssetValue(1e18);
        uint256 startingValue      = psm.totalAssets();

        // 3. Perform action against protocol
        dsrOracle.setPotData(IDSROracle.PotData({
            dsr: uint96(dsr),
            chi: uint120(chi),
            rho: uint40(rho)
        }));

        // 4. Perform action-specific assertions
        assertGe(
            psm.convertToAssetValue(1e18) + 1,
            startingConversion,
            "TimeBasedRateHandler/setPotData/conversion-rate-decrease"
        );

        assertGe(
            psm.totalAssets() + 1,
            startingValue,
            "TimeBasedRateHandler/setPotData/psm-total-value-decrease"
        );

        // 5. Update metrics tracking state
        setPotDataCount++;
    }

    function warp(uint256 skipTime) external {
        // 1. Setup and bounds
        uint256 warpTime = _bound(skipTime, 0, 10 days);

        // 2. Cache starting state
        uint256 startingConversion = psm.convertToAssetValue(1e18);
        uint256 startingValue      = psm.totalAssets();

        // 3. Perform action against protocol
        skip(warpTime);

        // 4. Perform action-specific assertions
        assertGe(
            psm.convertToAssetValue(1e18),
            startingConversion,
            "RateSetterHandler/warp/conversion-rate-decrease"
        );

        assertGe(
            psm.totalAssets(),
            startingValue,
            "RateSetterHandler/warp/psm-total-value-decrease"
        );

        // 5. Update metrics tracking state
        warpCount++;
    }

}
