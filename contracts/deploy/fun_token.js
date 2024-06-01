
module.exports = async ({ deployments, getNamedAccounts, getUnnamedAccounts, network }) => {
  const { deployer } = await getNamedAccounts()

  const name = "FunToken";
  const symbol = "FUN";
  const imageURI = "https://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi.ipfs.dweb.link";
  const initialSupply = 1000000;
  const campaignContract = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  const tokenDeployment = await deployments.deploy("FunToken", {
    from: deployer,
    args: [
      name,
      symbol,
      imageURI,
      initialSupply,
      campaignContract
    ],
    log: true,
});
  const token = await hre.ethers.getContractAt("FunToken", tokenDeployment.address)
}

module.exports.tags = ["FunToken"]
