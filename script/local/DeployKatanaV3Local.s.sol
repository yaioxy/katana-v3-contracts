// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { DeployKatanaV3Periphery } from "../DeployKatanaV3Periphery.s.sol";
import { MixedRouteQuoterV1 } from "@katana/v3-contracts/periphery/lens/MixedRouteQuoterV1.sol";
import { KatanaGovernanceMock } from "@katana/v3-contracts/external/KatanaGovernanceMock.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DeployKatanaV3Local is DeployKatanaV3Periphery {
  address mixedRouteQuoterV1;

  function setUp() public override {
    owner = address(new KatanaGovernanceMock(address(0), address(0), true));
    treasury = makeAddr("RoninTreasury");
    wron = address(new ERC20Mock("Wrapped Ronin", "WRON", address(this), 10 ** 9 * 10 ** 9));
    factoryV2 = makeAddr("KatanaV2Factory");

    super.setUp();
  }

  function run() public override {
    super.run();

    vm.broadcast();
    mixedRouteQuoterV1 = address(new MixedRouteQuoterV1(factory, factoryV2, wron));
    console.log("MixedRouteQuoterV1 deployed:", mixedRouteQuoterV1);
  }
}
