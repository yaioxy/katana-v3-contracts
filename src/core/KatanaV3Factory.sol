// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import "@openzeppelin/contracts/proxy/UpgradeableBeacon.sol";

import "./interfaces/IKatanaV3Factory.sol";

import "./KatanaV3PoolDeployer.sol";

import "./KatanaV3Pool.sol";

/// @title Canonical Katana V3 factory
/// @notice Deploys Katana V3 pools and manages ownership and control over pool protocol fees
contract KatanaV3Factory is IKatanaV3Factory, KatanaV3PoolDeployer {
  /// @inheritdoc IKatanaV3Factory
  address public immutable override beacon;

  /// @inheritdoc IKatanaV3Factory
  address public override owner;
  /// @inheritdoc IKatanaV3Factory
  address public override treasury;
  /// @inheritdoc IKatanaV3Factory
  bool public override flashLoanEnabled;

  /// @inheritdoc IKatanaV3Factory
  mapping(uint24 => int24) public override feeAmountTickSpacing;
  /// @inheritdoc IKatanaV3Factory
  mapping(uint24 => uint16) public override feeAmountProtocol;
  /// @inheritdoc IKatanaV3Factory
  mapping(address => mapping(address => mapping(uint24 => address))) public override getPool;

  constructor(address _owner, address _treasury) {
    address poolImplementation = address(new KatanaV3Pool());
    beacon = address(new UpgradeableBeacon(poolImplementation));

    owner = _owner;
    emit OwnerChanged(address(0), _owner);

    treasury = _treasury;
    emit TreasuryChanged(address(0), _treasury);

    // swap fee 0.01% = 0.005% for LP + 0.005% for protocol
    // tick spacing of 1, equivalent to 0.01% between initializable ticks
    _enableFeeAmount(100, 1, 5 | (10 << 8));

    // swap fee 0.3% = 0.25% for LP + 0.05% for protocol
    // tick spacing of 60, approximately 0.60% between initializable ticks
    _enableFeeAmount(3000, 60, 5 | (30 << 8));

    // swap fee 1% = 0.85% for LP + 0.15% for protocol
    // tick spacing of 200, approximately 2.02% between initializable ticks
    _enableFeeAmount(10000, 200, 15 | (100 << 8));
  }

  function upgradeBeacon(address newImplementation) external {
    require(msg.sender == owner);
    UpgradeableBeacon(beacon).upgradeTo(newImplementation);
  }

  /// @inheritdoc IKatanaV3Factory
  function createPool(address tokenA, address tokenB, uint24 fee) external override returns (address pool) {
    require(tokenA != tokenB);
    (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0));
    int24 tickSpacing = feeAmountTickSpacing[fee];
    require(tickSpacing != 0);
    require(getPool[token0][token1][fee] == address(0));
    pool = deploy(address(this), token0, token1, fee, tickSpacing);
    getPool[token0][token1][fee] = pool;
    // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
    getPool[token1][token0][fee] = pool;
    emit PoolCreated(token0, token1, fee, tickSpacing, pool);
  }

  /// @inheritdoc IKatanaV3Factory
  function setOwner(address _owner) external override {
    require(msg.sender == owner);
    emit OwnerChanged(owner, _owner);
    owner = _owner;
  }

  function setTreasury(address _treasury) external override {
    require(msg.sender == owner);
    emit TreasuryChanged(treasury, _treasury);
    treasury = _treasury;
  }

  function toggleFlashLoanPermission() external override {
    require(msg.sender == owner);
    flashLoanEnabled = !flashLoanEnabled;
  }

  /// @inheritdoc IKatanaV3Factory
  function enableFeeAmount(uint24 fee, int24 tickSpacing, uint16 feeProtocol) public override {
    require(msg.sender == owner);
    require(fee < 1000000);
    // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that
    // TickBitmap#nextInitializedTickWithinOneWord overflows int24 container from a valid tick
    // 16384 ticks represents a >5x price change with ticks of 1 bips
    require(tickSpacing > 0 && tickSpacing < 16384);
    require((feeProtocol & 255) < (feeProtocol >> 8));
    require(feeAmountTickSpacing[fee] == 0);

    _enableFeeAmount(fee, tickSpacing, feeProtocol);
  }

  function _enableFeeAmount(uint24 fee, int24 tickSpacing, uint16 feeProtocol) private {
    feeAmountTickSpacing[fee] = tickSpacing;
    feeAmountProtocol[fee] = feeProtocol;
    emit FeeAmountEnabled(fee, tickSpacing, feeProtocol);
  }
}
