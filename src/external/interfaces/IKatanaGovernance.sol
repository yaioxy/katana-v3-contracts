// SPDX-License-Identifier: MIT
pragma solidity >=0.5.17 <0.9.0;

interface IKatanaGovernance {
  struct Permission {
    // The timestamp until the whitelist is ended.
    // 0 means the whitelist is disabled.
    uint40 whitelistUntil;
    // The mapping of the allowed addresses in the whitelist stage.
    mapping(address => bool) allowed;
  }

  /// @dev Emitted when the factory address is updated.
  event FactoryUpdated(address indexed by, address factory);
  /// @dev Emitted when the permission of a token is updated.
  event PermissionUpdated(
    address indexed by, address indexed token, uint40 whitelistUntil, address[] allowed, bool[] statuses
  );

  /**
   * @dev Sets the permission of a token.
   *
   * - Requirements: Caller must be the owner.
   *
   * @param token The address of the token.
   * @param whitelistUntil The end of the whitelist duration in seconds.
   * @param alloweds The addresses to be allowed.
   * @param statuses The statuses of the addresses.
   */
  function setPermission(address token, uint40 whitelistUntil, address[] calldata alloweds, bool[] calldata statuses)
    external;

  /**
   * @dev Sets the factory address.
   *
   * - Requirements: Caller must be the owner.
   *
   * @param factory The address of the factory.
   */
  function setFactory(address factory) external;

  /**
   * @dev Creates a pair of tokens and sets the permission.
   *
   * - Requirements: Caller must be the owner.
   *
   * @param tokenA The address of the first token.
   * @param tokenB The address of the second token.
   * @param whitelistUntil The end of the whitelist duration in seconds.
   * @param alloweds The addresses to be allowed.
   * @param statuses The whitelist statuses of the addresses.
   * @return pair The address of the pair.
   */
  function createPairAndSetPermission(
    address tokenA,
    address tokenB,
    uint40 whitelistUntil,
    address[] calldata alloweds,
    bool[] calldata statuses
  ) external returns (address pair);

  /**
   * @notice Checks if an account is authorized to interact with a token.
   *
   * @param token The address of the token.
   * @param account The address of the account.
   * @return True if the account is authorized, otherwise false.
   */
  function isAuthorized(address token, address account) external view returns (bool);

  /**
   * @dev Get the factory address.
   */
  function getFactory() external view returns (address);

  /**
   * @notice Gets the whitelist duration of a token.
   *
   * @param token The address of the token.
   * @return The whitelist duration.
   */
  function getWhitelistUntil(address token) external view returns (uint40);

  /**
   * @notice Gets the whitelist information of many tokens.
   *
   * @return tokens The addresses of the tokens.
   * @return whitelistUntils The array of whitelist until timestamps.
   */
  function getManyTokensWhitelistInfo()
    external
    view
    returns (address[] memory tokens, uint40[] memory whitelistUntils);

  /**
   * @notice Gets all whitelisted tokens for given account.
   *
   * @param account The address of the account.
   * @return tokens The addresses of the tokens.
   * @return whitelistUntils The array of whitelist until timestamps.
   */
  function getWhitelistedTokensFor(address account)
    external
    view
    returns (address[] memory tokens, uint40[] memory whitelistUntils);

  /**
   * @notice Checks if an account is authorized to interact with a path tokens.
   *
   * @param tokens The path to swap on.
   * @param account The address of the account.
   * @return False if exists one token that the account is not authorized, otherwise true.
   */
  function isAuthorized(address[] calldata tokens, address account) external view returns (bool);
}
