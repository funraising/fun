const { expect } = require("chai")
const { ethers } = require("hardhat")
const { deployMockContract } = require("@ethereum-waffle/mock-contract")
const funFunAbi = require("../artifacts/contracts/FunFun.sol/FunFun.json").abi

describe("FunToken", function () {
  let mockFunContract
  let funOwner

  beforeEach(async function () {
    ;[funOwner] = await ethers.getSigners()
    mockFunContract = await deployMockContract(funOwner, funFunAbi)
  })

  it("Deployment should make the FunFun the contract owner.", async function () {
    const funTokenFactory = await ethers.getContractFactory("FunToken")
    const funToken = await funTokenFactory.deploy(
      "testName",
      "testSymbol",
      "imageURI",
      1000000,
      mockFunContract.address
    )

    expect(await funToken.owner()).to.equal(mockFunContract.address)
  })

  it("Deployment should set the max supply.", async function () {
    const funTokenFactory = await ethers.getContractFactory("FunToken")
    const expectedMaxSupply = 1000000
    const funToken = await funTokenFactory.deploy(
      "testName",
      "testSymbol",
      "imageURI",
      expectedMaxSupply,
      mockFunContract.address
    )

    expect(await funToken.maxSupply()).to.equal(expectedMaxSupply)
  })

  it("Deployment should set lock to true.", async function () {
    const funTokenFactory = await ethers.getContractFactory("FunToken")
    const expectedMaxSupply = 1000000
    const funToken = await funTokenFactory.deploy(
      "testName",
      "testSymbol",
      "imageURI",
      expectedMaxSupply,
      mockFunContract.address
    )

    expect(await funToken.locked()).to.equal(true)
  })

  it("Should reject transfer if token lock is active.", async function () {
    const transferTarget = ethers.Wallet.createRandom().address
    const funTokenFactory = await ethers.getContractFactory("FunToken")
    const funToken = await funTokenFactory.deploy(
      "testName",
      "testSymbol",
      "imageURI",
      1000000,
      funOwner.address
    )

    expect(await funToken.locked()).to.equal(true)
    try {
      await funToken.transfer(transferTarget.address, 100, {
        from: funOwner.address,
      })
    } catch (error) {
      expect(error.message).to.include("FunToken: token is locked")
    }
  })

  it("Should allow transfer if token lock is inactive.", async function () {
    const funTokenFactory = await ethers.getContractFactory("FunToken")
    const funToken = await funTokenFactory.deploy(
      "testName",
      "testSymbol",
      "imageURI",
      1000000,
      mockFunContract.address
    )

    expect(await funToken.locked()).to.equal(true)
    await funToken.unlock()
    expect(await funToken.locked()).to.equal(false)
    const success = await funToken.transfer(funOwner.address, 100)
    expect(success).to.be.true
  })
})
