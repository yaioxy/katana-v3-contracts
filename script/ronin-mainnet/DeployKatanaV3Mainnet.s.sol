// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { DeployKatanaV3Periphery } from "../DeployKatanaV3Periphery.s.sol";
import { MixedRouteQuoterV1 } from "@katana/v3-contracts/periphery/lens/MixedRouteQuoterV1.sol";

contract DeployKatanaV3Mainnet is DeployKatanaV3Periphery {
  address mixedRouteQuoterV1;

  function setUp() public override {
    owner = 0x2C1726346d83cBF848bD3C2B208ec70d32a9E44a; // Katana Governance Proxy
    treasury = 0x22cEfc91E9b7c0f3890eBf9527EA89053490694e; // Ronin Treasury
    wron = 0xe514d9DEB7966c8BE0ca922de8a064264eA6bcd4; // WRON
    factoryV2 = 0xB255D6A720BB7c39fee173cE22113397119cB930; // Katana V2 Factory

    vm.rememberKey(vm.envUint("MAINNET_PK"));

    super.setUp();
  }

  function run() public override {
    super.run();

    vm.broadcast();
    mixedRouteQuoterV1 = address(new MixedRouteQuoterV1(factory, factoryV2, wron));
    console.log("MixedRouteQuoterV1 deployed:", mixedRouteQuoterV1);
  }
}
