// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockAggregatorV3Interface.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint8 constant DECIMAL = 8;
    int256 constant PRICE = 410771e6;
    address constant PRICE_FEED_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

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
        NetworkConfig memory sepoliaAddress = NetworkConfig(PRICE_FEED_ADDRESS);
        return sepoliaAddress;
    }

    function getAnvilAddress() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMAL, PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilAddress = NetworkConfig(address(mockV3Aggregator));
        return anvilAddress;
    }
}
