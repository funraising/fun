const { ethers } = require("hardhat")
const { expect } = require("chai")
<<<<<<< Updated upstream
const { snapshot, revert, currentTime } = require("./evm")
=======
const {
  snapshot,
  revert,
  currentTime,
  advanceTimeForNextBlock
} = require("./evm")
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
      expect(
        startingToken - (await token.balanceOf(investor.address))
      ).to.be.greaterThan(0)
    })
=======
      expect(startingToken - await token.balanceOf(investor.address)).to.be.greaterThan(0)
    });

    it('reverts on zero', async () => {
      await expect(funFun.buyFun(0)).to.be.revertedWith(
        "Require non-zero amount"
      )
    });

    it('when target is reached, campaing gets finilized', async () => {
      await token.approve(funFun.address, maxSupply)
      await expect(funFun.buyFun(maxSupply))
        .to.emit(funFun, "CampaignFinished")
    });

    // it('when campaign is finilized unlocks the token', async () => {
    //   await token.approve(funFun.address, maxSupply)
    //   await funFun.buyFun(100_000)
    //
    //   await funToken.approve(host2.address, 40_000)
    //   await expect(funToken.transfer(host2.address, 40_000)).to.be.revertedWith(
    //     "FunToken: token is locked"
    //   )
    //
    //   await expect(funFun.buyFun(maxSupply-100_000))
    //     .to.emit(funFun, "CampaignFinished")
    //
    //   expect(await funToken.balanceOf(investor.address)).to.be.eq(100_000)
    //   await funToken.transfer(host2.address, 40_000)
    // });

    it('when target is not reached in time, no more buys are allowed', async () => {
      await advanceTimeForNextBlock(endsAt+1)
      await token.approve(funFun.address, 100_000)
      await expect(funFun.buyFun(100_000)).to.be.revertedWith(
        "Campaign finished"
      )
    });
  })

  describe("SellFun", function () {
    beforeEach(async function () {
      switchAccount(investor)
    })

    it('should sell all fun tokens', async () => {
      // Buying tokens
      await token.approve(funFun.address, 100_000)
      const startingToken = await token.balanceOf(investor.address)
      expect(await funToken.balanceOf(investor.address)).to.equal(0)
      await funFun.buyFun(100_000)
      expect(await funToken.balanceOf(investor.address)).to.be.eq(100_000)
      expect(startingToken - await token.balanceOf(investor.address)).to.be.greaterThan(0)

      // Expires the campaign
      await advanceTimeForNextBlock(endsAt+1)

      await funFun.sellFun()
      expect(await funToken.balanceOf(investor.address)).to.be.eq(0)
      expect(await token.balanceOf(investor.address)).to.be.eq(startingToken)
    });

    it('reverts when campaign not finished', async () => {
      await expect(funFun.sellFun()).to.be.revertedWith(
        "Campaign not finished"
      )
    });

    it('reverts when campaign not finished', async () => {
      // Expires the campaign
      await advanceTimeForNextBlock(endsAt+1)
      await expect(funFun.sellFun()).to.be.revertedWith(
        "No FunToken balance"
      )
    });

>>>>>>> Stashed changes
  })
})
