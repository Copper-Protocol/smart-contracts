const { ethers } = require('ethers');
const { writeFileSync, existsSync } = require('fs');
// const {
//   addresses: _addresses,
//   addressesFilePath,
//   wrappedTokens
// } = require('../config')

const { log } = require('console');

const fromWei = (x, u = 18) => ethers.utils.formatUnits(x, u);

// const addresses = _addresses
// exports.addresses = addresses

// log({addresses, _addresses})
const toWei = (x, u = 18) => ethers.utils.parseUnits(`${x}`, u)
const pctDiff = (startVal, newVal) => Math.abs(100 * (newVal - startVal) / startVal)

const bpsToPct =  (bps) => bps / 10000 
// network = 'aox'
// network = 'xdai'
// network = 'mumbai'
// network = 'rinkeby'
// network = 'goerli'
// network = 'hardhat'
const supportedNetworks = [
  {
    name: 'aox',
    chainId: 200
  },
  {
    name: 'xdai',
    chainId: 100
  },
  // {
  //   name: 'avalanche',
  //   chainId: 0
  // },
  {
    name: 'polygon',
    chainId: 137
  },
  {
    name: 'rinkeby',
    chainId: 4
  },
  {
    name: 'goerli',
    chainId: 5
  },
]

function getNetwork (_chainId) {
  return supportedNetworks.filter(x => x.chainId === _chainId)[0] || `unsupported network ${_chainId}`
}
const sleep = async time => new Promise(resolve => setTimeout(() => resolve(time), time))


async function saveContractAddresses (addressesFilePath, addresses) {
  if (!existsSync(addressesFilePath)) throw new Error(`ADDRESSES PATH UNSET`)
  writeFileSync(addressesFilePath, JSON.stringify(addresses, null, 2))
}
const ZERO_ADDRESS = `0x0000000000000000000000000000000000000000` 
const ETH_ADDRESS = `0x...CHANGE_ME` 

function uintToInt8Array(uint, numBytes) {
  uint = ethers.utils.hexZeroPad(uint.toHexString(), numBytes).slice(2);
  const array = [];
  for (let i = 0; i < uint.length; i += 2) {
    array.unshift(
      ethers.BigNumber.from("0x" + uint.substr(i, 2))
        .fromTwos(8)
        .toNumber()
    );
  }
  return array;
}

function sixteenBitArrayToUint(array) {
  const uint = [];
  for (let item of array) {
    if (typeof item === "string") {
      item = parseInt(item);
    }
    uint.push(item.toString(16).padStart(4, "0"));
  }
  if (array.length > 0) return ethers.BigNumber.from("0x" + uint.join(""));
  return ethers.BigNumber.from(0);
}

function sixteenBitIntArrayToUint(array) {
  const uint = [];
  for (let item of array) {
    if (typeof item === "string") {
      item = parseInt(item);
    }
    if (item < 0) {
      item = (1 << 16) + item;
    }
    // console.log(item.toString(16))
    uint.push(item.toString(16).padStart(4, "0"));
  }
  if (array.length > 0) return ethers.BigNumber.from("0x" + uint.join(""));
  return ethers.BigNumber.from(0);
}

function uintToItemIds(uint) {
  uint = ethers.utils.hexZeroPad(uint.toHexString(), 32).slice(2);
  const array = [];
  for (let i = 0; i < uint.length; i += 4) {
    array.unshift(
      ethers.BigNumber.from("0x" + uint.substr(i, 4))
        .fromTwos(16)
        .toNumber()
    );
  }
  return array;
}
async function ethWriteActionRaw (contract, method, args = [], options = {}) {
  options.gasPrice = await wallet.getGasPrice()
  log({args})
  options.gasLimit = await contract.estimateGas[method](...args, options)
  options.nonce = await wallet.getTransactionCount() + transQueue.length

  return await contract.populateTransaction[method](...args, options)
}

async function ethReadAction (contract, method, args = []) {
  if (!Array.isArray(args)) throw new Error(`ARGS MUST BE AN ARRAY`)
  log({args, argsCount: args.length})
  return (args.length) ? contract.interface.encodeFunctionData(method, args) : contract.interface.encodeFunctionData(method)
}
function compare(a, b) {
  const assetA = a.asset.toUpperCase();
  const assetB = b.asset.toUpperCase();

  let comparison = 0;
  if (assetA > assetB) {
    comparison = 1;
  } else if (assetA < assetB) {
    comparison = -1;
  }
  return comparison;
}


module.exports = {
  fromWei,
  toWei,
  pctDiff,
  bpsToPct,
  sleep,
  // updateContractAddresses,
  // saveContractAddresses,
  ZERO_ADDRESS,
  // updateContractAddresses,
  // saveContractAddresses,
  uintToInt8Array,
  sixteenBitArrayToUint,
  sixteenBitIntArrayToUint,
  uintToItemIds,
  ethWriteActionRaw,
  ethReadAction,
  // addresses,
  compare,
  getNetwork,
  supportedNetworks,
  
}
