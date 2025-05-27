// SPDX-License-Identifier: MIT

pragma solidity 0.8.29;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DecentralizedStableCoin dsc;
    DSCEngine dscEngine;
    HelperConfig config;
    address ethUsdPriceFeed;
    address weth;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public {
        DeployDSC deployer = new DeployDSC();
        (dsc, dscEngine, config) = deployer.run();
        (ethUsdPriceFeed,, weth,,) = config.activeNetworkConfig();
        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
        // Set up initial conditions if needed
        // e.g., minting tokens, setting price feeds, etc.
    }

    ///////////////////////////
    //      Price Tests      //
    ///////////////////////////
    function testGetUsdValue() public view {
        uint256 ethAmount = 1e18; // 1 ETH
        uint256 expectedUsdValue = (ethAmount * 2000e8) / 1e8; // Assuming ETH price is $2000
        uint256 actualUsdValue = dscEngine.getCollateralValueInUsd(weth, ethAmount);
        assertEq(actualUsdValue, expectedUsdValue);
    }

    ///////////////////////////////////////
    //      depositCollateral Tests      //
    ///////////////////////////////////////
    function testRevertsIfCollateralIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dscEngine), AMOUNT_COLLATERAL);

        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        dscEngine.depositCollateral(weth, 0);
        vm.stopPrank();
    }

}