// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IKatanaV3PoolOwnerActions {
  /// @notice Set the protocol fee as a ratio of the swap fees
  /// @param feeProtocolNumerator new protocol fee numerator
  /// @param feeProtocolDenominator new protocol fee denominator
  function setFeeProtocol(uint8 feeProtocolNumerator, uint8 feeProtocolDenominator) external;

  /// @notice Collect the protocol fee accrued to the pool
  /// @param recipient The address to which collected protocol fees should be sent
  /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
  /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
  /// @return amount0 The protocol fee collected in token0
  /// @return amount1 The protocol fee collected in token1
  function collectProtocol(address recipient, uint128 amount0Requested, uint128 amount1Requested)
    external
    returns (uint128 amount0, uint128 amount1);
}
