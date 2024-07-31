// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import "../interfaces/IKatanaGovernance.sol";
import "../../core/interfaces/IKatanaV3Factory.sol";

library AuthorizationLib {
  function checkRouter(address factory) internal view {
    IKatanaGovernance governance = IKatanaGovernance(IKatanaV3Factory(factory).owner());
    require(msg.sender == governance.getRouter());
  }

  function checkPositionManager(address factory) internal view {
    IKatanaGovernance governance = IKatanaGovernance(IKatanaV3Factory(factory).owner());
    require(msg.sender == governance.getPositionManager());
  }

  function checkPair(address factory, address token0, address token1) internal view {
    address[] memory tokens = new address[](2);
    tokens[0] = token0;
    tokens[1] = token1;
    IKatanaGovernance governance = IKatanaGovernance(IKatanaV3Factory(factory).owner());
    require(governance.isAuthorized(tokens, msg.sender), "UA");
  }
}
