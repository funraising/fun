const { ethers } = require("hardhat")
const { expect } = require("chai")
const { snapshot, revert, currentTime } = require("./evm")

const ACCOUNT_STARTING_BALANCE = 1_000_000_000

describe("FunFun", function () {
  let funFun, funToken
  let token
  let funder, investor, host1, host2, host3
  let endsAt
  const maxSupply = 1_000_000
  const raiseTarget = 2_000

  async function deployFunFun(endsAt, maxSupply, raiseTarget) {
    const FunFun = await ethers.getContractFactory("FunFun")
    return await FunFun.deploy(token.address, endsAt, maxSupply, raiseTarget)
  }

  async function deployFunToken(funFunAddress, maxSupply) {
    const FunToken = await ethers.getContractFactory("FunToken")
    return await FunToken.deploy(
      "Fun!",
      "FUN",
      "http://url",
      maxSupply,
      funFunAddress
    )
  }

  beforeEach(async function () {
    await snapshot()
    ;[funder, host1, host2, host3] = await ethers.getSigners()
    investor = host1

    const TestToken = await ethers.getContractFactory("TestToken")
    token = await TestToken.deploy()
    for (let account of [funder, host1, host2, host3]) {
      await token.mint(account.address, ACCOUNT_STARTING_BALANCE)
    }

    endsAt = (await currentTime()) + 3600
    funFun = await deployFunFun(endsAt, maxSupply, raiseTarget)
    funToken = await deployFunToken(funFun.address, maxSupply)
    await funFun.setFunToken(funToken.address)
  })

  afterEach(async function () {
    await revert()
  })

  function switchAccount(account) {
    token = token.connect(account)
    funFun = funFun.connect(account)
  }

  describe("BuyFun", function () {
    beforeEach(async function () {
      switchAccount(investor)
    })

    it("should purchase fun", async () => {
      await token.approve(funFun.address, 100_000)
      const startingToken = await token.balanceOf(investor.address)
      expect(await funToken.balanceOf(investor.address)).to.equal(0)
      await funFun.buyFun(100_000)
      expect(await funToken.balanceOf(investor.address)).to.be.eq(100_000)
      expect(
        startingToken - (await token.balanceOf(investor.address))
      ).to.be.greaterThan(0)
    })
  })
})
