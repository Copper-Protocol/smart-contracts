const { ethers } = require('hardhat');
const utils = require('../libraries/utils');
const common = require('../libraries/common');
const { existsSync, mkdirSync, writeFileSync, readFileSync } = require('fs');

async function deployCopperToken() {
  // Load contracts from the configuration file
  const contracts = await common.loadContracts();

  const [deployer] = await ethers.getSigners();
  // name, symbol, initialSupply, decimals, cap, minters, burners
  // Set the initial supply, name, and symbol for the token
  const initialSupply = ethers.utils.parseEther("1000");
  const name = "Copper Test Token";
  const symbol = "tCOPPER";
  const decimals = 18;
  const cap = ethers.utils.parseEther("1000000")

  // Define the minters and burners addresses
  const minters = [deployer.address];
  const burners = [deployer.address];

  const networkName = await common.getNetwork();

  try {
    // // Check if the config directory exists
    // if (!existsSync("config")) {
    //   mkdirSync("config");
    //   writeFileSync("config/address.json", '{}');
    // }

    // // Check if the config file exists
    // if (!existsSync("config/address.json")) {
    //   throw new Error("Config file does not exist");
    // }

    // Check if the contract has already been deployed on the network
    const copperTokenAddress = await common.isContractDeployed('CopperToken', networkName);

    if (copperTokenAddress) {
      console.log("CopperToken has already been deployed on", networkName);
      console.log("Contract address:", copperTokenAddress);
      return { address: copperTokenAddress, name, symbol, initialSupply, decimals, cap, minters, burners };
    }

    // Deploy the CopperToken contract
    const CopperToken = await ethers.getContractFactory("CopperToken")
    const copperToken = await CopperToken.deploy(name, symbol, initialSupply, decimals, cap, minters, burners)
    await copperToken.deployed()

    // Save contract address for future reference
    common.addContract('CopperToken', copperToken.address); // Use the common module function

    console.log("CopperToken deployed at:", copperToken.address);
    return { address: copperToken.address, name, symbol, initialSupply, decimals, cap, minters, burners };
  } catch (error) {
    console.error("Error:", error.message)
  }
}

deployCopperToken()
  .then(async ({ address, name, symbol, initialSupply, decimals, cap, minters, burners }) => {
    console.log(`Verifying Copper Token...`, {
      address, name, symbol, initialSupply, decimals, cap, minters, burners
    })
    await hre.run("verify:verify", {
      address,
      constructorArguments: [
        name, symbol, initialSupply, decimals, cap, minters, burners
      ],
    });


  })
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error.message)
    process.exit(1)
  });
