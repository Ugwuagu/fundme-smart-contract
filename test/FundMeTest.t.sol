// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    function setUp() public {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
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
}
