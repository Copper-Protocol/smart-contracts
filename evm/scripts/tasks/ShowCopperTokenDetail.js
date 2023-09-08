// deployAndAddMinter.js
const { ethers } = require('hardhat')
const utils = require('../libraries/utils')
const common = require('../libraries/common')
const hre = require("hardhat")

async function main () {
  // Load contracts from the configuration file
  const contracts = await common.loadContracts()
  const [deployer] = await ethers.getSigners()
  const networkName = await common.getNetwork()
  // Check if CopperToken is already deployed
  
  const copperTokenAddress = contracts.addresses[networkName]['CopperToken']
  const copperToken = await ethers.getContractAt("CopperToken", copperTokenAddress)

  console.log({
    name: await copperToken.name(),
    symbol: await copperToken.symbol(),
    totalSupply: ethers.utils.formatEther(await copperToken.totalSupply()).toString(),
    decimals: await copperToken.decimals(),
    maxSupply: ethers.utils.formatEther(await copperToken.cap()).toString()
  })
  console.log(`DONE`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
