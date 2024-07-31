// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import { Script, console } from "forge-std/Script.sol";
import { KatanaV3Factory } from "@katana/v3-contracts/core/KatanaV3Factory.sol";
import { KatanaV3FactoryProxy } from "@katana/v3-contracts/core/KatanaV3FactoryProxy.sol";

abstract contract DeployKatanaV3Core is Script {
  address public owner;
  address public treasury;

  address public factory;

  function setUp() public virtual {
    require(owner != address(0));
    require(treasury != address(0));
    logParams();
  }

  function run() public virtual {
    vm.startBroadcast();

    address factoryImplementation = address(new KatanaV3Factory());
    factory = address(
      new KatanaV3FactoryProxy(
        factoryImplementation, owner, abi.encodeWithSelector(KatanaV3Factory.initialize.selector, owner, treasury)
      )
    );
    console.log("KatanaV3Factory deployed:", factory);

    vm.stopBroadcast();
  }

  function logParams() internal virtual {
    console.log("owner:", owner);
    console.log("treasury:", treasury);
  }
}
