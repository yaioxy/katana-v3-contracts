// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import { Script, console } from "forge-std/Script.sol";
import { KatanaV3Factory } from "@katana/v3-contracts/core/KatanaV3Factory.sol";
import { KatanaV3Pool } from "@katana/v3-contracts/core/KatanaV3Pool.sol";
import { KatanaV3PoolBeacon } from "@katana/v3-contracts/core/KatanaV3PoolBeacon.sol";
import { TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";

abstract contract DeployKatanaV3Core is Script {
  address public sender;
  address public proxyAdmin;
  address public governance;
  address public treasury;

  address poolImplementation;
  address public beacon;
  address public factory;

  function setUp() public virtual {
    require(proxyAdmin != address(0));
    require(governance != address(0));
    require(treasury != address(0));
    logParams();
  }

  function run() public virtual {
    vm.startBroadcast();

    address predictedFactory = vm.computeCreateAddress(sender, vm.getNonce(sender) + 3);
    vm.label(predictedFactory, "PredictedFactory");

    poolImplementation = address(new KatanaV3Pool(predictedFactory, governance));
    beacon = address(new KatanaV3PoolBeacon(poolImplementation));

    address factoryImplementation = address(new KatanaV3Factory(beacon));
    factory = address(
      new TransparentUpgradeableProxy(
        factoryImplementation,
        proxyAdmin,
        abi.encodeWithSelector(KatanaV3Factory.initialize.selector, governance, treasury)
      )
    );
    require(factory == predictedFactory, "Factory address mismatch");

    console.log("KatanaV3Factory deployed:", factory);

    vm.stopBroadcast();
  }

  function logParams() internal virtual {
    console.log("governance:", governance);
    console.log("treasury:", treasury);
  }
}
