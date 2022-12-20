pragma solidity >=0.8.6;

import {IERC20} from "solidity-standard-interfaces/IERC20.sol";

/// @title A library which provides helpers to handle safely handle transfers for ERC20 tokens
/// @custom:coauthor Ainmox (https://github.com/ainmox)
library SafeERC20 {
    /// @dev Transfers `amount` of `token` tokens to `recipient`
    /// @param token The token to transfer
    /// @param recipient The address of the recipient
    /// @param amount The amount of tokens to transfer
    function safeTransfer(IERC20 token, address recipient, uint256 amount) internal {}

    /// @dev Transfers `amount` of `token` tokens from `owner` to `recipient`
    /// @param token The token to transfer
    /// @param owner The address of the owner
    /// @param recipient The address of the recipient
    /// @param amount The amount of tokens to transfer
    function safeTransferFrom(IERC20 token, address owner, address recipient, uint256 amount) internal {}
}