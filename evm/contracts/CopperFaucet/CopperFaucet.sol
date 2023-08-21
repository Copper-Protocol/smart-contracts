// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CopperFaucet {
    using SafeMath for uint256;
    using ECDSA for bytes32;

    address public admin;
    uint256 public requestInterval;
    uint256 public requestAmount;
    mapping(address => uint256) public lastRequestTime;

    // EIP-712 related variables
    string public constant DOMAIN_NAME = "CopperFaucet";
    string public constant DOMAIN_VERSION = "1";
    bytes32 public immutable DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(DOMAIN_NAME)),
            keccak256(bytes(DOMAIN_VERSION)),
            getChainID(),
            address(this)
        )
    );
    bytes32 public constant REQUEST_TYPEHASH = keccak256("Request(address user,uint256 timestamp)");

    constructor(uint256 _requestInterval, uint256 _requestAmount) {
        admin = msg.sender;
        requestInterval = _requestInterval;
        requestAmount = _requestAmount;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function getChainID() internal view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function hashRequest(address user, uint256 timestamp) internal view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(REQUEST_TYPEHASH, user, timestamp))));
    }

    function verifySignature(address user, uint256 timestamp, bytes memory signature) internal view returns (bool) {
        bytes32 messageHash = hashRequest(user, timestamp);
        address recoveredAddress = messageHash.recover(signature);
        return recoveredAddress == user;
    }

    function setRequestInterval(uint256 _requestInterval) external onlyAdmin {
        requestInterval = _requestInterval;
    }

    function setRequestAmount(uint256 _requestAmount) external onlyAdmin {
        requestAmount = _requestAmount;
    }

    function requestETH(bytes calldata signature) external {
        uint256 lastRequest = lastRequestTime[msg.sender];
        require(block.timestamp >= lastRequest.add(requestInterval), "Too soon to request ETH");
        require(address(this).balance >= requestAmount, "Faucet doesn't have enough ETH");
        require(verifySignature(msg.sender, lastRequest, signature), "Invalid signature");

        payable(msg.sender).transfer(requestAmount);
        lastRequestTime[msg.sender] = block.timestamp;
    }

    function depositTokens(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        IERC20 token = IERC20(tokenAddress);
        require(token.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
    }

    function withdrawTokens(address tokenAddress, uint256 amount) external onlyAdmin {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        require(token.transfer(msg.sender, amount), "Token transfer failed");
    }

    receive() external payable {}
}
