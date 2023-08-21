const { ethers } = require('hardhat');
const utils = require('../libraries/utils');
const common = require('../libraries/common');

async function deployCopperFaucet(requestInterval, requestAmount) {
  const CopperFaucet = await ethers.getContractFactory("CopperFaucet");
  const copperFaucet = await CopperFaucet.deploy(requestInterval, requestAmount);
  await copperFaucet.deployed();

  console.log("CopperFaucet deployed to:", copperFaucet.address);
  return copperFaucet;
}

async function main() {
  // Set the desired request interval and request amount (in wei)
   // Load contracts from the configuration file
   const contracts = await common.loadContracts();
   const [deployer] = await ethers.getSigners();
   const networkName = await common.getNetwork();

   const requestInterval = 4 * 60 * 60; // 4 hours (in seconds)
  const requestAmount = ethers.utils.parseEther("0.025"); // 0.025 ETH

  const copperFaucetAddress = contracts.addresses[networkName].CopperFaucet;
  if (typeof copperFaucetAddress !== 'undefined') {
    return console.log(`Contract Deployed @ ${copperFaucetAddress}`);
  }
  // Deploy CopperFaucet
  const copperFaucet = await deployCopperFaucet(requestInterval, requestAmount);

  // Add CopperFaucet contract to the contract manager
  // const contractManagerAddress = "ADDRESS_OF_CONTRACT_MANAGER"; // Replace with the address of your contract manager
  const contractName = "CopperFaucet";
  const contractAddress = copperFaucet.address;

  await common.addContract(contractName, contractAddress)
  // Load the contract manager instance
  // const ContractManager = await ethers.getContractFactory("ContractManager");
  // const contractManager = await ContractManager.attach(contractManagerAddress);

  // Add the CopperFaucet contract to the contract manager
  // await contractManager.addContract(contractName, contractAddress);

  console.log("CopperFaucet added to the contract manager:", contractAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
