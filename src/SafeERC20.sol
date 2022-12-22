pragma solidity >=0.8.6;

import {IERC20} from "solidity-standard-interfaces/IERC20.sol";

uint256 constant ERC20_TRANSFER_SIGNATURE = 0xa9059cbb00000000000000000000000000000000000000000000000000000000;
uint256 constant ERC20_TRANSFER_SIGNATURE_POINTER = 0x00;
uint256 constant ERC20_TRANSFER_RECIPIENT_POINTER = 0x04;
uint256 constant ERC20_TRANSFER_AMOUNT_POINTER = 0x18;
uint256 constant ERC20_TRANSFER_MESSAGE_LENGTH = 0x38;

uint256 constant ERC20_TRANSFER_FROM_SIGNATURE = 0x23b872dd00000000000000000000000000000000000000000000000000000000;
uint256 constant ERC20_TRANSFER_FROM_SIGNATURE_POINTER = 0x00;
uint256 constant ERC20_TRANSFER_FROM_OWNER_POINTER = 0x04;
uint256 constant ERC20_TRANSFER_FROM_RECIPIENT_POINTER = 0x18;
uint256 constant ERC20_TRANSFER_FROM_AMOUNT_POINTER = 0x2C;
uint256 constant ERC20_TRANSFER_FROM_MESSAGE_LENGTH = 0x4C;

/// @title A library which provides helpers to handle safely handle transfers for ERC20 tokens
/// @custom:coauthor Ainmox (https://github.com/ainmox)
library SafeERC20 {
    /// @dev Transfers `amount` of `token` tokens to `recipient`
    /// @param token The token to transfer
    /// @param recipient The address of the recipient
    /// @param amount The amount of tokens to transfer
    function safeTransfer(IERC20 token, address recipient, uint256 amount) internal {
        bool success;

        assembly ("memory-safe") {
            // Check that the token is a contract. This is a strict check and this implementation can do without it
            // if the caller trusts that the token exists.
            if iszero(extcodesize(token)) {
                revert(0, 0)
            }

            // Build the following message in memory:
            // memory[0x00:0x38] = ERC20_TRANSFER_SIGNATURE ++ recipient ++ amount
            //
            // This writes to scratch space (0x00-0x3f) so we do not need to reset the memory after.
            mstore(ERC20_TRANSFER_SIGNATURE_POINTER, ERC20_TRANSFER_SIGNATURE)
            mstore(ERC20_TRANSFER_RECIPIENT_POINTER, recipient)
            mstore(ERC20_TRANSFER_AMOUNT_POINTER, amount)

            // Call the token contract with the message built in memory.
            //
            // The following is a table that maps the success of the call given various outputs:
            //
            // | call | returndatasize | returndata | success |
            // |------|----------------|------------|---------|
            // | 0x00 | *              | *          | 0x00    |
            // | 0x01 | 0x00           | *          | 0x01    |
            // | 0x01 | 0x00..0x1f     | *          | 0x00    |
            // | 0x01 | 0x20..         | 0x01       | 0x01    |
            // | 0x01 | 0x20..         | ~0x01      | 0x01    |
            success := and(
                // Always succeeds if there was no data or if the data is at least 32 bytes long and the value
                // returned is equal to one. It is possible for the return data to not be exactly 32 bytes long even
                // though the value returned is correct. For example, this occurs in some simple proxy contracts.
                or(
                    iszero(returndatasize()),
                    and(eq(mload(0), 0x01), gt(returndatasize(), 0x1f))
                ),
                call(
                    gas(),                            /* gas */
                    token,                            /* address */
                    0x00                              /* value */,
                    ERC20_TRANSFER_SIGNATURE_POINTER, /* argsOffset */
                    ERC20_TRANSFER_MESSAGE_LENGTH,    /* argsLength */
                    0x00,                             /* retOffset */
                    0x32                              /* retLength */
                )
            )
        }

        require(success);
    }

    /// @dev Transfers `amount` of `token` tokens from `owner` to `recipient`
    /// @param token The token to transfer
    /// @param owner The address of the owner
    /// @param recipient The address of the recipient
    /// @param amount The amount of tokens to transfer
    function safeTransferFrom(IERC20 token, address owner, address recipient, uint256 amount) internal {
        bool success;

        assembly ("memory-safe") {
            // Check that the token is a contract. This is a strict check and this implementation can do without it
            // if the caller trusts that the token exists.
            if iszero(extcodesize(token)) {
                revert(0, 0)
            }

            let pointer := mload(0x40)

            // Build the following message in memory:
            // memory[0x00:0x38] = ERC20_TRANSFER_FROM_SIGNATURE ++ owner ++ recipient ++ amount
            //
            // IMPORTANT: This writes to scratch space (0x00-0x3f) and partially writes over the free memory pointer
            // (0x40-0x4C) so we will need to reset the memory pointer after but not the scratch space.
            mstore(ERC20_TRANSFER_FROM_SIGNATURE_POINTER, ERC20_TRANSFER_FROM_SIGNATURE)
            mstore(ERC20_TRANSFER_FROM_OWNER_POINTER, owner)
            mstore(ERC20_TRANSFER_FROM_RECIPIENT_POINTER, recipient)
            mstore(ERC20_TRANSFER_FROM_AMOUNT_POINTER, amount)

            // Call the token contract with the message built in memory.
            //
            // The following is a table that maps the success of the call given various outputs:
            //
            // | call | returndatasize | returndata | success |
            // |------|----------------|------------|---------|
            // | 0x00 | *              | *          | 0x00    |
            // | 0x01 | 0x00           | *          | 0x01    |
            // | 0x01 | 0x00..0x1f     | *          | 0x00    |
            // | 0x01 | 0x20..         | 0x01       | 0x01    |
            // | 0x01 | 0x20..         | ~0x01      | 0x01    |
            success := and(
                // Always succeeds if there was no data or if the data is at least 32 bytes long and the value
                // returned is equal to one. It is possible for the return data to not be exactly 32 bytes long even
                // though the value returned is correct. For example, this occurs in some simple proxy contracts.
                or(
                    iszero(returndatasize()),
                    and(eq(mload(0), 0x01), gt(returndatasize(), 0x1f))
                ),
                call(
                    gas(),                                 /* gas */
                    token,                                 /* address */
                    0x00                                   /* value */,
                    ERC20_TRANSFER_FROM_SIGNATURE_POINTER, /* argsOffset */
                    ERC20_TRANSFER_FROM_MESSAGE_LENGTH,    /* argsLength */
                    0x00,                                  /* retOffset */
                    0x32                                   /* retLength */
                )
            )

            // Restore the memory pointer
            mstore(0x40, pointer)
        }

        require(success);
    }
}