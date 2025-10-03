// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {PriceConverter} from "../src/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {MockV3Aggregator} from "../test/mocks/MockAggregatorV3Interface.sol";

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

    function testGetAnvilAddressIsMockAggregator() public {
        HelperConfig.NetworkConfig memory config = helperConfig.getAnvilAddress();

        // Check that the address is not the Sepolia price feed
        assertTrue(config.priceFeed != helperConfig.getPriceFeed());

        // Check that the address is a contract (code size > 0)
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(mload(add(config, 0x20)))
        }
        console.log(config.priceFeed);
        //assertGt(codeSize, 0, "Returned address is not a contract");

        // Optionally, check that the contract is a MockV3Aggregator
        // by calling a known function
        int256 answer = MockV3Aggregator(config.priceFeed).latestAnswer();
        assertEq(answer, helperConfig.getPrice(), "Not a MockV3Aggregator contract");
    }

    function testUpdatesFundedDataStructure() public {
        fundMe.fund{value: 0.1 ether}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));
        address funderAddress = fundMe.getFunders(0);
        assertEq(amountFunded, 0.1 ether);
        vm.assertEq(funderAddress, address(this));
    }

    function testOnlyOwnerCanWithdraw() public {
        fundMe.fund{value: 0.1 ether}();
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testOnwerCanWithdraw() public {
        fundMe.fund{value: 0.1 ether}();
        uint256 startingOwnerBalance = msg.sender.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.prank(msg.sender);
        fundMe.withdraw();
        uint256 endingOwnerBalance = msg.sender.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        vm.assertEq(endingFundMeBalance, 0);
        vm.assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testMultipleSenders() public {
        uint256 numberOfSenders = 10;
        for (uint160 i = 1; i <= numberOfSenders; i++) {
            hoax(address(i), 10 ether);
            fundMe.fund{value: 0.1 ether}();
        }

        uint256 startingBalanceOfFundMe = address(fundMe).balance;
        uint256 startingBalanceOfOwner = msg.sender.balance;

        vm.prank(msg.sender);
        fundMe.withdraw();

        uint256 endingBalanceOfFundMe = address(fundMe).balance;
        uint256 endingBalanceOfOwner = msg.sender.balance;

        vm.assertEq(endingBalanceOfFundMe, 0);
        vm.assertEq(startingBalanceOfFundMe + startingBalanceOfOwner, endingBalanceOfOwner);
    }
}
