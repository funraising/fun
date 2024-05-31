const MINTED_TOKENS = 1_000_000_000

module.exports = async ({ deployments, getNamedAccounts, getUnnamedAccounts, network }) => {
  const { deployer } = await getNamedAccounts()
  const tokenDeployment = await deployments.deploy("FunToken", { from: deployer })
  const token = await hre.ethers.getContractAt("FunToken", tokenDeployment.address)
}

module.exports.tags = ["FunToken"]
