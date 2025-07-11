require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config(); // This line loads your .env file

const ALCHEMY_AMOY_URL = process.env.ALCHEMY_AMOY_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

module.exports = {
  solidity: "0.8.20", // Make sure this matches your contract's pragma version
  networks: {
    amoy: {
      url: ALCHEMY_AMOY_URL,
      accounts: [`0x${PRIVATE_KEY}`], // Use your private key for deployment
      chainId: 80002, // Chain ID for Polygon Amoy
      gasPrice: 20000000000, // 20 Gwei (adjust if needed for Amoy)
    },
    // You can keep the default hardhat network for local testing if you want
    hardhat: {
      // Local development network
    }
  },
  etherscan: {
    apiKey: {
      polygonAmoy: process.env.POLYGONSCAN_API_KEY // Optional: for verifying on Polygonscan
    }
  }
};