const hre = require("hardhat");

async function main() {
  const ContractFactory = await hre.ethers.getContractFactory("MigrantID"); // replace with your contract name
  const contract = await ContractFactory.deploy();
  await contract.waitForDeployment(); // ✅ Modern Hardhat uses waitForDeployment

  console.log("Contract deployed to:", await contract.getAddress()); // ✅ Use getAddress instead of contract.address
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});