const AMOUNT = 10_000_000_000_000_000_00n;
const TRANSFER_AMOUNT = AMOUNT * 10n;
const MINT_AMOUNT = TRANSFER_AMOUNT * 10n;

module.exports = async ({ deployments, getNamedAccounts, getUnnamedAccounts, network }) => {
  const { deployer } = await getNamedAccounts()

  console.log("Deploying contracts with the account:", deployer);

  // Deploy TokenA
  const tokenADeployment = await deployments.deploy("TestToken", { from: deployer });
  const tokenA = await ethers.getContractAt("TestToken", tokenADeployment.address);
  const transaction = await tokenA.mint(deployer, MINT_AMOUNT, { from: deployer })
  await transaction.wait()

  // Deploy TokenB
  const tokenBDeployment = await deployments.deploy("TestToken2", { from: deployer });
  const tokenB = await ethers.getContractAt("TestToken", tokenBDeployment.address);
  const transaction2 = await tokenB.mint(deployer, MINT_AMOUNT, { from: deployer })
  await transaction2.wait()

  console.log("TokenA deployed to:", tokenA.address);
  console.log("TokenB deployed to:", tokenB.address);

  // const tokenA = await ethers.getContractAt("TestToken", '0x93269755e9A9b18b1F6cE95fBbe5b7b38fDCC732');
  // const tokenB = await ethers.getContractAt("TestToken", '0xa68dE24602d38Ef89271c98CC1bcD9Ab1A05b27F');
  
  // Deploy the UniswapV3Liquidity contract
  const UniswapV3Liquidity = await ethers.getContractFactory("UniswapV3Liquidity");
  const uniswapV3Liquidity = await UniswapV3Liquidity.deploy(tokenA.address, tokenB.address);
  await uniswapV3Liquidity.deployed();
  
  console.log("UniswapV3Liquidity deployed to:", uniswapV3Liquidity.address);

  // Approve UniswapV3Liquidity contract to spend DAI and WETH
  await tokenA.approve(uniswapV3Liquidity.address, TRANSFER_AMOUNT, { from: deployer });
  await tokenB.approve(uniswapV3Liquidity.address, TRANSFER_AMOUNT, { from: deployer });

  await tokenA.transfer(uniswapV3Liquidity.address, TRANSFER_AMOUNT, { from: deployer });
  await tokenB.transfer(uniswapV3Liquidity.address, TRANSFER_AMOUNT, { from: deployer });

  console.log("Transferred tokens to UniswapV3Liquidity contract")

  // Create pool
  const poolTx = await uniswapV3Liquidity.createPool({ from: deployer, gasLimit: 300_000,});
  console.log("Pool created:", poolTx.transactionHash);
  
  // Add liquidity
  const tx = await uniswapV3Liquidity.mintNewPosition(AMOUNT, AMOUNT, { from: deployer, 
    gasLimit: 300_000,
  });
  const receipt = await tx.wait();
  
  console.log("Mint new position transaction:", receipt.transactionHash);
  
  // Collect fees
  const tokenId = receipt.events[0].args.tokenId;
  const feeTx = await uniswapV3Liquidity.collectAllFees(tokenId);
  const feeReceipt = await feeTx.wait();
  
  console.log("Collect fees transaction:", feeReceipt.transactionHash);
  
  // Increase liquidity
  const daiAmountToAdd = ethers.utils.parseUnits("5", 18);
  const wethAmountToAdd = ethers.utils.parseUnits("0.5", 18);
  
  const increaseTx = await uniswapV3Liquidity.increaseLiquidityCurrentRange(tokenId, daiAmountToAdd, wethAmountToAdd);
  const increaseReceipt = await increaseTx.wait();
  
  console.log("Increase liquidity transaction:", increaseReceipt.transactionHash);
  
  // Decrease liquidity
  const decreaseTx = await uniswapV3Liquidity.decreaseLiquidityCurrentRange(tokenId, ethers.utils.parseUnits("0.5", 18));
  const decreaseReceipt = await decreaseTx.wait();
  
  console.log("Decrease liquidity transaction:", decreaseReceipt.transactionHash);
}

module.exports.tags = ["TokenA"]
