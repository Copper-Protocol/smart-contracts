const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CopperTestToken", function () {
  let copperTestToken;
  let owner;
  let alice;
  let bob;

  beforeEach(async function () {
    // Deploy the CopperTestToken contract
    const CopperTestToken = await ethers.getContractFactory("CopperTestToken");
    [owner, alice, bob] = await ethers.getSigners();
    copperTestToken = await CopperTestToken.deploy(
      "Copper Test Token",
      "tCOPPER",
      ethers.utils.parseEther("1000"),
      18,
      10000000,
      [owner.address],
      [owner.address]
    );
    await copperTestToken.deployed();
  });

  it("should initialize the ERC20 token", async function () {
    const name = await copperTestToken.name();
    const symbol = await copperTestToken.symbol();
    const decimals = await copperTestToken.decimals();
    const totalSupply = await copperTestToken.totalSupply();
    const ownerBalance = await copperTestToken.balanceOf(owner.address);

    expect(name).to.equal("Copper Test Token");
    expect(symbol).to.equal("tCOPPER");
    expect(decimals).to.equal(18);
    expect(totalSupply).to.equal(ethers.utils.parseEther("1000"));
    expect(ownerBalance).to.equal(ethers.utils.parseEther("1000"));
  });

  it("should transfer tokens", async function () {
    const initialOwnerBalance = await copperTestToken.balanceOf(owner.address);
    const transferAmount = ethers.utils.parseEther("100");

    await copperTestToken.transfer(alice.address, transferAmount);

    const aliceBalance = await copperTestToken.balanceOf(alice.address);
    const updatedOwnerBalance = await copperTestToken.balanceOf(owner.address);

    expect(aliceBalance).to.equal(transferAmount);
    expect(updatedOwnerBalance).to.equal(initialOwnerBalance.sub(transferAmount));
  });

  it("should approve spender to spend tokens", async function () {
    const initialOwnerAllowance = await copperTestToken.allowance(owner.address, alice.address);
    const approvalAmount = ethers.utils.parseEther("50");

    await copperTestToken.approve(alice.address, approvalAmount);

    const aliceAllowance = await copperTestToken.allowance(owner.address, alice.address);

    expect(aliceAllowance).to.equal(approvalAmount);
    expect(initialOwnerAllowance).to.equal(0);
  });

  it("should transfer tokens from one address to another", async function () {
    const initialOwnerBalance = await copperTestToken.balanceOf(owner.address);
    const transferAmount = ethers.utils.parseEther("100");

    await copperTestToken.approve(alice.address, transferAmount);

    await copperTestToken.connect(alice).transferFrom(owner.address, bob.address, transferAmount);

    const bobBalance = await copperTestToken.balanceOf(bob.address);
    const updatedOwnerBalance = await copperTestToken.balanceOf(owner.address);

    expect(bobBalance).to.equal(transferAmount);
    expect(updatedOwnerBalance).to.equal(initialOwnerBalance.sub(transferAmount));
  });

  it("should mint tokens", async function () {
    const initialOwnerBalance = await copperTestToken.balanceOf(owner.address);
    console.log('ON_MINT =>', {initialOwnerBalance: ethers.utils.formatEther(initialOwnerBalance)})
    const mintAmount = ethers.utils.parseEther("100");

    await copperTestToken.mint(alice.address, mintAmount);

    const aliceBalance = await copperTestToken.balanceOf(alice.address);
    console.log({aliceBalance: ethers.utils.formatEther(aliceBalance)})

    const updatedOwnerBalance = await copperTestToken.totalSupply();
    console.log('UPDATED =>', {updatedOwnerBalance: ethers.utils.formatEther(updatedOwnerBalance)})

    expect(aliceBalance).to.equal(mintAmount);
    expect(updatedOwnerBalance).to.equal(initialOwnerBalance.add(mintAmount));
  });

  it("should burn tokens", async function () {
    const initialOwnerBalance = await copperTestToken.balanceOf(owner.address);
    const burnAmount = ethers.utils.parseEther("100");

    await copperTestToken.burn(burnAmount);

    const ownerBalance = await copperTestToken.balanceOf(owner.address);

    expect(ownerBalance).to.equal(initialOwnerBalance.sub(burnAmount));
  });

  it("should add and remove minters", async function () {
    // Add a minter
    await expect(copperTestToken.connect(owner).addMinter(alice.address))
      .to.emit(copperTestToken, "MinterAdded")
      .withArgs(alice.address);
  
    // Verify that Alice has the minter role
    // expect(await copperTestToken.hasRole("ROLE_ERC20_MINTER", alice.address)).to.equal(true);
  
    // Remove the minter
    await expect(copperTestToken.connect(owner).removeMinter(alice.address))
      .to.emit(copperTestToken, "MinterRemoved")
      .withArgs(alice.address);
  
    // Verify that Alice no longer has the minter role
    // expect(await copperTestToken.hasRole("ROLE_ERC20_MINTER", alice.address)).to.equal(false);
  });
  
  it("should add and remove burners", async function () {
    // Add a burner
    await expect(copperTestToken.connect(owner).addBurner(alice.address))
      .to.emit(copperTestToken, "BurnerAdded")
      .withArgs(alice.address);
  
    // Verify that Alice has the burner role
    // expect(await copperTestToken.hasRole("ROLE_ERC20_BURNER", alice.address)).to.equal(true);
  
    // Remove the burner
    await expect(copperTestToken.connect(owner).removeBurner(alice.address))
      .to.emit(copperTestToken, "BurnerRemoved")
      .withArgs(alice.address);
  
    // Verify that Alice no longer has the burner role
    // expect(await copperTestToken.hasRole("ROLE_ERC20_BURNER", alice.address)).to.equal(false);
  });
  
  it("should add and remove mint-burn admins", async function () {
    // Add a mint-burn admin
    await expect(copperTestToken.connect(owner).addMintBurnAdmin(alice.address))
      .to.emit(copperTestToken, "MintBurnAdminAdded")
      .withArgs(alice.address);
  
    // Verify that Alice has the mint-burn admin role
    // expect(await copperTestToken.hasRole("ROLE_ERC20_MINT_BURN_ADMIN", alice.address)).to.equal(true);
  
    // Remove the mint-burn admin
    await expect(copperTestToken.connect(owner).removeMintBurnAdmin(alice.address))
      .to.emit(copperTestToken, "MintBurnAdminRemoved")
      .withArgs(alice.address);
  
    // Verify that Alice no longer has the mint-burn admin role
    // expect(await copperTestToken.hasRole("ROLE_ERC20_MINT_BURN_ADMIN", alice.address)).to.equal(false);
  });
  
});
