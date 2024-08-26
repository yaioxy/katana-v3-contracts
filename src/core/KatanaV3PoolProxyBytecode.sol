// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import "./KatanaV3PoolProxy.sol";

/// @title The canonical storage location for the KatanaV3PoolProxy creation code.
/// @dev Always returns the creation code (in low-level calls) of the KatanaV3PoolProxy contract.
/// @dev The existence of this contract ensures the KatanaV3PoolProxy creation code is constant in later development.
contract KatanaV3PoolProxyBytecode {
  fallback() external {
    bytes memory bytecode = type(KatanaV3PoolProxy).creationCode;
    assembly {
      return(add(bytecode, 0x20), mload(bytecode))
    }
  }
}