// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import { LibMeta } from "../shared/libraries/LibMeta.sol";

contract CopperTokenInternal is ERC20Capped, Ownable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    mapping(address => bool) public hasClaimed;

    uint256 public airdropSupply; // 10 percent of total supply
    uint256 public airdropAmountPerUser;
    bool public airdropEnded;
    uint256 public totalClaimed;

    event TokensClaimed(address indexed account, uint256 amount);

    constructor(
        uint256 initialSupply,
        uint256 max,
        string memory name,
        string memory symbol,
        address[] memory minters,
        address[] memory burners,
        address treasury
    ) ERC20(name, symbol) ERC20Capped(max) {
        _setupRole(ADMIN_ROLE, LibMeta.msgSender());
        _setupRole(MINTER_ROLE, LibMeta.msgSender());
        _setupRole(BURNER_ROLE, LibMeta.msgSender());
        airdropSupply = max / 10;
        airdropAmountPerUser = airdropSupply / 5000;
        _mint(treasury, initialSupply);

        for (uint256 i = 0; i < minters.length; ++i) {
            grantRole(MINTER_ROLE, minters[i]);
        }

        for (uint256 i = 0; i < burners.length; ++i) {
            grantRole(BURNER_ROLE, burners[i]);
        }
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, LibMeta.msgSender()), "Restricted to admins");
        _;
    }

    modifier hasNotClaimed() {
        require(!hasClaimed[LibMeta.msgSender()], "Already claimed tokens");
        _;
    }

    function _claim() internal hasNotClaimed {
        require(!airdropEnded, "AIRDROP ENDED");
        uint256 claimAmount = airdropAmountPerUser;
        totalClaimed += claimAmount;
        if (totalClaimed >= airdropSupply) {
            airdropEnded = true;
        }
        _mint(LibMeta.msgSender(), claimAmount);
        emit TokensClaimed(LibMeta.msgSender(), claimAmount);
        hasClaimed[LibMeta.msgSender()] = true;
    }

    function addMinter(address account) external onlyAdmin {
        grantRole(MINTER_ROLE, account);
    }

    function addBurner(address account) external onlyAdmin {
        grantRole(BURNER_ROLE, account);
    }
}

contract CopperToken is CopperTokenInternal {
    constructor(
        uint256 initialSupply,
        uint256 max,
        string memory name,
        string memory symbol,
        address[] memory minters,
        address[] memory burners,
        address treasury
    ) CopperTokenInternal(initialSupply, max, name, symbol, minters, burners, treasury) {}

    function mint(address to, uint256 amount) public {
        // Only minters can mint
        require(hasRole(MINTER_ROLE, LibMeta.msgSender()), "Restricted to minters");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        // Only burners can burn
        require(hasRole(BURNER_ROLE, LibMeta.msgSender()), "Restricted to burners");
        _burn(from, amount);
    }

    function claim() external {
        _claim();
    }
}
