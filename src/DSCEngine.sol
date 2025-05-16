// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity 0.8.29;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
    * @title Decentralized Stable Coin Engine
    * @author Marko Mrsevic
    * 
    * This system is designed to be as minimal as possible
    * Colateral: Exogenous (ETH & BTC)
    * Minting: Algorithmic
    * Pegged: 1:1 to USD
    * 
    * @notice This contract implements the engine for a decentralized stable coin.
    */

contract DSCEngine is ReentrancyGuard {
    //////////////////////
    //      Errors      //
    //////////////////////
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesLengthMismatch();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();

    ///////////////////////////////
    //      State Variables      //
    ///////////////////////////////
    mapping(address tokenAddress => address priceFeedAddress) public s_priceFeeds;
    DecentralizedStableCoin public immutable i_dsc;
    mapping(address user => mapping(address tokenAddress => uint256 amount)) public s_collateralDeposited;

    //////////////////////
    //      Events      //
    //////////////////////
    event CollateralDeposited(address indexed user, address indexed tokenAddress, uint256 amount);

    /////////////////////////
    //      Modifiers      //
    /////////////////////////
    modifier moreThanZero(uint256 _amount) {
        if (_amount <= 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isTokenAllowed(address _token) {
        if (s_priceFeeds[_token] == address(0)) {
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    /////////////////////////
    //      Functions      //
    /////////////////////////
    constructor(address dscAddress, address[] memory tokenAddresses, address[] memory priceFeedAddresses) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesLengthMismatch();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    //////////////////////////////////
    //      External Functions      //
    //////////////////////////////////
    function depositCollateralAndMintDSC() external {}

    /*
     * @notice Deposit collateral into the system.
     * @param tokenCollateralAddress The address of the collateral asset.
     * @param amountCollateral The amount of collateral to deposit.
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isTokenAllowed(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(
            msg.sender,
            address(this),
            amountCollateral
        );
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    function mintDSC() external {}

    function burnDSC() external {}

    function liquidate() external {}

    /////////////////////////////////////
    //      View & Pure Functions      //
    /////////////////////////////////////
    function getHealthFactor() external view returns (uint256) {}
}
