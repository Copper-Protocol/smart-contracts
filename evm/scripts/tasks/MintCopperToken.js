const hre = require("hardhat");
const fs = require("fs");

async function main() {
  console.log(`process.argv:`, process.argv)
  // const [recipientAddress, amountToMint] = process.argv.slice(2);

  // // Validate the command-line arguments
  // if (!recipientAddress || !amountToMint) {
  //   console.error("Please provide the recipient address and amount to mint as command-line arguments");
  //   return;
  // }

  // // Check if the config directory exists
  // if (!fs.existsSync("config")) {
  //   throw new Error("Config directory does not exist");
  // }

  // // Check if the config file exists
  // if (!fs.existsSync("config/CopperNetwork.json")) {
  //   throw new Error("Config file does not exist");
  // }

  // // Load the network configuration file
  // const configFile = fs.readFileSync("config/CopperNetwork.json", { encoding: "utf8" });

  // // Check if the config file is empty
  // if (!configFile) {
  //   throw new Error("Config file is empty");0x9a12881749509aa13c20f5afABE7aCfDE810Fac3
  // }

  // const config = JSON.parse(configFile);

  // // Get the deployed token contract address from the configuration
  // const networkName = hre.network.name;
  // const tokenAddress = config["CopperToken"] && config["CopperToken"][networkName];

  // // Validate the token contract address
  // if (!tokenAddress) {
  //   throw new Error("Token contract address not found in the configuration file");
  // }

  // // Convert the amount to a BigNumber
  // const amount = ethers.utils.parseEther(amountToMint);

  // // Get the deployed token contract
  // const Token = await hre.ethers.getContractFactory("CopperToken");
  // const token = await Token.attach(tokenAddress);

  // // Mint tokens
  // try {
  //   await token.mint(recipientAddress, amount);
  //   console.log(`${amountToMint} tokens successfully minted for address ${recipientAddress}`);
  // } catch (error) {
  //   console.error("An error occurred while minting tokens:", error);
  // }
}

// Run the script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
