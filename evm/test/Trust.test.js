const { expect } = require("chai");

describe("Trust", function () {
  let trustContract;
  let owner;
  let trustee1;
  let trustee2;

  beforeEach(async function () {
    // Deploy the Trust contract
    const Trust = await ethers.getContractFactory("Trust");
    [owner, trustee1, trustee2] = await ethers.getSigners();
    trustContract = await Trust.deploy();
    await trustContract.deployed();
  });

  it("should add a new trustee", async function () {
    // Add a new trustee
    await trustContract.addTrustee(trustee1.address);

    // Check if the trustee has been added
    const trusteeData = await trustContract.trusteeData(trustee1.address);
    expect(trusteeData.trustee).to.equal(trustee1.address);
    expect(trusteeData.accepted).to.equal(false);
    expect(trusteeData.resigned).to.equal(false);
    expect(trusteeData.terminated).to.equal(false);

    // Check if the trustee count has increased
    expect(await trustContract.trusteeCount()).to.equal(1);

    // Check if the TrusteeAdded event was emitted
    const trusteeAddedEvent = await trustContract.provider.getLogs(trustContract.filters.TrusteeAdded());
    expect(trusteeAddedEvent.length).to.equal(1);
    expect(trusteeAddedEvent[0].args.trustee).to.equal(trustee1.address);
  });

  it("should accept the role of a trustee", async function () {
    // Add a new trustee
    await trustContract.addTrustee(trustee1.address);

    // Accept the role of a trustee
    await trustContract.connect(trustee1).acceptTrustee();

    // Check if the trustee has been accepted
    const trusteeData = await trustContract.trusteeData(trustee1.address);
    expect(trusteeData.accepted).to.equal(true);

    // Check if the TrusteeAccepted event was emitted
    const trusteeAcceptedEvent = await trustContract.provider.getLogs(
      trustContract.filters.TrusteeAccepted()
    );
    expect(trusteeAcceptedEvent.length).to.equal(1);
    expect(trusteeAcceptedEvent[0].args.trustee).to.equal(trustee1.address);
  });

  it("should resign from the role of a trustee", async function () {
    // Add a new trustee
    await trustContract.addTrustee(trustee1.address);

    // Resign from the role of a trustee
    await trustContract.connect(trustee1).resignTrustee();

    // Check if the trustee has resigned
    const trusteeData = await trustContract.trusteeData(trustee1.address);
    expect(trusteeData.resigned).to.equal(true);

    // Check if the TrusteeResigned event was emitted
    const trusteeResignedEvent = await trustContract.provider.getLogs(
      trustContract.filters.TrusteeResigned()
    );
    expect(trusteeResignedEvent.length).to.equal(1);
    expect(trusteeResignedEvent[0].args.trustee).to.equal(trustee1.address);
  });

  it("should terminate a trustee", async function () {
    // Add two trustees
    await trustContract.addTrustee(trustee1.address);
    await trustContract.addTrustee(trustee2.address);

    // Terminate trustee1
    await trustContract.connect(trustee2).terminateTrustee(trustee1.address);

    // Check if trustee1 has been terminated
    const trusteeData = await trustContract.trusteeData(trustee1.address);
    expect(trusteeData.terminated).to.equal(true);

    // Check if the TrusteeTerminated event was emitted
    const trusteeTerminatedEvent = await trustContract.provider.getLogs(
      trustContract.filters.TrusteeTerminated()
    );
    expect(trusteeTerminatedEvent.length).to.equal(1);
    expect(trusteeTerminatedEvent[0].args.trustee).to.equal(trustee1.address);
  });

  // Add more tests for other contract functions

});
