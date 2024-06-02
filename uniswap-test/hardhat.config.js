require("@nomiclabs/hardhat-waffle")
require("hardhat-deploy")
require("hardhat-deploy-ethers")

module.exports = {
  solidity: {
    version: "0.8.23",
      debug: {
        revertStrings: "default"
      },
    settings: {
      evmVersion: "paris",
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  mocha: {
    bail: true,
    slow: 200,
    timeout: 30 * 1000,
  },
  namedAccounts: {
    deployer: { default: 0 },
  },
  networks: {
    hardhat: {
      tags: ["local"],
    },
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/",
      accounts: ["e7c7976ba1d34b9d6aaf59251e2dc2fac47945a4b8aa0e7fd2c2bef46edfd4d4"],
      // accounts: ["0a77315b818a511543aa584088a453356cf4d4551898a5715a17d75edc65a30a"],
      tags: ["sepolia"],
    }
  },
}
