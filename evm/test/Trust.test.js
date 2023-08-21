const {expect} = require('chai')

describe('Trust', () => {
  let trustContract;
  let owner;
  let trustee, trustee1, trustee2, trustee3, trustee4;

  beforeEach(async () => {
    [owner, trustee1, trustee2, trustee3, trustee4, trustee] = await ethers.getSigners();

    // Deploy the CopperTestToken contract
    CopperTestToken = await ethers.getContractFactory("CopperTestToken");
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

    CopperTestUnitsToken = await ethers.getContractFactory("CopperTestToken");
    copperTestUnitsToken = await CopperTestUnitsToken.deploy(
      "Copper Trust Units Test Token",
      "tctUNITS",
      ethers.utils.parseEther("1000"),
      18,
      10000000,
      [owner.address],
      [owner.address]
    );
    await copperTestUnitsToken.deployed();

    // Deploy the DocumentRegistry contract
    DocumentRegistry = await ethers.getContractFactory("DocumentRegistry");
    documentRegistry = await DocumentRegistry.deploy();
    await documentRegistry.deployed();

    
    const Trust = await ethers.getContractFactory('Trust');
    trustContract = await Trust.deploy();
    await trustContract.deployed();

    // [owner, trustee] = await ethers.getSigners();


  });
  describe(``, async () => {
    beforeEach(async () => {
        // await [trustee1.address, trustee2.address, trustee3.address, trustee4.address, trustee.address].map(async _trustee => {
        //   await trustContract.addTrustee(trustee.address)
        // })
        // await trustContract.addTrustee(trustee.address)
        await trustContract.initialize(
          copperTestUnitsToken.address,
          ethers.utils.toUtf8Bytes(`I accept my honorable role as trustee)`),
          documentRegistry.address,
          [owner.address],
          [trustee1.address, trustee2.address, trustee3.address, trustee4.address, trustee.address]
        )
    
    })
    it(`Should list all trustees, pending or therwise`, async () => {
      console.log(`ALL TRUSTEES`, await trustContract.getAllTrustees())
    })
    it('should add and revoke a trustee', async () => {
      // // Add a trustee
      // const acceptedSignature = '0x0123456789abcdef';
      // const acceptanceBlock = 1000;
  
      await trustContract.connect(trustee).addTrustee(trustee.address);
      const trusteeData = await trustContract.getTrusteeData(trustee.address);
      console.log({trusteeData})
      expect(trusteeData.accepted).to.be.false;
      expect(trusteeData.revoked).to.be.false;
      expect(trusteeData.declined).to.be.false;
      expect(trusteeData.acceptedSignature).to.equal(`0x`);
      expect(trusteeData.acceptanceBlock).to.equal(0);
  
      // Revoke the trustee
      await trustContract.revokeTrustee(trustee.address);
  
      const revokedTrusteeData = await trustContract.getTrusteeData(trustee.address);
      expect(revokedTrusteeData.revoked).to.be.true;
    });
  
    it('should decline the trust position', async () => {
      await trustContract.connect(trustee1).declineTrustee();
  
      const trusteeData = await trustContract.getTrusteeData(trustee1.address);
      expect(trusteeData.declined).to.be.true;
    });
  
    it('should accept the trust position', async () => {
      await trustContract.connect(trustee2).acceptTrustee();
  
      const trusteeData = await trustContract.getTrusteeData(trustee2.address);
      expect(trusteeData.accepted).to.be.true;
    });
  });

  })
