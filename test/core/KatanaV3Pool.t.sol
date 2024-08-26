// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import { Test, console } from "forge-std/Test.sol";

import { ERC20Mock } from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

import { TickMath } from "@katana/v3-contracts/core/libraries/TickMath.sol";

import { KatanaV3Factory } from "@katana/v3-contracts/core/KatanaV3Factory.sol";
import { KatanaV3Pool } from "@katana/v3-contracts/core/KatanaV3Pool.sol";
import { IKatanaV3Pool } from "@katana/v3-contracts/core/interfaces/IKatanaV3Pool.sol";

contract KatanaV3PoolTest is Test {
  address owner = makeAddr("factoryOwner");
  address treasury = makeAddr("treasury");

  KatanaV3Factory factory;
  uint24[] fees = [100, 3000, 10000];
  int24[] tickSpacings = [2, 60, 200];
  KatanaV3Pool[] pools;

  // Deploy token1 first to make token0 < token1
  address token1 = address(new ERC20Mock("Token1", "TK1", address(this), 10 ** 9 * 10 ** 9));
  address token0 = address(new ERC20Mock("Token0", "TK0", address(this), 10 ** 9 * 10 ** 9));

  function setUp() public {
    vm.label(token0, "token0");
    vm.label(token1, "token1");

    factory = new KatanaV3Factory(owner, treasury);

    pools.push(KatanaV3Pool(factory.createPool(token0, token1, 100)));
    pools.push(KatanaV3Pool(factory.createPool(token0, token1, 3000)));
    pools.push(KatanaV3Pool(factory.createPool(token0, token1, 10000)));

    vm.label(address(pools[0]), "pool[0.01%]");
    vm.label(address(pools[1]), "pool[0.3%]");
    vm.label(address(pools[2]), "pool[1%]");

    for (uint256 i = 0; i < pools.length; ++i) {
      KatanaV3Pool pool = pools[i];
      int24 tickSpacing = tickSpacings[i];
      // price: token0 = 10 token1
      pool.initialize(250541448375047931186413801569); // sqrt(10) * 2**96
      pool.mint(
        address(this),
        (23027 - 10000) / tickSpacing * tickSpacing,
        (23027 + 10000) / tickSpacing * tickSpacing,
        100_000_000,
        ""
      );
    }
  }

  function katanaV3MintCallback(uint256 amount0Owed, uint256 amount1Owed, bytes calldata) external {
    ERC20Mock(token0).transfer(msg.sender, amount0Owed);
    ERC20Mock(token1).transfer(msg.sender, amount1Owed);
  }

  function katanaV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external {
    if (amount0Delta > 0) ERC20Mock(token0).transfer(msg.sender, uint256(amount0Delta));
    if (amount1Delta > 0) ERC20Mock(token1).transfer(msg.sender, uint256(amount1Delta));
  }

  function test_swap() public {
    for (uint256 i = 0; i < 3; ++i) {
      KatanaV3Pool pool = pools[i];
      pool.swap(address(this), true, 10_000_000, TickMath.MIN_SQRT_RATIO + 1, "");
      (uint128 protocolFee0, uint128 protocolFee1) = pool.protocolFees();
      assertEq(uint256(protocolFee0), 0);
      assertEq(uint256(protocolFee1), 0);
      console.log(ERC20Mock(token0).balanceOf(treasury), ERC20Mock(token1).balanceOf(treasury));
    }
  }
}
