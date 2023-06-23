// SPDX-License-Identifier: COPPER-PROTOCOL
pragma solidity 0.8.18;

library LibMeta {
    // EIP712 domain type hash
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 salt,address verifyingContract)");

    // /**
    //  * @dev Generates the domain separator for EIP712 signatures.
    //  * @param name The name of the contract.
    //  * @param version The version of the contract.
    //  * @return The generated domain separator.
    //  */
    function domainSeparator(string memory name, string memory version) internal view returns (bytes32 domainSeparator_) {
        // Generate the domain separator hash using EIP712_DOMAIN_TYPEHASH and contract-specific information
        domainSeparator_ = keccak256(
            abi.encode(EIP712_DOMAIN_TYPEHASH, keccak256(bytes(name)), keccak256(bytes(version)), getChainID(), address(this))
        );
    }

    // /**
    //  * @dev Gets the current chain ID.
    //  * @return The chain ID.
    //  */
    function getChainID() internal view returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }

    // /**
    //  * @dev Gets the actual sender of the message.
    //  * @return The actual sender of the message.
    //  */
    function msgSender() internal view returns (address sender_) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender_ := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
            }
        } else {
            sender_ = msg.sender;
        }
    }
}
