// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import { Script, console } from "forge-std/Script.sol";
import { KatanaV3Factory } from "@katana/v3-contracts/core/KatanaV3Factory.sol";
import { KatanaV3FactoryProxy } from "@katana/v3-contracts/core/KatanaV3FactoryProxy.sol";

abstract contract DeployKatanaV3Core is Script {
  address public proxyAdmin;
  address public governance;
  address public treasury;

  address public factory;

  function setUp() public virtual {
    require(proxyAdmin != address(0));
    require(governance != address(0));
    require(treasury != address(0));
    logParams();
  }

  function run() public virtual {
    vm.startBroadcast();

    address factoryImplementation = address(new KatanaV3Factory());
    factory = address(
      new KatanaV3FactoryProxy(
        factoryImplementation, proxyAdmin, abi.encodeWithSelector(KatanaV3Factory.initialize.selector, governance, treasury)
      )
    );
    console.log("KatanaV3Factory deployed:", factory);

    vm.stopBroadcast();
  }

  function logParams() internal virtual {
    console.log("governance:", governance);
    console.log("treasury:", treasury);
  }
}
