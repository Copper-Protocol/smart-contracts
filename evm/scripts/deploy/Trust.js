const hre = require("hardhat");

async function main() {
  // Get the contract factory
  const Trust = await hre.ethers.getContractFactory("Trust");

  // Deploy the contract
  const trust = await Trust.deploy();

  // Wait for the contract to be mined
  await trust.deployed();

  console.log("Trust contract deployed to:", trust.address);
}

// Run the deployment script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });