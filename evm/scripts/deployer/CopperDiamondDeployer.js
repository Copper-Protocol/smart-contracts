const fs = require('fs');
const { ethers } = require('hardhat');
const { getSelectors, FacetCutAction } = require('../libraries/diamond.js');
const {
  verifyContract,
  loadContracts,
  addContract,
  isContractDeployed,
  saveContracts,
  getNetwork,
} = require('../libraries/common.js');

const {log} = require('console')

let diamond, diamondCutFacet, diamondInit, diamondCut, network, contracts

exports.deployDiamond = async function deployDiamond() {
  // await loadContracts()
  contracts = await loadContracts()
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];
  
  network = await getNetwork()

  if (typeof contracts.addresses === 'undefined') contracts.addresses = {}


  // deploy DiamondCutFacet
  if (!isContractDeployed('DiamondCutFacet', network)) {

    const DiamondCutFacet = await ethers.getContractFactory('DiamondCutFacet');
    diamondCutFacet = await DiamondCutFacet.deploy();
    await diamondCutFacet.deployed();
  
    log('DiamondCutFacet deployed:', diamondCutFacet.address);
    await addContract('DiamondCutFacet', diamondCutFacet.address);
    diamondCut = diamondCutFacet

    try {
      await verifyContract(diamondCutFacet.address);
    } catch {
      log(`Already Verified`)
    }
  } else {
    log(`Contract [ DiamondCutFacet ] already deployed at: ${contracts.addresses[network].DiamondCutFacet}`,contracts.addresses[network].DiamondCutFacet )
    diamondCutFacet = await ethers.getContractAt('DiamondCutFacet',contracts.addresses[network].DiamondCutFacet )
    await diamondCutFacet.attach(contracts.addresses[network].DiamondCutFacet)
    log(`DiamondCut Address:`, diamondCutFacet.address)
  }

  if (!isContractDeployed('Diamond', network)) {
      // deploy Diamond
    const Diamond = await ethers.getContractFactory('Diamond');
    diamond = await Diamond.deploy(contractOwner.address, diamondCutFacet.address);
    await diamond.deployed();
    log('Diamond deployed:', diamond.address);
    await addContract('Diamond', diamond.address);
    try {
      await verifyContract(diamond.address)
    } catch {
      log(`Already Verified`)
    }
  } else {
    log(`Contract [ Diamond ] already deployed at: ${contracts.addresses[network].Diamond}`)
    diamond = await ethers.getContractAt('Diamond', contracts.addresses[network].Diamond)
    log(`Diamond Address:`, diamond.address)

  }

  if (!isContractDeployed('DiamondInit', network)) {
      // deploy DiamondInit
    // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
    // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
    const DiamondInit = await ethers.getContractFactory('DiamondInit');
    diamondInit = await DiamondInit.deploy();
    await diamondInit.deployed();
    log('DiamondInit deployed:', diamondInit.address);
    await addContract('DiamondInit', diamondInit.address);
    try {
      await verifyContract(diamondInit.address);
    } catch {
      log(`Already Verified`)
    }
  } else {

    log(`Contract [ DiamondInit ] already deployed at: ${contracts.addresses[network].DiamondInit}`)
    diamondInit = await ethers.getContractAt('DiamondInit', contracts.addresses[network].DiamondInit)
    
    log(`DiamondInit Address:`, diamondInit.address)

  }

  // deploy facets
  log('');
  log('Deploying facets');
  const Facets = [
    { name: 'DiamondLoupeFacet' },
    { name: 'OwnershipFacet' },
    { name: 'CopperTrust' },
  ];
  const cut = [];
  for (const FacetInfo of Facets) {
    const Facet = await ethers.getContractFactory(FacetInfo.name);
    const facet = await Facet.deploy();
    await facet.deployed();
    log(`${FacetInfo.name} deployed: ${facet.address}`);
    await addContract(`Facet${FacetInfo.name}`, facet.address);
    try {
      await verifyContract(facet.address);
    } catch {
      log(`${FacetInfo.name} already verified: ${facet.address}`);
    }
    cut.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet),
    });
  }

  // upgrade diamond with facets
  log('');
  log('Diamond Cut:', cut);
  log(`Diamond Address: ${diamond.address}`, diamondInit.address)
  diamondCut = await ethers.getContractAt('IDiamondCut', diamond.address);
  // log({diamondCut})
  let tx;
  let receipt;
  // call to init function
  let functionCall = diamondInit.interface.encodeFunctionData('init', [`0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa`]);
  log({functionCall})
  tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall);
  log('Diamond cut tx:', tx.hash);
  receipt = await tx.wait();
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`);
  }
  log('Completed diamond cut');
  return diamond.address;
};
