const AMOUNT = 10_000_000_000_000_000_00n;
const TRANSFER_AMOUNT = AMOUNT * 10n;
const MINT_AMOUNT = TRANSFER_AMOUNT * 10n;

const NON_FUNGIBLE_POSITION_MANAGER = "0x1238536071E1c677A632429e3655c799b22cDA52";
const UNISWAP_V3_FACTORY = "0x0227628f3F023bb0B980b67D528571c95c6DaC1c";

module.exports = async ({ deployments, getNamedAccounts, getUnnamedAccounts, network }) => {
  const { deployer } = await getNamedAccounts();

  console.log("Deploying contracts with the account:", deployer);

  // Deploy TokenA
  const tokenADeployment = await deployments.deploy("TestToken", { from: deployer });
  const tokenA = await ethers.getContractAt("TestToken", tokenADeployment.address);
  const transaction = await tokenA.mint(deployer, MINT_AMOUNT, { from: deployer });
  await transaction.wait();

  // Deploy TokenB
  const tokenBDeployment = await deployments.deploy("TestToken2", { from: deployer });
  const tokenB = await ethers.getContractAt("TestToken2", tokenBDeployment.address);
  const transaction2 = await tokenB.mint(deployer, MINT_AMOUNT, { from: deployer });
  await transaction2.wait();

  console.log("TokenA deployed to:", tokenA.address);
  console.log("TokenB deployed to:", tokenB.address);

  // Deploy the UniswapV3Liquidity contract
  const UniswapV3Liquidity = await ethers.getContractFactory("UniswapV3Liquidity");
  const uniswapV3Liquidity = await UniswapV3Liquidity.deploy(tokenA.address, tokenB.address, 3000, UNISWAP_V3_FACTORY, NON_FUNGIBLE_POSITION_MANAGER);
  await uniswapV3Liquidity.deployed();

  console.log("UniswapV3Liquidity deployed to:", uniswapV3Liquidity.address);

  // Approve NON_FUNGIBLE_POSITION_MANAGER to spend tokens
  await tokenA.approve(NON_FUNGIBLE_POSITION_MANAGER, TRANSFER_AMOUNT, { from: deployer });
  await tokenB.approve(NON_FUNGIBLE_POSITION_MANAGER, TRANSFER_AMOUNT, { from: deployer });

  // Check approvals
  const allowanceA = await tokenA.allowance(deployer, NON_FUNGIBLE_POSITION_MANAGER);
  const allowanceB = await tokenB.allowance(deployer, NON_FUNGIBLE_POSITION_MANAGER);
  console.log(`Allowance of TokenA: ${allowanceA.toString()}`);
  console.log(`Allowance of TokenB: ${allowanceB.toString()}`);

  // Verify balances
  const balanceA = await tokenA.balanceOf(deployer);
  const balanceB = await tokenB.balanceOf(deployer);
  console.log(`Balance of TokenA: ${balanceA.toString()}`);
  console.log(`Balance of TokenB: ${balanceB.toString()}`);

  // Add liquidity
  try {
    const tx = await uniswapV3Liquidity.addLiquidity(AMOUNT, AMOUNT, {
      from: deployer,
      gasLimit: 500_000,  // Increased gas limit
    });
    const receipt = await tx.wait();
    console.log("Mint new position transaction:", receipt.transactionHash);
  } catch (error) {
    console.error("Error adding liquidity:", error);
  }
};

module.exports.tags = ["ALL"];