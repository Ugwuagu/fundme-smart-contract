// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockAggregatorV3Interface.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaAddress();
        } else {
            activeNetworkConfig = getAnvilAddress();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaAddress() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaAddress = NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return sepoliaAddress;
    }

    function getAnvilAddress() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(8, 4107);
        vm.stopBroadcast();

        NetworkConfig memory anvilAddress = NetworkConfig(address(mockV3Aggregator));
        return anvilAddress;
    }
}
