// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IKatanaV3PoolImmutablesInitializable {
  /// @notice Initializes the pool with immutable-treated parameters
  /// @dev This function is only call once during deployment with the pool's immutable parameters
  /// @param factory The contract that deployed the pool, which must adhere to the IKatanaV3Factory interface
  /// @param token0 The first of the two tokens of the pool, sorted by address
  /// @param token1 The second of the two tokens of the pool, sorted by address
  /// @param fee The pool's fee in hundredths of a bip, i.e. 1e-6
  /// @param tickSpacing The pool tick spacing
  function initializeImmutables(address factory, address token0, address token1, uint24 fee, int24 tickSpacing)
    external;
}
