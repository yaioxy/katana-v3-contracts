// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/UpgradeableBeacon.sol";

import "./interfaces/IKatanaV3FactoryImmutables.sol";

import "./KatanaV3Pool.sol";
import "./KatanaV3PoolProxy.sol";
import "./KatanaV3PoolProxyBytecode.sol";

contract KatanaV3FactoryProxy is TransparentUpgradeableProxy, IKatanaV3FactoryImmutables {
  /// @inheritdoc IKatanaV3FactoryImmutables
  bytes32 public constant override POOL_PROXY_INIT_CODE_HASH = keccak256(type(KatanaV3PoolProxy).creationCode);
  /// @inheritdoc IKatanaV3FactoryImmutables
  address public immutable override POOL_PROXY_BYTECODE_POINTER;
  /// @inheritdoc IKatanaV3FactoryImmutables
  address public immutable override BEACON;

  constructor(address _logic, address admin_, bytes memory _data) TransparentUpgradeableProxy(_logic, admin_, _data) {
    POOL_PROXY_BYTECODE_POINTER = address(new KatanaV3PoolProxyBytecode());

    address poolImplementation = address(new KatanaV3Pool());
    BEACON = address(new UpgradeableBeacon(poolImplementation));
  }

  function upgradeBeaconTo(address newImplementation) external ifAdmin {
    UpgradeableBeacon(BEACON).upgradeTo(newImplementation);
  }
}
