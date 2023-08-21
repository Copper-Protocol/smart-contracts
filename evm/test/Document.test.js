const { expect } = require("chai");
const {log} = require('console');
const { createHash } = require("crypto");
const {ethers} = require('hardhat')

function createSHA256Hash(text) {
  const hash = createHash('sha256');
  hash.update(text);
  const hashedText = hash.digest('hex');
  return hashedText;
}

describe("DocumentRegistry", function () {
  let DocumentRegistry;
  let documentRegistry;
  let owner, accounts

  beforeEach(async function () {
    [owner, ...accounts] = await ethers.getSigners()

    DocumentRegistry = await ethers.getContractFactory("DocumentRegistry");
    documentRegistry = await DocumentRegistry.deploy();
    await documentRegistry.deployed();
  });
  describe(`DocumentRegistry => Basics`, async () => {
    let docTypeId
    it (`Should add a docType`, async () => {
      const docType = "TesTing Doc"
      const hasDocType = await documentRegistry.hasDocType(docType)
  
      if (!hasDocType) {
        await documentRegistry.addDocType(docType)
      }
      docTypeId =  await documentRegistry.getDocTypeByName(docType)
      expect(docTypeId).to.be.greaterThan(0)
      
    })
    it(`Should add and retrieve documents correctly`, async () => {
      log({docTypeId})
      const totalDocumentsStart = await documentRegistry.totalDocuments()
      const contentHash = createSHA256Hash(`some random data, which will later be piped in from a file...`)
      log({contentHash, totalDocumentsStart})
      // Add documents
      await documentRegistry.connect(owner).addDocument(
        "Document 1",
        docTypeId,
        Date.now(),
        ethers.utils.toUtf8Bytes(contentHash),
        "url1"
      );
      const totalDocumentsEnd = await documentRegistry.totalDocuments()
  
      // log({totalDocumentsEnd})
      expect(totalDocumentsEnd).to.be.greaterThan(totalDocumentsStart)
    })
  })
});
