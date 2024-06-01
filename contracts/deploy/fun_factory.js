module.exports = async ({deployments}) => {
  const { deployer } = await getNamedAccounts()
  
  const tokenDeployment = await deployments.deploy("TestToken", { from: deployer })
  const testToken = await hre.ethers.getContractAt("TestToken", tokenDeployment.address)

  console.log(`Deployed TestToken at: ${testToken.address}`);

  const args = [ testToken.address ];

  const funFactoryDeployment = await deployments.deploy("FunFactory", { from: deployer, args })
  const funFactory = await hre.ethers.getContractAt("FunFactory", funFactoryDeployment.address)

  console.log(`Deployed FunFactory at: ${funFactory.address}`);
  console.log();
}

module.exports.tags = ["FunFactory"]
module.exports.dependencies = ["TestToken"]
