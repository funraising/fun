require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@typechain/hardhat");

module.exports = {
  solidity: {
    version: "0.8.23",
    settings: {
      evmVersion: "paris",
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v6",
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
<<<<<<< Updated upstream
=======
    },
    sepolia: {
      url: process.env.RPC_URL || "http://localhost:8545",
      accounts: [process.env.PRIV_KEY || "e7c7976ba1d34b9d6aaf59251e2dc2fac47945a4b8aa0e7fd2c2bef46edfd4d4"],
      tags: ["sepolia"],
>>>>>>> Stashed changes
    }
  },
}
