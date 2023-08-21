// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import {LibMeta} from "../../libraries/LibMeta.sol";
import {AccessControlInternal} from "../../facets/AccessControl/AccessControl/AccessControlInternal.sol";
import {AccessControlModifiers} from "../../facets/AccessControl/AccessControl/AccessControlModifiers.sol";
import {LibAccessControl, AccessControlStorage} from "../../libraries/LibAccessControl.sol";

import {IERC165} from "../../interfaces/IERC165.sol";
import {IERC173} from "../../interfaces/IERC173.sol";

import {ERC20BaseStorage, LibERC20Base} from "./LibERC20.sol";

contract ERC20BaseModifiers {

    // Modifier to restrict access to only the admin
    modifier onlyAdmin() {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();

        require(acl.hasAdminRole(LibMeta.msgSender()), "Only admin can call this function");
        _;
    }

    // Modifier to restrict access to only minters
    modifier onlyMinter() {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        require(acl.hasRole(AccessControlModifiers.acl.ROLE_COPPER_MINTER, LibMeta.msgSender()), "Only minter can call this function");
        _;
    }

    // Modifier to restrict access to only burners
    modifier onlyBurner() {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        require(acl.hasRole(AccessControlModifiers.acl.ROLE_COPPER_BURNER, LibMeta.msgSender()), "Only burner can call this function");
        _;
    }
    modifier isInitialized () {
        ERC20BaseStorage storage erc20Store = LibAccessControl.diamondStorage();
        require(erc20Store.ERC20_INIT, "NOT INITIALIZED");
        _;
    }
    modifier notInitialized () {
        ERC20BaseStorage storage erc20Store = LibAccessControl.diamondStorage();
        require(!erc20Store.ERC20_INIT, "ALREADY INITIALIZED");
        _;
    }
}

// Internal contract with ERC20 token functionality and access control
contract ERC20BaseInternal is AccessControlInternal, ERC20BaseModifiers, IERC165, IERC173 {
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event BurnerAdded(address indexed account);
    event BurnerRemoved(address indexed account);

    // Initialize the ERC20 token
    function _initialize(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint256 decimal_,
        uint256 cap_,
        address[] memory minters,
        address[] memory burners
    ) internal {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        erc20BaseStore.name = name_;
        erc20BaseStore.symbol = symbol_;
        erc20BaseStore.totalSupply = totalSupply_;
        erc20BaseStore.decimals = decimal_;
        erc20BaseStore.cap = cap_;

        // Set the caller of _initialize as the admin
        address admin = LibMeta.msgSender();
        acl.setAdminRole(admin);

        // Add minters
        for (uint256 i = 0; i < minters.length; i++) {
            acl.addMinterRole(minters[i]);
        }

        // Add burners
        for (uint256 i = 0; i < burners.length; i++) {
            acl.addBurnerRole(burners[i]);
        }

        erc20BaseStore.balances[admin] = totalSupply_;
        emit Transfer(address(0), admin, totalSupply_);
    }

    // Get the name of the token
    function _name() internal view returns (string memory) {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        return erc20BaseStore.name;
    }

    // Get the symbol of the token
    function _symbol() internal view returns (string memory) {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        return erc20BaseStore.symbol;
    }

    // Get the decimals of the token
    function _decimals() internal view returns (uint8) {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        return uint8(erc20BaseStore.decimals);
    }

    // Get the total supply of the token
    function _totalSupply() internal view returns (uint256) {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        return erc20BaseStore.totalSupply;
    }

    // Get the balance of an account
    function _balanceOf(address account) internal view returns (uint256) {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        return erc20BaseStore.balances[account];
    }

    // Get the allowance for spender on owner's tokens
    function _allowance(address owner, address spender) internal view returns (uint256) {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        return erc20BaseStore.allowances[owner][spender];
    }

    // Transfer tokens from one address to another
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(value > 0, "transfer value must be greater than zero");
        require(erc20BaseStore.balances[from] >= value, "transfer amount exceeds balance");

        erc20BaseStore.balances[from] -= value;
        erc20BaseStore.balances[to] += value;
        emit Transfer(from, to, value);
    }

    // Transfer tokens from one address to another
    function _transferFrom(
        address from,
        address to,
        uint256 value
    ) internal {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        require(erc20BaseStore.allowances[from][LibMeta.msgSender()] >= value, "transfer amount exceeds allowance");
        erc20BaseStore.allowances[from][LibMeta.msgSender()] -= value;
        _transfer(from, to, value);
    }

    // Approve spender to spend owner's tokens
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        erc20BaseStore.allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    // Mint new tokens and assign them to an account
    function _mint(address account, uint256 value) internal {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        require(account != address(0), "mint to the zero address");
        erc20BaseStore.totalSupply += value;
        erc20BaseStore.balances[account] += value;
        emit Transfer(address(0), account, value);
    }

    // Burn tokens from the caller's account
    function _burn(uint256 value) internal {
        ERC20BaseStorage storage erc20BaseStore = LibERC20Base.diamondStorage();
        require(erc20BaseStore.balances[LibMeta.msgSender()] >= value, "burn amount exceeds balance");
        erc20BaseStore.balances[LibMeta.msgSender()] -= value;
        erc20BaseStore.totalSupply -= value;
        emit Transfer(LibMeta.msgSender(), address(0), value);
    }

    // Add a minter role to an account
    function _addMinter(address account) internal {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        require(LibAccessControl.hasRole(acl.ROLE_ADMIN, LibMeta.msgSender()), "Only admin can add a minter");
        require(account != address(0), "Cannot add minter to the zero address");
        _grantRole(acl.ROLE_COPPER_MINTER, account);
        emit MinterAdded(account);
    }

    // Remove a minter role from an account
    function _removeMinter(address account) internal {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        require(LibAccessControl.hasRole(acl.ROLE_ADMIN, LibMeta.msgSender()), "Only admin can remove a minter");
        require(account != address(0), "Cannot remove minter from the zero address");
        _revokeRole(acl.ROLE_COPPER_MINTER, account);
        emit MinterRemoved(account);
    }

    // Add a burner role to an account
    function _addBurner(address account) internal {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        require(LibAccessControl.hasRole(acl.ROLE_ADMIN, LibMeta.msgSender()), "Only admin can add a burner");
        require(account != address(0), "Cannot add burner to the zero address");
        _grantRole(acl.ROLE_COPPER_BURNER, account);
        emit BurnerAdded(account);
    }

    // Remove a burner role from an account
    function _removeBurner(address account) internal {
        AccessControlStorage storage acl = LibAccessControl.diamondStorage();
        require(LibAccessControl.hasRole(acl.ROLE_ADMIN, LibMeta.msgSender()), "Only admin can remove a burner");
        require(account != address(0), "Cannot remove burner from the zero address");
        _revokeRole(acl.ROLE_COPPER_BURNER, account);
        emit BurnerRemoved(account);
    }
}

// ERC20 token contract with internal functions
contract ERC20Base is ERC20BaseModifiers, ERC20BaseInternal {
    // Transfer tokens to a given address
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(LibMeta.msgSender(), to, value);
        return true;
    }

    // Transfer tokens from one address to another
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public isInitialized returns (bool) {
        _transferFrom(from, to, value);
        return true;
    }

    // Approve spender to spend a certain amount of tokens
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(LibMeta.msgSender(), spender, value);
        return true;
    }

    // Mint new tokens and assign them to an account
    function mint(address account, uint256 value) public onlyMinter {
        _mint(account, value);
    }

    // Burn tokens from the caller's account
    function burn(uint256 value) public onlyBurner {
        _burn(value);
    }

    // Add a minter role to an account
    function addMinter(address account) public onlyAdmin {
        _addMinter(account);
    }

    // Remove a minter role from an account
    function removeMinter(address account) public onlyAdmin {
        _removeMinter(account);
    }

    // Add a burner role to an account
    function addBurner(address account) public onlyAdmin {
        _addBurner(account);
    }

    // Remove a burner role from an account
    function removeBurner(address account) public onlyAdmin {
        _removeBurner(account);
    }

    // Get the name of the token
    function name() public view returns (string memory) {
        return _name();
    }

    // Get the symbol of the token
    function symbol() public view returns (string memory) {
        return _symbol();
    }

    // Get the decimals of the token
    function decimals() public view returns (uint8) {
        return _decimals();
    }

    // Get the total supply of the token
    function totalSupply() public view returns (uint256) {
        return _totalSupply();
    }

    // Get the balance of an account
    function balanceOf(address account) public view returns (uint256) {
        return _balanceOf(account);
    }

    // Get the allowance for spender on owner's tokens
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance(owner, spender);
    }

}