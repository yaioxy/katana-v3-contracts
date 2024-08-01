// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/UpgradeableBeacon.sol";

import "./interfaces/IKatanaV3FactoryImmutables.sol";
import "./interfaces/IKatanaV3Factory.sol";

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

  constructor(address _logic, address proxyAdmin, bytes memory _data) TransparentUpgradeableProxy(_logic, proxyAdmin, _data) {
    POOL_PROXY_BYTECODE_POINTER = address(new KatanaV3PoolProxyBytecode());

    address governance;
    assembly {
      // the first 32 bytes of _data is the length of the bytes array
      // the next 4 bytes is the function selector of the initialize function (initialize(address,address))
      // the next 32 bytes (start at offset 36) is the owner (governance) address
      governance := mload(add(_data, 36))
    }
    address poolImplementation = address(new KatanaV3Pool(address(this), governance));
    BEACON = address(new UpgradeableBeacon(poolImplementation));
  }

  /// @notice Upgrades the beacon to a new pool implementation
  function upgradeBeaconTo(address newImplementation) external ifAdmin {
    UpgradeableBeacon(BEACON).upgradeTo(newImplementation);
  }
}
