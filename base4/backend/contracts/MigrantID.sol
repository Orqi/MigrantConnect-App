// contracts/MigrantID.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Ensure this is 0.8.0 or higher, 0.8.20 is good

contract MigrantID {

    struct Identity {
        string name;
        string ipfsHash; // Hash pointing to a JSON file containing all user data
        bool exists;     // Flag to check if an identity exists for an address
    }

    mapping(address => Identity) public identities;

    event IdentityCreated(address indexed user, string name, string ipfsHash);

    // IMPORTANT CHANGE: Added `address _userAddress` parameter
    function createIdentity(
        address _userAddress,          // The actual public address of the Magic Link user
        string memory _nameOnContract, // Full Name (stored directly on-chain)
        string memory _jsonIpfsHash    // IPFS hash of the JSON containing all other details
    ) public {
        // Ensure that an identity doesn't already exist for *this specific user address*
        require(!identities[_userAddress].exists, "Identity already exists for this user");

        // Store the identity using the provided `_userAddress` as the key
        identities[_userAddress] = Identity({
            name: _nameOnContract,
            ipfsHash: _jsonIpfsHash,
            exists: true
        });

        // Emit an event for logging and off-chain tracking, using the _userAddress
        emit IdentityCreated(_userAddress, _nameOnContract, _jsonIpfsHash);
    }

    function getIdentity(address user) public view returns (string memory name, string memory ipfsHash) {
        require(identities[user].exists, "Identity does not exist for this user");
        return (identities[user].name, identities[user].ipfsHash);
    }
}