// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9.0;

import "../interfaces/IKatanaGovernance.sol";

library AuthorizationLib {
  function checkRouter(address governance) internal view {
    require(msg.sender == IKatanaGovernance(governance).getRouter(), "IR");
  }

  function checkPositionManager(address governance) internal view {
    require(msg.sender == IKatanaGovernance(governance).getPositionManager(), "IPM");
  }

  function checkPair(address governance, address token0, address token1) internal view {
    address[] memory tokens = new address[](2);
    tokens[0] = token0;
    tokens[1] = token1;
    require(IKatanaGovernance(governance).isAuthorized(tokens, msg.sender), "UA");
  }
}
