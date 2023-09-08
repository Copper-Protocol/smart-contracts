// deployAndAddMinter.js
const { ethers } = require('hardhat');
const utils = require('../libraries/utils');
const common = require('../libraries/common');

async function main() {
  // Load contracts from the configuration file
  const contracts = await common.loadContracts();
  const [deployer] = await ethers.getSigners();
  const networkName = await common.getNetwork();
   // Check if CopperToken is already deployed
  const copperTokenAddress = contracts.addresses[networkName]['CopperToken'];
  // Check if CopperToken is already deployed
  const copperAirdropAddress = contracts.addresses[networkName]['CopperAirdrop'];

  // Deploy the CopperToken contract
  const copperToken = await ethers.getContractAt("CopperToken", copperTokenAddress);
  console.log({contracts: contracts.addresses[networkName]})
  console.log("CopperToken deployed to:", copperToken.address);
  console.log({copperTokenAddress, copperAirdropAddress })
  // Deploy the CopperAirdrop contract
  const copperAirdrop = await ethers.getContractAt("CopperAirdrop", copperAirdropAddress);

  console.log("CopperAirdrop deployed to:", copperAirdrop.address);

  // Add CopperAirdrop as a minter to CopperToken
  await copperToken.addMinter(copperAirdrop.address);
  console.log("CopperAirdrop added as a minter to CopperToken!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });