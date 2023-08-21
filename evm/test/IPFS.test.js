// Import the required modules from Hardhat
const { expect } = require("chai");

// Describe the IPFS contract tests
describe("IPFS Contract", function () {
  let IPFS;
  let ipfs;

  beforeEach(async function () {
    // Deploy the IPFS contract
    IPFS = await ethers.getContractFactory("IPFS");
    ipfs = await IPFS.deploy();
    await ipfs.deployed();
  });

  it("Should add a new IPFS hash", async function () {
    const cid = "QmHash123";
    const fileName = "test.txt";
    const hash = "0x123456";

    // Add a new IPFS hash
    await ipfs.addHash(cid, fileName, hash);

    // Retrieve the added hash
    const retrievedCID = await ipfs.getHash(0);

    // Check if the retrieved CID matches the added CID
    expect(retrievedCID).to.equal(cid);
  });

  it("Should revert on adding existing IPFS hash", async function () {
    const cid = "QmHash123";
    const fileName = "test.txt";
    const hash = "0x123456";
  
    // Add a new IPFS hash
    await ipfs.addHash(cid, fileName, hash);
  
    // Attempt to add the same IPFS hash again
    await expect(ipfs.addHash(cid, fileName, hash)).to.be.reverted;
  });
  
  it("Should retrieve the correct CID by ID", async function () {
    const cid1 = "QmHash123";
    const cid2 = "QmHash456";
    const fileName1 = "test1.txt";
    const fileName2 = "test2.txt";
    const hash = "0x123456";

    // Add two IPFS hashes
    await ipfs.addHash(cid1, fileName1, hash);
    await ipfs.addHash(cid2, fileName2, hash);

    // Retrieve the CIDs by their IDs
    const retrievedCID1 = await ipfs.getHash(0);
    const retrievedCID2 = await ipfs.getHash(1);

    // Check if the retrieved CIDs match the added CIDs
    expect(retrievedCID1).to.equal(cid1);
    expect(retrievedCID2).to.equal(cid2);
  });
});
