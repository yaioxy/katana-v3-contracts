// // SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import "./interfaces/IKatanaGovernance.sol";

contract KatanaGovernanceMock is IKatanaGovernance {
  address private _router;
  address private _positionManager;
  bool private immutable _defaultPermission;
  mapping(address => mapping(address => uint256)) private _permission;

  constructor(address router, address postionManager, bool defaultPermission) {
    _router = router;
    _positionManager = postionManager;
    _defaultPermission = defaultPermission;
  }

  function allow(address token, address account) external {
    _permission[token][account] = 1;
  }

  function disallow(address token, address account) external {
    _permission[token][account] = 2;
  }

  function setRouter(address router) external override {
    _router = router;
  }

  function setPositionManager(address postionManager) external {
    _positionManager = postionManager;
  }

  function getRouter() external view override returns (address) {
    return _router;
  }

  function getPositionManager() external view override returns (address) {
    return _positionManager;
  }

  function isAuthorized(address[] memory tokens, address account) external view override returns (bool) {
    for (uint256 i = 0; i < tokens.length; ++i) {
      if (!isAuthorized(tokens[i], account)) {
        return false;
      }
    }
    return true;
  }

  function isAuthorized(address token, address account) public view override returns (bool) {
    return _permission[token][account] == 1 || (_defaultPermission && _permission[token][account] == 0);
  }

  function setFactory(address) external pure override {
    revert("not implemented");
  }

  function setPermission(address, uint40, address[] memory, bool[] memory) external pure override {
    revert("not implemented");
  }

  function createPairAndSetPermission(address, address, uint40, address[] memory, bool[] memory)
    external
    pure
    override
    returns (address)
  {
    revert("not implemented");
  }

  function getFactory() external pure override returns (address) {
    revert("not implemented");
  }

  function getManyTokensWhitelistInfo() external pure override returns (address[] memory, uint40[] memory) {
    revert("not implemented");
  }

  function getWhitelistUntil(address) external pure override returns (uint40) {
    revert("not implemented");
  }

  function getWhitelistedTokensFor(address) external pure override returns (address[] memory, uint40[] memory) {
    revert("not implemented");
  }
}
