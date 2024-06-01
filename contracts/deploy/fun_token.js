
module.exports = async ({ deployments, getNamedAccounts, getUnnamedAccounts, network }) => {
  const { deployer } = await getNamedAccounts()

  const name = "FunToken";
  const symbol = "FUN";
  const initialSupply = 1000000;

  const tokenDeployment = await deployments.deploy("FunToken", {
    from: deployer,
    args: [name, symbol, initialSupply],
    log: true,
});
  const token = await hre.ethers.getContractAt("FunToken", tokenDeployment.address)
}

module.exports.tags = ["FunToken"]
