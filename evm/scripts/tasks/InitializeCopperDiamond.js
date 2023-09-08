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
    console.log(`Copper Token Initializating`, networkName, copperTokenAddress)
    const copperToken = await ethers.getContractAt("CopperToken", copperTokenAddress)

    const name = "Copper Protocol Token"
    const symbol = "COPPER"
    const initialSupply = ethers.utils.parseEther(`1000000`, 18)
    const decimals = `18`
    const cap = ethers.utils.parseEther(`10000000000`, 18)
    const minters = [contracts.addresses[networkName]['Diamond']]
    const burners = [contracts.addresses[networkName]['Diamond']]

    await copperToken.initialize(
        name,
        symbol,
        initialSupply,
        decimals,
        cap,
        minters,
        burners
    )
    // const tx = await copperToken.initialize(totalSuplly, decimals)
    console.log(`Copper Token Initialization Complete`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });