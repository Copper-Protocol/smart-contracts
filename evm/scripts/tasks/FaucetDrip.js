const { ethers, network } = require('hardhat');
const { signTypedData, SignTypedDataVersion } = require('@metamask/eth-sig-util');
const common = require('../libraries/common');
const {log} = require('console')

async function main() {
  const contracts = await common.loadContracts();
  const networkName = await common.getNetwork();
  const accounts = config.networks.hardhat.accounts;

  const [deployer, signer] = await ethers.getSigners();
  const copperFaucetAddress = contracts.addresses[networkName].CopperFaucet;
  const copperFaucet = await ethers.getContractAt('CopperFaucet', copperFaucetAddress);

  const requestInterval = 4 * 60 * 60; // 4 hours in seconds
  const requestAmount = ethers.utils.parseEther('0.025'); // 0.025 ETH

  const currentTimestamp = Math.floor(Date.now() / 1000);
  const lastRequest = await copperFaucet.lastRequestTime(signer.address);
  const requestTimestamp = lastRequest.add(requestInterval);

  const domain = {
    name: 'CopperFaucet',
    version: '1',
    chainId: 11155111, // Replace with the chain ID of the network you are using
    verifyingContract: copperFaucet.address,
  };
  log(`copperFaucet.address`, copperFaucet.address)
  const types = {
    RequestETH: [
      { name: 'signature', type: 'bytes' },
    ],
  };

  const value = {
    signature: signer.address,
    // timestamp: requestTimestamp.toNumber(),
  };

  const privateKey = Buffer.from(accounts[0].privateKey.substr(2), 'hex'); // Use the private key in buffer format
  log({})
  const signature = signer._signTypedData(domain, types, value)

  // Call the requestETH function on the CopperFaucet contract using the signature
  const tx = await copperFaucet.connect(signer).requestETH(signature);

  console.log('Transaction hash:', tx.hash);

  // Wait for the transaction to be mined
  await tx.wait();

  console.log('ETH requested successfully!');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
