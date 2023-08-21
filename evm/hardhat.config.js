require("@nomicfoundation/hardhat-toolbox");
require("@matterlabs/hardhat-zksync-deploy")
require("@matterlabs/hardhat-zksync-solc")
require("@matterlabs/hardhat-zksync-verify")

const { randomBytes } = require('crypto');
const { utils } = require("ethers");
const { toWei } = require("./scripts/libraries/utils");
const { log } = require("console");


const {
  DEPLOYER_PRIVATE_KEY,
  PRIVATE_KEY,
  BOT_MANAGER_PRIVATE_KEY,
  BOT_RUNNER_PRIVATE_KEY,
} = process.env


const deployerPrivateKey = process.env.DEPLOYER_PRIVATE_KEY
const privateKey = process.env.PRIVATE_KEY
const pkTest01 = `${randomBytes(32).toString('hex')}`
const pkTest02 = `${randomBytes(32).toString('hex')}`
const pkTest03 = `${randomBytes(32).toString('hex')}`
const pkTest04 = `${randomBytes(32).toString('hex')}`
const pkTest05 = `${randomBytes(32).toString('hex')}`
const pkTest06 = `${randomBytes(32).toString('hex')}`
const pkTest07 = `${randomBytes(32).toString('hex')}`

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
      // from: `${process.env.DEPLOYER_ADDRESS}`,
      accounts: [ 
        {
          privateKey: deployerPrivateKey, 
          balance: toWei(`10000000`).toString()
        }, 
        {
          privateKey, 
          balance: toWei(`10000000`).toString()
        }, 
        {
          privateKey: pkTest01, 
          balance: toWei(`10000000`).toString()
        }, 
        {
          privateKey: pkTest02, 
          balance: toWei(`10000000`).toString()
        }, 
        {
          privateKey: pkTest03, 
          balance: toWei(`10000000`).toString()
        }, 
        {
          privateKey: pkTest04, 
          balance: toWei(`10000000`).toString()
        }, 
        {
          privateKey: pkTest05, 
          balance: toWei(`10000000`).toString()
        }, 
        {
          privateKey: pkTest06, 
          balance: toWei(`10000000`).toString()
        }, 
        {
          privateKey: pkTest07, 
          balance: toWei(`10000000`).toString()
        }, 
     ],
      chainId: 1137,
      forking: {
        url: process.env.MATIC_RPC_PROVIDERS.split(',')[0],
        // blockNumber: 21244653
      },
      mining: {
        mempool: {
          order: "fifo"
        }
      },  
      saveDeployments: true,
      tags: ["local"],
    },
    goerli: {
      url: process.env.GOERLI_RPC_PROVIDERS.split(',')[0],
      accounts: [
          DEPLOYER_PRIVATE_KEY,
          PRIVATE_KEY,
          BOT_MANAGER_PRIVATE_KEY,
          BOT_RUNNER_PRIVATE_KEY,
              
      ],
      chainId: 5
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_PROVIDERS.split(',')[0],
      accounts: [
          DEPLOYER_PRIVATE_KEY,
          PRIVATE_KEY,
          BOT_MANAGER_PRIVATE_KEY,
          BOT_RUNNER_PRIVATE_KEY,
              
      ],
      chainId: 11155111
    },
    zkTestnet: {
      url: "https://testnet.era.zksync.dev", // URL of the zkSync network RPC
      accounts: [
          DEPLOYER_PRIVATE_KEY,
          PRIVATE_KEY,
          BOT_MANAGER_PRIVATE_KEY,
          BOT_RUNNER_PRIVATE_KEY,
              
      ],
      ethNetwork: "goerli", // Can also be the RPC URL of the Ethereum network (e.g. `https://goerli.infura.io/v3/<API_KEY>`)
      zksync: true,
    },
  },
  solidity: "0.8.18",
  etherscan: {
    apiKey: {
      mainnet: "E1CYUHNRN9GD33UV9C3SKA6JRGUKVV3XH8",
      sepolia: "E1CYUHNRN9GD33UV9C3SKA6JRGUKVV3XH8",
    },
  },

};
