// const hre = require("hardhat");
// const fs = require("fs");

// async function main() {
//   console.log(`process.argv:`, process.argv)

//     // Load contracts from the configuration file
//     const contracts = await common.loadContracts();
//     const [deployer] = await ethers.getSigners();
//     // name, symbol, initialSupply, decimals, cap, minters, burners
//     // Set the initial supply, name, and symbol for the token
  
//   const [recipientAddress, amountToMint] = process.argv.slice(2);

//   // Validate the command-line arguments
//   if (!recipientAddress || !amountToMint) {
//     console.error("Please provide the recipient address and amount to mint as command-line arguments");
//     return;
//   }




//   // Get the deployed token contract address from the configuration
//   const networkName = hre.network.name;
//   const tokenAddress = contracts.addresses[networkName]["CopperToken"] || false;
//   console.log({tokenAddress, networkName, recipientAddress, amountToMint})
//   // Validate the token contract address
//   if (!tokenAddress) {
//     throw new Error("Token contract address not found in the configuration file");
//   }

//   // Convert the amount to a BigNumber
//   const amount = ethers.utils.parseEther(amountToMint);

//   // Get the deployed token contract
//   const Token = await hre.ethers.getContractFactory("CopperToken");
//   const token = await Token.attach(tokenAddress);

//   // Mint tokens
//   // console.log({recipientAddress, amount, amountToMint, tokenAddress})
//   // try {
//   //   await token.mint(recipientAddress, amount);
//   //   console.log(`${amountToMint} tokens successfully minted for address ${recipientAddress}`);
//   // } catch (error) {
//   //   console.error("An error occurred while minting tokens:", error);
//   // }
// }

// // Run the script
// main()
//   .then(() => process.exit(0))
//   .catch((error) => {
//     console.error(error);
//     process.exit(1);
//   });
