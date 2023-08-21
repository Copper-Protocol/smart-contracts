const { ethers } = require('hardhat');
const utils = require('../libraries/utils');
const common = require('../libraries/common');

async function deployContracts() {
  // Load contracts from the configuration file
  const contracts = await common.loadContracts();
  const [deployer] = await ethers.getSigners();
  const networkName = await common.getNetwork();

  // Check if CopperToken is already deployed
  const copperTokenAddress = contracts.addresses[networkName]['CopperToken'];
  let CopperToken


  if (copperTokenAddress) {
    // console.log('CopperToken is already deployed at:', copperTokenAddress);
    CopperToken = await ethers.getContractAt('CopperToken', copperTokenAddress);
    console.log('Retrieved CopperToken contract:', CopperToken.address);
  } else {
    // Get the account that will deploy the contracts
    return console.log('CopperToken contract not yet deployed')
  }

  // Retrieve the CopperAirdrop contract address from contracts object
  // let copperAirdropAddress = ;

  // Check if CopperAirdrop is already deployed
  if (typeof contracts.addresses[networkName]['CopperAirdrop'] === 'undefined') {
    // Get the CopperToken contract instance
    // const CopperToken = await ethers.getContractAt('CopperToken', copperTokenAddress);

    // Deploy the CopperAirdrop contract
    const CopperAirdrop = await ethers.getContractFactory('CopperAirdrop');
    const copperAirdrop = await CopperAirdrop.deploy(CopperToken.address);
    await copperAirdrop.deployed();
    console.log('CopperAirdrop contract deployed to:', copperAirdrop.address);

    // Save contract address for future reference
    await common.addContract('CopperAirdrop', copperAirdrop.address); // Use the common module function
  } else {
    // console.log('CopperAirdrop is already deployed at:', contracts.addresses[networkName]['CopperAirdrop']);
    // const CopperAirdrop = await ethers.getContractAt('CopperAirdrop', contracts.addresses[networkName]['CopperAirdrop']);
    return console.log('Retrieved CopperAirdrop contract:', contracts.addresses[networkName]['CopperAirdrop']);
  }
}

deployContracts()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
