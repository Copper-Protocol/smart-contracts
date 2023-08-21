// SPDX-License=Identifier: COPPER-PROTOCOL
pragma solidity 0.8.18;

import {IERC20} from "../shared/interfaces/IERC20.sol";
import {ERC1155Base} from "../shared/facets/ERC1155/base/ERC1155Base.sol";
import {ERC1155Meta} from "../shared/facets/ERC1155/meta/ERC1155Meta.sol";

struct CopperVaultUser {
  uint256 id;
  address user;
}
struct VaultPosition {
  CopperVaultUser user;
  bool isPaused;
  uint256 bpsFee;
  IERC20 token0;
  IERC20 token1;
  uint256 amount0;
  uint256 amount1;
}

struct CoperVaultStorage {
  mapping(address => CopperVaultUser) users;
  mapping(address => bool) authorizedUsers;
  uint256 nextUserId;
  mapping(uint256 => VaultPosition) vaultPositions;
  uint256 nextVaultPositionId;
}
library LibCopperVault {
    bytes32 constant STORAGE_POSITION = keccak256("copper-protocol.copper-vault.storage");

    /**
     * @dev Returns the access control storage struct
     * @return ds Access control storage struct
     */
    function diamondStorage() internal pure returns (CoperVaultStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }


}

contract CopperVaultInternal is ERC1155Base, ERC1155Meta {
    // Initialization function
    function _initializeCopperVault () internal {
        CoperVaultStorage storage s = LibCopperVault.diamondStorage();
        s.nextUserId = 1;
        s.nextVaultPositionId = 1;
    }

    // Add a user to the Copper Vault
    function _addUser(address user_) internal {
        CoperVaultStorage storage s = LibCopperVault.diamondStorage();
        s.users[user_].id = s.nextUserId;
        s.users[user_].user = user_;
        s.authorizedUsers[user_] = true;
        s.nextUserId += 1;
    }

    // Create an LP position for a user
    function _createLPPosition(
        address user_,
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 bpsFee
    ) internal {
        CoperVaultStorage storage s = LibCopperVault.diamondStorage();
        CopperVaultUser storage user = s.users[user_];

        // Ensure tokens are in order
        (IERC20 token0, IERC20 token1, uint256 amount0, uint256 amount1) = tokenA < tokenB
            ? (tokenA, tokenB, amountA, amountB)
            : (tokenB, tokenA, amountB, amountA);

        VaultPosition storage position = s.vaultPositions[s.nextVaultPositionId];
        position.user = user;
        position.isPaused = false;
        position.bpsFee = bpsFee;
        position.token0 = token0;
        position.token1 = token1;
        position.amount0 = amount0;
        position.amount1 = amount1;

        s.nextVaultPositionId += 1;
    }
  function _addLiquidity (
    uint256 userId,
    IERC20 tokenA,
    IERC20 tokenB,
    uint256 amountA,
    uint256 amountB
  ) internal {
    CoperVaultStorage storage s = LibCopperVault.diamondStorage();
    VaultPosition storage position = s.vaultPositions[userId];

    // Ensure tokens are in order
    (IERC20 token0, IERC20 token1, uint256 amount0, uint256 amount1) = tokenA < tokenB
      ? (tokenA, tokenB, amountA, amountB)
      : (tokenB, tokenA, amountB, amountA);

    require(position.token0 == token0 && position.token1 == token1, "CopperVault: INVALID_TOKEN_ORDER");

    position.token0.transferFrom(msg.sender, address(this), amount0);
    position.token1.transferFrom(msg.sender, address(this), amount1);
    position.amount0 += amount0;
    position.amount1 += amount1;
  }
  function _removeLiquidity (uint256 userId) internal {
    CoperVaultStorage storage s = LibCopperVault.diamondStorage();
    VaultPosition storage position = s.vaultPositions[userId];
    position.token0.transfer(msg.sender, position.amount0);
    position.token1.transfer(msg.sender, position.amount1);
    position.amount0 = 0;
    position.amount1 = 0;
  }

  function _setFee (uint256 userId, uint256 bpsFee) internal {
    CoperVaultStorage storage s = LibCopperVault.diamondStorage();
    s.vaultPositions[userId].bpsFee = bpsFee;
  }

  function _pausePosition (uint256 userId) internal {
    CoperVaultStorage storage s = LibCopperVault.diamondStorage();
    s.vaultPositions[userId].isPaused = true;
  }

  function _unpausePosition (uint256 userId) internal {
    CoperVaultStorage storage s = LibCopperVault.diamondStorage();
    s.vaultPositions[userId].isPaused = false;
  }
}