// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    address constant V3_ADDRESS = address(0x694AA1769357215DE4FAC081bf1f309aDC325306);

    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(helperConfig.activeNetworkConfig());
        vm.stopBroadcast();

        return fundMe;
    }
}
