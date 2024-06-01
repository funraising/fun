module.exports = async (environment) => {
  const testToken = await deployments.get("TestToken")
  const funToken = await deployments.get("FunToken")
  const args = [testToken.address, funToken.address]
  const { deployer: from } = await getNamedAccounts()
  const factory = await deployments.deploy("FunFactory", { args, from })
  console.log("Deployed FunFactory at:")
  console.log(factory.address)
  console.log()
}

module.exports.tags = ["FunFactory"]
module.exports.dependencies = ["TestToken", "FunToken"]
