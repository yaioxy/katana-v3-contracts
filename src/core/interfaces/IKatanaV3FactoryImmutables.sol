// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title The interface for the Katana V3 Factory immutables
interface IKatanaV3FactoryImmutables {
  /// @dev The init code hash for the pool proxy
  function POOL_PROXY_INIT_CODE_HASH() external view returns (bytes32);

  /// @dev The address that stores the pool proxy bytecode
  function POOL_PROXY_BYTECODE_POINTER() external view returns (address);

  /// @dev The address of the beacon that returns the current pool implementation
  function BEACON() external view returns (address);
}
