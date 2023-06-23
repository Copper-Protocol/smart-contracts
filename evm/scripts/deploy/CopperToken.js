// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat")
const { readFileSync, writeFileSync, existsSync, mkdir, mkdirSync } = require('fs')

const configDir = `${process.cwd()}/config/${hre.network.name}`
if (!existsSync(configDir)) mkdirSync(configDir, {recursive: true})

const treasuryAddress = (readFileSync(`${configDir}/CopperTreasury`)).toString().trim()
console.log({treasuryAddress})

const {BigNumber} = hre.ethers
async function main() {
  // const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  // const unlockTime = currentTimestampInSeconds + 60;

  // const lockedAmount = hre.ethers.utils.parseEther("0.001");

  // const Lock = await hre.ethers.getContractFactory("Lock");
  // const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

  // await lock.deployed();

  // console.log(
  //   `Lock with ${ethers.utils.formatEther(
  //     lockedAmount
  //   )}ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`
  // );
  // constructor (uint256 initialSupply, uint256 max, string memory name, string memory symbol, address[] memory minters, address[] memory burners, address treasury) 
  const treasury = treasuryAddress
  const max = ethers.utils.parseEther(`1000000000`)
  const initialSupply = ethers.utils.parseEther(`1000000000` )
  const name = `FraktalDeFi`
  const symbol = `FRAKTAL`
  const minters = [treasury]
  const burners = [treasury]

  console.log({initialSupply, max, name, symbol, minters, burners, treasury})
  const FraktalDeFiToken = await hre.ethers.getContractFactory("FraktalDeFiToken")
  const fraktalDeFiToken = await FraktalDeFiToken.deploy(initialSupply, max, name, symbol, minters, burners, treasury)
  await fraktalDeFiToken.deployed()
  console.log(`FraktalDeFi Token (FRAKTAL) deployed @ ${await fraktalDeFiToken.address}`)

  writeFileSync(`${configDir}/FraktalDeFiToken`, fraktalDeFiToken.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
