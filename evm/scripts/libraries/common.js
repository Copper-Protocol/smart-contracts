const { log } = require('console');
const fs = require('fs');
const { existsSync, mkdirSync, writeFileSync, readFileSync } = require('fs');
const { ethers } = require('hardhat');

let contracts = {};
const confDir = './config';
const contractFile = confDir + '/contracts.json';

// Get the current network name
async function getNetwork() {
  const _net = await ethers.provider.getNetwork()
  return _net.name;
}
exports.getNetwork = getNetwork;
exports.contracts = contracts;

// Verify a contract
const verifyContract = async (address, ...args) => await hre.run("verify:verify", {
  address,
  constructorArguments: [
    ...args
  ],
});
exports.verifyContract = verifyContract;

// Load contracts from the configuration file
function loadContracts() {
  try {
    // Check if the config directory exists
    if (!existsSync(confDir)) {
      mkdirSync(confDir);
      writeFileSync(contractFile, '{}');
    }

    // Check if the config file exists
    if (!existsSync(contractFile)) {
      writeFileSync(contractFile, '{ "addresses": {} }');
    }

    // Load the network configuration file
    const configFile = readFileSync(contractFile, { encoding: 'utf8' });

    // Check if the config file is empty
    if (!configFile) {
      throw new Error("Config file is empty");
    }

    contracts = JSON.parse(configFile);
    return contracts;
  } catch (error) {
    // Handle error if the file doesn't exist or is invalid
    console.error('Error loading contracts:', error);
  }
}
exports.loadContracts = loadContracts;

// Add a contract to the contracts object
async function addContract(name, address) {
  log(`Saving contract [ ${name} ] => ADDRESS: ${address}`)
  const network = await getNetwork();

  if (typeof contracts.addresses === 'undefined') contracts.addresses = {};

  if (typeof contracts.addresses[network] === 'undefined') contracts.addresses[network] = {};

  contracts.addresses[network][name] = address;
  saveContracts();
}
exports.addContract = addContract;

// Check if a contract is deployed on a specific network
function isContractDeployed(name, network) {
  if (typeof contracts.addresses[network] === 'undefined') {
    contracts.addresses[network] = {};
    return false;
  }

  if (typeof contracts.addresses[network][name] === 'undefined') {
    contracts.addresses[network][name] = '';
    return false;
  }

  return (
    typeof contracts.addresses[network][name] === 'string' &&
    contracts.addresses[network][name].length > 39 &&
    !! contracts.addresses[network][name]
  )
}
exports.isContractDeployed = isContractDeployed;

// Save the contracts object to the configuration file
function saveContracts() {
  log(`Saving contracts to file system...`)
  try {
    const json = JSON.stringify(contracts, null, 2);
    writeFileSync(contractFile, json);
  } catch (error) {
    // Handle error while saving contracts
    console.error('Error saving contracts:', error);
  }
}
exports.saveContracts = saveContracts;

// Automatically load contracts on module import
exports.loadContracts();
