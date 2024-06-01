const { expect } = require("chai");
const { ethers } = require("hardhat");
const { deployMockContract } = require("@ethereum-waffle/mock-contract");
const funFunAbi = require("../artifacts/contracts/FunFun.sol/FunFun.json").abi;

describe("FunToken", function () {
  let mockFunContract;
  let caller;

  beforeEach(async function () {
    [caller] = await ethers.getSigners();
    mockFunContract = await deployMockContract(caller, funFunAbi);
  });

  it("Deployment should make the FunFun the contract owner.", async function () {
    const funTokenFactory = await ethers.getContractFactory("FunToken");
    const funToken = await funTokenFactory.deploy(
      "testName",
      "testSymbol",
      "imageURI",
      1000000,
      mockFunContract.address
    );
  
    expect(await funToken.owner()).to.equal(mockFunContract.address);
  });

  it("Deployment should set the max supply.", async function () {
    const funTokenFactory = await ethers.getContractFactory("FunToken");
    const expectedMaxSupply = 1000000;
    const funToken = await funTokenFactory.deploy(
      "testName",
      "testSymbol",
      "imageURI",
      expectedMaxSupply,
      mockFunContract.address
    );

    expect(await funToken.maxSupply()).to.equal(expectedMaxSupply);
  });

  it("Deployment should set lock to true.", async function () {
    const funTokenFactory = await ethers.getContractFactory("FunToken");
    const expectedMaxSupply = 1000000;
    const funToken = await funTokenFactory.deploy(
      "testName",
      "testSymbol",
      "imageURI",
      expectedMaxSupply,
      mockFunContract.address
    );

    expect(await funToken.locked()).to.equal(true);
  });

  it("Should reject transfer if token lock is active.", async function () {
    const funTokenFactory = await ethers.getContractFactory("FunToken");
    const funToken = await funTokenFactory.deploy(
      "testName",
      "testSymbol",
      "imageURI",
      1000000,
      mockFunContract.address
    );

    expect(await funToken.locked()).to.equal(true);
    await expect(funToken.transfer(caller.address, 100))
      .to.be.revertedWith("FunToken: token is locked.");
  });

  it("Should allow transfer if token lock is inactive.", async function () {
    const funTokenFactory = await ethers.getContractFactory("FunToken");
    const funToken = await funTokenFactory.deploy(
      "testName",
      "testSymbol",
      "imageURI",
      1000000,
      mockFunContract.address
    );

    expect(await funToken.locked()).to.equal(true);
    await funToken.unlock();
    expect(await funToken.locked()).to.equal(false);
    const success = await funToken.transfer(caller.address, 100);
    expect(success).to.be.true;
  });
});
