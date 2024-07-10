// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import { Test, console } from "forge-std/Test.sol";

import { KatanaV3Factory } from "@katana/v3-contracts/core/KatanaV3Factory.sol";
import { IKatanaV3Pool } from "@katana/v3-contracts/core/interfaces/IKatanaV3Pool.sol";

contract KatanaV3FactoryTest is Test {
  address owner = makeAddr("factoryOwner");
  address treasury = makeAddr("treasury");
  KatanaV3Factory factory;

  function setUp() public {
    factory = new KatanaV3Factory(owner, treasury);
  }

  function test_createPool() public {
    address token0 = makeAddr("token0");
    address token1 = makeAddr("token1");
    uint24 fee = 3000; // 0.3%
    int24 tickSpacing = 60;

    address pool = factory.createPool(token0, token1, fee);

    assertEq(IKatanaV3Pool(pool).factory(), address(factory));
    assertEq(IKatanaV3Pool(pool).token0(), token0);
    assertEq(IKatanaV3Pool(pool).token1(), token1);
    assertEq(uint256(IKatanaV3Pool(pool).fee()), uint256(fee));
    assertEq(uint256(IKatanaV3Pool(pool).tickSpacing()), uint256(tickSpacing));
  }
}
