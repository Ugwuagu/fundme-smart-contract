// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {PriceConverter} from "../src/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address currentContractAddress;
    HelperConfig helperConfig;

    function setUp() public {
        deployFundMe = new DeployFundMe();
        (fundMe, currentContractAddress) = deployFundMe.run();
        helperConfig = new HelperConfig();
        //console.log("Emmanuel");
    }

    function testMinimumDollarAmout() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOnwer() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testVersion() public view {
        vm.assertEq(fundMe.getVersion(), 4);
    }

    function testEthPrice() public view {
        uint256 price = PriceConverter.getPrice(AggregatorV3Interface(currentContractAddress));
        assertEq(price, 410771e16);
    }

    //function testFundFunction() public view {}

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund{value: 1000}();
    }

    function testSepoliaAddressGottenFromHelperConfig() public view {
        vm.assertEq(helperConfig.getSepoliaAddress().priceFeed, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    //function testAnvilAddressGottenFromHelperConfig() public {}

    function testUpdatesFundedDataStructure() public {
        fundMe.fund{value: 0.1 ether}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));
        assertEq(amountFunded, 0.1 ether);
    }
}